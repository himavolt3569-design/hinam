# Hinam Ride — Development History

This document is a historical record of how the Hinam Ride feature was built, not an active roadmap. All 24 planned phases (0–23) have been completed.

Hinam's other transportation services — Public Bus, School Bus, and their shared admin/fleet tooling — predate this rollout and are not covered here; see [project_overview.md](project_overview.md) for their current state.

Phases were sequenced so each depended only on infrastructure that already existed: shared storage and notifications first, then driver/passenger profiles and verification, then trip matching, and finally lifecycle, safety, and consolidation features. Cloud Functions were introduced at Phase 11, exactly when a real race condition first required server-side arbitration, rather than upfront.

---

## Phase 0 — Platform & Infrastructure Prerequisites

Enabled Firebase Storage and Cloud Functions on the project, confirmed the Blaze billing plan, and added the Flutter dependencies Ride would need. Pure infrastructure — no feature code.

## Phase 1 — Shared Storage Capability

Built a generic, reusable file-upload capability in `shared/` (`storage_providers.dart`, `storage_service.dart`) with owner-writes-own-path `storage.rules`, usable by any feature — not Ride-specific.

## Phase 2 — Shared Notification Capability

Added FCM token capture on login, storage against the user's `uid` (`fcm_tokens/{uid}`), and foreground notification display — client-side only, platform-level rather than Ride-owned.

## Phase 3 — Ride Driver Profile

Added ride driver registration (model, repository, datasource, provider), independent of the bus-driver `drivers` collection. No verification gating, online status, or location yet at this stage.

## Phase 4 — Ride Passenger Profile

Mirrored Phase 3 for passengers, including emergency-contact fields from the start (needed later by Phase 18).

## Phase 5 — Shared Verification Submodule

Built one verification workflow — document submission on top of Phase 1's storage service — shared by both driver and passenger onboarding rather than duplicated per role.

## Phase 6 — Admin Verification Review

Added a pending-verification queue with approve/reject actions, kept deliberately separate from the existing global `AdminRepository`.

## Phase 7 — Splash & Routing Integration

Wired Ride into app entry points: extended `splash_screen.dart`'s role resolution, added Ride route constants, and added `ChoiceButton` entries.

## Phase 8 — Driver Online/Offline & Location Tracking

Added an online/offline toggle gated on `verificationStatus == approved`, streaming location into `ride_locations` — isolated from the public `bus_locations` collection.

## Phase 9 — Trip Request Creation

Added pickup/drop-off selection, a suggested-fare display, request creation, and cancel-before-match. No matching yet.

## Phase 10 — Matching Service & Sequential Offer Creation

Implemented candidate lookup against `ride_locations`/`ride_drivers` and sequential offer creation to the nearest available, verified, online driver.

## Phase 11 — Offer Accept/Decline/Counter + Negotiation

Made the accept path race-safe. Implemented as sequential, rule-gated Firestore writes from the existing repository layer rather than a Cloud Function, to avoid introducing a second runtime for a case Firestore transactions could already handle safely.

## Phase 12 — Notification Delivery Triggers

Introduced the first real Cloud Functions (`functions/` scaffolded fresh): `onOfferCreated` and `onRideStatusChanged`, covering exactly the events with no viable client-only alternative. No Flutter files changed.

## Phase 13 — Trip Lifecycle Screens

Added full driver and passenger UI for `matched → arrived → in_progress → completed`. `RideStatus` extended with `arrived`/`inProgress`/`completed`; `firestore.rules` gained three driver-only, forward-only transition clauses.

## Phase 14 — Cancellation & No-Show Handling

Added `noShow` to `RideStatus`; `RideModel` gained `arrivedAt`/`cancelledBy`/`cancelReason`; `firestore.rules` gained post-match cancel, mandatory-reason mid-trip cancel, and grace-period-gated no-show clauses. Extended the existing `cancelRide` (Phase 9) rather than duplicating it.

## Phase 15 — Ratings & Ride History

Added `driverRating`/`driverRatingComment`/`passengerRating`/`passengerRatingComment` to `RideModel`, exactly-once range-checked rating rules, and the two composite indexes (`passengerId + createdAt`, `driverId + createdAt`) history screens depend on.

## Phase 16 — Payments (Cash)

Added an isolated `hinam_ride/payments/` submodule (`RideTransactionModel`, datasource, repository, provider, `MarkPaidButton`) and a top-level `ride_transactions/{rideId}` collection keyed by the ride's own id, guaranteeing exactly one transaction per ride.

## Phase 17 — Reports

Added `RideReportModel`/repository/providers under `administration/` and a `ride_reports/{reportId}` collection with a rule-derived (never client-asserted) `reportedUserId`. `ReportFormDialog` wired into both active-trip screens and the post-trip view. The reports queue screen was built but not yet linked from a dashboard — that landed in Phase 19.

## Phase 18 — SOS / Emergency Incidents

Added `RideIncidentModel`/repository/providers, a `ride_incidents/{incidentId}` collection readable only by the triggering user and admins, and `onIncidentCreated` — a high-priority push path separate from Phase 12's routine triggers. Added `SosButton` to both active-trip screens and `url_launcher` for the native SMS-intent fallback.

## Phase 19 — Ride Administration Dashboard Consolidation

Added `RideAdminHomeScreen`, composing the three existing queue providers from Phases 6/17/18 with no new providers or repositories. Added one additive summary tile to `admin_dashboard_screen.dart` and four new routes.

## Phase 20 — Theme & Design Consistency Pass

Added one domain color pair (`rideAccent`/`rideAccentBg`) applied to Ride's identity avatar and live-position marker. Audited every `hinam_ride/` file for raw color literals and unified ad hoc `Colors.*` usage onto existing semantic tokens, including the SOS alarm styling.

## Phase 21 — Firestore Rules & Indexes Consolidation Audit

Reviewed `firestore.rules` and `firestore.indexes.json` together against a live Firestore emulator, covering every Ride collection's allow/deny matrix. Found and fixed one real gap: `ride_verifications` was missing its `status`+`createdAt` composite index.

## Phase 22 — Regression & Integration Testing

Pure verification, no files changed: confirmed `splash_screen.dart`'s role-priority order still checks pre-existing roles before either Ride check, confirmed every pre-existing route still resolves correctly, confirmed no pre-existing feature depends on `hinam_ride/` besides Phase 19's one dashboard tile, and confirmed `flutter analyze` is clean project-wide.

## Phase 23 — Documentation Sync & Rollout Readiness

Reconciled `project_overview.md` with the shipped system (corrected the mapping/backend tech list, added Cloud Functions and cash settlement, added an implementation-notes section). Confirmed `AGENTS.md`/`CLAUDE.md` needed no changes.
