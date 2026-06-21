# Hinam - Project Overview

## Project Name

Hinam

## Project Description

Hinam is a smart transportation platform built for Nepal that enables users to track public buses and school buses in real time.

The long-term vision is to evolve Hinam into a complete mobility ecosystem by adding:

* Public Bus Tracking
* School Bus Tracking
* Ambulance Tracking
* Women-only Ride Sharing
* Auto/Taxi Booking
* Emergency Transport Services
* Location-Based Mobility Services

The initial MVP focuses only on Public Bus and School Bus Tracking.

---

# MVP Goals

The first version of Hinam should allow:

### Drivers

* Register using phone number authentication
* Create a driver profile
* Register their bus
* Share live location
* Start and stop tracking

### Passengers

* View nearby buses
* View bus locations on a map
* Search buses
* Track bus movement in real time

---

# Technology Stack

## Frontend

* Flutter
* Dart

## State Management

* Riverpod
* AsyncNotifier

## Backend

* Firebase

### Firebase Services

* Firebase Authentication
* Cloud Firestore

## Maps

* OpenStreetMap

Future:

* flutter_map

## Location Tracking

* Geolocator

## Navigation

* Named Routes

---

# Architecture

Feature First Architecture

```text
lib/

core/

features/

auth/
driver/
tracking/
passenger/

shared/
```

Each feature contains its own:

```text
data/
presentation/
```

Structure Example:

features/auth/

data/
├── repositories/

presentation/
├── providers/
├── screens/
├── widgets/

````

---

# Current Features

## Authentication

Status: Completed

Features:

- Splash Screen
- Login Screen
- OTP Verification
- Firebase Phone Authentication
- Logout

---

## Driver Registration

Status: Completed

Features:

- Full Name
- Bus Number
- Bus Type
- Route Name (Public Bus)
- School Name (School Bus)

Stored in Firestore.

---

## Driver Dashboard

Status: MVP Complete

Features:

- Driver Profile Display
- Bus Information
- Approval Status
- Start Tracking Button
- Logout

---

## Location Tracking

Status: In Progress

### Phase 2A

Completed

Features:

- Request Location Permission
- Get Current Location
- Show Coordinates

### Phase 2B

Current Development

Features:

- Live Location Stream
- Tracking Status
- Real-Time Coordinate Updates

### Phase 2C

Planned

Features:

- Firestore Location Updates
- Bus Location Collection

### Phase 2D

Planned

Features:

- Background Tracking
- Tracking Reliability Improvements

---

# Firestore Structure

## Drivers

Collection:

```text
drivers
````

Document ID:

```text
driverUid
```

Example:

```json
{
  "uid": "123",
  "fullName": "Ram Sharma",
  "phoneNumber": "+97798XXXXXXX",
  "busNumber": "Ba 3 Kha 1234",
  "busType": "public",
  "routeName": "Kalanki - Ratnapark",
  "schoolName": null,
  "isApproved": false,
  "createdAt": "timestamp"
}
```

---

## Bus Locations

Collection:

```text
bus_locations
```

Document ID:

```text
driverUid
```

Example:

```json
{
  "driverId": "123",
  "busNumber": "Ba 3 Kha 1234",
  "latitude": 27.7172,
  "longitude": 85.3240,
  "speed": 25.0,
  "isTracking": true,
  "updatedAt": "timestamp"
}
```

---

# Development Roadmap

## Phase 1

Authentication & Driver Onboarding

Status: Completed

* Splash
* Login
* OTP
* Driver Registration
* Dashboard

---

## Phase 2

Driver Tracking

Status: In Progress

* Location Permission
* Current Location
* Location Stream
* Firestore Sync

---

## Phase 3

Passenger Application

* Passenger Dashboard
* Map Screen
* Nearby Buses
* Live Bus Tracking

---

## Phase 4

Bus Search

* Search by Bus Number
* Search by Route
* Search by School

---

## Phase 5

Bus Stops

* Bus Stop Management
* Bus Stop Markers
* Stop Information

---

## Phase 6

ETA System

* Estimated Arrival Time
* Distance Calculation
* Route Progress

---

## Phase 7

School Bus Features

* School Dashboard
* Student Tracking
* Parent Monitoring

---

## Phase 8

Admin Panel

* Driver Approval
* Bus Approval
* Route Management
* Monitoring Dashboard

---

# Development Rules

1. Use Riverpod for state management.
2. Use AsyncNotifier for async operations.
3. Keep business logic inside providers/services.
4. UI should remain clean and reusable.
5. Follow Feature First Architecture.
6. Avoid unnecessary files and complexity.
7. Build MVP first before adding advanced features.
8. Prioritize scalability and maintainability.

---

# Current Project Status

Authentication: Complete

Driver Registration: Complete

Dashboard: Complete

Location Tracking: In Progress

Passenger Module: Not Started

Admin Panel: Not Started

Overall Progress: Approximately 35%
