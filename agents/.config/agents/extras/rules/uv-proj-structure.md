# Python Project Structure Guidelines (uv-Only, for Coding Agents)

These guidelines define a **default, broadly applicable** layout for Python
packages, libraries, and services **using uv exclusively** for dependency
management and environment orchestration. Prefer **boring, standard** structure
unless a strong reason exists to deviate.

## Goals ✅

- **Installable package** with clear import paths
- **Fast, reliable tests** with clean separation from runtime code
- **Reproducible builds** via `pyproject.toml` + `uv.lock`
- **Deterministic tooling** using uv-managed environments
- **Clear places** for data, docs, examples, benchmarks, and scripts
- **Minimal surprises** for contributors and automation

## Recommended Default Layout

```bash
project-name/
├─ pyproject.toml
├─ uv.lock
├─ README.md
├─ LICENSE
├─ CHANGELOG.md
├─ .gitignore
├─ .python-version                      # optional (pyenv / uv pin)
├─ src/
│  └─ package_name/
│     ├─ **init**.py
│     ├─ py.typed                       # optional (if distributing type hints)
│     ├─ **main**.py                    # optional (python -m package_name)
│     ├─ cli.py                         # optional (CLI entrypoints)
│     ├─ config.py                      # optional
│     ├─ logging.py                     # optional
│     ├─ exceptions.py                  # optional
│     ├─ constants.py                   # optional
│     ├─ _version.py                    # optional (single source of truth)
│     ├─ internal/                      # optional (non-public modules)
│     └─ ...                            # package modules
├─ tests/
│  ├─ conftest.py
│  ├─ unit/
│  ├─ integration/
│  ├─ e2e/                              # optional
│  ├─ fixtures/                         # test-only assets (goldens, inputs)
│  └─ data/                             # small test datasets only
├─ examples/                            # runnable, user-facing examples
├─ docs/                                # documentation sources
├─ scripts/                             # automation helpers (not importable code)
├─ tools/                               # dev tools (lint wrappers, release helpers)
├─ data/                                # non-test data (see rules below)
├─ notebooks/                           # optional (exploration only)
├─ benchmarks/                          # optional (e.g., pytest-benchmark, asv)
└─ .github/
└─ workflows/                        # CI pipelines

```

## Core Principles 📌

### 1) Use the `src/` layout for packages

- **All importable runtime code goes under `src/`.**
- Prevents accidental imports from the repo root during tests.
- Ensures tests validate the package as installed by uv.

**Rule:** Anything meant to be imported by users must live in
`src/package_name/`.

### 2) Keep `tests/` fully separate from runtime code

- Tests must not be importable as part of the package distribution.
- Organize tests by scope:
  - `tests/unit/` — isolated behavior, fast
  - `tests/integration/` — component interactions
  - `tests/e2e/` — full system (optional)

**Rule:** Put fixtures and test-only sample inputs in `tests/fixtures/` or
`tests/data/`.

### 3) Avoid mixing “examples” with “tests”

- **Examples** are for users and should be runnable via `uv run`.
- **Tests** are for validation and CI.

**Rule:** If it is intended for documentation or user learning, it belongs in
`examples/`, not `tests/`.

### 4) Data placement rules

Data can mean different things. Use these conventions:

#### `tests/data/` and `tests/fixtures/`

- Small datasets used in tests only.
- Lightweight and version-controlled.

#### `data/`

- Project data that is not purely test-only.
- Sample datasets, schemas, reference artifacts, configuration templates.

**Rule:** Keep `data/` small and stable. Large or volatile datasets should be
external and fetched explicitly (document the process).

### 5) Scripts are not libraries

`scripts/` is for one-off runnable utilities:

- migration helpers
- dataset fetchers
- release tasks
- maintenance commands

**Rule:** Scripts may import from `src/`, but `src/` must not depend on
`scripts/`.

## uv-Specific Rules 🧪⚡

### 1) `pyproject.toml` is the single source of truth

- All dependencies, metadata, and tool configuration live in `pyproject.toml`.
- Avoid separate config files (`setup.cfg`, `requirements*.txt`) unless
    strictly required.

**Rule:** If a tool supports `pyproject.toml`, configure it there.

### 2) Always commit `uv.lock`

- `uv.lock` provides deterministic resolution for all environments.
- CI, local dev, and automation must rely on it.

**Rule:** Any dependency change requires updating `uv.lock`.

### 3) Dependency groups instead of requirements files

Use uv dependency groups for separation of concerns:

- Runtime dependencies → `project.dependencies`
- Development tools → `dependency-groups.dev`
- Testing tools → `dependency-groups.test`
- Docs, linting, etc. → separate groups as needed

**Rules:**

- Do not add dev-only tools to runtime dependencies.
- Prefer small, purpose-specific groups over one large “dev” group.

### 4) No `requirements.txt` by default

For uv-only projects:

- Do **not** include `requirements.txt`, `requirements-dev.txt`, etc.
- Only add them if interoperability with non-uv tooling is explicitly
    required.

### 5) Running commands via uv

All commands should be executed through uv-managed environments:

Examples:

- `uv sync`
- `uv run pytest`
- `uv run python examples/basic.py`
- `uv run ruff check .`

**Rule:** Do not assume a globally installed Python environment.

### 6) CI is uv-native

CI workflows should:

1. Install uv
2. Run `uv sync` (optionally with groups)
3. Execute commands via `uv run ...`

**Rule:** CI must never bypass uv by invoking system Python directly.

## Packaging and Metadata 🧱

### Required files

- `pyproject.toml` — build system, dependencies, tool config
- `uv.lock` — locked dependency graph
- `README.md` — overview, installation, usage
- `LICENSE` — required for open source; recommended otherwise

### Common optional files

- `CHANGELOG.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`

## Naming Conventions 🏷️

### Repository vs package naming

- Repo name must include hyphens: `project-name`
- Python package name must be import-safe: `package_name`

**Rule:** Keep `src/package_name/` aligned with the intended import path.

### Private vs public modules

- Use `_private.py` or `_internal/` for non-public APIs.

**Rule:** Only export the intended public surface from
`package_name/__init__.py`.

## Configuration & Settings ⚙️

### Runtime configuration

- Prefer explicit config objects and environment variables.
- Avoid heavy side effects at import time.

**Rule:** Configuration parsing should occur at runtime entrypoints, not module
import.

## CLI & Entry Points 🧰

If the project exposes a CLI:

- Place CLI code in `src/package_name/cli.py`
- Optionally include `__main__.py` to support:

```python
uv run python -m package_name
```

**Rule:** CLI layers must delegate to library code, not duplicate logic.

## Type Checking 🧠

If shipping type hints:

- Use inline annotations or `.pyi` stubs.
- Include `py.typed` in the package root.

**Rule:** If `py.typed` exists, ensure it is included in the built distribution.

## Testing Practices 🧪

Recommended baseline:

- `pytest`
- Deterministic, isolated tests
- No network or external services unless explicitly marked

**Rules:**

- Mark slow tests (e.g., `@pytest.mark.slow`)
- Use `tmp_path` for filesystem interactions
- Store golden files in `tests/fixtures/`

## Documentation 📚

`docs/` contains documentation sources:

- Markdown, Sphinx, or MkDocs inputs

**Rule:** Code samples should live in `examples/` and be referenced from docs.

## Notebooks 🧾 (Optional)

`notebooks/` is for exploration only.

- Convert stable insights into `examples/` or `docs/`.

**Rule:** Notebooks must never be required for core functionality.

## Benchmarks 🏁 (Optional)

`benchmarks/` for performance testing.

- Benchmarks are not tests.
- Benchmark dependencies belong in a separate dependency group.

## What NOT to do 🚫

- Put importable code at repository root
- Put tests inside `src/`
- Make runtime code depend on `tests/`, `docs/`, or `scripts/`
- Commit large datasets directly into `data/`
- Execute expensive work at import time
- Bypass uv by calling system Python in automation

## Minimal Template (Library)

```bash
project/
├─ pyproject.toml
├─ uv.lock
├─ src/
│  └─ package_name/
│     ├─ **init**.py
│     └─ core.py
└─ tests/
├─ conftest.py
└─ unit/
└─ test_core.py
```

## Minimal Template (CLI Tool)

```bash
project/
├─ pyproject.toml
├─ uv.lock
├─ src/
│  └─ package_name/
│     ├─ **init**.py
│     ├─ cli.py
│     └─ **main**.py
└─ tests/
└─ unit/
└─ test_cli.py
```

## Decision Rules for Coding Agents 🤖

When adding new files:

1. **Is it importable runtime code?** → `src/package_name/...`
2. **Is it a test?** → `tests/...`
3. **Is it a runnable example?** → `examples/...`
4. **Is it documentation source?** → `docs/...`
5. **Is it automation or maintenance?** → `scripts/...` or `tools/...`
6. **Is it data?**
    - test-only small → `tests/data/` or `tests/fixtures/`
    - project sample/reference small → `data/`
    - large/unstable → external (document retrieval)
