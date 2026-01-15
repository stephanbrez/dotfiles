# Coding Agent Guidelines

This file defines **how coding agents should discover, load, and apply rule
files**. It does **not** define language- or project-specific rules itself.

## Rule Discovery & External File Loading (CRITICAL)

When encountering a file reference (e.g., `@rules/general.md`,
`@docs/python-guidelines.md`):

### Loading Rules

- **Use lazy loading only**

  - Do NOT preemptively load all referenced files
  - Load a file **only when its scope is relevant to the task**

- **Relevance triggers include:**

  - The task involves the language or ecosystem governed by the file
  - The task requires creating, modifying, or reviewing artifacts covered by
        the file
  - The task explicitly references the file or its domain

- **Recursive loading**
  - If a loaded file references additional rule files, follow those
        references **only if they are relevant to the current task**

## Rule Authority & Precedence

When multiple rules apply, resolve conflicts using this order (highest wins):

1. **Explicit instructions from the user**
2. **Task-specific referenced files**
3. **Language / ecosystem guidelines**
4. **General or global guidelines**
5. **Default agent behavior**

Once a rule file is loaded:

- Treat its contents as **mandatory**
- Do not soften, reinterpret, or partially apply rules
- Do not introduce exceptions unless explicitly permitted

## Development Guidelines (Python)

When working on Python-related tasks:

- **Code style, typing, execution rules** → `@docs/python-guidelines.md`

- **Project structure and layout rules (uv-only)** →
    `@docs/uv-proj-structure.md`

Load these files **only when the task involves Python code or Python project
structure**.

## General Guidelines

- This file governs **how rules are used**, not their content
- All domain-specific rules live in `@docs/`
- Additional guideline files may be added to `@docs/` when:
  - A new language, tool, or workflow requires strict rules
  - The rules are reusable across multiple tasks

### Adding New Rule Files

When adding a new rules file:

- Give it a **clear, scope-specific name**
- Place it under `@docs/`
- Reference it explicitly from tasks or from other rule files
- Ensure it can be applied **standalone**

## Non-Goals 🚫

This file does **not**:

- Define coding style
- Define project structure
- Replace language- or tool-specific guidelines

Its sole purpose is to define **how agents discover and apply rules correctly**.
