# Hinam Ride — Implementation Roadmap

24 phases (0–23), each independently implementable and reviewable. No code — file paths, data shapes, and responsibilities only. Ordered so that every phase only depends on infrastructure that already exists by the time it starts; Cloud Functions are introduced exactly when a real race condition first appears (Phase 11), not deferred to the end and not built speculatively before there's a schema for them to operate on.

### Dependency graph (high level)

```
Phase 0 (infra) ─┬─> Phase 1 (storage) ──> Phase 5 (verification) ──> Phase 6 (admin review)
                 └─> Phase 2 (notif. client) ───────────────────────┐
Phase 3 (driver profile) ──┬─> Phase 5 ──> Phase 7 (routing) ──> Phase 8 (online/tracking)
Phase 4 (passenger profile)┘                                          │
                                                                       v
                                            Phase 9 (trip request) ──> Phase 10 (matching)
                                                                       ──> Phase 11 (accept + Cloud Function)
                                                                       ──> Phase 12 (notification triggers, needs Phase 2)
                                                                       ──> Phase 13 (trip lifecycle screens)
                                                                       ──> Phase 14 (cancellation) ──> Phase 15 (ratings/history)
                                                                       ──> Phase 16 (payments)
                                                                       ──> Phase 17 (reports) ──> Phase 18 (SOS, needs Phase 12)
                                                                       ──> Phase 19 (admin consolidation)
Phase 20 (theme) / Phase 21 (rules audit) / Phase 22 (regression) / Phase 23 (docs) close the roadmap.
```

---

## Phase 0 — Platform & Infrastructure Prerequisites

**Objective:** Resolve every project-level gap identified in the architecture review before any Ride feature code exists.

**Scope:** Enable Firebase Storage on the project; scaffold a Cloud Functions project and deploy one trivial function to prove the deploy pipeline; confirm/upgrade Firebase billing to Blaze; register the iOS app in Firebase if iOS is a real target; add required Flutter dependencies.

**Dependencies:** None — this is the root of the roadmap.

**Files involved:** `pubspec.yaml` (add `firebase_storage`, `firebase_messaging`, `cloud_functions` if callable functions are used), `firebase.json` (add `"functions"` and `"storage"` keys), new `functions/` directory (Functions project scaffold), new `storage.rules`, `.firebaserc`, possibly a new iOS Firebase app registration affecting `ios/Runner/GoogleService-Info.plist` and `lib/firebase_options.dart`.

**Firestore collections:** None yet.

**Providers / Repositories / Models / Screens / Widgets:** None — this phase is infrastructure only, no Dart feature code.

**Tests:** Manual verification that `firebase deploy --only functions` succeeds with a placeholder function; manual verification that a test file can be uploaded to Storage from a throwaway script.

**Review checklist:**
- [ ] Confirmed with project owner: Blaze plan active
- [ ] Confirmed with project owner: iOS in/out of scope for launch
- [ ] `firebase.json` validates and deploys cleanly
- [ ] No existing feature's build or deploy broke

**Completion criteria:** `firebase deploy` succeeds for firestore, storage, and functions targets; app still builds and runs unchanged on all currently-supported platforms.

---

## Phase 1 — Shared Storage Capability

**Objective:** A generic, reusable file-upload capability in `shared/`, usable by Ride now and any future feature later.

**Scope:** Wrap Firebase Storage upload/download behind a small provider-based API; no Ride-specific logic here.

**Dependencies:** Phase 0.

**Files involved:** `lib/shared/providers/storage_providers.dart` (new `firebaseStorageProvider`), `lib/shared/services/storage_service.dart` (upload/get-url operations), `storage.rules` (owner-writes-own-path pattern, mirroring `firestore.rules`' `isOwner` convention).

**Firestore collections:** None.

**Providers:** `firebaseStorageProvider`, `storageServiceProvider`.

**Repositories:** None at this layer — this is infra, not a domain repository.

**Models:** None.

**Screens / Widgets:** None.

**Tests:** Unit test for path-building logic (e.g., `verification/{uid}/{filename}`); no widget tests needed (no UI yet).

**Review checklist:**
- [ ] No Ride-specific logic leaked into this shared file
- [ ] `storage.rules` reviewed for the same owner-only-write discipline as `firestore.rules`

**Completion criteria:** A throwaway test upload from an authenticated test account succeeds and is rejected for a non-owner path.

---

## Phase 2 — Shared Notification Capability (client-side only)

**Objective:** Generic FCM token registration and local notification display, usable by any current or future service — no Ride-specific triggers yet.

**Scope:** Token capture on login, token storage against the user's `uid`, permission request flow, foreground notification display.

**Dependencies:** Phase 0.

**Files involved:** `lib/shared/providers/notification_providers.dart`, `lib/shared/services/notification_service.dart`, a new top-level collection `fcm_tokens/{uid}` (or a `fcmToken` field merged onto whatever profile doc exists — decide during implementation, not here).

**Firestore collections:** `fcm_tokens/{uid}` (token, platform, updatedAt) — platform-level, not Ride-owned.

**Providers:** `notificationServiceProvider`, `fcmTokenSyncProvider` (wires token refresh to auth state changes).

**Repositories:** `NotificationTokenRepository` (shared, not under `hinam_ride/`).

**Models:** None Ride-specific.

**Screens / Widgets:** A permission-request prompt reusing existing dialog/snackbar conventions — no new screen.

**Tests:** Unit test for token-write-on-login logic (mocked FirebaseMessaging/Firestore).

**Review checklist:**
- [ ] Confirmed this lives in `shared/`, not inside `hinam_ride/`
- [ ] Token registration doesn't run for unauthenticated sessions

**Completion criteria:** Logging in on a test device produces a token document; logging out does not leave a stale, unrevoked token.

---

## Phase 3 — Ride Driver Profile

**Objective:** A ride driver can register a profile, independent of the bus-driver `drivers` collection.

**Scope:** Registration form, model, repository, datasource, provider — no verification gating, no online status, no location yet.

**Dependencies:** Phase 0 (for the pubspec/project state), none of Phases 1–2 strictly required yet.

**Files involved:** `lib/features/hinam_ride/driver/data/{models/ride_driver_model.dart, datasources/ride_driver_remote_datasource.dart, repositories/ride_driver_repository.dart}`, `lib/features/hinam_ride/driver/presentation/{providers/ride_driver_provider.dart, providers/ride_driver_profile_provider.dart, screens/ride_driver_registration_screen.dart, widgets/ride_driver_registration_form.dart}`.

**Firestore collections:** `ride_drivers/{uid}` — fullName, phoneNumber, gender, dateOfBirth, vehicleType, vehiclePlate, licenseNumber, verificationStatus (`pending`), isOnline (`false`), ratingAvg, totalRides, createdAt. Add a matching `firestore.rules` block: owner-create with `verificationStatus == 'pending'` enforced, mirroring the existing `drivers` rule exactly.

**Providers:** `rideDriverDatasourceProvider`, `rideDriverRepositoryProvider`, `rideDriverProfileProvider` (AsyncNotifier, mirrors `driverProfileProvider`).

**Repositories:** `RideDriverRepository` (create, get, update non-sensitive fields).

**Models:** `RideDriverModel` with a real `VerificationStatus` enum (per the approved deviation).

**Screens:** `RideDriverRegistrationScreen`.

**Widgets:** `RideDriverRegistrationForm` (or split into smaller field-group widgets, matching the existing `RegistrationFormCard` precedent).

**Tests:** Repository unit tests (create/get against a fake Firestore instance), rule test for `ride_drivers` create/update boundaries (using the Firestore emulator).

**Review checklist:**
- [ ] Confirmed no reuse of `shared/models/driver_model.dart`
- [ ] `verificationStatus` cannot be set to anything but `pending` on create, client-side or rule-side
- [ ] Naming matches existing convention exactly (`xRepositoryProvider`, etc.)

**Completion criteria:** A test user can create a `ride_drivers` doc, cannot self-approve, and the doc is retrievable via `rideDriverProfileProvider`.

---

## Phase 4 — Ride Passenger Profile

**Objective:** Mirror of Phase 3 for the passenger side.

**Scope:** Registration, model, repository, datasource, provider — including emergency-contact fields from day one (structurally needed for Phase 18, cheap to add now).

**Dependencies:** Phase 0.

**Files involved:** `lib/features/hinam_ride/passenger/data/{models/ride_passenger_model.dart, datasources/ride_passenger_remote_datasource.dart, repositories/ride_passenger_repository.dart}`, `lib/features/hinam_ride/passenger/presentation/{providers/ride_passenger_provider.dart, providers/ride_passenger_profile_provider.dart, screens/ride_passenger_registration_screen.dart, widgets/ride_passenger_registration_form.dart, widgets/emergency_contact_tile.dart}`.

**Firestore collections:** `ride_passengers/{uid}` — fullName, phoneNumber, gender, verificationStatus (`pending`), emergencyContacts (array of `{name, phone}`), ratingAvg, totalRides, createdAt. Matching rule block, same shape as `ride_drivers`.

**Providers:** `ridePassengerDatasourceProvider`, `ridePassengerRepositoryProvider`, `ridePassengerProfileProvider`.

**Repositories:** `RidePassengerRepository`.

**Models:** `RidePassengerModel`.

**Screens:** `RidePassengerRegistrationScreen`.

**Widgets:** `RidePassengerRegistrationForm`, `EmergencyContactTile` (add/remove a contact).

**Tests:** Repository unit tests; rule tests for the `ride_passengers` boundaries; widget test for adding/removing an emergency contact.

**Review checklist:**
- [ ] Same isolation check as Phase 3 (no shared-model reuse)
- [ ] Emergency contacts capped at a sane max (e.g. 3) client- and rule-side

**Completion criteria:** A test user can create a passenger profile with at least one emergency contact and retrieve it via the profile provider.

---

## Phase 5 — Shared Verification Submodule

**Objective:** One verification workflow, consumed by both Driver and Passenger — not duplicated.

**Scope:** Document submission (using Phase 1's storage service), verification-request model, repository, and the submission UI embedded into both driver and passenger onboarding.

**Dependencies:** Phase 1 (storage), Phase 3 and 4 (profiles to attach verification status to).

**Files involved:** `lib/features/hinam_ride/verification/data/{models/verification_request_model.dart, datasources/ride_verification_remote_datasource.dart, repositories/ride_verification_repository.dart}`, `lib/features/hinam_ride/verification/presentation/{providers/ride_verification_provider.dart, widgets/document_upload_tile.dart, widgets/verification_status_banner.dart}`.

**Firestore collections:** `ride_verifications/{requestId}` — subjectType (`driver`/`passenger` enum), subjectId, documentUrls (map), status (`pending`/`approved`/`rejected` enum), reviewedBy, reviewedAt, rejectionReason, createdAt. Rule block: create restricted to `subjectId == request.auth.uid`; status mutation restricted to `isAdmin()`.

**Providers:** `rideVerificationRepositoryProvider`, `submitVerificationControllerProvider` (AsyncNotifier).

**Repositories:** `RideVerificationRepository` (submit, watch-by-subject).

**Models:** `VerificationRequestModel`.

**Screens:** None new — this is embedded as a step inside the existing registration screens from Phases 3/4.

**Widgets:** `DocumentUploadTile`, `VerificationStatusBanner` (shown on driver/passenger dashboards while pending/rejected).

**Tests:** Repository test for submit + resubmission-preserves-history behavior; rule test confirming a non-admin cannot flip `status`.

**Review checklist:**
- [ ] Resubmission creates a new document, does not overwrite the rejected one
- [ ] Denormalization write (verification result → profile's `verificationStatus`) is a single batched write, not two separate writes that could drift

**Completion criteria:** A driver and a passenger can each submit documents through the same underlying repository, and a manually-approved verification (via emulator/console) correctly denormalizes onto the corresponding profile doc.

---

## Phase 6 — Admin Verification Review

**Objective:** Admins can review and act on pending verification requests — the first slice of the Ride-specific admin submodule.

**Scope:** A pending-verification queue and approve/reject actions, deliberately kept out of the existing global `AdminRepository`.

**Dependencies:** Phase 5.

**Files involved:** `lib/features/hinam_ride/administration/data/repositories/ride_admin_repository.dart`, `lib/features/hinam_ride/administration/presentation/{providers/ride_admin_providers.dart, screens/ride_verification_queue_screen.dart, widgets/verification_review_card.dart}`.

**Firestore collections:** Reads `ride_verifications` (status == pending), writes approve/reject as designed in Phase 5.

**Providers:** `rideAdminRepositoryProvider`, `pendingRideVerificationsProvider` (StreamProvider).

**Repositories:** `RideAdminRepository` (gated by the existing `adminRepositoryProvider.isAdmin()` check — reused, not reimplemented).

**Models:** Reuses `VerificationRequestModel`.

**Screens:** `RideVerificationQueueScreen`.

**Widgets:** `VerificationReviewCard` (mirrors `DriverApprovalCard`'s confirm-reject dialog pattern).

**Tests:** Repository test for approve/reject; rule test confirming a non-admin uid cannot call these paths even if they guess the client method.

**Review checklist:**
- [ ] Confirmed zero new methods added to the existing `AdminRepository`
- [ ] Reuses the existing `isAdmin()` gate rather than reimplementing an admin check

**Completion criteria:** An admin test account can approve/reject a submitted verification from this screen, and a non-admin account is rejected by rules if it attempts the same write directly.

---

## Phase 7 — Splash & Routing Integration

**Objective:** Wire Ride into app entry points, executing the decision made in the architecture review (Conflict D).

**Scope:** Extend `splash_screen.dart`'s role resolution per the chosen option (explicit priority check, or defer-to-choice-screen — whichever was decided), add new route constants, add new `ChoiceButton` entries.

**Dependencies:** Phases 3–4 (profiles must exist to check against).

**Files involved:** `lib/features/auth/presentation/screens/splash_screen.dart` (modified — flagged explicitly since this is shared code), `lib/core/routes/app_routes.dart`, `lib/core/routes/app_router.dart` (both modified, additive).

**Firestore collections:** Reads `ride_drivers/{uid}` and `ride_passengers/{uid}` existence during splash resolution.

**Providers:** None new — reuses `authControllerProvider`, `rideDriverProfileProvider`, `ridePassengerProfileProvider`.

**Repositories:** None new.

**Models:** None new.

**Screens:** No new screens; modifies `SplashScreen`'s behavior only.

**Widgets:** Two new `ChoiceButton` entries ("Drive with Hinam Ride," "Book a Hinam Ride") on the existing choice list.

**Tests:** Widget/integration test covering every existing role-resolution path (admin, bus driver, no profile) to confirm none regressed, plus the two new Ride paths.

**Review checklist:**
- [ ] Every existing splash-screen path re-tested, not just the new one
- [ ] Priority order is explicit and centralized in one place, not scattered

**Completion criteria:** All five entry paths (admin, bus driver, ride driver, ride passenger, brand-new user) resolve to the correct destination on relaunch, verified manually and by test.

---

## Phase 8 — Driver Online/Offline & Location Tracking

**Objective:** An approved ride driver can go online and broadcast location, reusing the existing `LocationService`.

**Scope:** Online/offline toggle gated on `verificationStatus == approved`; location streaming into a new collection, isolated from `bus_locations`.

**Dependencies:** Phase 5 (verification must be approvable), Phase 3.

**Files involved:** `lib/features/hinam_ride/driver/data/{models/ride_location_model.dart, datasources/ride_location_remote_datasource.dart, repositories/ride_tracking_repository.dart}`, `lib/features/hinam_ride/driver/presentation/{providers/ride_online_status_provider.dart, providers/ride_tracking_provider.dart, widgets/ride_online_toggle.dart}`.

**Firestore collections:** `ride_locations/{driverId}` — latitude, longitude, speed, isOnline, updatedAt. Rule block: owner-write gated on `ride_drivers/{uid}.verificationStatus == 'approved'`, read restricted (not public, per the deliberate departure from `bus_locations`' public-read pattern).

**Providers:** `rideTrackingRepositoryProvider`, `rideOnlineStatusProvider` (Notifier, gates on approval), `rideTrackingProvider` (Notifier wrapping a stream subscription — same shape as `TrackingNotifier`).

**Repositories:** `RideTrackingRepository`.

**Models:** `RideLocationModel`.

**Screens:** None new — toggle embedded in the driver dashboard (built out further in Phase 13).

**Widgets:** `RideOnlineToggle`.

**Tests:** Rule test confirming an unapproved driver cannot write to `ride_locations`; repository test for start/stop tracking.

**Review checklist:**
- [ ] Confirmed `ride_locations` read rule is NOT `allow read: if true` (unlike `bus_locations`)
- [ ] Confirmed reuse of `LocationService` with zero modification

**Completion criteria:** An approved driver can go online and see their location document update in real time; an unapproved driver's write attempt is rejected server-side.

---

## Phase 9 — Trip Request Creation

**Objective:** A passenger can create a ride request; no matching yet.

**Scope:** Pickup/drop-off selection, suggested-fare display (static calculation, no negotiation), request creation, and cancel-before-match.

**Dependencies:** Phase 4 (passenger must be verified — decide whether verification is required before requesting or only before boarding; document the decision here during implementation).

**Files involved:** `lib/features/hinam_ride/trip/data/{models/ride_model.dart, datasources/ride_trip_remote_datasource.dart, repositories/ride_trip_repository.dart}`, `lib/features/hinam_ride/trip/presentation/{providers/active_ride_provider.dart, providers/ride_request_controller.dart, screens/ride_request_screen.dart, widgets/pickup_dropoff_picker.dart}`, `lib/features/hinam_ride/pricing/presentation/{providers/suggested_fare_provider.dart}` (pure calculation, no Firestore access, per the repository-boundary decision).

**Firestore collections:** `rides/{rideId}` — passengerId, driverId (null), pickup, dropoff, status (`requested` enum), suggestedFare, agreedFare (null), timestamps. Rule block: passenger-owned create, `driverId` must be null on create.

**Providers:** `rideTripRepositoryProvider`, `activeRideProvider` (StreamProvider, passenger's current in-flight ride), `rideRequestController` (AsyncNotifier for the create action), `suggestedFareProvider` (pure function, Pricing submodule).

**Repositories:** `RideTripRepository` (create, cancel-before-match, watch).

**Models:** `RideModel` with `RideStatus` enum.

**Screens:** `RideRequestScreen`.

**Widgets:** `PickupDropoffPicker` (map-based, reusing `flutter_map` the same way `single_bus_map_screen.dart` does).

**Tests:** Repository test for create/cancel; rule test confirming `driverId` can't be set on create.

**Review checklist:**
- [ ] Confirmed "one active request per passenger" is enforced (client check now; rule-level enforcement considered but may require a Function — note as a known gap if deferred)
- [ ] Suggested-fare calculation has zero Firestore/network dependency

**Completion criteria:** A passenger can create and cancel a request before any driver is involved; the request is visible via `activeRideProvider`.

---

## Phase 10 — Matching Service & Sequential Offer Creation

**Objective:** The nearest available, verified, online driver receives an offer for a requested ride.

**Scope:** Query `ride_locations`/`ride_drivers` for eligible candidates, create the first offer, implement the escalate-to-next-driver-on-timeout logic client-side for now (server-side enforcement of the timeout arrives in Phase 11/12 alongside the Function work).

**Dependencies:** Phase 8 (driver location/online status), Phase 9 (ride requests).

**Files involved:** `lib/features/hinam_ride/trip/presentation/providers/matching_service_provider.dart` (the "matching" logic — lives inside `trip/`, not its own top-level folder, per the approved design), `lib/features/hinam_ride/trip/data/models/ride_offer_model.dart`, extends `ride_trip_remote_datasource.dart` to read/write the `offers` subcollection.

**Firestore collections:** `rides/{rideId}/offers/{offerId}` — the app's first subcollection — driverId, offerAmount, status (`pending`/`accepted`/`declined`/`expired` enum), createdAt. New rule block nested under the `rides/{rideId}` match — written and tested in isolation per the architecture review's sequencing note.

**Providers:** `matchingServiceProvider`, `rideOffersProvider` (StreamProvider.family<rideId>).

**Repositories:** Extends `RideTripRepository` (no new repository — offers are part of the ride aggregate, per the approved boundary decision).

**Models:** `RideOfferModel`.

**Screens:** None new yet — surfaced in Phase 11's driver-facing offer screen.

**Widgets:** None yet.

**Tests:** Unit test for nearest-candidate selection logic (mocked location data); rule test for the new subcollection's isolated `match` block.

**Review checklist:**
- [ ] Confirmed no `collectionGroup` index was speculatively added (none needed per the approved design)
- [ ] Confirmed the subcollection rule block was tested independently before touching the parent `rides` rules

**Completion criteria:** Creating a ride request produces exactly one offer to the nearest eligible driver; if that driver doesn't respond within the timeout, the next-nearest receives one (verified manually with two test driver accounts).

---

## Phase 11 — Offer Accept/Decline/Counter + Negotiation Cloud Function

**Objective:** Make the accept path race-safe — the first Cloud Function with real business logic.

**Scope:** Driver-facing accept/decline/counter UI; passenger-facing accept/decline-counter UI; a Cloud Function that atomically arbitrates offer acceptance and fare-bound enforcement, replacing any client-only accept logic from Phase 10.

**Dependencies:** Phase 0 (Functions pipeline proven), Phase 10.

**Files involved:** `functions/` (new `onOfferAccept` or equivalent trigger/callable), `lib/features/hinam_ride/pricing/presentation/{providers/negotiation_controller.dart, widgets/offer_card.dart, widgets/counter_offer_dialog.dart}`, `lib/features/hinam_ride/trip/presentation/screens/incoming_request_screen.dart` (driver side).

**Firestore collections:** Writes to `rides` (status → `matched`, `agreedFare` set) and `offers` (status transitions) — now performed via the Function rather than a direct client write for the accept step specifically; declines/counters can remain direct client writes with rule-level bound checks.

**Providers:** `negotiationController` (AsyncNotifier calling the callable Function or watching the Function's Firestore write).

**Repositories:** No new repository — `RideTripRepository` gains methods that call the Function instead of writing directly for the accept path.

**Models:** No changes.

**Screens:** `IncomingRequestScreen` (driver).

**Widgets:** `OfferCard`, `CounterOfferDialog` (numeric-only input, no free text, per the approved negotiation design).

**Tests:** Cloud Functions unit test simulating two concurrent accepts, confirming only one wins; widget test for the counter-offer numeric bound.

**Review checklist:**
- [ ] Confirmed counter-offers are numeric-only, no free-text field exists anywhere in this UI
- [ ] Confirmed the double-accept race was actually tested (emulator, concurrent calls), not just assumed fixed

**Completion criteria:** Two test driver accounts attempting to accept the same offer simultaneously result in exactly one `matched` ride and one rejected attempt with a clear error, verified against the Functions emulator.

> **Implementation note (as actually built):** During implementation, the plan to use a Cloud Function was reconsidered and replaced with a pure Flutter/Dart solution: a race-safe `acceptOffer` implemented as two sequential, rule-gated Firestore writes from `RideTripRemoteDatasource` (ride update first, then the offer update, with the offer's security rule cross-checking the ride's already-committed state). This preserves the same atomicity/race-safety guarantee without introducing Cloud Functions, TypeScript, or any backend outside the existing Flutter/Firebase-client architecture. See the Phase 11 implementation report for the full reasoning.

---

## Phase 12 — Notification Delivery Triggers

**Objective:** Real push delivery for the events that actually need it, using Phase 2's client registration and Phase 0's Functions pipeline.

**Scope:** Firestore-triggered Functions: new offer → notify driver; ride status change → notify the counterpart; keep the trigger list minimal — only the events already defined in the product spec.

**Dependencies:** Phase 2, Phase 11 (proven Functions deploy + a real event source).

**Files involved:** `functions/` (new `onOfferCreated`, `onRideStatusChanged` triggers), no new Flutter files beyond consuming the existing `notification_service.dart` from Phase 2.

**Firestore collections:** No schema changes — reads `offers`/`rides` writes, uses `fcm_tokens`.

**Providers:** None new on the client beyond what Phase 2 already built.

**Repositories:** None new.

**Models:** None new.

**Screens / Widgets:** None new.

**Tests:** Functions test asserting the correct token is targeted for a given ride's driver/passenger.

**Review checklist:**
- [ ] Confirmed the trigger list matches exactly what the product spec defined — no speculative extra notifications added
- [ ] Confirmed a backgrounded test device actually receives the push (not just a foreground in-app banner)

**Completion criteria:** Creating an offer on one test device produces a real push notification on a second, backgrounded test device.

> **Implementation note:** The open question above was resolved in favor of building the Cloud Functions scaffold: this phase's completion criteria (a backgrounded device receiving a real push) has no client-only equivalent, and the project's Technology Lock was explicitly carved out for this exact case. `functions/` did not previously exist (it was removed during the Phase 11 correction), so this was a fresh scaffold rather than a reuse of prior work. The **Dependencies** line above is therefore slightly inaccurate as originally written — Phase 11 ended up implemented without Cloud Functions (see its own implementation note), so Phase 12 is actually the first phase with a proven Functions deploy, not a consumer of one from Phase 11.

---

## Phase 13 — Trip Lifecycle Screens

**Objective:** Full driver and passenger UI for `matched → arrived → in_progress → completed`.

**Scope:** Live map tracking during the trip (reusing `flutter_map`/`LocationService`), status-transition buttons, driver/passenger identity display before boarding.

**Dependencies:** Phase 11.

**Files involved:** `lib/features/hinam_ride/trip/presentation/{screens/ride_tracking_screen.dart, screens/ride_driver_trip_screen.dart, widgets/trip_status_bar.dart, widgets/driver_identity_card.dart, widgets/passenger_identity_card.dart}`.

**Firestore collections:** Writes to `rides.status` per the forward-only transition rule already scoped in the architecture (§15 of the design).

**Providers:** `rideTripStatusController` (AsyncNotifier for status transitions).

**Repositories:** Extends `RideTripRepository` with `markArrived`/`startTrip`/`completeTrip`.

**Models:** No changes.

**Screens:** `RideTrackingScreen` (passenger), `RideDriverTripScreen` (driver).

**Widgets:** `TripStatusBar`, `DriverIdentityCard`, `PassengerIdentityCard`.

**Tests:** Rule test confirming status can't skip states or be written by a non-participant; widget test for the identity cards rendering correctly.

**Review checklist:**
- [ ] Confirmed forward-only transition is enforced server-side, not just in UI
- [ ] Confirmed only the assigned `driverId`/`passengerId` can write to their respective allowed transitions

**Completion criteria:** A full trip can be driven end-to-end between two test accounts from `matched` to `completed`, with an illegal transition (e.g. skipping `arrived`) rejected by rules.

> **Implementation note:** Live map tracking was implemented as: pickup/dropoff markers (static, from the ride) on both screens, plus the *driver's own* live position on their own screen — sourced by re-watching Phase 8's existing `rideTrackingProvider` (zero new location-stream code), not a new Firestore read. The passenger's screen does **not** show the driver's live position cross-user; doing so would require extending Phase 8's `ride_locations` read rule (currently owner/admin-only) with a denormalized pointer, which this phase's own "Firestore collections" line (writes to `rides.status` only) did not authorize and which the completion criteria does not test. This was a deliberate scope decision to avoid touching a completed phase's schema/rules beyond what was strictly required. `firestore.rules`' `rides` update block gained three new driver-only, forward-only transition clauses (`matched→arrived`, `arrived→inProgress`, `inProgress→completed`), each locking every field except `status` — verified against the Firestore emulator's actual rules engine where the sandbox's JDK version allowed it, and by direct compilation checks otherwise. `RideDriverTripScreen` and `RideRequestScreen`/`OfferCard` were extended (additively) so the two new screens are actually reachable from the existing accept/request flows, since PHASES.md's file list did not itemize this integration wiring but it is required for the screens not to be dead code.

---

## Phase 14 — Cancellation & No-Show Handling

**Objective:** Implement the cancellation rules from the product spec as first-class ride outcomes.

**Scope:** Passenger/driver cancel actions at each stage, the arrival grace-period timer, `no_show` as a distinct outcome from `cancelled`.

**Dependencies:** Phase 13.

**Files involved:** `lib/features/hinam_ride/trip/presentation/{providers/cancellation_controller.dart, widgets/cancel_ride_dialog.dart, widgets/no_show_banner.dart}`.

**Firestore collections:** `rides.status → cancelled` (with `cancelledBy`, `cancelReason`) or `→ no_show`; no new collections.

**Providers:** `cancellationController` (AsyncNotifier).

**Repositories:** Extends `RideTripRepository` with `cancel`/`markNoShow`.

**Models:** No changes.

**Screens:** None new.

**Widgets:** `CancelRideDialog` (mandatory reason field for mid-trip cancels, per the product spec), `NoShowBanner`.

**Tests:** Repository test distinguishing `cancelled` vs `no_show` outcomes; rule test confirming a mid-trip cancel requires a reason.

**Review checklist:**
- [ ] Confirmed mid-trip cancellation surfaces to the admin incidents/reports pipeline as flagged in the product spec, not treated as routine
- [ ] Confirmed no monetary cancellation fee logic was added (product spec explicitly rejected this at launch — trust-score only)

**Completion criteria:** Each cancellation scenario from the product spec (pre-match, post-match, post-arrival grace period, mid-trip) produces the correct distinct outcome and metadata.

> **Implementation note:** `RideTripRepository` kept the existing `cancelRide` method name (extended with `cancelledBy`/`cancelReason` parameters) rather than introducing a separate `cancel` method — Phase 9 already established `cancelRide` for the pre-match path, and adding a second, same-purpose method would have been duplicate logic. `markNoShow` was added as named. The `RideStatus` enum and `RideModel` (`arrivedAt`, `cancelledBy`, `cancelReason`) were extended despite this section's "Models: No changes" line, for the same reason Phase 13's status values required it — the Firestore-collections line above only makes sense with these fields actually present on the model. The first review-checklist item ("mid-trip cancellation surfaces to the admin incidents/reports pipeline") could not be satisfied: that pipeline doesn't exist yet (it's Phase 17/18), so this remains a known, deliberate gap until those phases are implemented — `cancelReason` is captured and displayed to the counterpart now, ready for that pipeline to consume later. The second checklist item is confirmed: no fee logic of any kind was added. The rule enforcing the arrival grace period (`request.time > resource.data.arrivedAt + duration.value(5, 'm')`) was verified by careful manual trace and successful rules compilation; a live emulator test (as done manually for prior phases) was blocked by the sandbox's JDK 17 (the Firestore emulator requires 21+, and passwordless sudo is unavailable) — the same limitation encountered in Phase 13, reported honestly rather than worked around.

---

## Phase 15 — Ratings & Ride History

**Objective:** Post-trip rating capture and historical trip listing.

**Scope:** Rating UI on completion, fields written directly to the `rides` document (no separate collection, per the approved design), history screens for both roles.

**Dependencies:** Phase 13.

**Files involved:** `lib/features/hinam_ride/trip/presentation/{screens/ride_history_screen.dart, widgets/rating_prompt.dart, widgets/ride_history_tile.dart, providers/ride_history_provider.dart}`.

**Firestore collections:** Adds `passengerRating`, `passengerRatingComment`, `driverRating`, `driverRatingComment` fields to `rides` — no new collection. New composite index: `rides` by `passengerId + createdAt` and `driverId + createdAt`.

**Providers:** `rideHistoryProvider` (StreamProvider.family<uid>).

**Repositories:** Extends `RideTripRepository` with `submitRating`.

**Models:** No changes (fields added to `RideModel`).

**Screens:** `RideHistoryScreen`.

**Widgets:** `RatingPrompt`, `RideHistoryTile`.

**Tests:** Rule test confirming only the actual participant can submit their side of the rating, and only once.

**Review checklist:**
- [ ] Confirmed a rating can't be resubmitted/overwritten after the first submission
- [ ] Confirmed the two new composite indexes are added to `firestore.indexes.json` before this phase's queries ship

**Completion criteria:** Both parties can rate a completed trip exactly once, and each can see their own ride history sorted by date.

> **Implementation note:** `driverRating`/`driverRatingComment` hold the rating the driver *received* (submitted by the passenger); `passengerRating`/`passengerRatingComment` mirror this for the driver rating the passenger — standard ride-hailing naming (the field names the party being scored, not the scorer). No separate "rating controller" name was given in this section's own Providers line, but one was required to keep every write going through `Provider → Repository`, never directly from a widget — `ratingControllerProvider` was added for this, mirroring `cancellationControllerProvider`'s shape from Phase 14. `rideHistoryProvider`'s family key is the record `({String uid, bool isDriver})` rather than a bare uid, following the same record-as-family-key pattern already established by `suggestedFareProvider` (Phase 9) — a bare uid can't say which of the two composite indexes/fields to query. A "Ride History" entry point (an AppBar icon) was added to `RideRequestScreen` and `IncomingRequestScreen` and a route registered, since `RideHistoryScreen` would otherwise be unreachable — neither screen currently has a dashboard wiring them in from anywhere, a pre-existing gap from Phases 9/11 left untouched. Both review-checklist items are satisfied: the rule's `resource.data.driverRating == null` / `passengerRating == null` guard makes resubmission structurally impossible (a second attempt sees a non-null value and no clause matches), and the two named composite indexes were added to `firestore.indexes.json` before `watchRideHistory` was written. Verification used a temporary `fake_cloud_firestore` test (submitRating writes the correct pair of fields per role, watchRideHistory filters correctly by each role, full model round-trip) — passed and removed; the rating rule clauses were confirmed via successful `firebase deploy --dry-run` compilation and manual trace, with live emulator testing still blocked by the sandbox's JDK 17 (same limitation as Phases 13–14).

---

## Phase 16 — Payments (Cash)

**Objective:** Record how a completed ride was settled, structured for a future payment-gateway addition without a schema migration.

**Scope:** Mark-as-paid flow at trip completion, `method` field always present (only `cash` valid at launch).

**Dependencies:** Phase 13.

**Files involved:** `lib/features/hinam_ride/payments/data/{models/ride_transaction_model.dart, datasources/ride_payment_remote_datasource.dart, repositories/ride_payment_repository.dart}`, `lib/features/hinam_ride/payments/presentation/{providers/ride_payment_provider.dart, widgets/mark_paid_button.dart}`.

**Firestore collections:** `ride_transactions/{transactionId}` — rideId, payerId, payeeId, amount, method (`cash` enum with room for future values), status, createdAt. Rule block: writable only by the ride's two participants, referencing the ride's `agreedFare`.

**Providers:** `ridePaymentRepositoryProvider`, `ridePaymentController`.

**Repositories:** `RidePaymentRepository`.

**Models:** `RideTransactionModel`.

**Screens:** None new — embedded in the trip-completion flow.

**Widgets:** `MarkPaidButton`.

**Tests:** Rule test confirming the transaction amount can't diverge from the ride's `agreedFare`.

**Review checklist:**
- [ ] Confirmed no payment-gateway SDK was added speculatively — `method` is just a field, not an integration
- [ ] Confirmed this repository is genuinely isolated (no cross-import from `payments/` into other submodules beyond a `rideId` reference)

**Completion criteria:** Every completed trip in the test set has exactly one corresponding `ride_transactions` document with `method: cash`.

> **Implementation note:** `ride_transactions` is keyed by the ride's own id (`ride_transactions/{rideId}`) rather than a separately generated `transactionId`. This makes "exactly one transaction per ride" a structural rule guarantee — a first write hits the `create` rule, and any later attempt at the same path is a Firestore *update*, which the rules deny outright — rather than an invariant only a query or Cloud Function could otherwise enforce. Both review-checklist items are confirmed: no payment SDK of any kind was added (`method` is validated as the literal string `'cash'`, nothing else); and `payments/` has zero imports from `trip/`, `driver/`, or `passenger/` — verified by grep — taking only a plain `rideId`/`payerId`/`payeeId`/`amount` from its caller (`TripEndedView`, Phase 13/14/15), never a `RideModel`. The rule cross-checks `amount == rides/{rideId}.agreedFare` and requires `rides/{rideId}.status == 'completed'` before a transaction can be created at all. Verified with a temporary `fake_cloud_firestore` test (4 cases: write shape, null-before-paid, reflects-after-paid, model round-trip) — passed and removed; the rule was confirmed via successful `firebase deploy --dry-run` compilation and manual trace, with live emulator testing still blocked by the sandbox's JDK 17 (same limitation reported honestly in Phases 13–15).

---

## Phase 17 — Reports

**Objective:** Either party can report an issue tied to a specific ride; admins can review it.

**Scope:** Report-filing UI (during and after a trip, per the product spec), an admin reports queue.

**Dependencies:** Phase 13, Phase 6 (extends the Ride admin shell).

**Files involved:** `lib/features/hinam_ride/administration/data/{models/ride_report_model.dart, datasources/ride_report_remote_datasource.dart, repositories/ride_report_repository.dart}`, `lib/features/hinam_ride/administration/presentation/{screens/ride_reports_queue_screen.dart, widgets/report_form_dialog.dart, widgets/report_review_card.dart}`.

**Firestore collections:** `ride_reports/{reportId}` — rideId, reportedBy, reportedUserId, reason, details, status (`open`/`reviewed`/`resolved` enum), createdAt, reviewedBy. Rule block: creatable by either ride participant, readable by the reporter, the reported party (their own report about them — decide read scope carefully), and admins only.

**Providers:** `rideReportRepositoryProvider`, `openReportsProvider` (StreamProvider, kept separate from the incidents provider per the approved design).

**Repositories:** `RideReportRepository`.

**Models:** `RideReportModel`.

**Screens:** `RideReportsQueueScreen` (admin).

**Widgets:** `ReportFormDialog`, `ReportReviewCard`.

**Tests:** Rule test confirming a report is not publicly readable.

**Review checklist:**
- [ ] Confirmed reports are reachable mid-trip, not just post-completion, per the product spec
- [ ] Confirmed this provider is structurally separate from `openIncidentsProvider` (Phase 18), not merged

**Completion criteria:** A test account can file a report during an active trip; an admin account can see and resolve it; a third-party test account cannot read it.

> **Implementation note:** `reportedUserId` is derived by the security rule itself (whichever of the ride's `passengerId`/`driverId` isn't the caller), never taken from client input — a report can't be filed against an unrelated third party. `openReportsProvider` queries `status whereIn ['open', 'reviewed']`, not literally `== 'open'`: with the three-state lifecycle PHASES.md itself defines (open/reviewed/resolved), a strictly-`open` query would make a reviewed report vanish from the admin queue before it could ever be resolved — caught and fixed during this phase's own review, not a bug the user reported. `RideReportsQueueScreen`/`ReportReviewCard` follow the Theme.of(context) styling already established by Phase 6's `RideVerificationQueueScreen`/`VerificationReviewCard` (the closer sibling precedent), while `ReportFormDialog` follows the `AppColors` convention used by the trip screens it's actually shown from (`RideTrackingScreen`, `RideDriverTripScreen`, `TripEndedView`) — each widget matches the convention of wherever it visually lives. Per the same precedent as Phase 6, `RideReportsQueueScreen` is not wired into any admin route yet — Phase 19 ("Ride Administration Dashboard Consolidation") is explicitly where the verification/reports/incidents queues get a shared entry point, so adding one here would be starting that phase's work early. Both review-checklist items are confirmed: reports are filable from the two active-trip screens *and* from the post-trip screen (not merged into one path), and `openReportsProvider` lives in its own `ride_report_providers.dart`, structurally separate from any future incidents provider. Verified with a temporary `fake_cloud_firestore` test (write shape, open+reviewed visibility, status transition, model round-trip); the rule was confirmed via successful `firebase deploy --dry-run` compilation and manual trace, with live emulator testing still blocked by the sandbox's JDK 17 (same limitation as Phases 13–16).

---

## Phase 18 — SOS / Emergency Incidents

**Objective:** The concrete, mechanism-level safety feature defined in the product spec — not a slogan.

**Scope:** SOS button on every active-trip screen, trip-details + location sharing to emergency contacts, urgent admin incidents queue with real push delivery, offline SMS fallback.

**Dependencies:** Phase 12 (push infra), Phase 4 (emergency contacts), Phase 13 (active-trip screens to attach the button to).

**Files involved:** `lib/features/hinam_ride/trip/presentation/widgets/sos_button.dart`, `lib/features/hinam_ride/administration/data/{models/ride_incident_model.dart, datasources/ride_incident_remote_datasource.dart, repositories/ride_incident_repository.dart}`, `lib/features/hinam_ride/administration/presentation/{screens/ride_incidents_queue_screen.dart, widgets/incident_card.dart}`, `functions/` (new `onIncidentCreated` — urgent push, structurally distinct channel from Phase 12's routine triggers), plus device-native SMS-intent integration for the offline fallback.

**Firestore collections:** `ride_incidents/{incidentId}` — triggeredBy, rideId, location, status (`open`/`acknowledged`/`resolved` enum), createdAt, acknowledgedBy. Rule block: creatable by the ride's participants, readable only by the triggering user and admins.

**Providers:** `rideIncidentRepositoryProvider`, `openIncidentsProvider` (StreamProvider, distinct priority/UI treatment from `pendingRideVerificationsProvider` and `openReportsProvider`).

**Repositories:** `RideIncidentRepository`.

**Models:** `RideIncidentModel`.

**Screens:** `RideIncidentsQueueScreen` (admin, visually distinct urgency treatment).

**Widgets:** `SosButton`, `IncidentCard`.

**Tests:** Functions test confirming an incident push is sent through a distinct, higher-priority channel than a routine notification; manual test of the offline SMS fallback with device networking disabled.

**Review checklist:**
- [ ] Confirmed the admin incidents queue is visually and functionally distinct from the routine verification-badge pattern — this was an explicit, non-negotiable product requirement
- [ ] Confirmed the offline SMS fallback was actually tested with the device offline, not just assumed to work

**Completion criteria:** Triggering SOS on a test device with networking disabled still results in an SMS reaching a test emergency contact; with networking enabled, an admin test account receives a push distinctly flagged as urgent.

> **Implementation note:** Emergency contacts exist only on `RidePassengerModel` (Phase 4) — `RideDriverModel` has no such field. `SosButton` accepts `emergencyContacts` as a plain parameter rather than looking anything up itself: the passenger's screen supplies its own contacts (via the existing `ridePassengerByIdProvider`), the driver's screen supplies an empty list. Both roles still get the Firestore incident + urgent admin push either way; only the SMS-to-contacts channel is passenger-only, which is a real, disclosed data-model boundary, not an oversight. `functions/` gained `onIncidentCreated` (the Technology Lock's standing Cloud-Functions carve-out applies here exactly as it did in Phase 12, since this phase's own text explicitly requires it) — it queries `admins/` for every admin uid and sends through a separate `notifyUrgent` path (high Android/APNS priority, distinct 🚨-prefixed content) rather than reusing Phase 12's `notifyUser`, keeping the channel structurally separate as required. `url_launcher` was added as a genuine, permanent dependency (not a temporary test dependency) for the native `sms:` intent — the standard, permission-free way to reach the OS SMS composer. During review, `rideParticipantNameProvider` was extracted out of Phase 17's `ride_report_providers.dart` into its own file: the uid→name lookup it already had was generic (checks driver then passenger), not report-specific, and reusing it for `IncidentCard` rather than duplicating it required only a rename plus one import-line update in `report_review_card.dart` — the smallest change that avoided a second copy of the same lookup. Both review-checklist items are addressed: `IncidentCard`/`RideIncidentsQueueScreen` use a deliberately alarm-styled red treatment (solid header, no pastel badges) unmistakably distinct from `VerificationReviewCard`/`ReportReviewCard`; the SMS fallback's URI-construction logic was verified with a temporary unit test (multi-contact joining, query-param encoding, Maps-link embedding), but the actual cross-app launch on a real device with networking disabled could not be exercised in this sandbox — reported honestly rather than assumed to work, the same limitation disclosed for the Firestore emulator in Phases 13–17.

---

## Phase 19 — Ride Administration Dashboard Consolidation

**Objective:** Bring the verification, reports, and incidents queues (Phases 6, 17, 18) together into one Ride admin entry point, linked from the existing `AdminDashboardScreen` without merging into it.

**Scope:** A `RideAdminHomeScreen` linking to the three queues, plus a summary tile added to the existing admin dashboard.

**Dependencies:** Phases 6, 17, 18.

**Files involved:** `lib/features/hinam_ride/administration/presentation/screens/ride_admin_home_screen.dart`, `lib/features/admin/presentation/screens/admin_dashboard_screen.dart` (one additive link added — the only touch to existing admin code in the whole roadmap), `lib/core/routes/app_routes.dart` / `app_router.dart` (additive).

**Firestore collections:** No new collections — this phase is purely UI composition over Phases 6/17/18's data.

**Providers:** No new providers — composes the existing three queue providers.

**Repositories:** No new repositories.

**Models:** No changes.

**Screens:** `RideAdminHomeScreen`.

**Widgets:** A summary/link tile on the existing admin dashboard, styled consistently with `QuickActionTile`.

**Tests:** Widget test confirming the incidents count/badge is visually distinct from the verification/report counts.

**Review checklist:**
- [ ] Confirmed the one touch to `admin_dashboard_screen.dart` is additive only (a new tile), not a restructuring of the existing screen
- [ ] Confirmed incident urgency is visually obvious from the main admin dashboard, not buried a click away

**Completion criteria:** An admin can reach all three Ride queues from the existing dashboard, and an open incident is visually unmistakable from the dashboard's first screen.

> **Implementation note:** `RideAdminHomeScreen` composes the three existing queue providers (`pendingRideVerificationsProvider`, `openReportsProvider`, `openIncidentsProvider`) directly and reuses the existing `QuickActionTile` for each of its three links, rather than introducing a new list-tile widget. `QuickActionTile` gained one optional, backward-compatible parameter — `badgeColor` (defaults to its existing orange) — so the incidents link could render its badge in `AppColors.error` without duplicating the widget; its two pre-existing call sites (Pending Approvals, Fleet Management) are unaffected.
>
> The one touch to `admin_dashboard_screen.dart` is a single additive tile plus three `ref.watch` calls on the same pre-existing providers — no existing widget, provider, or layout was restructured. Because the review checklist requires incident urgency to be "visually obvious... not buried a click away," a plain reused `QuickActionTile` (single badge) wasn't enough: it can only show one number, and summing incidents into the routine pending count would hide them. So this one tile is a small private `_RideAdminSummaryTile` (kept in `admin_dashboard_screen.dart`, mirroring the file's existing `_StatCard` pattern rather than a new shared widget file, since Phase 19's own file list names only the screen and the dashboard) that renders two independently colored badges — `AppColors.warning` for the combined verification+report backlog, `AppColors.error` (plus an alarm icon and a thicker red tile border) for open incidents — so the two are never visually conflated. The temporary widget test asserted these two badge colors are distinct before being removed per the test-file policy.
>
> New routes (`rideAdminHome`, `rideVerificationQueue`, `rideReportsQueue`, `rideIncidentsQueue`) are additive only; `RideVerificationQueueScreen` (Phase 6), `RideReportsQueueScreen` (Phase 17), and `RideIncidentsQueueScreen` (Phase 18) required no internal changes — they were simply unwired screens waiting for this phase's entry point, exactly as those phases' own implementation notes anticipated.

---

## Phase 20 — Theme & Design Consistency Pass

**Objective:** Ride's UI reads as part of Hinam, not a bolted-on module.

**Scope:** Add Ride-specific `AppColors` tokens following the exact existing naming convention (e.g., a ride accent color, mirroring how `schoolGreen`/`stopOrange` were added); audit every screen/widget built in Phases 3–19 against the existing `AppTheme`.

**Dependencies:** All prior UI phases (3–19) should exist to audit against.

**Files involved:** `lib/core/theme/app_colors.dart` (additive tokens only), no other theme file changes; a review pass across every `hinam_ride/` screen/widget file.

**Firestore collections:** None.

**Providers / Repositories / Models:** None.

**Screens / Widgets:** No new ones — this phase reviews and adjusts existing ones for consistency (spacing, color usage, typography).

**Tests:** Golden/widget tests for the new tokens' contrast/accessibility if the project has a golden-test convention; otherwise manual visual QA.

**Review checklist:**
- [ ] No Ride screen uses a raw `Color(0xFF...)` value outside `AppColors`
- [ ] No new theme file was created — extended the existing one only

**Completion criteria:** Every Ride screen passes a visual side-by-side comparison against existing bus/school-bus screens for consistency of spacing, color, and type.

> **Implementation note:** `AppColors` gained one new domain pair, `rideAccent`/`rideAccentBg` (a violet, chosen to be distinct from every existing hue — primary blue, schoolGreen, stopOrange, error red, warning orange — and unclaimed by any other module), mirroring the `schoolGreen`/`stopOrange` convention exactly. It replaces the generic `AppColors.primary`/`primaryBg` previously used for Ride's two most recurring, Ride-specific UI moments: the driver/passenger identity avatar shown on every trip screen (`DriverIdentityCard`, `PassengerIdentityCard`) and the driver's own live vehicle marker on the trip map (`ride_driver_trip_screen.dart`). Before this, those elements were visually indistinguishable from unrelated generic-blue elements elsewhere in the app (e.g. the "Nearby Buses" hero tile); they now carry Ride's own identity, the same way School Bus's icons carry `schoolGreen`.
>
> A full audit of every `hinam_ride/` screen and widget for raw color usage found **zero** raw `Color(0xFF...)` hex literals — that checklist item already held. It also found several ad hoc Material `Colors.*` values that duplicated meanings the theme already names, introduced independently across different phases without reference to each other:
> - Three admin queue screens (verification, reports, incidents) each had their own `Colors.green.withValues(...)` for an identical "all caught up" checkmark — unified onto `AppColors.success`.
> - `ReportReviewCard`/`VerificationReviewCard` each had their own `Colors.orange`/`Colors.blue` "pending/reviewed" badges — unified onto `AppColors.warning`/`AppColors.primary`, and `VerificationReviewCard`'s approve/reject buttons (`Colors.green.shade600`/`Colors.red`) unified onto `AppColors.success`/`AppColors.error`.
> - `IncidentCard` and `RideIncidentsQueueScreen`'s alarm styling (Phase 18) used raw Material `Colors.red.shade50/400/600/700` and `Colors.grey.shade50/600/700` — a different red family than the rest of Ride's own danger styling (`SosButton`, `CancelRideDialog`, `ReportFormDialog` all already use `AppColors.error`). Unified onto `AppColors.error`/`errorBg` so SOS's visual language is drawn from the same red as the rest of Ride, not a slightly-different Material shade; the alarm's structural distinctiveness (solid header, thicker border, red AppBar) is fully preserved, only the literal color values changed. `RideIncidentsQueueScreen`'s subtitle/background were also brought in line with its two sibling queue screens (`scheme.onSurface.withValues(alpha: 0.5)`, no explicit Scaffold background override), which had already been mutually consistent with each other.
>
> `Colors.white`/`Colors.transparent`/`Colors.black` usages for text/icons rendered on top of a colored surface (map marker icons, alarm-header text) were left as-is — this is the exact same convention the rest of the app (e.g. `single_bus_map_screen.dart`, `driver_approval_card.dart`) already uses for that purpose, not a Ride-specific inconsistency. No spacing or typography deviations were found; Ride's radii (12–20), padding (12–20), and font sizes already match the values used throughout `AppTheme` and the bus/school-bus screens, because every prior phase built directly off those same existing widgets and patterns. Only `app_colors.dart` was extended; `app_theme.dart` was not touched.

---

## Phase 21 — Firestore Rules & Indexes Consolidation Audit

**Objective:** A single, deliberate security review of every rule block added across Phases 3–18, together, rather than trusting each phase's isolated review alone.

**Scope:** Full read-through of `firestore.rules` and `firestore.indexes.json` as they now stand; emulator-based penetration-style testing (attempt every write as a non-owner, non-admin, non-participant).

**Dependencies:** All data-bearing phases (3–18).

**Files involved:** `firestore.rules`, `firestore.indexes.json` (both fully reviewed, not just diffed phase-by-phase).

**Firestore collections:** All Ride collections, reviewed together.

**Providers / Repositories / Models / Screens / Widgets:** None — this is a security-only phase.

**Tests:** A comprehensive Firestore emulator rules-test suite covering every collection's allowed/denied cases in one place (may consolidate individual phase rule tests into one suite here).

**Review checklist:**
- [ ] Confirmed no collection uses `bus_locations`' public-read pattern where it shouldn't
- [ ] Confirmed every status-transition rule enforces forward-only movement, not just documented intent
- [ ] Confirmed the subcollection rule block behaves correctly alongside its parent's rules under emulator testing

**Completion criteria:** The consolidated rules test suite passes, and a manual attempt to read/write any Ride collection as an unrelated authenticated user fails everywhere it should.

> **Implementation note:** Every prior phase (13–18) disclosed the same limitation — the Firestore emulator needs JDK 21+, and the sandbox only had JDK 17 with no passwordless `sudo` to upgrade it. This phase resolved that: a portable Eclipse Temurin 21 build was downloaded and extracted directly under the user's home directory (no root required), and the real Firestore emulator was run against it. This is the first phase where the rules audit was verified against a live emulator rather than `firebase deploy --dry-run` plus manual tracing alone.
>
> A temporary Node test harness (`@firebase/rules-unit-testing`) exercised every Ride collection's full allow/deny matrix — `ride_drivers`, `ride_passengers`, `ride_verifications`, `ride_locations`, `rides` (every forward-only status transition: requested→matched→arrived→inProgress→completed, both cancellation paths, the no-show grace period both before and after it elapses, both rating clauses including the exactly-once guard), the `offers` subcollection (including the ±20% counter-offer bound), `ride_transactions`, `ride_reports`, and `ride_incidents` — 83 assertions, all passing after the harness itself was corrected through several iterations (test fixture bugs, not rule bugs: matching a document's owner-uid to its own id, isolating fixtures that earlier tests had already mutated, and matching `RideModel.toMap()`'s convention of writing every nullable field explicitly as `null` rather than omitting the key, which the rating clauses' `resource.data.driverRating == null` comparison depends on). Per the project's established temporary-test-file convention (matching how Phase 12/18's Cloud Functions were verified with disposable Node scripts), the harness, the downloaded JDK, and the emulator's cache were all removed after the run — nothing Node-based is added to this otherwise pure-Flutter project.
>
> **Checklist verified:**
> - No Ride collection uses `bus_locations`' public-read pattern — confirmed by grep (only `bus_locations` and `bus_stops`, both pre-existing non-Ride collections, use `allow read: if true`) and by an emulator test proving `ride_locations` denies an unrelated authenticated reader (it is deliberately *not* public, unlike `bus_locations`).
> - Every `rides` status transition is forward-only in practice, not just by documented intent — confirmed by emulator tests that a backward transition (`matched` → `requested`) and a skipped stage (`matched` → `inProgress`, bypassing `arrived`) are both denied.
> - The `offers` subcollection behaves correctly alongside its parent's rules — confirmed that an offer can only be accepted *after* the parent `rides` document is already committed as `matched` (accepting first, or in the same atomic batch as the ride-match update, is denied either way — Firestore evaluates a batch's per-document rules against the pre-batch snapshot, so the two writes are only valid done sequentially, exactly as Phase 13's own inline rule comment already documented).
>
> **One genuine, previously-undetected bug was found and fixed:** `RideAdminRepository.watchPendingVerifications()` (Phase 6) queries `ride_verifications` by `status == 'pending'` ordered by `createdAt` — structurally identical to `ride_reports` and `ride_incidents`'s own status+createdAt queries, both of which received a matching composite index in their own phases (17, 18). `ride_verifications` never did; only its unrelated `subjectId`+`createdAt` index existed. This would have failed at runtime with Firestore's "query requires an index" error the first time any admin opened the verification queue in production — the Firestore emulator does not reliably enforce this, which is why it went undetected until this phase's dedicated cross-check of every datasource query against `firestore.indexes.json`. Fixed by adding the missing composite index, confirmed via `firebase deploy --only firestore:indexes --dry-run`.

---

## Phase 22 — Regression & Integration Testing

**Objective:** Confirm Ride's additions — especially the splash-screen change — did not degrade any existing feature.

**Scope:** Full regression pass on auth, bus driver, school bus, fleet, admin, and bus-stop flows.

**Dependencies:** Phase 7 in particular; effectively all prior phases.

**Files involved:** None modified — this is a testing/verification phase.

**Firestore collections:** None new.

**Providers / Repositories / Models / Screens / Widgets:** None new.

**Tests:** Re-run (or write, if absent) integration tests for: bus driver login → dashboard, admin login → dashboard, school bus passenger flow, bus stop management — confirmed unaffected by the splash-screen and routing changes.

**Review checklist:**
- [ ] Every pre-existing role's login path manually walked through end-to-end
- [ ] `flutter analyze` clean across the whole project, not just `hinam_ride/`

**Completion criteria:** No regression in any existing feature; `flutter analyze` reports no issues project-wide.

> **Implementation note:** No files were created or modified as a lasting part of this phase, per its own "Files involved: None" scope — this was purely verification.
>
> `splash_screen.dart`'s role-resolution (`_initialize()`, added in Phase 7) was traced end-to-end for every pre-existing role: it checks `isAdmin` first, then bus-driver `driverExists`, each returning immediately via `Navigator.pushReplacementNamed` before either of the two Ride-specific checks (ride driver, then ride passenger) ever runs. Because admin and bus-driver are checked *first* and return early, neither path can be affected by anything added for Ride — the two new checks are strictly appended after, not interleaved. A brand-new user (or an authenticated user matching none of the four) falls through to `setState(() => _showChoice = true)` exactly as before Phase 7, just with two more `if` blocks now sitting between the bus-driver check and that fallthrough.
>
> A temporary widget test (`test/app_router_regression_test.dart`, since removed) drove `AppRouter.onGenerateRoute` directly for every pre-existing route constant (`login`, `dashboard`, `publicBusList`, `schoolBusList`, `manageBusStops`, `adminDashboard`, `pendingDrivers`, `manageBuses`, `manageAssignments`) and asserted each still resolves to its original, unmodified screen type — proving the many Ride `case` branches added across Phases 7–19 never shadowed an existing one — plus that an unrecognized route name still falls back to `SplashScreen` via `default:`, not a crash. A separate check confirmed every route path string in `app_routes.dart` is unique (no two constants silently colliding on the same string). `flutter analyze` was re-run clean across the whole project, not scoped to `hinam_ride/`.
>
> The two Ride-adjacent flows named in this phase's scope were confirmed unaffected structurally, not just by route resolution: a repo-wide import search found `hinam_ride/` is referenced from exactly one pre-existing file — `admin_dashboard_screen.dart` (Phase 19's single, deliberate, additive summary tile) — and nowhere else. `school_bus/`, `bus_stops/`, `driver/`, `passenger/`, and `fleet/` have zero dependency on any Ride code, so the school-bus passenger flow (reached only from the splash choice screen, itself unaffected as traced above) and bus-stop management (reached from the bus driver's own, untouched `DashboardScreen`) could not have regressed from anything built in Phases 3–21.
>
> `test/widget_test.dart` — the one permanent test file — still fails with the pre-existing `Bad state: No ProviderScope found` error (it pumps `HinamApp()` without the `ProviderScope` `main.dart` normally supplies); this was independently confirmed via `git stash` back in Phase 19 to already exist on unmodified `main`, unrelated to any Ride phase, and out of this phase's own scope ("Files involved: None modified") to fix.

---

## Phase 23 — Documentation Sync & Rollout Readiness

**Objective:** Close the loop per CLAUDE.md/AGENTS.md's own rule that documentation must reflect the current architecture, not its history.

**Scope:** Update `PROJECT_OVERVIEW.md` (fold in the real Ride feature set as shipped, reconcile the Google Maps vs. `flutter_map` and Storage/FCM-now-present discrepancies flagged in the earlier architecture review), confirm `AGENTS.md`/`CLAUDE.md` still apply without contradiction, and run a final production-readiness checklist.

**Dependencies:** All prior phases.

**Files involved:** `PROJECT_OVERVIEW.md`, `AGENTS.md` (only if a genuinely new durable rule emerged during implementation), `CLAUDE.md` (same).

**Firestore collections:** None.

**Providers / Repositories / Models / Screens / Widgets:** None.

**Tests:** None — documentation phase.

**Review checklist:**
- [ ] `PROJECT_OVERVIEW.md`'s tech-stack section matches what was actually built (no aspirational entries left unreconciled)
- [ ] Every deliberate deviation made along the way (enums, subcollection, private ride-location reads) is documented somewhere discoverable, not just in this conversation's history

**Completion criteria:** Documentation accurately describes the shipped system; a new contributor reading only the docs would not be misled about what exists.

> **Implementation note:** `PROJECT_OVERVIEW.md` was reconciled against the actual, shipped codebase rather than its original aspirational draft:
> - **Maps & Location** claimed "Google Maps" and "Geocoding" — neither is present anywhere in `pubspec.yaml` or the code (no `google_maps_flutter`, no reverse-geocoding calls). Every map in the app, bus tracking included, renders via `flutter_map` over OpenStreetMap tiles, with `Geolocator` for device position. Replaced the false claim; removed the unused "Geocoding" line entirely rather than leaving it as an unfulfilled aspiration.
> - **Backend** was missing **Cloud Functions** — a real, shipped part of the backend since Phase 12 (ride/offer notifications) and Phase 18 (SOS incident alerts) — added.
> - **Storage** and **Cloud Messaging** were already listed and are genuinely used (`shared/services/storage_service.dart` for verification document uploads, `shared/services/notification_service.dart` + `functions/` for push notifications) — no discrepancy there; both were already correctly implemented as cross-cutting `shared/` services, exactly matching this document's own "Shared Platform Services" section and AGENTS.md's shared-layer rule.
> - **Hinam Ride**'s capability list was missing **cash payment settlement** — a fully shipped submodule since Phase 16 — added.
> - Added a short, present-tense **"Implementation Notes"** section under Hinam Ride naming the three deviations this checklist calls out by name (enums for status fields, the `offers` subcollection, ride-location reads being private rather than public like bus locations) at a vision-document level of detail, pointing to `PHASES.md` for the full rationale behind each — satisfying "documented somewhere discoverable" without duplicating 23 phases of engineering detail into a document whose own stated purpose is high-level vision, not implementation history.
>
> `AGENTS.md` and `CLAUDE.md` were reviewed against everything actually built across Phases 0–22 and require **no changes** — every rule they state (Feature-First structure, UI → Provider → Repository → Datasource → Firebase, Riverpod-only state management, centralized routes, security rules as the real enforcement boundary, "documentation describes the current system, not its history") was followed throughout, and no genuinely new durable rule emerged during implementation that isn't already covered by their existing text.
>
> **Final production-readiness checklist:** `flutter analyze` — 0 issues, project-wide (re-confirmed after this phase's edits). `test/` contains only the original `widget_test.dart`. `firestore.rules`/`firestore.indexes.json` were audited end-to-end against a live emulator in Phase 21 (one real missing-index bug found and fixed there). Routing and role-resolution were regression-tested in Phase 22 with no findings. The one pre-existing, disclosed, out-of-scope gap across every phase since 13 — `test/widget_test.dart`'s stock counter test failing with `Bad state: No ProviderScope found` — remains, confirmed via `git stash` in Phase 19 to already exist on unmodified `main`, unrelated to Ride.

---

This is the complete roadmap — 24 phases, each independently implementable and reviewable, none skipped.

All 24 phases (0–23) are now implemented.

## Implementation Status (as of last update)

- **Phases 0–10:** Implemented.
- **Phase 11:** Implemented, with one deliberate deviation from this document's original text — see the implementation note under Phase 11 above. The race-safe accept path was built as sequential, rule-gated Firestore writes from the existing Flutter/Dart repository layer instead of a Cloud Function, to avoid introducing a second language/runtime into the project.
- **Phase 12:** Implemented. Unlike Phase 11, this phase's own explicit scope required Cloud Functions with no client-only alternative, and the Technology Lock's carve-out for this exact case authorized it — see the implementation note under Phase 12 above. `functions/` was scaffolded fresh with exactly the two named triggers (`onOfferCreated`, `onRideStatusChanged`); no Flutter files were changed.
- **Phase 13:** Implemented. `RideStatus` extended with `arrived`/`inProgress`/`completed`; `firestore.rules` gained three new driver-only, forward-only transition clauses on `rides` — see the implementation note under Phase 13 above for the live-tracking scope decision.
- **Phase 14:** Implemented. `RideStatus` extended with `noShow`; `RideModel` gained `arrivedAt`/`cancelledBy`/`cancelReason`; `firestore.rules` gained post-match cancel, mandatory-reason mid-trip cancel, and grace-period-gated no-show clauses on `rides`. `cancelRide` (Phase 9) was extended rather than duplicated — see the implementation note under Phase 14 above, including the deferred admin-pipeline checklist item (blocked on Phases 17/18, not yet implemented).
- **Phase 15:** Implemented. `RideModel` gained `driverRating`/`driverRatingComment`/`passengerRating`/`passengerRatingComment`; `firestore.rules` gained exactly-once, range-checked rating clauses on `rides`; `firestore.indexes.json` gained the two named composite indexes (`passengerId + createdAt`, `driverId + createdAt`). See the implementation note under Phase 15 above for the field-naming convention and the added history entry points.
- **Phase 16:** Implemented. New, fully isolated `hinam_ride/payments/` submodule (`RideTransactionModel`, `RidePaymentRemoteDatasource`, `RidePaymentRepository`, `ride_payment_provider.dart`, `MarkPaidButton`); `firestore.rules` gained a new top-level `ride_transactions/{rideId}` collection, keyed by the ride's own id so "exactly one transaction per ride" is structurally guaranteed. See the implementation note under Phase 16 above.
- **Phase 17:** Implemented. New `RideReportModel`/`RideReportRemoteDatasource`/`RideReportRepository`/`ride_report_providers.dart` under `administration/`; `firestore.rules` gained a `ride_reports/{reportId}` collection with rule-derived `reportedUserId` (never client-asserted) and admin-only status transitions. `ReportFormDialog` wired into both active-trip screens and the post-trip view; `RideReportsQueueScreen` built but not yet linked from any dashboard, matching Phase 6's own precedent (deferred to Phase 19). See the implementation note under Phase 17 above.
- **Phase 18:** Implemented. New `RideIncidentModel`/`RideIncidentRemoteDatasource`/`RideIncidentRepository`/`ride_incident_providers.dart` under `administration/`; `firestore.rules` gained a `ride_incidents/{incidentId}` collection (readable only by the triggering user and admins — never the other participant); `functions/` gained `onIncidentCreated`, a structurally separate high-priority push path from Phase 12's routine triggers. `SosButton` (new, `trip/presentation/widgets/`) wired into both active-trip screens; `url_launcher` added as a real dependency for the native SMS-intent fallback. `rideParticipantNameProvider` was extracted from Phase 17's `ride_report_providers.dart` into its own file and reused rather than duplicated. See the implementation note under Phase 18 above, including the passenger-only emergency-contacts boundary and the SMS-launch testing limitation.
- **Phase 19:** Implemented. New `RideAdminHomeScreen` composes the three existing queue providers from Phases 6/17/18 (no new providers/repositories); `QuickActionTile` gained one optional, backward-compatible `badgeColor` parameter; `admin_dashboard_screen.dart` gained exactly one additive tile (`_RideAdminSummaryTile`) rendering the incident count in a distinctly colored, alarm-styled badge separate from the routine verification/report badge. Four new routes added, all additive. See the implementation note under Phase 19 above.
- **Phase 20:** Implemented. `AppColors` gained one additive domain pair, `rideAccent`/`rideAccentBg` (violet), applied to the driver/passenger identity avatar and the driver's own live-position map marker — Ride's two most-recurring UI moments, previously indistinguishable from generic `AppColors.primary` elements elsewhere in the app. A full raw-color audit of every `hinam_ride/` file found zero raw hex `Color(0xFF...)` literals; several ad hoc Material `Colors.*` duplicates of existing semantic tokens (success/warning/error/primary) introduced independently across Phases 6/17/18 were unified onto those existing tokens, including bringing the SOS alarm styling onto the same `AppColors.error` red used by the rest of Ride's danger UI. `app_theme.dart` was not modified. See the implementation note under Phase 20 above.
- **Phase 21:** Implemented. A full read-through of `firestore.rules` and `firestore.indexes.json` together, verified against a real Firestore emulator (a portable JDK 21, requiring no root, finally unblocked this after five phases of disclosed limitation) via a temporary 83-assertion Node test harness covering every Ride collection's allow/deny matrix, removed after the run. All three review-checklist items confirmed directly against the live emulator. One real bug found and fixed: `ride_verifications` was missing the `status`+`createdAt` composite index its own Phase 6 query requires — added, matching the identical pattern already used for `ride_reports`/`ride_incidents`. See the implementation note under Phase 21 above.
- **Phase 22:** Implemented. Pure verification, no files changed — `splash_screen.dart`'s role-priority order (admin → bus driver → ride driver → ride passenger → choice screen) traced end-to-end confirming the two pre-existing roles are checked and return before either Ride check runs; a temporary widget test confirmed every pre-existing route still resolves to its original screen (removed after passing); a repo-wide import search confirmed no pre-existing feature besides Phase 19's one deliberate admin-dashboard tile depends on `hinam_ride/` at all; `flutter analyze` clean project-wide. See the implementation note under Phase 22 above.
- **Phase 23:** Implemented. `PROJECT_OVERVIEW.md` reconciled with the shipped system: "Google Maps"/"Geocoding" replaced with the actually-used `flutter_map`+`Geolocator`; "Cloud Functions" added to the Backend list; "Cash payment settlement" added to Hinam Ride's capabilities; a new "Implementation Notes" section documents the enum/subcollection/private-location-reads decisions with a pointer to this file for full rationale. `AGENTS.md`/`CLAUDE.md` reviewed and confirmed to need no changes — nothing built across Phases 0–22 contradicts either document. See the implementation note under Phase 23 above.
