---
name: tech-digest
description: Generate a curated tech digest of the latest news, releases, and articles across Android, Kotlin, Ktor, Kotlin Multiplatform (KMP), AI, Claude/Anthropic, system design, design patterns, and software engineering. Always use this skill when the user asks for a "дайджест", "digest", "що нового", "what's new", "останні новини", "tech news", "свіже по Kotlin/Android/AI", or any request to round up recent developments in these topics. The skill performs live web searches and produces a compact digest with working links. Use it even if the user only names a subset of topics (e.g. "дайджест по Kotlin і AI"). On every run it also surfaces context-aware items based on the current repo stack, recent git activity, and memory files, and uses that context to filter and rank the standard topics.
---

# Tech Digest

Generates a compact, link-rich digest of the latest developments across Danylo's core interest areas. Output is in Ukrainian.

## Topics covered

Default scope (search all unless the user narrows it):
1. **Android** — Jetpack, Compose, AGP/Gradle, tooling, Google releases
2. **Kotlin** — language releases, KEEP proposals, compiler, stdlib
3. **Ktor** — server/client releases, plugins, features
4. **KMP** — Kotlin Multiplatform, Compose Multiplatform, shared logic
5. **AI** — models, agentic tooling, dev workflow, notable papers/launches
6. **Claude / Anthropic** — new models, Claude Code, API, skills, agent SDK
7. **System Design** — distributed systems, scalability, architecture writeups
8. **Design Patterns / Software** — engineering practices, notable OSS, refactoring/architecture articles

Plus one context-driven section appended after the eight (see "Context personalization").

## Context personalization

On every run, derive the user's working context and use it to (a) filter/rank the eight standard topics and (b) build one narrow section of items those topics don't cover.

**Sources of context (read these before searching):**
- **Current repo** — `CLAUDE.md`, build files (`build.gradle.kts`, `gradle/libs.versions.toml` / version catalog) for the stack and key libraries; `git log --since="14 days ago" --oneline` (or `git diff`) for what's being actively worked on.
- **Memory files** — `MEMORY.md` index plus `project_*` (current initiatives, e.g. active epic/task) and `user_profile.md` (long-term interests). The memory dir lives under the project's `.claude/projects/.../memory/` path surfaced in context.

**How context drives the digest:**
- **Filter/rank the 8 topics** — drop a standard topic if the stack clearly has no use for it (e.g. no Android in the repo → skip Android), and rank items within a topic toward the detected stack.
- **Build the 9th section** (`## 🎯 Під твій контекст`) — narrow finds tied to actual dependencies / current tasks that the broad topics miss (e.g. Exposed / Koin / Flyway releases, a security advisory on a used dependency, an article on a pattern currently being applied). Never duplicate an item already shown under the 8 topics.

**Search budget — max 3 extra searches for the 9th section, by priority:**
1. Current activity — last ~14 days of git + active epic/task from memory `project_*` → 1–2 queries.
2. Top stack dependency NOT covered by the 8 topics (e.g. Exposed, Flyway) → 1 query.
Recent activity outranks static dependencies (you touch code daily; a library releases monthly).

**Graceful degradation:**
- No git repo / no memory / no fresh activity → silently omit the 9th section; keep the 8 topics at their defaults.
- Foreign stack (Python, JS, …) → the 9th section adapts to the *actual* repo stack; the 8 Kotlin/Android topics remain as the standing radar.
- Never fall back to a hardcoded profile, and never ask the user which stack to use — keep it "straight to the digest".

## Workflow

1. **Scope.** If the user named specific topics, restrict to those. Otherwise cover all eight.
2. **Gather context.** Read the context sources (see "Context personalization"): repo stack + key libraries, last ~14 days of git activity, and memory `project_*` / `user_profile.md`. Use it to decide which of the 8 topics to keep/rank and to derive ≤ 3 narrow queries for the 9th section. Skip silently if no context is available.
3. **Search.** Run one **`WebSearch`** call per topic (or per narrowed topic), plus the ≤ 3 context queries. Use recency-biased queries — include the current year and words like "release", "new", "latest", "changelog", "2026". Examples:
   - `Kotlin release 2026`
   - `Jetpack Compose latest 2026`
   - `Ktor new version 2026`
   - `Kotlin Multiplatform news 2026`
   - `Anthropic Claude announcement 2026`
   - `AI agent tooling news 2026`
   - `system design article 2026`
   - `software architecture patterns 2026`
   - context examples: `Exposed ORM Kotlin release 2026`, `Flyway PostgreSQL 2026`, `<active-task-topic> 2026`
4. **Filter.** Keep only genuinely recent and substantive items (prefer last 1–2 months). Drop SEO listicles, reposts, and low-signal aggregators. Favor primary sources: official blogs (Kotlin, Android Developers, Anthropic), GitHub releases, KEEP, peer writeups with depth. For the 9th section, drop anything already shown under the 8 topics.
5. **Verify links.** Every item MUST carry a real URL taken verbatim from the `WebSearch` results — copy the exact `url` field, do not shorten or guess it. If unsure a link is valid, use **`WebFetch`** to confirm before including. Never invent URLs. If an item has no usable source URL, drop the item rather than printing it without a link.

> Tool names are case-sensitive: the search tool is `WebSearch` and the fetch tool is `WebFetch`. There is no `web_search` / `web_fetch`.
6. **Compose digest.** Follow the output format below.

## Output format

Markdown directly in chat (not a file unless asked). Structure:

```
# 📰 Tech Digest — <дата>

> 🧭 Контекст: стек — <напр. Kotlin/Ktor/Exposed/Koin/Postgres>; активне — <напр. spovishun-93 (dogfooding), update-doc-full>; інтереси — <напр. agentic AI, KMP>.

## 🤖 Android
- **<заголовок>** — одне речення суті. [джерело](url)

## 🟣 Kotlin
- ...

## ⚡ Ktor
...

## 🎯 Під твій контекст
- **<заголовок>** — чому релевантно саме твоїй задачі/залежності. [джерело](url)
```

Rules:
- Put the `> 🧭 Контекст:` callout directly under the title, before the topic sections. It names the detected stack, active tasks, and interests so the picks are auditable. Omit it only when no context was found.
- Only include a topic heading if there's at least one fresh item for it. Skip empty topics silently.
- 1–4 items per topic. Quality over volume.
- Each item: bold title, one sentence of why it matters (Danylo's stack context — Clean Architecture, Koin, Coroutines, бот на Kotlin/Ktor), then a working link.
- `## 🎯 Під твій контекст` is the last section before the final line: 2–4 narrow items tied to the detected stack/tasks, none duplicating the 8 topics. Omit the whole section if context yielded nothing fresh.
- Keep the whole digest scannable — aim for one to two screens.
- End with one optional line: «🔎 Що варто глибше копнути:» + the single most relevant item for Danylo's current work (Spovishun bot, KMP, agentic AI workflow), if one stands out. Skip if nothing fits.
- Respect copyright: paraphrase, never quote source text beyond a few words.

## Notes

- Default language: Ukrainian. Match Danylo's preferences — no fluff, no intros, straight to the digest.
- Each run is live: re-search every time, never reuse stale results from earlier in the conversation unless the user asks to continue a previous digest.
- If a topic returns nothing fresh, omit it rather than padding with old news.
