# PROJECT_OVERVIEW.md

# Hinam

## 1. Introduction

Hinam is a cross-platform Flutter application designed to provide real-time public transportation tracking within Nepal.

The application connects drivers, passengers, and administrators through a unified platform that enables reliable vehicle tracking, route visibility, and transportation management.

The project follows an MVP-first development strategy while maintaining an architecture that supports future expansion without requiring significant structural changes.

---

# 2. Purpose

The primary objective of Hinam is to improve the public transportation experience by providing accurate, real-time vehicle information.

The system allows drivers to securely share their live location while enabling passengers to locate buses, monitor routes, and make informed travel decisions.

The project emphasizes simplicity, reliability, scalability, and maintainability over unnecessary complexity.

---

# 3. Project Scope

The application currently focuses on public transportation tracking through three primary user roles.

### Driver

Drivers authenticate using their phone number, register their vehicle, and share their live location.

### Passenger

Passengers can discover available buses, view their locations on a map, search routes, and monitor vehicle movement.

### Administrator

Administrators manage drivers, vehicle approvals, routes, and platform data to ensure information remains accurate and reliable.

---

# 4. Technology Stack

## Frontend

* Flutter
* Dart

## State Management

* flutter_riverpod
* AsyncNotifier

## Backend

Firebase

Services used:

* Firebase Authentication
* Cloud Firestore

## Maps

* OpenStreetMap
* flutter_map

## Location Services

* geolocator

## Navigation

* Flutter Named Routes

## Development

* Git
* GitHub
* Flutter Lints
* Dart Formatter

---

# 5. Architectural Principles

The project follows a **Feature-First Architecture**.

Each feature is responsible for its own presentation, state management, and business logic. This keeps features isolated, maintainable, and scalable.

Project structure:

```text
lib/

core/
features/
shared/
```

Example feature structure:

```text
features/

auth/
driver/
tracking/
passenger/
admin/
```

Each feature generally follows:

```text
feature/

data/
presentation/
```

Presentation contains:

```text
screens/
widgets/
providers/
services/
```

Additional layers should only be introduced when they provide clear architectural value.

---

# 6. Core Module

The `core` directory contains application-wide resources that are shared across all features.

Typical contents include:

* Application routing
* Theme configuration
* Constants
* Utility functions
* Global services
* Shared configuration

Feature-specific business logic should never be placed inside the `core` module.

---

# 7. Shared Module

The `shared` directory contains reusable components that are not owned by a specific feature.

Examples include:

* Buttons
* Cards
* Dialogs
* Loading indicators
* Common form components
* Shared widgets

Reusable components should be extracted only when they are used by multiple features.

---

# 8. Data Management

The application uses Firebase as its backend service.

Responsibilities are separated by concern:

* Firebase Authentication manages user identity.
* Cloud Firestore stores application data.
* Live tracking data is stored independently from permanent profile information.

This separation minimizes unnecessary reads and keeps frequently updated tracking data independent from relatively static user data.

---

# 9. State Management Philosophy

Riverpod is the single state management solution used throughout the project.

General guidelines:

* AsyncNotifier is preferred for asynchronous workflows.
* Providers should have a single responsibility.
* UI should react to provider state rather than contain business logic.
* Business logic should remain outside widgets whenever possible.

---

# 10. Design Principles

The project follows the following engineering principles:

* Simplicity over complexity
* Readability over cleverness
* Consistency over personal preference
* Reusability over duplication
* Scalability without over-engineering
* Predictable project structure
* Clear separation of responsibilities

Every implementation should improve the maintainability of the codebase.

---

# 11. Development Guidelines

When implementing new functionality:

* Follow the existing project architecture.
* Keep feature logic isolated.
* Reuse existing components before creating new ones.
* Avoid unnecessary dependencies.
* Prefer small, focused widgets.
* Write meaningful names for classes, methods, and variables.
* Keep asynchronous operations inside providers or services.
* Minimize duplicated code.

Architecture changes should only be introduced when they provide measurable long-term benefits.

---

# 12. Performance Philosophy

Performance considerations should be incorporated throughout development rather than treated as a final optimization step.

Key principles include:

* Minimize unnecessary widget rebuilds.
* Avoid redundant Firestore reads.
* Keep providers lightweight.
* Reuse widgets whenever appropriate.
* Load data only when required.
* Optimize location updates for battery efficiency.

---

# 13. Security Principles

The project follows secure development practices by default.

General guidelines:

* Never trust client-side validation alone.
* Protect Firestore using security rules.
* Store only required user information.
* Keep authentication separate from application data.
* Avoid exposing sensitive configuration within source code.

---

# 14. Scalability

The architecture is intentionally modular.

New transportation services or platform capabilities should be implemented as independent features while preserving the existing project structure.

The addition of future functionality should require minimal changes to existing modules.

---

# 15. Code Quality Standards

The project values long-term maintainability.

Every contribution should strive to be:

* Simple
* Readable
* Consistent
* Testable
* Maintainable
* Well-organized

The objective is to build a codebase that remains understandable as the project grows.

---

# 16. Guiding Principle

Every architectural and implementation decision should answer one question:

> Does this make the project easier to understand, maintain, and extend?

If the answer is no, the solution should be reconsidered.

The long-term success of Hinam depends not only on its features, but also on the quality and sustainability of its architecture.
