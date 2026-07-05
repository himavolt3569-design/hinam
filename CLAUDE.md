# CLAUDE.md

# Claude Code Instructions

This document provides repository-specific instructions for Claude Code when contributing to the Hinam project.

Claude should treat this file as operational guidance and use it alongside the project documentation.

---

# Primary Objective

Produce production-quality code that is simple, maintainable, and consistent with the existing architecture.

The goal is not to generate the largest amount of code, but to generate the most appropriate solution for the current problem.

---

# Understand Before Implementing

Before writing code:

1. Read the relevant feature.
2. Understand the existing implementation.
3. Identify reusable components.
4. Follow established patterns.
5. Avoid assumptions.

Never rewrite code simply because another implementation is possible.

---

# Development Philosophy

The project values:

* Simplicity
* Readability
* Consistency
* Maintainability
* Scalability

Favor solutions that future developers can quickly understand.

Avoid unnecessary complexity.

---

# Feature Development Workflow

For every new feature:

### Step 1

Understand the requirement.

If the requirement is ambiguous, ask for clarification before implementing.

### Step 2

Review the existing architecture.

New code should integrate naturally with the current project.

### Step 3

Create a small implementation plan.

Break larger features into manageable phases.

### Step 4

Implement incrementally.

Avoid implementing unrelated functionality.

### Step 5

Verify consistency.

Ensure naming, formatting, and structure match the surrounding code.

---

# Project Architecture

Follow the project's Feature-First Architecture.

Every feature owns its own:

* Data
* Presentation
* Providers
* Services

Do not move logic across features unless explicitly requested.

---

# Riverpod Guidelines

Use Riverpod consistently.

General preferences:

* Prefer AsyncNotifier for asynchronous state.
* Keep providers focused on a single responsibility.
* Do not place business logic inside widgets.
* Minimize unnecessary provider dependencies.

---

# Widget Guidelines

Widgets should primarily render UI.

Business logic belongs in providers or services.

Extract widgets only when they improve readability or are reused.

Avoid excessive widget fragmentation.

---

# Code Generation Principles

Generated code should:

* Compile without modification.
* Follow Flutter formatting.
* Use null safety.
* Be easy to understand.
* Minimize boilerplate.
* Avoid duplication.

Do not generate placeholder implementations unless explicitly requested.

---

# Dependencies

Before recommending a package:

* Prefer Flutter SDK capabilities.
* Prefer official packages.
* Minimize dependency count.
* Explain why a dependency is needed.

Do not introduce packages without justification.

---

# Refactoring

Refactor only when it provides clear value.

Avoid changing unrelated files during feature implementation.

Preserve public APIs unless modification is requested.

---

# Error Handling

Handle failures explicitly.

Provide meaningful error messages.

Avoid swallowing exceptions.

Maintain predictable application behavior.

---

# Performance Considerations

Prefer efficient implementations.

Examples:

* Reduce unnecessary rebuilds.
* Minimize Firestore reads.
* Avoid duplicate computations.
* Keep providers lightweight.

Optimize without sacrificing readability.

---

# Communication Style

When responding:

* Be concise.
* Explain architectural decisions.
* Identify trade-offs.
* Mention assumptions.
* Recommend improvements when appropriate.

Avoid unnecessary verbosity.

---

# When Unsure

If multiple valid implementations exist:

* Explain the available options.
* Recommend the approach that best fits the existing architecture.
* Wait for confirmation before making significant architectural changes.

---

# What to Avoid

Do not:

* Rewrite working code without reason.
* Introduce unnecessary abstractions.
* Create duplicate utilities.
* Ignore repository conventions.
* Add speculative features.
* Over-engineer simple problems.

---

# Repository Expectations

Claude should preserve:

* Project consistency.
* Existing architecture.
* Naming conventions.
* Folder organization.
* Coding standards.

The repository should become cleaner over time, not more complex.

---

# Guiding Principle

Every implementation should answer the following question:

> Does this solution improve the project while keeping it simple to understand, maintain, and extend?

If a simpler solution provides the same value, prefer the simpler solution.

Claude should prioritize long-term maintainability over short-term convenience.

Before implementing a new
transportation service,
first determine whether it
belongs in an existing feature
or should be implemented as
its own module.

Default to independent modules.