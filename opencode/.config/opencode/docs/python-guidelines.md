# Python Development Guidelines (uv-Only, for Coding Agents)

These guidelines define **coding, typing, formatting, and execution rules** for
Python projects that **use uv exclusively**. They are designed to work **in
conjunction with** the companion _Project Structure Guidelines_, while remaining
**fully valid as a standalone reference**.

When used together:

- The **structure guide** answers _where things go_.
- This guide answers _how code is written, typed, formatted, and executed_.

---

## Package Management & Execution Requirements (Strict)

1. **ONLY recommend and assume `uv`**

    - uv is the sole tool for dependency resolution, environments, and
      execution.

2. **NEVER suggest `pip`, `pipx`, `poetry`, or system Python commands**

    - Do not recommend `pip install`, `python script.py`, or similar.
    - All execution must be uv-mediated.

3. **Use uv for all execution**

    - Tools, scripts, tests, and examples must be run via:

        ```python
        uv run <command>
        ```

    - Example:

        ```python
        uv run pytest
        uv run python examples/basic.py
        ```

4. **Assume `pyproject.toml` + `uv.lock`**

    - Dependencies are declared in `pyproject.toml`
    - Resolution is locked in `uv.lock`
    - No `requirements*.txt` by default

5. **uv dependency groups**
    - Runtime deps → `project.dependencies`
    - Tooling / dev deps → `dependency-groups.*`
    - Never add dev-only tools to runtime dependencies

---

## Import Rules (Strict)

1. **Import entire modules or packages**

    - Preferred:

        ```python
        import pandas as pd
        import pathlib
        ```

    - Avoid:

        ```python
        from pandas import DataFrame
        from pathlib import Path
        ```

2. **No inline imports**

    - Imports must appear at module top level.
    - Do not import inside functions, methods, or blocks.

3. **Internal vs public imports**
    - Public API should be exposed via package `__init__.py`
    - Internal modules may be prefixed with `_` or placed under an internal
      namespace

---

## Type Annotation Requirements (Strict)

1. **Annotate everything**

    - Function parameters
    - Return types
    - Class attributes
    - Public constants

2. **Prefer precise types**

    - Avoid `Any` unless absolutely necessary
    - Model structure explicitly

3. **Python 3.12+ typing syntax only**

    - Use built-ins: `list`, `dict`, `tuple`
    - Use unions: `A | B`
    - Use `type` instead of `Type`
    - Avoid legacy `typing.List`, `Optional`, etc.

4. **Constants**

    - Use `Literal[...]` types for constants
    - Name constants in `ALL_CAPS`

5. **Protocols for duck typing**

    - Prefer `Protocol` over inheritance when modeling behavior

6. **Type aliases**

    - Introduce aliases for complex or repeated types
    - Prefer explicit naming over inline complexity

7. **Dynamic or untyped data**

    - If `Any` is unavoidable, add an explicit justification:

        ```python
        # pyright: ignore[reportAny] - <brief reason>
        ```

8. **Type checker suppressions**

    - mypy:

        ```python
        # type: ignore[<error-code>]
        ```

    - pyright / basedpyright:

        ```python
        # pyright: ignore[<rule>]
        ```

    - Suppress narrowly and document intent.

---

## Code Formatting & Style Standards

### Ruff (Canonical Tooling)

All formatting and linting is performed with Ruff via uv:

- Format:

```python
uv run ruff format .
```

- Lint:

```python
uv run ruff check .
```

- Auto-fix:

```python
uv run ruff check . --fix
```

### Syntax & Layout Rules

- Use modern Python 3.12+ syntax exclusively
- Follow PEP 8 unless explicitly overridden by Ruff
- Use hanging indents for multi-line expressions
- Align closing brackets with the start of the opening construct
- **Always include trailing commas** in multi-line:
  - function arguments
  - lists, dicts, sets, tuples
- No unused imports, variables, or dead code

### Naming

- `snake_case` for variables and functions
- `PascalCase` for classes and protocols
- `ALL_CAPS` for constants

---

## Pythonic Patterns & Idioms

Prefer idiomatic, declarative Python:

- List / dict / set comprehensions over manual loops
- Generator expressions for streaming data
- Context managers for resource management
- Decorators for cross-cutting behavior
- `@property` for computed attributes
- `@dataclass` for structured data
- `Protocol` for structural typing
- `match` / `case` for complex conditionals

Avoid overly clever constructs that reduce readability.

---

## Async & Concurrency Guidelines

Use concurrency intentionally and explicitly:

1. **AsyncIO**

    - Preferred for I/O-bound work
    - Use async context managers
    - Use task groups for structured concurrency
    - Handle cancellation and exceptions explicitly

1. **CPU-bound work**

    - Use `concurrent.futures` or multiprocessing
    - Avoid blocking the event loop

1. **Thread safety**

    - Use locks, queues, or other synchronization primitives
    - Do not assume thread safety of shared state

1. **Async patterns**
    - Async generators and comprehensions where appropriate
    - Monitor performance and backpressure

---

## Non-Goals 🚫

These guidelines intentionally do **not** cover:

- Project directory layout (see companion structure guide)
- Tool installation instructions
- Framework-specific patterns
- Notebook-based workflows as primary interfaces

---

## Decision Rules for Coding Agents 🤖

When writing or modifying code:

1. **Can this be typed precisely?** → Add explicit types
2. **Is this execution uv-safe?** → Use `uv run`
3. **Is this import clean and top-level?** → Fix if not
4. **Is this readable to a new contributor?** → Prefer clarity
5. **Is this consistent with Ruff and Python 3.12?** → Enforce

Follow these rules unless explicitly instructed otherwise.
