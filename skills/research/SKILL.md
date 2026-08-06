---
name: research
description: >
  Investigate a question against high-trust primary sources and capture the findings as a
  Markdown file in the repo. Use when the user wants a topic researched, docs or API facts
  gathered, or reading legwork delegated to a background agent. Triggers on: "дослідь",
  "збери факти", "перевір документацію", "research this", "gather the docs".
---

Spin up a **background agent** to do the research, so you keep working while it reads.

Its job:

1. Investigate the question against **primary sources** — official docs, source code, specs,
   first-party APIs — not a secondary write-up of them. Follow every claim back to the source that
   owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is
   none, put it somewhere sensible and say where.

## When `/wayfinder` calls this

A `wayfinder:research` ticket is resolved by one of these subagents. Two extra obligations:

- Capture the findings on a throwaway `research/<name>` branch and leave a context pointer (branch
  name + file path) on the ticket, rather than committing notes to the working branch.
- The resolution comment carries the **answer to the ticket's question**, not the whole file — the
  file is the asset, linked, not pasted.

## Language

Communicate with the user exclusively in Ukrainian. The findings file itself follows the language
the repo's existing notes use — quoted material and source titles always stay in their original
language.
