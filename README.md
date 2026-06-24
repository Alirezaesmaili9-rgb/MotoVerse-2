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
   └─ home/        { presentation }                   ← command center + shell
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
✅ Supabase schema for **every** module + Row Level Security + seed data

## Roadmap (next slices on the same architecture)

These modules have backend tables + RLS ready; the Flutter slices follow the
exact `domain/data/presentation` pattern above:

- MotoFix (diagnostics) · MotoSanj (valuation) · MotoType (recommendation)
- MotoBimeh (insurance) · Roadside Assistance (live tracking)
- Marketplace (parts/accessories) + Wallet + Orders
- Service Centers (map + booking) · Motor World (news) · AI Copilot
- Admin dashboard · FCM notifications · Analytics

---

## Conventions

- Persian-first, RTL throughout; numbers/currency via `PersianUtils`.
- Repositories never throw to the UI — they return `Either<Failure, T>`.
- Secrets only via `--dart-define`; `.env` is git-ignored.
- Generated files (`*.g.dart`, `*.freezed.dart`) are git-ignored.
