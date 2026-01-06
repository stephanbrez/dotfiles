---
name: generating-commit-messages
description:
    Generates clear commit messages from git diffs. Use when writing commit
    messages or reviewing staged changes.
---

# Generating Commit Messages

## Instructions

1. Run `git diff --staged` to see changes
2. I'll suggest a commit message with:
    - A prefix from this list: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`,
      `perf:`, `test:`, `revert:`, `chore:`
    - An optional affected scope immediately following the prefix in parenthesis
      e.g. "feat(core): ", "refactor(cli): "
    - Summary under 50 characters
    - Detailed description
    - Affected components

## Best practices

- Use present tense
- Explain what and why, not how
