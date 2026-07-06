---
name: setup-spovishun-config
description: Configure the spovishun-skills.config.yaml for a freshly cloned project by harvesting the project's Notion page/database ids with bootstrap-config.js. Use this when a spovishun-skills project already exists in Notion and on GitHub, someone cloned the repo, and now needs to set up their local (gitignored) config. Drives .claude/scripts/notion/bootstrap-config.js to fill the notion.* ids, sources the non-notion fields (project name, git, stack) from the committed example or the init wizard, verifies the token, and runs doctor. Triggers on "налаштуй конфіг", "налаштувати spovishun-skills.config", "підтягни notion id", "стягнув проєкт налаштуй notion", "bootstrap config", "set up spovishun config", "configure spovishun-skills.config.yaml", "I cloned the repo set up the Notion config".
---

# Setup Spovishun Config

Bring a **cloned** spovishun-skills project from "no config" to a fully populated
`spovishun-skills.config.yaml`, harvesting every Notion id from the project's
Notion page with the project's own `bootstrap-config.js`.

Use when the project **already exists** in Notion *and* on GitHub, someone has
cloned the repo, and the local config is missing (it is gitignored, so it never
comes with the clone). Communicate with the user in Ukrainian.

## What bootstrap-config.js does (and doesn't)

`bootstrap-config.js` walks the Notion page tree by its **fixed English anchor
titles** (`Board` → `Tasks` DB, `Documentation` → `CLAUDE.md` + the 7 category
pages + `Epics` → `Epics` DB) and writes/patches only the **`notion.*` ids**:
`database_id`, `root_page_id`, `docs_root_id`, `claude_md_page_id`,
`epics_database_id`, `epics_group_page_id` and every `categories.*`.

It does **not** touch `project.name`, `git.*`, `stack.*`, or
`notion.picker.stage_filter` — those come from the committed example file or the
`init` wizard (see step 2). It patches an **existing** config in place; it never
creates the file.

## Preconditions

- Run from the **cloned project's repo root** (where `.claude/scripts/notion/`
  and the config live) — the script resolves the config via `process.cwd()`.
- The user provides the **Notion project page URL** (or bare id). This is the
  established project's real root page — not a fresh template duplicate.
- Node.js ≥ 18.
- A Notion integration secret in `NOTION_TOKEN` (or `NOTION_SKILLS_TOKEN`), via
  env or the project `.env`, **and** the integration must have access to the
  project's pages.

## Workflow

1. **Locate the project & script.** Confirm the cwd is the project root and that
   `.claude/scripts/notion/bootstrap-config.js` exists. If it's missing, the
   spovishun-skills artifacts aren't installed yet — tell the user to run
   `npx spovishun-skills@latest install --target=claude` first, then stop.

2. **Ensure the config file exists** (bootstrap patches, never creates). Resolve
   its provenance in this order:
   - **Config already present** (`spovishun-skills.config.yaml`) → use it as-is;
     bootstrap will patch the notion ids into it.
   - **Else example present** (`spovishun-skills.config.example.yaml`) → copy it
     to `spovishun-skills.config.yaml`. This carries the real `project.name`,
     `git.*` and `stack.*` (only the notion ids are zeroed placeholders).
   - **Else neither** → run the interactive wizard `npx spovishun-skills@latest
     init` to create the config, then continue. (Tell the user this is
     interactive — suggest they run it via `!npx spovishun-skills@latest init`
     so its prompts land in the session.)

3. **Verify the Notion token.** Check `NOTION_TOKEN` / `NOTION_SKILLS_TOKEN` in
   the environment, then in `.env`. If neither is set, stop and ask the user to
   add it — e.g. `NOTION_TOKEN=secret_…` to the project `.env` (never print or
   store the secret value; it belongs only in `.env`/env, which is gitignored).

4. **Run the extractor.** From the repo root:
   ```bash
   node .claude/scripts/notion/bootstrap-config.js <notion-page-url> --write
   ```
   Prefer a dry run first to preview without touching the file — drop `--write`
   (add `--format json` for JSON) — then re-run with `--write` to patch.

5. **Verify the result.** Read back `spovishun-skills.config.yaml` and confirm no
   `notion.*` id is still a zero/placeholder (`00000000…`). Then run
   `npx spovishun-skills@latest doctor` to validate config, ids, `.gitignore`
   and settings. Report the ids written and doctor's verdict.

6. **Flag the leftovers bootstrap can't set.** Remind the user to confirm the
   non-harvested fields: `project.name`, `git.dev_branch`/`main_branch`, the
   `stack.*` flags, and `notion.picker.stage_filter` — set the stage filter for a
   Board v2 (Scrum) board, or leave it empty / omit `picker` for Board v1.

## Fallback: harvest ids via Notion MCP (anchors drifted)

Use this **only** when `bootstrap-config.js` fails with `Anchor not found`
because the owner renamed a structural title — bootstrap matches titles exactly,
but the Notion MCP tools let you identify each anchor by its **role/structure**,
not its literal title. Requires a connected Notion MCP server (`notion-fetch`,
`notion-search`) with access to the project's pages.

1. **Fetch the tree.** `notion-fetch` the root page (the URL the user gave), then
   its children, walking down. Map each config id to its anchor by role:
   | Config key | Anchor (role) |
   |---|---|
   | `root_page_id` | the page from the URL itself |
   | `docs_root_id` | the docs hub page (was "Documentation") |
   | `claude_md_page_id` | the page holding the CLAUDE.md doc under docs |
   | `database_id` | the **Tasks** board database (Status/Stage/Priority, Epic + Blocked-by relations) |
   | `epics_group_page_id` | the group page holding the Epics DB |
   | `epics_database_id` | the **Epics** database |
   | `categories.*` | the 7 doc category pages/DBs: architecture, database, testing, cicd, features, aitools, epics |

   Disambiguate by structure when titles are unhelpful: the Tasks DB is the one
   with the Status/Stage/Priority + Epic/Blocked-by schema; each category is a
   child under the docs hub. If a role is genuinely ambiguous, **ask the user**
   which page it is — never guess an id.
2. **Normalize** every id to a dashed 32-hex uuid (strip the slug/`?…` from any
   URL; take the last 32-hex run) — the same shape bootstrap writes.
3. **Write only the resolved `notion.*` ids** into `spovishun-skills.config.yaml`
   with Edit, keeping each `key: "value"` on its own line with **no trailing
   comment** (the config reader doesn't strip inline `#` — a comment would be
   read into the value). Leave every non-notion field untouched. This is the one
   sanctioned case of writing ids by hand — do it precisely.
4. **Verify** exactly as in step 5: no placeholder ids remain, then `doctor`. If
   `doctor` or a later CLI script 404s, the integration lacks access — have the
   user share the pages with it.

> Prefer restoring the drifted title + re-running bootstrap when it's one page —
> it's less error-prone than hand-resolving. Use MCP when renaming isn't an
> option or several anchors drifted.

## Error handling

- **`Anchor not found: … "<Title>"`** — the extractor keys off English structural
  titles (`Board`, `Documentation`, `Tasks`, `CLAUDE.md`, `Epics`, and the seven
  category titles). On an established project one may have been renamed, so
  title-matching breaks. Report the exact title from the error, then choose:
  either the user restores that one anchor title in Notion and re-runs bootstrap
  (cleanest), or — if several drifted or they can't rename — switch to the
  **Notion MCP fallback** below to harvest the ids semantically.
- **`404` from a later CLI script** — the integration lacks access to the new
  pages. Tell the user to share the project's pages with their Notion
  integration, then retry.
- **`NOTION_TOKEN … required`** — token not found; go back to step 3.
- **`<config> not found` on `--write`** — the config file doesn't exist; go back
  to step 2 (the example copy or `init` must run before `--write`).

## Constraints

**MUST DO**
- Run everything from the cloned project's repo root.
- Make sure the config exists (existing → example copy → `init`) *before*
  `--write`; bootstrap only patches.
- Keep the secret in `.env`/env only — reference it by var name, never echo it.
- Verify after writing: no placeholder ids remain, and `doctor` passes.
- Surface the exact `Anchor not found` title rather than a generic failure.

**MUST NOT DO**
- Hand-edit notion ids in the normal path — let bootstrap resolve them (it maps
  titles → ids correctly; manual copying is what this skill replaces). The only
  exception is the Notion MCP fallback, when title-matching has broken.
- Commit `spovishun-skills.config.yaml` (it's gitignored — holds Notion ids).
- Assume a committed example exists — some projects don't ship one; fall back to
  `init`.
- Overwrite an already-populated config's non-notion fields — reuse it in place.
