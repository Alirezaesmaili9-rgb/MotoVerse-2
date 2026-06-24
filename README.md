# MotoVerse 🏍️

> The complete digital ecosystem and intelligent companion for motorcycle
> riders in Iran — premium, modern, intelligent, trustworthy.

MotoVerse is a Flutter + Supabase super app. This repository holds the
**production-grade application foundation**: Clean Architecture, Riverpod state
management, a fully-tokenized design system, Supabase backend with Row Level
Security, and complete end-to-end vertical slices for **Auth**, **My Garage**,
and the **Maintenance system**.

---

## Tech stack

| Layer | Choice |
|-------|--------|
| Frontend | Flutter (Material 3, RTL/Persian-first, light + dark) |
| State management | Riverpod |
| Architecture | Clean Architecture (feature-first) |
| Backend | Supabase (PostgreSQL + Auth + RLS + Realtime) |
| Routing | go_router (auth-aware redirects) |
| Auth | Phone OTP · Google · Apple |
| Maps | Google Maps (Service Centers, Roadside) |
| Notifications | Firebase Cloud Messaging |
| Functional errors | dartz `Either<Failure, T>` |

---

## Getting started

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure environment (never commit the real .env)
cp .env.example .env        # fill in SUPABASE_URL, SUPABASE_ANON_KEY, ...

# 3. Provision the backend (see supabase/README.md)
#    run migrations 0001 → 0002 → 0003

# 4. Run
flutter run --dart-define-from-file=.env

# Tests
flutter test
```

---

## Architecture

Clean Architecture with a feature-first layout. Each feature owns three layers
and dependencies point **inward** (presentation → domain ← data):

```
lib/
├─ main.dart                 # entry → bootstrap()
├─ bootstrap.dart            # init Supabase + prefs, run ProviderScope
├─ app/
│  ├─ app.dart               # MaterialApp.router, RTL, themes
│  └─ router/                # go_router + auth redirects
├─ core/                     # cross-cutting, framework-level code
│  ├─ config/                # Env (compile-time --dart-define)
│  ├─ constants/             # table names, prefs keys
│  ├─ error/                 # Failure / Exception hierarchies
│  ├─ network/               # SupabaseService
│  ├─ providers/             # core Riverpod providers (client, auth state)
│  ├─ theme/                 # design tokens → ThemeData (light + dark)
│  ├─ utils/                 # Persian digit/currency helpers
│  └─ widgets/               # shared component library (plate, card, button)
└─ features/
   ├─ auth/        { domain · data · presentation }   ← Phone OTP / Google / Apple
   ├─ garage/      { domain · data · presentation }   ← My Garage (multi-bike)
   ├─ maintenance/ { domain · data · presentation }   ← service intervals
   ├─ marketplace/ { domain · data · presentation }   ← parts/accessories, cart, orders
   ├─ wallet/      { domain · data · presentation }   ← balance, recharge, payments
   ├─ tools/        { domain · data · presentation }  ← MotoFix/MotoSanj/MotoType WebView
   ├─ copilot/      { domain · data · presentation }  ← AI chat (provider-agnostic)
   ├─ insurance/    { domain · data · presentation }  ← MotoBimeh
   ├─ service_centers/ { domain · data · presentation } ← centers + booking
   ├─ roadside/     { domain · data · presentation }  ← assistance + live tracking
   ├─ motor_world/  { domain · data · presentation }  ← news
   ├─ notifications/{ domain · data · presentation }  ← in-app + realtime badge
   ├─ admin/        { domain · data · presentation }  ← role-gated dashboard
   └─ home/         { presentation }                  ← command center + shell
```

**Layer responsibilities**

- **domain** — entities + repository *interfaces* + business rules. Pure Dart,
  no Flutter or Supabase imports. (e.g. `MaintenanceStatus` computes
  "service due in X km" with no framework dependency.)
- **data** — models (JSON ↔ entity) + repository *implementations* against
  Supabase. Catches exceptions, returns `Either<Failure, T>`.
- **presentation** — Riverpod providers/notifiers + screens/widgets.

---

## Design system

All visual tokens live in `lib/core/theme/` — a single source of truth.

- **Colors** (`app_colors.dart`): primary `#2563EB`, cyan `#06B6D4`, marketplace
  purple `#7C3AED`, accessories pink `#EC4899`, semantic success/warning/danger,
  light **and** dark surfaces, brand & motor-health gradients.
- **Radii** (`app_dimens.dart`): cards 20 · buttons 16 · inputs 14 · sheets 28.
- **Shadows** (`app_shadows.dart`): soft card + floating-button elevations.
- **Typography** (`app_typography.dart`): Vazirmatn, weights 400/500/600/700.
- **Theme** (`app_theme.dart`): builds Material 3 light & dark `ThemeData`.

Shared components: `IranianPlate` (renders the real plate, dynamic numbers, no
dummy placeholders), `MvCard`, `PrimaryButton`.

---

## What's implemented

✅ Clean Architecture skeleton + DI via Riverpod
✅ Design system / design tokens (light + dark, RTL)
✅ Supabase init, auth-aware routing, session stream
✅ **Auth** — Phone OTP + Google + Apple (full vertical slice)
✅ **My Garage** — multiple motorcycles, CRUD, Iranian plate
✅ **Maintenance** — 9 service types, interval logic, "service due in X km"
   (no health percentages, per product spec), unit-tested
✅ **Home** — command center (bike card, next-maintenance reminder, quick
   actions, wallet strip) + bottom-nav shell
✅ **Marketplace** — Parts (purple) + Accessories (pink) verticals, search,
   category chips, sort/filter, product detail, ratings & reviews, favorites,
   server-backed cart, checkout, order tracking timeline
✅ **Wallet** — balance, transaction history, recharge via a **modular payment
   gateway** abstraction (sandbox impl), 2% cashback, wallet-funded checkout
✅ **Intelligent tools** — MotoFix / MotoSanj / MotoType embedded **unmodified**
   via WebView, with a JS bridge to the app's data (see below)
✅ **AI Copilot** — globally accessible streaming chat behind a
   **provider-agnostic `AiProvider`** abstraction (offline mock for now),
   grounded in the rider's bike + maintenance state
✅ **MotoBimeh (insurance)** — compare provider offers by kind, buy online,
   "my policies" with renewal reminders
✅ **Service Centers** — searchable catalog, ratings/brands, appointment booking
✅ **Roadside Assistance** — dispatch by service type, **live tracking** via
   Supabase realtime (status timeline + ETA), history
✅ **Motor World** — news feed with tag filters + article detail; home carousel
✅ **Notifications** — in-app center with live unread badge (realtime)
✅ **Admin dashboard** — role-gated in-app panel: analytics, user management
   (role toggle + send notification), product/news CRUD, order & roadside
   management. Guarded by `is_admin()` RLS + admin override policies
✅ Supabase schema for **every** module + Row Level Security + seed data

### AI Copilot (provider-agnostic)

Like the payment layer, the Copilot depends only on the `AiProvider` interface
(`features/copilot/domain/services/ai_provider.dart`). The current binding is an
offline `MockAiProvider` that streams domain-aware Persian answers. Swap in
Claude / OpenAI / a self-hosted model by implementing `AiProvider` and
overriding `aiProviderProvider` — the chat UI and controller are unchanged.
Answers are grounded via `CopilotContext`, derived from the user's primary
motorcycle and next-service status. Reachable from every primary tab via the
✨ FAB.

### Embedded tools bridge (MotoFix / MotoSanj / MotoType)

The three HTML tools are self-contained (no `localStorage`, no `postMessage`,
no hooks), so they are bundled as assets (`assets/tools/*.html`) and loaded
**without modification** in a WebView (`features/tools`). The bridge is built
entirely on the Flutter side:

- **app → tool**: on page load the app injects `window.MotoVerseContext`
  (the user's primary motorcycle) and dispatches a `motoverse:context` event,
  so a tool can pre-fill the bike.
- **tool → app**: the app exposes `window.MotoVerse.sendResult(obj)` (backed by
  the `MotoVerseBridge` JS channel). Any result a tool sends is persisted to
  `tool_results` (migration `0005`) against the user + motorcycle.

This keeps the "integrate the final logic without modification" rule intact
while still wiring the tools to real app data.

> Platform note: WebView needs generated platform folders (`flutter create .`)
> and Android `INTERNET` permission (present in the default debug manifest).

### Marketplace + Wallet design notes

- **Money is never mutated from the client.** `wallet_transactions` is
  read-only under RLS; balance changes happen only through the SECURITY DEFINER
  RPCs `wallet_recharge(amount, ref)` and `place_order(items)` (migration
  `0004`). `place_order` validates stock, debits the wallet, writes the order +
  items, credits cashback, and clears the cart **atomically**.
- **Payments are provider-agnostic.** The recharge flow depends only on the
  `PaymentGateway` interface; swap Zarinpal/IDPay/any PSP by overriding
  `paymentGatewayProvider` — no UI or repository changes.
- **Cart is server-backed** (`cart_items`) so it persists across devices.

## Roadmap (next slices on the same architecture)

These modules have backend tables + RLS ready; the Flutter slices follow the
exact `domain/data/presentation` pattern above:

- FCM push delivery (in-app notifications + realtime badge already built)
- Analytics export / charts (admin dashboard shows live counts today)
- Google Maps rendering for Service Centers / Roadside (deps wired; needs API key)

### Becoming an admin

The dashboard appears in Profile only for users whose `profiles.role = 'admin'`.
Promote a user from Supabase SQL:

```sql
update public.profiles set role = 'admin' where phone = '+9891...';
```

Admin actions are authorized by the `is_admin()` RLS policies + the override
policies in migration `0006` — the panel is enforced server-side, not just hidden.

---

## Conventions

- Persian-first, RTL throughout; numbers/currency via `PersianUtils`.
- Repositories never throw to the UI — they return `Either<Failure, T>`.
- Secrets only via `--dart-define`; `.env` is git-ignored.
- Generated files (`*.g.dart`, `*.freezed.dart`) are git-ignored.
