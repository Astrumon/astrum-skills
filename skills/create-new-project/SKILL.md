---
name: create-new-project
description: Bootstraps a complete new project from the shared Notion template — duplicates "TEMPLATE — New Project" in the Projects database, extracts all Notion anchor IDs, writes spovishun-skills.config.yaml, installs the spovishun-skills .claude/ stack, fills the project root page, archives placeholder records, sets up git (main/develop) with optional GitHub remote, and validates everything with doctor. Use ONLY for explicit project-setup requests: "насетап новий проект", "розгорни проект з шаблону", "bootstrap new project", "set up project from template", "створи проект з шаблону", or /create-new-project [name]. Do NOT trigger on a mere mention of a "new project" or a feature idea — discussing or brainstorming a project is not setting one up. Requires the spovishun-skills npm package and the Notion MCP connector.
---

# Create New Project

Bootstrap a new project end-to-end: Notion workspace structure + local `spovishun-skills` stack + git repository. The flow mirrors the SDLC Workflow doc ("Notion + Claude Code") and was extracted from real bootstraps (spovishun-admin, Shynok).

Communicate with the user in Ukrainian. Perform every step yourself except the ones explicitly marked as user-owned.

## Hard rules

1. **Never read, write, copy, or source `.env` files.** Token handling is entirely the user's job. You may only check that the `NOTION_TOKEN` environment variable is non-empty (`[ -n "$NOTION_TOKEN" ]`) — that check does not touch the file.
2. **Never duplicate the Notion template twice.** If `spovishun-skills.config.yaml` in the target folder already contains a non-empty `root_page_id`, the Notion side already exists — resume from a later step instead. A second duplicate silently creates a junk row in the Projects DB that the user then has to hunt down.
3. **Push to GitHub only after explicit confirmation.** Local commits that are part of the bootstrap are fine; anything leaving the machine is not.

## Prerequisites (check before starting)

- Node.js 18+ (`node --version`) and npm — the plugin and its CLI scripts need them.
- Notion MCP tools available (`notion-fetch`, `notion-duplicate-page`, `notion-update-page`, `notion-search`). Without MCP the Notion half cannot run — stop and tell the user.
- `gh` CLI — optional, only needed if the user wants a GitHub remote. Check lazily at that step, not upfront.

## Step 0 — Intake (one question block)

Ask everything at once, don't drip-feed:

1. **Project name** (e.g. "Shynok") — may come as the skill argument.
2. **Folder path** for the project (create it if missing; an existing non-empty folder is fine — this flow only adds files).
3. **Template URL** — optional. If not given, find the page titled `TEMPLATE — New Project` in the Projects database via `notion-search`. If search finds nothing or several candidates, ask for the URL.
4. **Design docs URL** — optional. Used later for the root-page overview and CLAUDE.md.

Derive and remember: `slug` = lowercase-kebab of the project name; `branch_prefix` = `feature/<slug>`.

## Resume logic

Before each step, check its observable outcome and skip the step if it's already done:

| Evidence | Conclusion |
|---|---|
| `spovishun-skills.config.yaml` exists with filled `root_page_id` | Template already duplicated — reuse those IDs, never re-duplicate |
| `.claude/` + `spovishun-skills.lock.yaml` exist | `install` already ran — skip (or run `sync` if config changed) |
| Root page already renamed (fetch it and look) | Skip rename/overview |
| No PLACEHOLDER records found in Tasks/Epics data sources | Skip archiving |
| `.git/` exists | Skip `git init`; still verify `main`/`develop` branches exist |

This makes the skill safe to re-run after any mid-flow failure.

## Step 1 — Duplicate the template in Notion

1. `notion-duplicate-page` on the template page. **Duplication is async** — the returned page exists immediately but its children populate with a delay. Fetch the new page; if `Board`/`Documentation` children are missing, wait a few seconds and fetch again.
2. Collect all anchor IDs by fetching the duplicated tree. The template has **fixed English titles** — navigate by them:

| Config key | Where it lives |
|---|---|
| `root_page_id` | the duplicated page itself |
| `database_id` | inline **Tasks** database on the **Board** child page |
| `docs_root_id` | **Documentation** child page |
| `claude_md_page_id` | **CLAUDE.md** page under Documentation |
| `categories.architecture/database/testing/cicd/features/aitools` | **Architecture / Database / Testing / CI/CD / Features / AI Tools** pages under Documentation |
| `epics_group_page_id` and `categories.epics` | **Epics** page under Documentation |
| `epics_database_id` | **Epics** database inside the Epics page |

Use the *database* IDs (from `<database url=...>`), not the `collection://` data-source IDs, for `database_id` / `epics_database_id`.

## Step 2 — Write local config files

Show the user one preview of the config with derived defaults and get a single confirmation (they can override any field):

- `project.name` = project name, `project.language` = `uk`
- `stack`: `kotlin: true`, `notion: true`, others `false` (adjust if the user says otherwise)
- `git.branch_prefix` = `feature/<slug>`, `main_branch: main`, `dev_branch: develop`
- `notion`: `token_env: "NOTION_TOKEN"`, `picker.stage_filter: "Sprint"`, plus all IDs from Step 1

Then write:
- `spovishun-skills.config.yaml` — full config with real IDs. **This must exist with valid IDs before `install`** — the installer validates ID patterns and refuses to run otherwise.
- `.gitignore` — must cover: `spovishun-skills.config.yaml`, `.env`, `.env.*` (with `!.env.example`), `node_modules/`, `.claude/settings.local.json`, `.dev-context/`, plus stack-appropriate entries (Gradle/Android for Kotlin projects).
- `.env.example` — documented `NOTION_TOKEN=` stub (see rule 1: the example file is fine, the real one is not yours to create).

## Step 3 — PAUSE: user sets up the token

Tell the user to do two things themselves and confirm when done:

1. Create `<project>/.env` with `NOTION_TOKEN=ntn_...` (hooks and CLI scripts load it from the file on their own).
2. Make `NOTION_TOKEN` available in the environment Claude Code runs in — `doctor` and direct script checks read the process env, **not** `.env`.

Wait for confirmation. Then verify only `[ -n "$NOTION_TOKEN" ]`; if empty, remind that `doctor` will partially fail and offer to continue anyway or wait.

## Step 4 — Install the plugin stack

```bash
npx --yes spovishun-skills@latest install --target=claude
```

Expect "Installed N artifact(s)" and a written `spovishun-skills.lock.yaml`. Then cross-check the extractor agrees with Step 1:

```bash
node .claude/scripts/notion/bootstrap-config.js <root-page-url>
```

(The script only exists after install — that's why MCP fetch, not this script, is the primary ID source.) Compare its output to the config; fix the config and re-run `npx spovishun-skills sync` if they differ.

## Step 5 — Fill the Notion root page

1. `notion-update-page` on the root: set `Name` = project name, an icon the user likes (suggest one), `Status` = `In progress`, and a one-line `Text` property summary.
2. Replace the template's "How to use this template" callout with a project overview:
   - Design docs URL given → read the docs, write a tight overview (what the project is, stack) and link the docs.
   - No docs → ask the user for 1–2 sentences.
3. Archive the placeholder seed records. Find them by searching `PLACEHOLDER` within the Tasks and Epics data sources, then:
   ```bash
   node .claude/scripts/notion/archive-task.js <pageId>
   ```
   (works for both tasks and epics; the script reads the token from `.env` itself).

## Step 6 — Local CLAUDE.md skeleton

Create a minimal `CLAUDE.md` (English): project name + one-line description, stack from config, links to the Notion root page / board / design docs, commit convention (`type: short description`, imperative, ≤72 chars), and clearly marked TODO sections for architecture rules and build/test commands. Keep it honest — don't invent architecture that doesn't exist yet.

## Step 7 — Git repository

1. `git init` (skip if `.git/` exists), ensure default branch `main`.
2. Initial commit of the bootstrap artifacts (`.gitignore`, `.env.example`, `CLAUDE.md`, `.claude/`, `spovishun-skills.lock.yaml` — the config and `.env` stay ignored):
   ```
   chore: bootstrap project from spovishun-skills template
   ```
3. Create `develop` from `main`.
4. **Ask** whether to create a GitHub remote. If yes:
   ```bash
   gh repo create <name> --private --source . --remote origin
   ```
   (`--private` is the default choice; if `gh` is missing or not authenticated, suggest the user runs `! gh auth login`). Push `main` and `develop` **only after the user confirms the push**.

## Step 8 — Validate and report

Run the final gate yourself (token is already in env from Step 3):

```bash
npx --yes spovishun-skills@latest doctor
```

All checks must pass. If only `notion-token-env` fails, the env var is missing — point back to Step 3. If `notion-database-access` fails, the integration likely isn't shared with the new pages — tell the user to share the project root with their Notion integration and re-run doctor.

Finish with a short report: what was created (Notion root URL, board, docs), local files, git state — and next steps: fill CLAUDE.md TODOs, create the first task via `newtask`, start work with "start new task".

## Example

```
/create-new-project Shynok
```

Expected end state: a "Shynok" row in the Projects DB with Board (Tasks DB), Documentation
(7 category pages + Epics DB) and a filled overview; no PLACEHOLDER records left;
`spovishun-skills.config.yaml` with real IDs, `.claude/` (40+ artifacts), `CLAUDE.md`,
`.gitignore`, `.env.example` in the project folder; git repo on `develop` with the bootstrap
commit on `main`; `npx spovishun-skills doctor` — all checks green.

## Related skills

- `newtask` / `notion-spovishun-task-manager` — available *after* this bootstrap, from the
  installed `.claude/` stack; use them for day-to-day board work.
- Brainstorming or shaping a project idea is **not** this skill's job — that belongs to an
  idea/design discussion (e.g. `idea-brainstormer` where the spovishun stack is installed).
  This skill starts where the idea is already decided and needs infrastructure.
