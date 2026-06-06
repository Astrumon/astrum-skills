---
name: explain-code
description: Explains a file, function, class, PR, or diff with a layered walkthrough (simple → advanced), an ASCII flow diagram, and Feynman-style gap-checking — to help the reader learn the code, not just read a summary. Adapts to whatever architecture and patterns the current project actually uses. Read-only — never edits code. Use when the user says "поясни код", "як це працює", "розбери файл", "explain this", "walk me through", "explain this PR/diff", "онбординг по цьому модулю", or asks to understand or learn part of a codebase.
---

# Explain Code

Teach the reader a piece of code — don't just describe it. Optimised for learning and onboarding in any codebase.

## Quick start

Given a target (file path, function/class name, `git diff`, or PR), produce four sections in order:

1. **TL;DR** — 1–2 sentences: what this does and where it sits in the system.
2. **Layered walkthrough** — *Simple* (plain language) → *Mechanics* (step by step) → *Advanced* (edge cases, concurrency, failure modes).
3. **Flow diagram** — an ASCII diagram of control/data flow (format below).
4. **Check your understanding** — 2–4 Feynman-style questions that expose likely gaps, each with a short answer.

## Workflow

1. **Locate the target.** Read the actual code. For a PR/diff, read the changed hunks *and* the surrounding context — never explain a diff in isolation.
2. **Learn the project's own conventions first.** Before explaining, ground yourself in *this* codebase:
   - Read `CLAUDE.md` / `README` / `ARCHITECTURE` if present — they name the project's layers, patterns, and vocabulary.
   - Infer the architecture from structure (e.g. layered/Clean, MVC, hexagonal, feature-modules) and the language's idioms.
   - Identify the project's recurring patterns (its error-handling type, its DB/IO boundary, its DI mechanism, its request/command flow) and **use the project's real names for them**, not generic textbook labels.
3. **Place the unit in the system.** State which layer/module/boundary it belongs to — this frames the whole explanation.
4. **Write the layered walkthrough.** Keep each layer at a uniform altitude — don't mix "it greets the user" with "it acquires a connection from the pool" in one sentence. Progress simple → advanced.
5. **Draw the flow diagram** (see format).
6. **Surface gaps Feynman-style.** Ask the questions a sharp reviewer would. If a step is awkward to explain, that awkwardness *is* the lesson — call it out instead of glossing over it.
7. **Stop at explaining.** This skill teaches only. If you spot a bug or smell, name it in one line and suggest a review/fix path — do not modify code.

## If the target is unclear

Never explain the wrong thing. Stop and ask, or narrow scope, in these cases:

- **Ambiguous target** — the name matches multiple symbols/files, or "explain this" has no clear referent. Stop and ask the user which one, listing the candidates you found.
- **Not found** — the file/function/PR doesn't exist or can't be read. Report that plainly; do not explain from the name alone.
- **Empty/no-op diff** — the diff or PR has no substantive changes (whitespace, already merged). Say so instead of inventing a rationale.
- **Too large to cover well** — the target exceeds what a focused explanation can cover. Explain the requested slice and explicitly name what you skipped — never flatten the whole thing into a shallow summary.
- **No project conventions found** — if `CLAUDE.md`/`README`/`ARCHITECTURE` are absent, say you're inferring patterns from code structure rather than asserting them as established.

## Related skills

This skill **teaches** code — it is not a reviewer, designer, or fixer:

- For finding bugs, security, or quality issues → use a **code-review** skill, not this one.
- For designing new structure or weighing trade-offs → use an **architecture/design** skill.
- For changing code → this skill never edits; hand off to the appropriate implementation flow.

(Skill names vary per project; pick the installed equivalent.)

## Flow diagram format

Use a vertical ASCII flow. Tag each box with its layer/module. Generic shape:

```
[Entry point / trigger]
       │
       ▼
 (<layer>) <unit>            ── what it does, one phrase
       │  calls / returns
       ▼
 (<layer>) <next unit>       ── …
       │
       ▼
 [Result / side effect]
```

Adapt boxes to the code at hand (request handler chain, data pipeline, state machine, event flow). Keep the layer/module tags — they are what makes the diagram teach architecture, not just call order.

## Examples / Common patterns

- **"поясни цю функцію"** → TL;DR + 3-level walkthrough + small diagram of its inputs → transforms → output; gap question on its preconditions or failure path.
- **"explain this PR/diff"** → read context around the hunks, explain *why* it changes behaviour (not just what lines moved), diagram the before→after flow, gap question on what could regress.
- **"онбординг по цьому модулю"** → start at the module's public entry points, explain how a request/command travels through it, name the project's own patterns, end with questions a new hire should be able to answer.

## Constraints

**MUST DO**
- Read the real code before explaining; quote actual identifiers and `file_path:line`.
- Detect and use the project's own architecture and pattern names (read `CLAUDE.md`/`README` first).
- State the layer/module of every explained unit.
- Keep each walkthrough layer at one altitude; progress simple → advanced.
- End with Feynman-style gap questions + brief answers.
- Match the question's depth — don't pad with theory the reader didn't ask for.

**MUST NOT DO**
- Edit, refactor, or "fix while explaining" — strictly read-only.
- Invent patterns the project doesn't use, or force a generic template onto code that doesn't fit it.
- Explain a diff/PR without reading the surrounding context.
- Assume a specific framework/architecture before checking what the project actually uses.
