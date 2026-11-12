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

To connect a Supabase project during a local run, use the project's **Project URL** and **publishable/anon key** (never a service-role key):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY
```

The app reads Dart compile-time defines; creating a `.env` file by itself does not inject values into a Flutter build.

## 2. Configure GitHub Actions APK builds

In GitHub, open **Settings → Secrets and variables → Actions** for this repository and add:

- Repository secret `SUPABASE_URL`: `https://eztqoyhbcfcsxvommgxi.supabase.co`.
- Repository secret `SUPABASE_PUBLISHABLE_KEY`: the project's publishable key (never a `service_role` or secret key).
- The older `SUPABASE_ANON_KEY` secret is still accepted for backward compatibility, but new builds should use `SUPABASE_PUBLISHABLE_KEY`.
- Optional repository variable `TRANSLATION_API_URL`: publicly reachable HTTPS URL for the Go translation API.

Add the two repository secrets before expecting a live-connected APK. Push to `main`, `feature/**`, or `fix/**`, or run **Actions → Build Android APK → Run workflow**. After the workflow succeeds, open its run and download the `padcare-release-apk` artifact. If Supabase secrets are not configured, the APK can still build, but it will use simulation mode.

## 3. Configure Supabase

1. Use the configured project `eztqoyhbcfcsxvommgxi`; copy its Project URL and publishable key from Project Settings → API Keys.
2. Review `backend/supabase_schema.sql` before applying it in **SQL Editor**.
3. Enable the authentication methods the app will use in **Authentication → Providers**.
4. In **Authentication → URL Configuration**, configure only the redirect URLs you actually use.
5. Test signup, sign-in, session restoration, creating a pickup request, and realtime updates on two separate devices.

### Important security warning

The current `backend/supabase_schema.sql` contains broad public write policies for requests, messages, and live locations. Those policies are **not suitable for production**: a client with the public key could read or modify other users' data, create fake requests, or spoof locations. Do not deploy this schema for real users until those policies are replaced with least-privilege rules and request/message access is tied to an authenticated user or a server-validated voucher. Never put a Supabase service-role key in the mobile app.

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
