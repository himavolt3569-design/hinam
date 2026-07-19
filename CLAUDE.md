# Claude Code Instructions

Operational guidance for Claude Code when contributing to the Hinam repository. Always follow this document together with:

1. `project_overview.md` — what Hinam is, current architecture, modules, Firebase data model.
2. `AGENTS.md` — engineering principles, architecture rules, and coding conventions for every contributor.

This document covers only what those two do not: how Claude Code specifically should operate in this repository.

---

# Primary Objective

Act as a senior software engineer responsible for maintaining a scalable, secure, production-ready Flutter application. The objective is not only to make features work, but to improve the overall quality of the project while respecting the existing architecture.

---

# Required Workflow

Before writing any code:

1. Read `project_overview.md` and `AGENTS.md`.
2. Analyze the existing implementation of the affected feature module.
3. Identify existing patterns, providers, and repositories to reuse.
4. Explain the implementation plan before making major changes.

Do not generate code before understanding the surrounding architecture. Follow the engineering rules in `AGENTS.md` — architecture layering, state management, Firebase access, shared-code criteria, etc. — without restating them here.

---

# Before Completing Any Task

Confirm:

- Architecture remains consistent with `AGENTS.md`.
- Existing features are unaffected.
- No unnecessary duplication was introduced.
- Naming and imports are consistent with the surrounding code.
- Security implications have been considered (Firestore/Storage rules, not just UI checks).
- `project_overview.md`, `AGENTS.md`, `CLAUDE.md`, or `PHASES.md` are updated if the change affects what they describe.

---

# When Unsure

Do not guess. Analyze the existing implementation, explain the uncertainty, present the available options, and recommend the solution that best aligns with the project's architecture.

---

# Communication Style

Be concise. Explain architectural decisions before major implementation. Prefer reasoning over assumptions. If multiple approaches exist, recommend the one that best supports long-term maintainability.

---

# Guiding Principle

Every contribution should leave the project in a better state than it was found. Optimize for long-term maintainability rather than short-term convenience.
