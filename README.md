# PadCare — Dignified Menstrual Hygiene & Discreet Aid Platform 🌸

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Go Translation API](https://img.shields.io/badge/Go-1.22-00ADD8?logo=go&logoColor=white)](https://golang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-26%20Passing-brightgreen.svg)]()
[![Code Quality](https://img.shields.io/badge/Analysis-0%20Issues-brightgreen.svg)]()

> **"Restoring dignity, ensuring confidentiality, and providing safe, barrier-free access to menstrual hygiene products for girls and women everywhere."**

PadCare is an enterprise-grade, offline-first mobile application designed to overcome period poverty, social stigma, and logistical barriers across East Africa (Uganda, Kenya, Tanzania, Rwanda) and global communities. Built in Flutter with a clean architecture layer, Riverpod state management, GoRouter, offline queue sync with CRDT conflict resolution, and seamless integration with a Go-powered neural machine translation microservice.

---

## 👥 Core Engineering Team

- **Dan Mungufeni** — Lead Flutter/Dart Architect & Full-Stack Mobile Engineer (`devgtnation@gmail.com`)
- **Nichlas Abeti** — Senior Mobile Engineer & Field Infrastructure Lead (`abetinichlas@gmail.com`)

---

## 🎨 Design System & Visual Specification

PadCare is built directly against the authoritative `DESIGN.md` specification, adhering to an 8pt spatial grid, rounded organic radii, and WCAG AAA accessibility standards.

### Color Tokens
| Token | Hex Value | Purpose |
| :--- | :--- | :--- |
| **Primary** | `#58236A` | Royal plum — Brand identity, hero titles, primary action buttons |
| **Primary Container** | `#713B83` | Deep orchid — Floating action elements, active tab indicators |
| **On Primary** | `#FFFFFF` | Crisp white contrast on primary surfaces |
| **Background / Surface** | `#FEF7FF` | Warm lavender tint reducing glare and visual fatigue |
| **Surface Lowest** | `#FFFFFF` | Clean white card backgrounds, discrete input containers |
| **Surface Low** | `#F9F0FF` | Subtle elevated panels, soft badges |
| **Surface Container** | `#F4EBF9` | Secondary card fills, category card backgrounds |
| **Surface Container High** | `#EEE5F3` | Modal sheets, navigation backdrops |
| **Surface Highest** | `#E8DFEE` | Hover states, disabled borders, dividers |
| **On Surface** | `#1E1A24` | Deep charcoal — High-contrast readable typography |
| **On Surface Variant** | `#4D444E` | Subdued metadata, secondary subtitles |
| **Outline / Border** | `#7F747F` | Subtle structural borders |
| **Outline Variant** | `#D0C2CF` | Divider lines, light input borders |
| **Tertiary / Coral Pink**| `#E87596` | Healthcare alerts, urgency tags, maternal badges |
| **Error / Crimson** | `#BA1A1A` | Stock depletion, validation errors, field warnings |

### Typography Scale
- **Manrope** (Headlines & Display):
  - `Headline XL`: 32px / 40px / 800 (Extra Bold)
  - `Headline LG`: 26px / 34px / 700 (Bold)
  - `Headline MD`: 22px / 28px / 700 (Bold)
  - `Headline SM`: 18px / 24px / 600 (Semi-Bold)
- **Inter** (Body & Interface Labels):
  - `Body LG`: 16px / 24px / 400 (Regular)
  - `Body MD`: 14px / 20px / 400 (Regular)
  - `Body SM`: 13px / 18px / 400 (Regular)
  - `Label LG`: 15px / 20px / 600 (Semi-Bold)
  - `Label MD`: 13px / 18px / 600 (Semi-Bold)
  - `Label SM`: 11px / 14px / 500 (Medium)

---

## 📱 Complete Screen Catalog (All 23 Screens Implemented)

Every single screen from the reference specification is fully realized without placeholders or shortcuts:

```
├── 1. Welcome & Authentication          (/)
├── 2. User Onboarding Carousel          (/onboarding)
├── 3. Security Verification (PIN/Biometric) (/security-verification)
├── 4. Terms & Consent Acceptance        (/terms-consent)
├── 5. PadCare Home Dashboard            (/home)
├── 6. Live Map Discovery                (/map)
├── 7. Add Distribution Point            (/add-hub)
├── 8. Distribution Point Details        (/hub-details/:id)
├── 9. Discreet Request Flow (Vouchers)  (/request)
├── 10. Discreet Messaging               (/messaging)
├── 11. In-App Notifications Center      (/notifications)
├── 12. HerHelp Assistant                (/herhelp)
├── 13. User Profile & Privacy Settings  (/profile)
├── 14. Support / Donations — Step 1     (/donations-step1)
├── 15. Support / Donations — Step 2     (/donations-step2)
├── 16. Support / Donations — Step 3     (/donations-step3)
├── 17. Donation Receipt Confirmation    (/donation-receipt)
├── 18. Supplier Dashboard               (/supplier-dashboard)
├── 19. Stock Management                 (/stock-management)
├── 20. Admin Verification Dashboard     (/admin-dashboard)
├── 21. Full Offline Queue Sync Manager  (/offline-sync)
├── 22. Offline Sync Confirmation        (/offline-sync-confirmation)
└── 23. Sync Conflict Resolution (CRDT)  (/sync-conflict-resolution)
```

### Detailed Screen Highlights
1. **Welcome / Authentication**: Quick anonymous guest entry for seekers with zero barrier to entry, alongside structured phone/credential sign-in for suppliers and NGOs.
2. **User Onboarding Carousel**: 3-step value illustration with regional language selector directly accessible in the top-right corner.
3. **Security Verification**: 6-digit numeric PIN entry pad with biometric touch confirmation and anti-shoulder-surfing disguise.
4. **Terms & Consent Acceptance**: Granular privacy controls, GDPR/African Data Protection compliant, with quick expandable sections and full legal text preview.
5. **PadCare Home Dashboard**: Search bar, emergency banner, category quick-pills, nearby distribution points with real-time stock levels, HerHelp AI quick access, and bottom navigation.
6. **Live Map Discovery**: Dual-view interactive map with custom distribution markers, EAC city quick switcher (Kampala, Nairobi, Dar es Salaam, Kigali), category filters, and distance sorting.
7. **Add Distribution Point**: Full NGO field intake form capturing GPS coordinates, operating hours, stock capacities, emergency contact, and discreet pickup tags.
8. **Distribution Point Details**: Comprehensive hub view with verified status badge, real-time product inventory, step-by-step directions, accessibility notes, and instant request trigger.
9. **Discreet Request Flow**: Anonymized 3-step product allocation flow generating 6-character encrypted redemption voucher codes (e.g., `PAD-749`), QR code presentation, zero PII requirement, and immediate disguise triggers.
10. **Discreet Messaging**: End-to-end encrypted messaging channel connecting seekers with verified healthcare workers and distribution staff, featuring preset quick replies and message auto-deletion timer.
11. **In-App Notifications Center**: Filterable activity feed (All, Urgent, Deliveries, Educational, System) with mark-as-read and clear actions.
12. **HerHelp Assistant**: Friendly, compassionate maternal and menstrual health guidance bot with categorized prompt suggestions and an interactive calculator disguise for instant privacy masking.
13. **User Profile / Privacy Settings**: Account persona switcher (Seeker, Field Nurse, NGO Lead, Supplier, Admin), incognito browsing toggle, passkey biometric lock, language selector, and zero-trace data wipe.
14. **Support / Donations (Step 1 - Cause & Tier)**: Transparent impact tiers (`UGX 15,000` = 1 Girl / 3 Months), custom amount input with live EAC multi-currency equivalents (KES, TZS, RWF), and verified 80/20 impact breakdown.
15. **Support / Donations (Step 2 - Payment Gateway)**: Direct payment selection featuring MTN Mobile Money, Airtel Money, M-Pesa, Rwanda Pay, and Visa/Mastercard.
16. **Support / Donations (Step 3 - Team Dedication)**: Dedicated developer credit cards showcasing lead architects Dan Mungufeni & Nichlas Abeti with verified emails, direct contribution options, and final checkout.
17. **Donation Receipt Confirmation**: Transaction summary card, unique reference ID (`PC-DON-8841`), printable/shareable receipt actions, and donor impact statement.
18. **Supplier Dashboard**: Enterprise logistics view with key metrics (Total Dispatched, Remaining Inventory, Active Alerts), urgent restocking requests, and supplier action center.
19. **Stock Management**: Inventory table with low-stock warnings, inline +/- stock adjustments, and incoming NGO delivery intake form.
20. **Admin Verification Dashboard**: NGO distribution point vetting portal with pending applicant review, proof of certification inspections, and one-tap Approve/Reject decisions.
21. **Full Offline Queue Sync Manager**: Field sync telemetry monitor displaying pending mutations, bandwidth compression toggles, 2G/3G low-data mode, and one-tap sync trigger.
22. **Offline Sync Confirmation**: Post-sync success summary indicating synced record count, zero failed payloads, network latency benchmarks, and return to dashboard.
23. **Sync Conflict Resolution**: Multi-master Conflict-Free Replicated Data Type (CRDT) visual resolution portal allowing side-by-side comparison of local device edits vs. remote server edits with Last-Write-Wins and manual merge overrides.

---

## 🌐 Localization & Go Translation Engine

PadCare provides native support for 11 regional and international languages, with full Right-to-Left (RTL) mirroring for Arabic:

- 🇺🇬 **English** (`en`)
- 🇹🇿 **Swahili / Kiswahili** (`sw`)
- 🇺🇬 **Luganda** (`lg`)
- 🇫🇷 **French / Français** (`fr`)
- 🇸🇦 **Arabic / العربية** (`ar` — Full RTL)
- 🇪🇸 **Spanish / Español** (`es`)
- 🇰🇪 **Luo / Dholuo** (`luo`)
- 🇩🇪 **German / Deutsch** (`de`)
- 🇵🇹 **Portuguese / Português** (`pt`)
- 🇪🇹 **Amharic / አማርኛ** (`am`)
- 🇮🇳 **Hindi / हिन्दी** (`hi`)

### Go Translation Microservice Integration
The app integrates with the provided Go translation microservice running at `backend/translate_api`:

```http
POST /translate
Content-Type: application/json

{
  "text": "Emergency menstrual hygiene kit needed",
  "to": "sw"
}
```

Response:
```json
{
  "translatedText": "Kifaa cha dharura cha usafi wa hedhi kinahitajika",
  "status": true,
  "message": ""
}
```

### 3-Tier Offline-First Translation Resilience
1. **Memory & Persistent Storage Cache**: Common UI strings and previous translations are cached locally via `SharedPreferences`.
2. **Go Translation Backend**: Active network calls automatically retry up to 3 times with exponential backoff.
3. **Hardcoded Healthcare Dictionary Fallback**: Over 50+ critical menstrual, emergency, and healthcare terms are built directly into `TranslationService` so that when a device is deep offline in rural areas, accurate translations are still rendered without network connectivity.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, feature-driven domain architecture:

```
Team-Fara-/
├── android/                     # Android native platform configuration & permissions
├── assets/
│   ├── docs/                    # Full legal terms & privacy policy documents
│   └── images/                  # Badges, payment logos, avatars, illustrations
├── backend/
│   └── translate_api/           # Production Go translation API
│       ├── Dockerfile           # Multi-stage lightweight Alpine container
│       ├── docker-compose.yml   # Single-command local microservice stack
│       ├── main.go              # Go HTTP server
│       ├── config/              # Environment config
│       └── handlers/            # HTTP /translate handler
├── ios/                         # iOS native platform configuration
├── lib/
│   ├── main.dart                # Application entrypoint
│   ├── app/
│   │   ├── app.dart             # PadCareApp root widget with theme & locale builders
│   │   ├── router.dart          # GoRouter configuration for all 23 routes
│   │   └── theme/               # Centralized Design System tokens
│   │       ├── app_colors.dart
│   │       ├── app_typography.dart
│   │       ├── app_spacing.dart
│   │       ├── app_radius.dart
│   │       ├── app_elevation.dart
│   │       └── app_theme.dart
│   ├── core/
│   │   ├── constants/           # AppConstants & AssetPaths
│   │   ├── errors/              # AppException & error handling
│   │   ├── network/             # ApiClient & ConnectivityService
│   │   ├── storage/             # LocalStorage & SecureStorage
│   │   ├── localization/        # AppLocale, AppLocalizations, TranslationService
│   │   ├── responsive/          # ResponsiveLayout & Breakpoint utilities
│   │   ├── permissions/         # PermissionService
│   │   └── utils/               # Currency, distance, and date formatters
│   ├── data/
│   │   ├── models/              # Immutable data models with copyWith & JSON serialization
│   │   ├── repositories/        # Abstract & concrete data repositories
│   │   └── services/            # MockBackendStore (realistic field database)
│   ├── features/                # 23 Screen implementations grouped by feature
│   │   ├── authentication/
│   │   ├── onboarding/
│   │   ├── dashboard/
│   │   ├── maps/
│   │   ├── distribution_points/
│   │   ├── requests/
│   │   ├── messaging/
│   │   ├── notifications/
│   │   ├── herhelp/
│   │   ├── profile/
│   │   ├── donations/
│   │   ├── supplier/
│   │   ├── stock/
│   │   ├── admin/
│   │   └── synchronization/
│   └── shared/                  # Reusable Design System components
│       └── widgets/
│           ├── dignity_card.dart
│           ├── dignity_button.dart
│           ├── dignity_text_field.dart
│           ├── dignity_chip.dart
│           ├── dignity_badge.dart
│           ├── app_bottom_nav.dart
│           ├── discreet_camouflage_view.dart
│           └── language_selector_sheet.dart
└── test/                        # Comprehensive unit & widget test suite
    ├── unit/
    └── widget/
```

---

## 🔒 Privacy & Discreet Mode Features

- **Zero PII Seeker Requests**: Users do not enter names, national IDs, or menstrual cycle dates to access supplies. Only temporary 6-character redemption tokens (`PAD-749`) are generated.
- **Calculator Camouflage Disguise**: A persistent disguise action opens a fully working calculator in place of the app UI to shield vulnerable seekers from prying eyes or domestic violence in unsafe settings.
- **Incognito Seeker Browsing**: Bypasses local search history and clears cache upon exiting the application.
- **Biometric / Passkey Protection**: Protects voucher retrieval behind local hardware biometric authentication.
- **Emergency Wipe**: Allows one-tap complete local database wipe from the Profile settings screen.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.3.0)
- [Go](https://go.dev/) (>= 1.20) *or* [Docker](https://www.docker.com/) (optional, for backend)
- Android Studio / Xcode / VS Code

### 1. Clone the Repository
```bash
git clone https://github.com/danmungufeni-dev/Team-Fara-.git
cd Team-Fara-
```

### 2. Configure Environment
Copy the example environment file:
```bash
cp .env.example .env
```
Key configuration parameters:
- `TRANSLATION_API_URL`: URL of the Go translation service (defaults to `http://10.0.2.2:8000` for Android emulator or `http://localhost:8000` for Web/Desktop).
- `GOOGLE_MAPS_API_KEY`: API key for Google Maps integration.

### 3. Run the Go Translation Microservice (Optional)
Using Docker Compose:
```bash
cd backend/translate_api
docker-compose up -d
```
Or directly using Go:
```bash
cd backend/translate_api
go run main.go
```
The translation server starts on port `8000`.

### 4. Install Dependencies & Run Flutter App
```bash
flutter pub get
flutter run
```

---

## 🧪 Testing & Code Quality

PadCare features an automated test suite verifying business logic, translation fallback resilience, stock adjustments, offline synchronization, CRDT conflict resolution, and UI rendering:

```bash
# Run all tests
flutter test

# Run static analysis
flutter analyze --no-fatal-infos
```

**Results:**
- ✅ **26/26 Tests Passing**
- ✅ **0 Errors / 0 Warnings**

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

---

*Dedicated with deep gratitude to all the community health workers, volunteers, and grassroots NGOs working tirelessly across East Africa to eliminate period poverty.* 🌸
