# PadCare — Production Setup

This repository contains the Flutter app and an optional Supabase backend. Without backend credentials the app intentionally starts in offline/simulation mode; that is useful for UI testing but does **not** provide shared accounts, cross-device data, or production realtime data.

## 1. Run the app locally

Install the Flutter SDK compatible with `pubspec.yaml`, then from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To connect the configured PadCare Supabase project during a local run, provide its **publishable key** (never a service-role key):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://eztqoyhbcfcsxvommgxi.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

The app reads Dart compile-time defines; creating a `.env` file by itself does not inject values into a Flutter build.

## 2. Configure GitHub Actions APK builds

In GitHub, open **Settings → Secrets and variables → Actions** for this repository and add:

- Repository secret `SUPABASE_PUBLISHABLE_KEY`: the project's publishable key (never a `service_role` or secret key).
- Optional repository secret `SUPABASE_URL`: override the configured project URL only if you intentionally switch projects. The PadCare project URL is already set as non-secret app configuration.
- The older `SUPABASE_ANON_KEY` secret is still accepted for backward compatibility, but new builds should use `SUPABASE_PUBLISHABLE_KEY`.
- Optional repository variable `TRANSLATION_API_URL`: publicly reachable HTTPS URL for the Go translation API.

Add the `SUPABASE_PUBLISHABLE_KEY` repository secret before expecting a live-connected APK. Push to `main`, `feature/**`, or `fix/**`, or run **Actions → Build Android APK → Run workflow**. After the workflow succeeds, open its run and download the `padcare-release-apk` artifact. If Supabase secrets are not configured, the APK can still build, but it will use simulation mode.

## 3. Configure Supabase

1. Use the configured project `eztqoyhbcfcsxvommgxi`; copy its Project URL and publishable key from Project Settings → API Keys.
2. Review `backend/supabase_schema.sql` before applying it in **SQL Editor**.
3. Enable the authentication methods the app will use in **Authentication → Providers**.
4. In **Authentication → URL Configuration**, configure only the redirect URLs you actually use.
5. Test signup, sign-in, session restoration, creating a pickup request, and realtime updates on two separate devices.

### Secure pickup operations (required before live use)

Do **not** apply `backend/supabase_schema.sql` as-is to a production project: its legacy policies grant broad public access. The production-readiness branch contains two migrations which must be reviewed and applied in order in the Supabase SQL Editor (prefer a staging project first):

1. `backend/migrations/20261112_production_lockdown.sql` removes broad policies and disables direct client access to requests, messages and live locations.
2. `backend/migrations/20261112_secure_pickup_operations.sql` adds server-side RPCs for request creation/listing, one-time voucher verification, voucher-scoped messaging, and authorized staff location publishing/reading.

The mobile app calls those RPCs rather than writing sensitive tables directly. Pickup codes are generated server-side with high entropy; collection checks the expiry and status and requires an active staff assignment for the pickup hub. Message access requires the authenticated request owner or assigned hub staff. Location publishing and reading require an active staff assignment. Message and staff-location streams poll the authorized RPCs; they are not database-wide realtime subscriptions.

**Before enabling these operations:**
- Apply both migrations in order and verify they succeed. They have not been applied by this code change.
- Create an auth user for each real caretaker/coordinator, then insert their verified user UUID and hub ID into `public.hub_staff` using the trusted Supabase SQL Editor/admin process. Never let the app write this table or self-assign staff roles.
- Ensure anonymous sign-in is enabled if anonymous seekers are a supported flow. Anonymous sessions are still authenticated Supabase users.
- Test with separate seeker and staff accounts: a seeker must only list their own requests; unrelated accounts must not read messages; only assigned staff may verify a code or publish/read locations; expired/already-collected codes must fail.
- Do not publish actual location tracking until volunteers/staff have been informed and the app has clear consent and access rules.

Never put a Supabase service-role/secret key in the mobile app. The publishable key is intended for client apps, but is safe only with correctly restricted database privileges and RPC authorization.

The app handles sensitive menstrual-health and pickup information. Use synthetic test data until access controls have been reviewed. Verify the actual distribution partners and stock information before publishing any pickup locations.

## 4. HerHelp (Gemini) and API keys

The Gemini client integration accepts a key at runtime, but any key compiled into a mobile app can be extracted. For a public release, put Gemini behind a server-side endpoint with rate limits and abuse protection instead of shipping a long-lived Gemini API key inside the APK. Keep secrets out of source control, screenshots, logs, and issue reports.

## 5. Translation API

The Go service lives in `backend/translate_api`. Follow its README to run or deploy it, then set `TRANSLATION_API_URL` to its reachable HTTPS endpoint. `localhost` inside an Android phone refers to the phone itself, not your development computer.

## 6. Release checklist

- [ ] Replace broad Supabase write/read policies with least-privilege RLS policies and test as anon, signed-in seeker, supplier, and admin.
- [ ] Remove mock authentication paths from production flows; ensure Google sign-in is real or clearly unavailable.
- [ ] Ensure voucher generation and collection verification are server-validated and resistant to guessing/replay.
- [ ] Move Gemini calls behind a protected server endpoint.
- [ ] Confirm locations, operating hours, inventory, partner names, payment options, and donation claims with the real providers.
- [ ] Run `flutter analyze` and `flutter test`, then test the release APK on a physical Android device.
- [ ] Publish a privacy policy and support contact that are reachable and accurate.
