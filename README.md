# Veritas Mobile App

Veritas holds every payment safely in escrow and settles in your local currency. Built for freelancers and clients doing borderless, modern work.

## Overview

A Flutter/Dart mobile application with:
- **Escrow-based contracts** with milestone tracking
- **Dual-role experience** — Freelancer and Client views
- **USD → NGN conversion** at live FX rates (₦1,540.20/$1)
- **KYC identity verification** flow
- **Dispute resolution** system
- **In-app support chat** (Tomi agent)

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x / Dart |
| State management | Riverpod (`flutter_riverpod ^2.5.1`) |
| Navigation | Named routes via `MaterialApp` |
| Fonts | Google Fonts — Inter + Istok Web |
| Data | Mock/in-memory (no backend required) |

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0

### Setup

```bash
# Clone the repo
git clone https://github.com/Digital-Ninja-Technologies/Veritas-Mobileapp.git
cd Veritas-Mobileapp

# Generate platform files (Android / iOS)
flutter create . --project-name veritas_app

# Install dependencies
flutter pub get

# Run
flutter run
```

> **Note:** `flutter create .` will generate the platform-specific `android/` and `ios/` directories without overwriting the existing `lib/` source files.

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + routing
├── core/
│   ├── models.dart              # All data models + seed data
│   └── theme.dart               # AppColors + buildAppTheme()
├── providers/
│   └── app_state.dart           # Riverpod providers + formatters
├── widgets/
│   └── common.dart              # Shared UI components
└── screens/
    ├── onboarding/              # Splash, Intro, AuthChoice, Country, Phone, Details, Password
    ├── auth/                    # Login, OTP
    ├── main/                    # Shell (bottom nav), Home, Contracts, Activity, Profile/Wallet
    ├── contract/                # Detail, Create, SubmitWork, RequestChanges, Dispute
    ├── wallet/                  # Withdraw, AddFunds, FxDetail, TransactionReceipt
    └── settings/                # Settings, KYC, Notifications, SupportChat, PayoutMethods,
                                 # VeritasTag, EditProfile, PinFlow, ChangePassword, Legal
```

## Design Tokens

```dart
AppColors.bg        = Color(0xFFFCFFC1)  // Pale yellow background
AppColors.dark      = Color(0xFF26230F)  // Dark olive (nav, buttons)
AppColors.yellow    = Color(0xFFFEEA27)  // Brand yellow (CTA)
AppColors.greenDark = Color(0xFF008751)  // Nigerian green
AppColors.redDark   = Color(0xFFC0362C)  // Dispute / danger
```

## Key Flows

| Flow | Entry |
|---|---|
| Onboarding | `SplashScreen` → `IntroScreen` → `AuthChoiceScreen` |
| Sign up | `CountryPickerScreen` → `PhoneInputScreen` → `PersonalDetailsScreen` → `CreatePasswordScreen` |
| Log in | `LoginScreen` → `OtpScreen` (any 6 digits in demo) |
| Create escrow | FAB (client) → `CreateEscrowScreen` |
| Submit milestone | `ContractDetailScreen` → `SubmitWorkScreen` |
| Release funds | `ContractDetailScreen` → confirm dialog |
| Withdraw | Home → `WithdrawScreen` (freelancer: USD→NGN, client: USD→USD) |
| Dispute | `ContractDetailScreen` → `DisputeScreen` |

## Demo Credentials

The app runs fully offline with seeded mock data:

- **Default user:** Amaka Okafor (`amaka@example.com`)
- **OTP:** Any 6 digits
- **Known VeritasTags:** `@danielokafor`, `@zaramensah`, `@techtalk`, `@amaka`
- **Seeded contracts:** Brand Identity ($2,500), E-commerce ($3,800), Podcast ($1,200)
- **Freelancer balance:** $2,350 | **Client balance:** $4,500

## Contact

Veritas Technologies Ltd — info@useveritasapp.com
