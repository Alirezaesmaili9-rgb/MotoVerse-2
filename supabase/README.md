# MotoVerse — Supabase Backend

PostgreSQL schema, Row Level Security, and seed data for the MotoVerse super app.

## Migrations

Run in order:

| File | Purpose |
|------|---------|
| `0001_init.sql` | Tables, indexes, `updated_at` triggers, auth→profile trigger |
| `0002_rls.sql`  | Row Level Security policies (owner-scoped + public catalogs + admin) |
| `0003_seed.sql` | Demo products, service centers, news |

### Apply with the Supabase CLI

```bash
supabase db reset           # local: recreates DB and runs all migrations
# or push to a linked project:
supabase db push
```

Or paste each file into the Supabase Studio SQL editor in order.

## Schema overview

```
auth.users ──1:1──► profiles ──1:N──► motorcycles ──1:N──► maintenance_records
                       │                   │
                       │                   └──1:N──► insurance_policies
                       ├──1:N──► orders ──1:N──► order_items ──► products
                       ├──1:N──► wallet_transactions
                       ├──1:N──► service_bookings ──► service_centers
                       ├──1:N──► roadside_requests
                       └──1:N──► notifications

public catalogs: products, service_centers, news_articles
```

## Security model

- **Rider** (`profiles.role = 'rider'`): can read/write only their own rows
  (motorcycles, maintenance, insurance, orders, bookings, roadside,
  notifications). Wallet transactions are **read-only** from the client —
  balance mutations should go through a trusted Edge Function / RPC.
- **Public catalogs**: `products`, `service_centers`, `news_articles` are
  world-readable (active/published rows), admin-writable.
- **Admin** (`profiles.role = 'admin'`): full access via the `is_admin()`
  helper, powering the admin dashboard.

## Auth

Phone OTP, Google, and Apple are configured in the Supabase Auth dashboard.
A trigger (`handle_new_user`) provisions a `profiles` row on first sign-in.
