# Development Guide

These rules apply to every task unless explicitly overridden. Prefer caution,
clarity, and minimal changes over speed.

## 1. Work Approach

- State assumptions on non-trivial work.
- Ask when requirements are unclear; do not guess.
- Prefer the simplest complete solution.
- Push back when a simpler approach exists.
- Define success criteria before implementation.
- Stop and surface confusion, conflicts, skipped work, or uncertainty.
- Build minimal functionality first, verify it, then add complexity only when
  needed.

## 2. Code Changes

- Read relevant exports, callers, shared utilities, and nearby patterns before
  editing.
- Touch only what the task requires; do not refactor, reformat, or improve
  adjacent code unless required.
- Clean up only your own changes.
- Match existing codebase conventions; when conventions conflict, choose one
  deliberately and explain why.

## 3. Coding Standards

- Prioritize readable, modular, scalable code with descriptive names and
  single-purpose units.
- Use early returns, upfront edge-case handling, robust validation, error
  handling, and logging.
- Use named constants or environment variables instead of hardcoded values.
- Prefer functional, stateless, and immutable approaches where practical.
- Follow DRY unless abstraction would add unnecessary complexity.
- Document data sources, assumptions, methodologies, and public APIs with
  NumPy-style docstrings.
- Check official documentation for current APIs and patterns when needed.

## 4. Formatting and Naming

- Limit lines to 80 characters where practical.
- Use `lowercase_with_underscores` for variables, functions, and filenames.
- Use `UPPER_CASE` for constants and environment variables.
- Use `CamelCase` for class names.
- Use `lowercase-with-dashes` for directories.
- Prefer YAML over JSON for configuration files unless JSON is required.

## 5. Code Organization

- Break up large functions with step comments using: `─── Description ───`.
- Create sections in large files with headers using: `===== Section Name =====`.
- Use section headers only for main file content, never inside functions.
- Use emojis in comments and logging for clarity, e.g. `⚠️ WARNING:` for
  potential issues or deprecated features.

## 6. AI-Assisted Work

Use AI for judgment tasks: classification, drafting, summarization, extraction,
and tradeoffs. Use code for deterministic work: routing, retries, transforms,
and verification.

## 7. Testing and Verification

- Tests should verify intent, not just behavior.
- A test is weak if it would still pass after the business logic breaks.
- Run relevant tests, linters, formatters, or type checks before marking work
  complete.
- State what was verified, skipped, untested, or uncertain.
- Do not say work is complete if anything required was skipped.
- Do not say tests pass if relevant tests were skipped.

## 8. Checkpoints

After every significant step, summarize what changed, what was verified, what
remains, and any uncertainty. If the current state is unclear, stop and restate
it before continuing.

## 9. Version Control

- Use git for tracking changes when appropriate.
