# AGENTS.md

# AI Contributor Guidelines

This document defines the expectations and contribution standards for any AI coding agent working within the Hinam repository.

These guidelines apply to all contributors, regardless of the AI model or development environment.

---

# Mission

Contribute code that improves the project while preserving its simplicity, consistency, and maintainability.

Every implementation should integrate naturally with the existing architecture rather than introducing unnecessary complexity.

---

# Primary Responsibilities

AI agents should:

* Understand the existing implementation before making changes.
* Respect the established project architecture.
* Keep changes focused on the requested task.
* Preserve code readability.
* Minimize unnecessary modifications.
* Produce production-quality code.

---

# Before Writing Code

Before implementing any feature:

1. Understand the relevant feature module.
2. Review nearby files to maintain consistency.
3. Reuse existing components whenever possible.
4. Avoid introducing duplicate functionality.
5. Consider how the new code affects the overall architecture.

Never begin implementation without understanding the surrounding code.

---

# Architecture Rules

The project follows a Feature-First Architecture.

Every feature owns its own:

* Presentation
* State management
* Business logic
* Data access

Feature logic should remain inside the feature that owns it.

Do not move business logic into unrelated modules.

---

# Directory Responsibilities

## core/

Contains application-wide resources.

Examples:

* Theme
* Routing
* Constants
* Utilities
* Global services

Do not place feature-specific logic here.

---

## shared/

Contains reusable components shared across multiple features.

Examples:

* Buttons
* Cards
* Dialogs
* Common widgets

Only move code into `shared` when it is genuinely reusable.

---

## features/

Each feature should remain independent.

Avoid creating dependencies between unrelated features unless absolutely necessary.

---

# Coding Standards

Code should be:

* Readable
* Predictable
* Consistent
* Maintainable

Prefer clear implementations over clever solutions.

Meaningful naming is preferred over abbreviations.

Avoid deeply nested logic whenever possible.

---

# Widget Guidelines

Widgets should focus on presentation.

Business logic should remain inside providers or services.

Extract reusable widgets only when they are used in multiple places or clearly improve readability.

Avoid creating unnecessary widget files.

---

# State Management

Riverpod is the project's state management solution.

General expectations:

* Prefer AsyncNotifier for asynchronous workflows.
* Keep providers focused on a single responsibility.
* Avoid storing unnecessary state.
* UI should react to provider state instead of containing business logic.

---

# Data Management

Firebase is the primary backend.

Responsibilities should remain separated.

Authentication data, user profiles, and live tracking data should not be merged into a single data model unless there is a clear architectural reason.

---

# Dependencies

Before introducing a new package:

* Verify that existing packages cannot solve the problem.
* Consider maintenance implications.
* Minimize dependency count.
* Prefer official Flutter packages when appropriate.

Do not introduce dependencies without clear justification.

---

# Refactoring

Refactoring is encouraged only when it improves the codebase.

Avoid refactoring unrelated code while implementing a feature.

Large architectural changes should not be introduced without explicit approval.

---

# Error Handling

Handle failures gracefully.

Avoid silent failures.

Provide meaningful error messages where appropriate.

Never ignore exceptions without reason.

---

# Performance

Consider performance during implementation.

Examples:

* Avoid unnecessary widget rebuilds.
* Minimize Firestore reads.
* Reduce redundant computations.
* Avoid excessive object creation.
* Keep providers lightweight.

Optimization should never sacrifice readability.

---

# Documentation

Update documentation when architectural decisions change.

Do not leave outdated comments.

Keep documentation concise and accurate.

---

# Testing Mindset

Even when automated tests are not being written, implement code as though it will be tested.

Write deterministic, modular, and predictable code.

Avoid tightly coupled implementations.

---

# Pull Request Philosophy

Each contribution should:

* Solve one problem.
* Avoid unrelated modifications.
* Preserve formatting.
* Maintain existing naming conventions.
* Keep commits logically organized.

---

# Things to Avoid

Do not:

* Rewrite working code without reason.
* Introduce unnecessary abstractions.
* Create duplicate utilities.
* Add unused dependencies.
* Ignore existing project conventions.
* Modify unrelated files.
* Sacrifice readability for brevity.

---

# Decision Making

When multiple valid implementations exist, prefer the one that is:

1. Easier to understand.
2. Easier to maintain.
3. Consistent with the existing codebase.
4. Simpler to extend.
5. Less likely to introduce bugs.

---

# Guiding Principles

Every contribution should improve at least one of the following:

* Readability
* Maintainability
* Consistency
* Reliability
* Simplicity

If a proposed change does not provide measurable value, it should not be introduced.

The objective is not only to build new features, but also to preserve a clean, scalable, and sustainable codebase throughout the lifetime of the project.

Each transportation service
must remain independent.

Do not mix business logic
between services.
