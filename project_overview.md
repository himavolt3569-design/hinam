# PROJECT_OVERVIEW.md

# Hinam

> A modular mobility platform for Nepal that makes public transportation safer, smarter, and easier to use.

---

# Vision

Hinam is a unified mobility platform designed to improve the way people travel. Instead of building a single-purpose application, Hinam provides multiple transportation services under one ecosystem while maintaining a clean, scalable architecture.

The goal is to make transportation more accessible, transparent, and secure through real-time technology and thoughtful user experiences.

Every transportation service should operate independently while sharing a common infrastructure such as authentication, notifications, administration, and user management.

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

Allows passengers to track public buses in real time.

Primary capabilities:

- Live bus locations
- Route information
- Bus stop information
- Estimated arrival information
- Passenger count (future)
- Driver tracking

---

## School Bus Tracking

Allows schools and parents to monitor school buses safely.

Primary capabilities:

- Live school bus tracking
- Student count
- Route assignment
- Driver information
- Parent visibility
- Administrative monitoring

---

## Hinam Ride

A women-focused ride-sharing service integrated into the Hinam platform.

Primary capabilities:

- Female driver registration
- Female passenger matching
- Live ride tracking
- Negotiable ride pricing
- Driver verification
- Emergency safety features
- Ride history
- Ratings and reporting
- Cash payment settlement

---

# Implementation Notes

A few Hinam Ride data-modeling decisions are worth knowing before reading the code:

- Ride status, verification status, and similar states are modeled as Dart enums, serialized as their string name in Firestore.
- Ride pricing negotiation is stored as an `offers` subcollection under each ride document, keeping every bid scoped to the ride it belongs to rather than living in a separate top-level collection.
- A ride driver's live location is visible only to that driver and to administrators — unlike public bus locations, it is never broadcast publicly, since there is no passenger-facing "nearby ride drivers" map.

Full rationale for these and other implementation decisions is recorded phase-by-phase in `PHASES.md`.

---

# Platform Architecture

Hinam follows a modular architecture.

Each transportation service is implemented as an independent feature module.

Business logic should never be tightly coupled between services.

Example:

```text
features/

auth/
admin/

bus/
school_bus/
tracking/

hinam_ride/

shared/
```

Only reusable components belong inside `shared/`.

Transportation-specific logic must remain inside its own module.

---

# Technology Stack

## Mobile

- Flutter
- Dart

## State Management

- Riverpod (AsyncNotifier, Provider, StreamProvider)

## Backend

- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Cloud Messaging
- Cloud Functions

## Maps & Location

- flutter_map (OpenStreetMap tiles)
- Geolocator

## Architecture

- Feature-First Architecture
- Repository Pattern
- Clean Feature Separation
- Dependency Injection using Riverpod

---

# Application Roles

## Passenger

Can:

- Track buses
- View routes
- Book rides
- View ride history
- Report issues
- Rate drivers

---

## Bus Driver

Can:

- Register bus
- Share live location
- Manage tracking
- Update passenger information

---

## Ride Driver

Can:

- Register vehicle
- Submit verification documents
- Go online/offline
- Accept ride requests
- Negotiate pricing
- Complete rides

---

## Administrator

Can:

- Approve drivers
- Manage transportation services
- View analytics
- Moderate reports
- Suspend accounts
- Manage routes
- Review ride activity

---

# Shared Platform Services

Every transportation service uses common infrastructure.

Shared services include:

- Authentication
- User management
- Notifications
- Image uploads
- Permissions
- Theme
- Navigation
- Error handling
- Logging

---

# Design Philosophy

Every feature should answer one question:

> "Does this belong to the platform, or only to one transportation service?"

If it belongs to only one transportation service, keep it inside that feature.

If multiple services require it, promote it to the shared layer.

This philosophy keeps the project modular and prevents unnecessary coupling.

---

# Code Quality Standards

The project prioritizes:

- Readability
- Maintainability
- Predictability
- Testability
- Security
- Consistency

Code should always favor clear architecture over clever implementations.

---

# Future Growth

The architecture intentionally supports adding new transportation services without modifying existing ones.

Potential future services may include:

- Emergency transportation
- Corporate transport
- Shuttle services
- Accessibility transport

These services should be introduced as independent feature modules while continuing to share the common platform infrastructure.

---

# Guiding Principle

> Build a mobility platform, not a collection of unrelated features.

Every architectural decision should support scalability, maintainability, and a consistent experience for users and contributors alike.