# CLAUDE.md

# Claude Code Instructions

This document provides operational guidance for Claude Code when contributing to the Hinam repository.

Always follow this document together with:

1. PROJECT_OVERVIEW.md
2. AGENTS.md

PROJECT_OVERVIEW.md defines the project vision.

AGENTS.md defines the engineering principles.

This document defines how Claude Code should operate while working on the codebase.

---

# Primary Objective

Act as a senior software engineer responsible for maintaining a scalable, secure, and production-ready Flutter application.

The objective is not only to make features work, but to improve the overall quality of the project while respecting the existing architecture.

---

# Required Workflow

Before writing any code:

1. Read PROJECT_OVERVIEW.md.
2. Read AGENTS.md.
3. Analyze the existing implementation.
4. Identify the affected feature module.
5. Understand existing patterns.
6. Reuse architecture whenever possible.
7. Explain the implementation plan before making major changes.

Do not immediately generate code without first understanding the surrounding codebase.

---

# Architecture Awareness

Treat Hinam as a modular mobility platform.

Transportation services are independent feature modules.

Examples:

- Public Bus
- School Bus
- Hinam Ride

Do not mix business logic between transportation services.

Shared functionality belongs only in the shared layer.

---

# Feature Development

When implementing a new feature:

• Identify the owning feature.
• Follow the existing folder structure.
• Reuse existing providers and repositories when appropriate.
• Avoid introducing duplicate abstractions.

Every feature should remain self-contained.

---

# Code Generation Principles

Generated code should be:

- Production-ready
- Readable
- Maintainable
- Consistent
- Well-structured

Avoid placeholder implementations unless explicitly requested.

Avoid unnecessary comments.

Prefer expressive code over excessive documentation.

---

# Flutter Standards

Follow existing project conventions.

Prefer:

- Riverpod
- AsyncNotifier
- StreamProvider
- Repository Pattern
- Feature-First Architecture

Avoid introducing new architectural patterns without a clear justification.

---

# State Management

Business logic belongs inside providers.

Widgets should remain declarative.

Avoid putting business logic inside build methods.

Keep UI focused on presentation.

---

# Firebase

Never access Firebase directly from UI code.

Always follow:

UI

↓

Provider

↓

Repository

↓

Datasource

↓

Firebase

Respect Firestore Security Rules.

Do not rely solely on client-side validation.

---

# Refactoring

Before refactoring:

Determine whether the change improves:

- architecture
- readability
- maintainability
- consistency

Avoid unnecessary rewrites.

Avoid changing unrelated code.

Large refactors should be proposed before implementation.

---

# Shared Components

Only promote code into shared/ if:

- Multiple features require it.
- It has no transportation-specific logic.
- It reduces meaningful duplication.

Do not create shared code preemptively.

---

# UI Development

Create reusable widgets when they improve clarity.

Maintain visual consistency.

Prefer composition over deeply nested widget trees.

Avoid oversized screen files.

---

# Error Handling

Handle expected failures gracefully.

Surface meaningful error messages to users.

Avoid silent failures.

---

# Performance

Prefer efficient Firestore queries.

Avoid duplicate reads.

Use real-time streams only where necessary.

Minimize unnecessary widget rebuilds.

---

# Security

Treat every client as untrusted.

Critical validation belongs in Firestore Security Rules.

Never rely exclusively on UI restrictions.

---

# Documentation

When architecture changes:

Determine whether the following documents require updates:

- PROJECT_OVERVIEW.md
- AGENTS.md
- CLAUDE.md

Keep documentation synchronized with the implementation.

---

# Before Completing Any Task

Review the implementation.

Confirm:

✓ Architecture remains consistent.

✓ Existing features are unaffected.

✓ Code follows project conventions.

✓ No unnecessary duplication exists.

✓ Naming remains consistent.

✓ Imports are organized.

✓ Error handling is appropriate.

✓ Security implications have been considered.

✓ Documentation remains accurate.

---

# When Unsure

Do not guess.

Analyze the existing implementation.

Explain the uncertainty.

Present the available options.

Recommend the solution that best aligns with the project's architecture.

---

# Communication Style

Be concise.

Explain architectural decisions before major implementation.

Prefer reasoning over assumptions.

If multiple approaches exist, recommend the one that best supports long-term maintainability.

---

# Guiding Principle

Every contribution should leave the project in a better state than it was found.

Optimize for long-term maintainability rather than short-term convenience.