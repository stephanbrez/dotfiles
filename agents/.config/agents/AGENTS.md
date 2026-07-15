# Agent Guidelines

This file defines how agents discover, load, and apply rule files. It does not
define language- or project-specific rules.

## Rule Discovery

When encountering a file reference, such as `@rules/general.md` or
`@docs/python-guidelines.md`:

- Use lazy loading only; load referenced files only when relevant to the task.
- Relevance includes language, ecosystem, artifact type, explicit file
  reference, or domain match.
- Recursively load referenced rule files only when relevant to the current task.

## Rule Authority

When multiple rules apply, resolve conflicts in this order:

1. Explicit user instructions.
2. Task-specific referenced files.
3. Language or ecosystem guidelines.
4. General or global guidelines.
5. Default agent behavior.

Once a rule file is loaded:

- Treat it as **mandatory**.
- Do not soften, reinterpret, or partially apply rules.
- Do not introduce exceptions unless explicitly permitted.

## Required Development Rules

**Read `@rules/dev-standards.md` before any workflow. Do not proceed if it
cannot be loaded.**

## Python Rules

When working on Python code or projects:

- Code style, typing, and execution rules: `@rules/python-guidelines.md`.
- Project structure and layout rules for uv projects:
  `@rules/uv-proj-structure.md`.

## Rule File Management

- This file governs rule usage, not rule content.
- Domain-specific rules belong in `@rules/`.
- Add new rule files only when a reusable language, tool, or workflow needs
  strict rules.
- New rule files must have clear scope-specific names, live under `@rules/`, be
  explicitly referenced, and work standalone.

## Non-Goals 🚫

This file does not define coding style, define project structure, or replace
language- or tool-specific guidelines.
