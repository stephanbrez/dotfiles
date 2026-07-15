---
name: review-journals
description: Review and process past Obsidian daily journal entries over a date range. Summarizes content, suggests where to move ideas into permanent notes, and supports interactive editing. Use when the user wants to review journals, process daily notes, or catch up on past entries. Invoked as /review-journals with a date range argument.
---

# Review Journals Skill

Process past daily journal entries from an Obsidian vault. Summarize content, suggest where ideas should be moved into the vault's knowledge structure, and interactively help the user refine their notes.

## Invocation

The user provides a date range as the skill argument:

```
/review-journals this week
/review-journals last 30 days
/review-journals january 2026
/review-journals 2025-01-01 - 2025-03-31
```

## Workflow

### Phase 1: Load and Summarize

1. **Parse the date range.** Run the bundled script to resolve the date range into journal file paths:

   ```bash
   python3 <skill_path>/scripts/parse_dates.py "<user_argument>" --vault-path "<vault_path>"
   ```

   - `<vault_path>` is the current working directory (the Obsidian vault root).
   - The script prints matching file paths to stdout (one per line) and metadata to stderr.
   - If no files are found, tell the user and stop.

2. **Read each journal file.** For each file returned by the script, read its full contents.

3. **Summarize each entry.** For each journal, produce a concise summary:
   - **Date** — the journal date as a heading
   - **Summary** (2-4 bullet points) — key topics, ideas, or events captured
   - **Action items** — any todos, tasks, or commitments mentioned (if any)
   - Flag entries that are empty or contain only template boilerplate as "Empty / template only"

4. **Present all summaries** to the user in chronological order. At the end, include a count: "Reviewed N journals, M with substantive content."

### Phase 2: Suggest Destinations

After presenting summaries, for each journal with substantive content, suggest where its content could live permanently in the vault:

1. **Existing notes to link to.** Search the vault for notes that relate to the journal's topics:
   - Search `Connect/` for matching `§` farm/topic notes (e.g., if the journal discusses AI, suggest `[[§ AI]]`)
   - Search `Create/` and `Capture/` for notes with overlapping themes
   - Use Grep to find notes mentioning the same key terms

2. **New notes to create.** If an idea in the journal is substantial enough to stand alone:
   - Suggest a filename following vault conventions (e.g., `∞ idea-name` for saplings in `Create/`)
   - Suggest which 3C directory it belongs in (Capture, Create, or Connect)
   - Suggest initial `topics:` frontmatter values

3. **Topic links to add.** Suggest `[[§ Topic]]` wikilinks for the journal's `topics:` frontmatter field based on its content.

Present suggestions grouped by journal entry. Keep suggestions concise — 1-3 per entry.

### Phase 3: Interactive Editing

After presenting summaries and suggestions, ask the user what they'd like to do. Support these actions:

- **Move content** — Extract content from a journal entry and create a new note or append to an existing note, following vault conventions:
  - Use wikilinks (shortest-path format)
  - Apply appropriate frontmatter based on note type (use templates in `templates/` as reference)
  - Add a `🍄::` root link back to the journal in the new note
  - Add a `🍊::` fruit link in the journal pointing to the new note

- **Add topic links** — Update the journal's `topics:` frontmatter with suggested or user-specified `[[§ Topic]]` wikilinks

- **Update processing status** — Set `journal-process:` in frontmatter to indicate the entry has been reviewed

- **Skip** — Move on to the next entry or end the review

- **Regenerate** — Re-summarize a specific entry with more or less detail

## Vault Conventions (Reference)

These conventions MUST be followed when creating or editing notes:

- **Frontmatter property names**: `lowercase-with-dashes` (kebab-case)
- **Wikilinks**: shortest-path format — `[[Note Name]]`, never absolute paths
- **New files**: default to `Create/` unless the content type suggests otherwise
- **Attachments**: go in `Assets/`
- **Filename prefixes**: `§` for farms/topics, `∞` for saplings, `π` for orchards, `@` for people, `book.`/`article.`/`video.`/`podcast.` for captures
- **Topic links**: `[[§ Topic Name]]` format in `topics:` frontmatter (YAML list of wikilinks)
- **Branches** (`🌿::`): links to similar/related notes
- **Roots** (`🍄::`): sources that informed a note
- **Fruit** (`🍊::`): outputs or creations derived from a note

## Important

- Always read journal files before summarizing — never guess at content.
- Present summaries BEFORE suggesting changes — let the user see the landscape first.
- Do not modify any files without explicit user approval.
- When creating new notes, check if a similar note already exists before suggesting creation.
- Keep summaries factual and concise — do not editorialize or add interpretation.
