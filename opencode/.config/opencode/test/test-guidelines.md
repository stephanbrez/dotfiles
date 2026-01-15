# Test Automation Guidelines (General, for Coding Agents)

These guidelines define **how to design, write, organize, maintain, and evaluate
automated tests** across languages and ecosystems. They are
**framework-agnostic** and optimized for:

- **High-signal coverage**
- **Fast feedback**
- **Deterministic, reliable results**
- **Clear failure analysis**
- **Ease of fixing failures by coding agents**

They apply to **unit, integration, system, and end-to-end tests**, as well as
test-related scripting and automation.

## Core Objectives 🎯

All test automation must optimize for:

1. **Bug detection**
    - Catch regressions early and precisely
2. **Fast feedback**
    - Enable tight edit–test–fix loops
3. **Reliability**
    - Deterministic behavior with zero tolerance for flakiness
4. **Fixability**
    - Failures must clearly explain _what broke_, _where_, and _why_

A test that is hard to interpret or diagnose is considered **low quality**, even
if technically correct.

## Test Types & Scope

### 1) Unit Tests

**Purpose**

- Validate behavior of a single function, method, or small component in
    isolation

**Rules**

- No network access
- No real filesystem writes (use temporary or isolated mechanisms)
- No reliance on real time, randomness, or environment unless explicitly
    controlled
- Extremely fast execution (milliseconds per test)

**Design Guidelines**

- One logical behavior per test
- Explicit inputs and outputs
- Failures should localize to a very small region of code

### 2) Integration Tests

**Purpose**

- Validate interactions between multiple components or subsystems

**les**

- Scope must be intentional and limited
- External dependencies must be:
  - stubbed
  - containerized
  - or explicitly provisioned

**Design Guidelines**

- Focus on boundaries (APIs, persistence layers, service contracts)
- Avoid exhaustive combinations; test representative paths
- Reset state fully between runs

### 3) System / End-to-End Tests

**Purpose**

- Validate complete workflows from a user-facing perspective

\*ules\*\*

- Fewer tests, broader coverage
- Explicitly marked and optionally excluded from fast feedback loops
- Stable, isolated environments only

**Design Guidelines**

- Test critical user journeys
- Failures must indicate _which step_ of the workflow failed

## Test Structure & Organization

### Separation by Intent

Organize tests by **scope and responsibility**, not by implementation detail.

**Rule:** A test’s location and naming must make its intent obvious without
reading the code.

### Naming Conventions

- Names must describe **behavior**, not implementation
- Prefer:
  - `when_<condition>_<expected_behavior>`
  - `given_<state>_<outcome>`
- Avoid:
  - `test_basic`
  - `test_case_1`
  - `test_works`

**Rule:** A failing test name alone should communicate why the test exists.

## Assertions & Failure Messages

### Assertions

- Prefer few, strong assertions
- Assert outcomes, not incidental implementation details
- Avoid over-asserting on derived or redundant values

### Failure Output (Critical)

A failure must answer:

1. What was expected?
2. What actually happened?
3. Under what conditions?

**Rules**

- Include contextual values in assertion output
- Avoid opaque equality checks for complex objects
- Prefer structured diffs when available

A test that fails cryptically is a **liability**, not an asset.

## Test Data & Fixtures

### Fixtures

- Use fixtures to express intent and reduce duplication
- Keep fixtures minimal and explicit

**Rules**

- Fixtures must be deterministic
- Avoid deeply nested or implicit fixture chains
- Override fixtures explicitly; never mutate shared state

### Test Data

- Small, human-readable, version-controlled
- Representative, not production-scale

**Rule:** If a coding agent cannot quickly inspect test data, it is too complex.

## Determinism & Reliability (Strict)

### Flakiness Policy (Aggressive)

A flaky test is one that fails intermittently without code changes.

**Policy**

- **Zero tolerance for flaky tests**
- Any detected flakiness must be treated as a failure of the test suite

**Required Actions**

- Immediately quarantine or disable the flaky test
- Investigate root cause
- Fix or remove the test promptly

**Rule:** Trust in test automation is more important than test count.

### Isolation

- Every test must run independently
- No reliance on execution order or shared state
- Cleanup must be automatic and guaranteed

## Performance & Feedback Speed

### Fast Feedback Pyramid

- Unit tests: overwhelming majority
- Integration tests: targeted and limited
- End-to-end tests: minimal and critical-path only

**Rules**

- Fast tests must be runnable on every change
- Slow tests must be clearly labeled
- Performance regressions must be detected intentionally

## Reporting of Test Results & Metrics 📊

### Test Result Reporting (Required)

Every test run must report:

- Total tests executed
- Passed / failed / skipped counts
- Total execution time
- Slowest individual tests

Results must be:

- **Human-readable** (clear summaries)
- **Machine-readable** (structured output)

### Coverage Metrics

Coverage is a **confidence indicator**, not a quality guarantee.

**Single Global Target**

- **Overall test coverage: ≥ 80%**

Guidance:

- Applies to runtime and public-facing code
- Exclusions must be explicit and documented
- Critical paths should exceed the baseline where practical

**Anti-Patterns 🚫**

- Writing meaningless tests to satisfy coverage
- Blanket exclusions without justification

## Failure Analysis & Debuggability 🔍

### Failure Quality Requirements

Failures must preserve:

- Relevant inputs
- State at time of failure
- Logs, traces, or error context

Failures should enable:

- Rapid classification (regression vs test defect vs environment)
- Narrowing the fix to a small search space

### Agent-Focused Design (Critical)

Tests must be written so that:

- A coding agent can infer the likely fix location
- The failure reduces ambiguity rather than increasing it

## Test Maintenance & Refactoring

### Tests Are First-Class Code

- Maintain tests with the same rigor as production code
- Refactor tests when intent becomes unclear

### Refactoring Policy (Strict)

Coding agents **may refactor tests only to improve signal**, including:

- clarity
- determinism
- failure diagnostics
- reduction of brittleness

**Agents must never:**

- weaken assertions
- broaden tolerances
- remove coverage of meaningful behavior
- change tests solely to make them pass

## Test Automation Scripts

### Purpose

Scripts may orchestrate:

- test subsets
- environment setup/teardown
- data seeding
- multi-step test flows

### Rules

- Scripts must be deterministic and idempotent
- Scripts must fail loudly and early
- Scripts must not contain business logic

**Rule:** Scripts support tests; they do not replace them.

## Decision Rules for Coding Agents 🤖

When writing or modifying tests:

1. **Is the intent obvious without reading production code?**
2. **Will the test fail deterministically?**
3. **Is the failure easy to diagnose?**
4. **Does it test behavior, not implementation?**
5. **Does it increase confidence meaningfully?**

If the answer to any is “no”, revise the test.

## Non-Goals 🚫

These guidelines intentionally do **not** prescribe:

- Specific testing frameworks
- Language-specific syntax
- CI configuration details
- UI testing strategies in depth

They define **principles, constraints, and quality bars**, not tools.
