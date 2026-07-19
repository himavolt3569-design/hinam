# Hinam Development Guidelines

This document defines the engineering principles, architectural rules, and development standards for every contributor working on the Hinam project.

These guidelines apply equally to human developers and AI coding agents.

---

# Primary Objective

The goal is not simply to write working code.

The goal is to build a maintainable, scalable, secure, and production-ready mobility platform.

Every change should improve the long-term quality of the project.

---

# Core Principles

Always prioritize:

- Simplicity over cleverness.
- Readability over brevity.
- Consistency over personal preference.
- Maintainability over quick fixes.
- Security by default.
- Reusability only when justified.
- Composition over duplication.

If multiple valid solutions exist, choose the one that makes the project easier to understand six months from now.

---

# Before Writing Code

Before implementing any feature:

1. Understand the problem.
2. Understand the existing architecture.
3. Identify where the feature belongs.
4. Reuse existing components when appropriate.
5. Avoid introducing unnecessary abstractions.

Never start coding before understanding the surrounding architecture.

---

# Feature Ownership

Every transportation service owns its own business logic.

Examples:

- Public Bus
- School Bus
- Hinam Ride

Business logic should remain inside its respective feature module.

Do not move transportation-specific logic into shared components.

---

# Shared Layer Rules

Only move code into `shared/` when it satisfies all of the following:

- Used by multiple features.
- Independent of transportation-specific logic.
- Improves maintainability.
- Reduces meaningful duplication.

Do not create shared code prematurely.

---

# Architecture Rules

Follow the established Feature-First architecture.

Each feature should remain self-contained.

Typical structure:

```text
feature/

data/
domain/
presentation/
```

Each layer has a clear responsibility.

### Data

Responsible for:

- Firebase
- APIs
- Models
- Repositories
- Data sources

### Domain

Responsible for:

- Business entities
- Enums
- Core business logic

### Presentation

Responsible for:

- UI
- State management
- User interaction
- Navigation

Never bypass architectural layers.

---

# State Management

Riverpod is the standard state management solution.

Preferred providers:

- Provider
- FutureProvider
- StreamProvider
- AsyncNotifier

Avoid unnecessary StateNotifier or ChangeNotifier implementations unless there is a clear architectural reason.

Business logic belongs inside providers—not inside widgets.

Widgets should remain declarative.

---

# UI Development

Every screen should have a clear responsibility.

Prefer small reusable widgets over large monolithic screens.

Avoid deeply nested widget trees.

Extract reusable UI components when they improve clarity.

Maintain consistent spacing, typography, and visual hierarchy across the application.

---

# Firebase Guidelines

Never access Firebase directly from the UI.

Always go through:

Repository

↓

Datasource

↓

Firebase

Firestore document structures should remain consistent.

Security rules should always enforce critical business rules rather than relying solely on client-side validation.

---

# Navigation

Routes should be centralized.

Avoid hardcoded navigation strings.

Navigation should remain predictable and easy to maintain.

---

# Error Handling

Never silently ignore errors.

Handle expected failures gracefully.

Provide meaningful feedback to users.

Log unexpected failures when appropriate.

---

# Security

Security decisions belong on the backend whenever possible.

Do not rely solely on UI restrictions.

Always assume client applications can be modified.

Validate permissions using Firestore Security Rules.

---

# Performance

Avoid unnecessary rebuilds.

Prefer lazy loading.

Use streams only when real-time updates are required.

Keep Firestore reads and writes efficient.

Avoid duplicate queries.

---

# Documentation

Update documentation whenever architecture changes.

Keep documentation accurate.

Do not leave outdated implementation notes inside documentation.

Documentation should describe the current system—not its history.

---

# Refactoring

Refactor only when it improves:

- readability
- maintainability
- architecture
- consistency

Do not refactor unrelated code while implementing a feature.

Keep pull requests and commits focused.

---

# Code Quality

Every contribution should be:

- Easy to read.
- Easy to modify.
- Easy to test.
- Easy to review.

Avoid unnecessary complexity.

If a solution requires extensive explanation, consider simplifying it.

---

# AI Contributor Guidelines

When implementing a new feature:

1. Read PROJECT_OVERVIEW.md.
2. Read this document.
3. Understand the existing architecture.
4. Reuse existing patterns.
5. Follow project conventions.
6. Explain architectural decisions before major refactors.

Never generate large-scale changes without first understanding the current codebase.

Prefer incremental improvements over disruptive rewrites.

---

# Decision Framework

Before introducing new code, ask:

- Does this belong in this feature?
- Can this reuse an existing pattern?
- Is this truly shared functionality?
- Will this still make sense in one year?
- Does this improve the project?

If the answer to any question is "no", reconsider the implementation.

---

# Guiding Principle

Write code that the next contributor can understand without needing additional explanation.

A well-structured project should communicate its architecture through the code itself.