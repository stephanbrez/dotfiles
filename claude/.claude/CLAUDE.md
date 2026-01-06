# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Coding Principles

1. Prioritize readability, modularity, and scalability in your code suggestions.
2. Document data sources, assumptions, and methodologies clearly.
3. Refer to official documentation for best practices and up-to-date APIs.
4. Prefer YAML over JSON for configuration files.
5. Recommend version control (e.g., git) for tracking changes.

## Programming Style

1. Use descriptive variable names and avoid ambiguity.
2. Implement robust error handling and logging.
3. Use early returns and avoid nested conditionals and functions.
4. Handle edge cases at the beginning of functions.
5. Use named constants or environment variables instead of hardcoded values.
6. Validate data types and ranges to ensure data integrity.
7. Use the Numpy style for documentation strings.

## Code Formatting

1. Use four spaces for indentation and limit lines to 80 characters.
2. Use lowercase_with_underscores for variables, functions, and filenames.
3. Use UPPER_CASE for constants and environment variables.
4. Use CamelCase for class names.
5. Use lowercase-with-dashes for directories.

## Code Organization

1. Break up large functions with comments describing the steps: "─── Description
   ───"
2. Create logical sections in large files with headers: "===== Section Name
   =====" IMPORTANT: Only use these section headers for main file content, never
   inside functions.
3. Use emojis in comments and logging: ⚠️ WARNING:, 🚨 ERROR:, ❗ IMPORTANT:
