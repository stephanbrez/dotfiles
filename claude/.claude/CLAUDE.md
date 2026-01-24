# Coding Project Rules

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Core Coding Principles

1. **Readability, Modularity, and Scalability**: Prioritize these qualities in
   all suggestions
2. **Documentation**: Ensure data sources, assumptions, and methodologies are
   clearly documented
3. **Best Practices**: Reference official documentation for current APIs and
   patterns
4. **Configuration**: Recommend YAML over JSON for configuration files
5. **Iterative Development**: Build minimal functionality first, verify before
   adding complexity
6. **Version Control**: Recommend git for tracking changes when appropriate

## Programming Style Guidelines

1. Use descriptive, unambiguous variable names
2. Implement robust error handling and logging throughout
3. Use early returns to avoid nested conditionals and functions
4. Handle edge cases at the beginning of functions
5. Use named constants or environment variables instead of hardcoded values
6. Validate data types and ranges to ensure data integrity
7. Write documentation strings in NumPy style
8. Prefer functional, stateless, and immutable approaches
9. Follow DRY principles (Don't Repeat Yourself)
10. Ensure modules, classes, and functions have single responsibility and are
    self-contained

## Code Formatting Standards

1. **Indentation**: Use four spaces, limit lines to 80 characters
2. **Naming Conventions**:
    - `lowercase_with_underscores` for variables, functions, and filenames
    - `UPPER_CASE` for constants and environment variables
    - `CamelCase` for class names
    - `lowercase-with-dashes` for directories

## Code Organization Requirements

1. Break up large functions with step comments using: `"─── Description ───"`
2. Create sections in large files with headers: `"===== Section Name ====="`
    - **IMPORTANT**: Only use section headers for main file content, never
      inside functions
3. Use emojis in comments and logging for clarity:
    - ⚠️ WARNING: For potential issues or deprecated features
    - 🚨 ERROR: For critical errors and exceptions
    - ❗ IMPORTANT: For crucial information or breaking changes
    - ✅ SUCCESS: For successful operations or validations
    - 🔍 DEBUG: For debugging information
    - 📝 NOTE: For general informational comments
    - 🚀 PERFORMANCE: For performance-related notes
    - 🔒 SECURITY: For security-related considerations
    - 💡 TIP: For helpful hints or best practices
    - 🧪 TEST: For testing-related comments
