# Hinam

> A modular mobility platform for Nepal that makes public transportation safer, smarter, and easier to use.

---

# What Hinam Is Today

Hinam is a single Flutter application that unifies three independent transportation services on shared platform infrastructure:

- **Public Bus Tracking** — live bus locations and bus stop information for passengers.
- **School Bus Tracking** — live tracking of school buses for parents.
- **Hinam Ride** — a women-focused ride-sharing service: driver/passenger verification, trip matching, negotiable pricing, live tracking, safety features, ratings, and cash settlement.

Each service is implemented as an independent feature module. Authentication, notifications, storage, theme, and navigation are shared platform infrastructure used by every service.

---

# Core Principles

- One application, multiple transportation services.
- Modular architecture over feature coupling.
- Simplicity before complexity.
- Security by default.
- Production-ready code over quick solutions.
- Consistent user experience across every service.
- Scalable architecture that supports future expansion.

---

# Transportation Services

## Public Bus Tracking

- Live bus locations on an interactive map
- Bus stop directory, managed by admins
- Driver-side live location broadcasting

## School Bus Tracking

- Live school bus tracking for parents
- Route/school assignment per bus, managed by admins

## Hinam Ride

- Separate driver and passenger registration, gated on document verification
- Driver online/offline status with live location broadcasting (visible only to that driver and to admins)
- Trip requests matched to the nearest available, verified, online driver
- Sequential, negotiable price offers per ride
- Full trip lifecycle: matched → arrived → in progress → completed
- Cancellation and no-show handling, with mandatory reasons on mid-trip cancellation
- Post-trip ratings (driver and passenger) and ride history
- Cash payment settlement, recorded per ride
- In-trip reporting, reviewed by admins
- SOS / emergency incident triggering, with high-priority push notifications to admins

## Administration

- Bus and Ride driver approval workflows
- Fleet management (buses, route assignments, bus stops)
- Ride verification, report, and incident review queues, consolidated under one Ride admin entry point

---

# Platform Architecture

Hinam follows a feature-first architecture:

```
lib/
  core/                   App-wide theme and routing
  features/
    admin/                Driver approval, admin dashboard
    auth/                 Phone auth, OTP, splash/role routing
    bus_stops/            Bus stop management
    driver/               Bus driver profile, tracking, dashboard
    fleet/                Bus and route-assignment management
    passenger/             Public bus tracking (passenger side)
    school_bus/             School bus tracking
    tracking/                Shared live-location plumbing
    hinam_ride/
      administration/       Verification, report, and incident review queues
      driver/                 Ride driver profile and status
      passenger/               Ride passenger profile
      pricing/                  Offer/negotiation UI
      trip/                      Trip lifecycle, tracking, history
      verification/               Shared driver/passenger verification submodule
      payments/                    Cash settlement recording
      shared/                       Ride-only cross-cutting helpers
  shared/                 Cross-feature datasources, models, providers, repositories, services, widgets
```

Each feature follows `data/` (datasources, models, repositories) and `presentation/` (providers, screens, widgets). Business logic never crosses between transportation services; only genuinely cross-feature code lives in `shared/`.

---

# Technology Stack

## Mobile

- Flutter, Dart

## State Management

- Riverpod (`Provider`, `StreamProvider`, `AsyncNotifier`)

## Backend

- Firebase Authentication (phone/OTP)
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Cloud Functions (TypeScript, Node.js 20)

## Maps & Location

- `flutter_map` (OpenStreetMap tiles)
- `geolocator`

## Architecture

- Feature-First Architecture
- Repository Pattern
- Dependency Injection via Riverpod

---

# Application Roles

## Passenger

Tracks buses, views routes, books rides, views ride history, reports issues, rates drivers.

## Bus Driver

Registers a bus, shares live location, manages tracking.

## Ride Driver

Registers a vehicle, submits verification documents, goes online/offline, accepts and negotiates ride offers, completes rides.

## Ride Passenger

Registers a profile, submits verification documents, requests rides, negotiates pricing, rates drivers.

## Administrator

Approves drivers, manages fleet and routes, reviews Ride verification/report/incident queues, moderates reports.

A returning authenticated user's role is resolved once at launch, in priority order: admin → bus driver → ride driver → ride passenger → manual choice screen (`splash_screen.dart`).

---

# Firebase Architecture

## Firestore Collections

| Collection | Purpose |
|---|---|
| `admins/{uid}` | Admin role membership |
| `drivers/{uid}` | Bus driver profiles |
| `bus_locations/{driverId}` | Live bus driver location |
| `buses/{busId}` | Bus fleet records |
| `assignments/{assignmentId}` | Bus-to-route/school assignments |
| `bus_stops/{stopId}` | Bus stop directory |
| `fcm_tokens/{uid}` | Push notification token per user |
| `ride_drivers/{uid}` | Ride driver profiles and verification status |
| `ride_passengers/{uid}` | Ride passenger profiles and verification status |
| `ride_verifications/{requestId}` | Shared driver/passenger verification queue |
| `ride_locations/{driverId}` | Live ride driver location (driver + admin only) |
| `rides/{rideId}` | Ride requests and trip lifecycle |
| `rides/{rideId}/offers/{offerId}` | Sequential price offers, scoped to their ride |
| `ride_transactions/{rideId}` | Cash settlement record, one per ride |
| `ride_reports/{reportId}` | In-trip reports |
| `ride_incidents/{incidentId}` | SOS/emergency incidents |

## Cloud Functions (`functions/src/index.ts`)

- `onOfferCreated` — notifies a driver when a new ride offer targets them.
- `onRideStatusChanged` — notifies the passenger on match, and the driver on a post-match cancellation.
- `onIncidentCreated` — sends a high-priority push to every admin on a new SOS incident.

## Storage

Files live under a per-user path (`{uid}/...`). Owners may read/write their own files; admins may read for review workflows (verification documents, etc.).

---

# Security Approach

- Every client is treated as untrusted; critical validation is enforced in `firestore.rules` and `storage.rules`, never solely in the UI.
- Sensitive fields (e.g. a report's `reportedUserId`, a ride's negotiated status transitions) are rule-derived rather than client-asserted where the rule can compute them.
- State transitions (ride status, verification status) are modeled as forward-only, rule-gated writes rather than trusting arbitrary client updates.
- A ride driver's live location (`ride_locations`) is never broadcast publicly — only the driver themself and admins may read it, unlike public bus locations.

---

# Implementation Notes

A few data-modeling decisions are worth knowing before reading the code:

- Ride status, verification status, and similar states are modeled as Dart enums, serialized as their string name in Firestore.
- Ride pricing negotiation is stored as an `offers` subcollection under each ride document, keeping every bid scoped to the ride it belongs to rather than living in a separate top-level collection.
- A ride driver's live location is visible only to that driver and to administrators — unlike public bus locations, it is never broadcast publicly, since there is no passenger-facing "nearby ride drivers" map.

Full rationale for these and other Hinam Ride implementation decisions is recorded in `PHASES.md`.

---

# Design Philosophy

Every feature should answer one question:

> "Does this belong to the platform, or only to one transportation service?"

If it belongs to only one transportation service, keep it inside that feature. If multiple services require it, promote it to the shared layer.

---

# Code Quality Standards

The project prioritizes readability, maintainability, predictability, testability, security, and consistency over clever implementations.

---

# Guiding Principle

> Build a mobility platform, not a collection of unrelated features.

Every architectural decision should support scalability, maintainability, and a consistent experience for users and contributors alike.
