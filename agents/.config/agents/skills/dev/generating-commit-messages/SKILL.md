---
name: generating-commit-messages
description:
    Generates conventional commit messages from git diffs. Use when writing
    commit messages or reviewing staged changes.
---

# Generating Commit Messages

## Instructions

1. Run `git diff --staged` to see changes
2. I'll suggest a commit message with:
    - A prefix from this list: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`,
      `perf:`, `test:`, `build:`, `ci:`, `revert:`, `chore:`
    - An optional affected scope immediately following the prefix in parenthesis
      e.g. "feat(core): ", "refactor(cli): "
    - A concise and specific summary
    - Detailed description
    - Affected components

## Best practices

- Use imperative mood: `add`, `fix`, `update`, `remove`.
- Explain what and why, not how
- Do not mention AI agents, prompts, or implementation attempts unless directly
  relevant.
- For breaking changes, use `!` and include a `BREAKING CHANGE:` footer.
