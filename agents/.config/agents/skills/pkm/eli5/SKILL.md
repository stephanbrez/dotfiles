---
name: eli5
description: Explain a topic as if the reader knows nothing about it, delivered as a self-contained HTML file with big pictures and very few words. Use this skill whenever the user asks to "explain like I'm 5", wants a beginner-friendly or jargon-free breakdown of a concept, asks for an ELI5, or wants a topic made simple and visual — even if they don't explicitly say "HTML" or "eli5". Also use it when someone says they're new to a subject, confused by a concept, or need a plain-English explainer.
---

# ELI5

Explain a topic as though the reader has zero background knowledge, using a single self-contained HTML file built around big pictures and very few words.

The goal is genuine understanding, not a dumbed-down summary. A reader who knows nothing about the topic should finish the HTML file feeling like they "get it" — what it is, why it matters, and how it works at the most basic level.

## What makes a good ELI5

- **Big pictures, few words.** The HTML should be visual-first. Each section is an image (or diagram) with a one-or-two-sentence caption underneath. The pictures do the explaining; the words just point at what to look at.
- **No jargon.** If a technical term is unavoidable, define it inline in plain English the first time it appears — never assume the reader already knows it.
- **No circular definitions.** Don't define a word using the word itself or a close synonym. "A database is where you store data" is circular. "A database is like a filing cabinet that a computer can search instantly" is not.
- **Concrete analogies.** Tie every abstract concept to something the reader already encounters in everyday life (food, traffic, mail, shopping, cooking).
- **One idea per screen.** Break the topic into its smallest meaningful pieces and give each its own visual section. Scroll through the file top to bottom and the story builds naturally.

## Workflow

1. **Understand the topic and the gap.** Identify what the reader is most likely to already understand and what is genuinely new. The explanation bridges from the known to the unknown.

2. **Decompose into 3–7 core ideas.** Strip the topic down to its essential building blocks. If you can't explain it in fewer than seven pictures, the pieces are too big — split them further.

3. **Find or create visuals for each idea.**
   - Prefer real images, diagrams, or simple SVG illustrations embedded directly in the HTML (base64 or inline SVG so the file is fully self-contained).
   - When no suitable image exists, draw a simple inline SVG — boxes, arrows, and labels are enough. A crude but clear diagram beats a missing one.
   - Every image should be large and immediately readable on a phone screen.

4. **Write captions, not paragraphs.** Under each image, write one or two short sentences in plain English. If you find yourself writing a third sentence, the picture isn't doing its job — make a better picture or split the idea.

5. **Order for building understanding.** Start with the most familiar analogy, then layer in one new concept per section. A reader scrolling top to bottom should never hit an idea that depends on a later section.

6. **End with the "so what."** The final section answers why anyone should care — one picture, one sentence on what the reader can now do or understand that they couldn't before.

## HTML structure

Produce a single `.html` file with inline CSS (no external stylesheets or scripts). Use a layout like:

```
<h1>Topic Name — explained simply</h1>

<section>
  <img ... big, centered ...>
  <p>One or two plain-English sentences.</p>
</section>

<section>
  <img ...>
  <p>...</p>
</section>

...

<section>
  <img ...>
  <p>Why this matters: ...</p>
</section>
```

- Use generous spacing and large fonts; the file should feel like a picture book, not a document.
- Keep the total word count low — aim for under 150 words across the whole file for most topics.
- Save the file with a descriptive filename (e.g., `eli5-encryption.html`) and tell the user where it is.

## What to avoid

- Walls of text with a small decorative image.
- Jargon dropped in without definition.
- Definitions that use the term being defined.
- More than two sentences per image.
- External dependencies — the file must open standalone in any browser.
