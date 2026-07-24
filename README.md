# Hinam

Hinam is a modular mobility platform for Nepal, built with Flutter and Firebase. It brings multiple transportation services — public bus tracking, school bus tracking, and a women-focused ride-sharing service (Hinam Ride) — into a single application on shared authentication, notification, and administration infrastructure.

See [project_overview.md](project_overview.md) for the full architecture description and [PHASES.md](PHASES.md) for the Hinam Ride development history.

## Features

**Public Bus Tracking**
- Live bus location on an interactive map
- Bus stop directory
- Driver-side live location broadcasting

**School Bus Tracking**
- Live school bus tracking for parents
- Route and driver visibility per school

**Hinam Ride** (women-focused ride-sharing)
- Separate driver and passenger registration; drivers are verified via uploaded documents
- Driver online/offline status with live location broadcasting
- Trip requests matched to the nearest verified, online driver
- Sequential, negotiable price offers per ride
- Full trip lifecycle: matched → arrived → in progress → completed
- Cancellation and no-show handling with mandatory reasons
- Post-trip ratings and ride history
- Cash payment settlement recorded per ride
- In-trip reporting and admin report review
- SOS / emergency incident triggering with high-priority admin push notifications
- Driver leaderboard ranking verified, currently online drivers by completed ride count

**Administration**
- Driver approval workflows (bus and Ride)
- Fleet management (buses, route assignments, bus stops)
- Ride verification, report, and incident review queues

**Platform**
- Phone number authentication (OTP)
- Push notifications (Firebase Cloud Messaging)
- Role-based routing resolved at app launch

## Tech Stack

| Layer | Technology |
|---|---|
| Client | Flutter (Dart), Material 3 |
| State management | Riverpod (`flutter_riverpod`) |
| Backend | Firebase Authentication, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging, Cloud Functions |
| Maps & location | `flutter_map` (OpenStreetMap tiles), `latlong2`, `geolocator` |
| Cloud Functions runtime | TypeScript, Node.js 20 |

## Architecture

Hinam follows a feature-first architecture. Each transportation service is an independent feature module with its own data and presentation layers; only genuinely cross-cutting code lives in `shared/`.

```
UI → Provider (Riverpod) → Repository → Datasource → Firebase
```

- **UI** stays declarative; it never talks to Firebase directly.
- **Providers** hold business logic and expose state to widgets.
- **Repositories** define domain operations against a feature's data.
- **Datasources** are the only layer that calls Firebase APIs.
- **Firestore Security Rules** enforce authorization server-side; the client is never trusted for critical checks.

See [project_overview.md](project_overview.md) for module boundaries and the Firestore data model, and [AGENTS.md](AGENTS.md) for the engineering conventions that implement this architecture in code.

## Folder Structure

```
lib/
  core/                   App-wide theme and routing
    routes/
    theme/
  features/
    admin/                Driver approval, admin dashboard
    auth/                 Phone auth, OTP, splash/role routing
    bus_stops/             Bus stop management
    driver/                Bus driver profile, tracking, dashboard
    fleet/                 Bus and route-assignment management
    passenger/             Public bus tracking (passenger side)
    school_bus/             School bus tracking
    tracking/               Shared live-location plumbing
    hinam_ride/
      administration/       Verification, report, and incident review queues
      driver/                Ride driver profile and status
      passenger/              Ride passenger profile
      pricing/                 Offer/negotiation UI
      trip/                     Trip lifecycle, tracking, history
      verification/              Shared driver/passenger verification submodule
      payments/                    Cash settlement recording
      shared/                       Ride-only cross-cutting helpers
  shared/                 Cross-feature datasources, models, providers, repositories, services, widgets
  firebase_options.dart
  main.dart

functions/                Cloud Functions (TypeScript) — notification triggers
firestore.rules
firestore.indexes.json
storage.rules
```

Each feature under `features/` follows `data/` (datasources, models, repositories) and `presentation/` (providers, screens, widgets).

## Firebase Services Used

- **Authentication** — phone number / OTP sign-in
- **Cloud Firestore** — all application data (see [project_overview.md](project_overview.md) for the collection list)
- **Storage** — verification document and image uploads, under a per-user (`{uid}/...`) path
- **Cloud Messaging** — push notifications for ride offers, status changes, and SOS incidents
- **Cloud Functions** — server-side notification triggers (`functions/src/index.ts`)

Firebase project: `hinam-4eacd` (configured via `.firebaserc` / `lib/firebase_options.dart`).

## Setup

### Prerequisites

- Flutter SDK (`^3.12.0`) and Dart
- A Firebase project with Authentication (Phone), Firestore, Storage, Cloud Messaging, and Cloud Functions enabled
- [Firebase CLI](https://firebase.google.com/docs/cli) and the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)
- Node.js 20 (for Cloud Functions)

### Install

```bash
git clone <repository-url>
cd hinam
flutter pub get
```

Configure Firebase for your own project (regenerates `lib/firebase_options.dart` and the platform config files):

```bash
firebase login
flutterfire configure
```

Install Cloud Functions dependencies:

```bash
cd functions
npm install
cd ..
```

## Running the Application

```bash
flutter run
```

Run tests:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

Run Cloud Functions locally against the Firebase emulator:

```bash
cd functions
npm run serve
```

## Deployment

Deploy Firestore rules, indexes, storage rules, and Cloud Functions:

```bash
firebase deploy --only firestore,storage,functions
```

Build the Flutter client for a target platform (example: Android):

```bash
flutter build apk --release
```

## Contributing

Read [AGENTS.md](AGENTS.md) before making changes — it defines the engineering conventions (architecture, state management, Firebase access patterns, naming) that all contributions, human or AI, are expected to follow. Keep changes scoped to the feature module they belong to; only promote code to `shared/` when multiple features genuinely need it.
