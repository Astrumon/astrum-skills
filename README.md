# astrum-skills

Personal custom [Claude Code](https://claude.com/claude-code) skills by [@Astrumon](https://github.com/Astrumon).

These are user-global skills — they live in `~/.claude/skills/` and are available in
every project, independent of any project-specific skill set (e.g. `spovishun-skills`).

## Skills

| Skill | What it does |
|---|---|
| [`tech-digest`](skills/tech-digest/SKILL.md) | Live web-search digest of the latest Android/Kotlin/Ktor/KMP/AI/Claude news, plus context-aware picks based on the current repo stack, recent git activity, and memory files. |
| [`explain-code`](skills/explain-code/SKILL.md) | Explains a file, function, PR, or diff with a layered walkthrough (simple → advanced), an ASCII flow diagram, and Feynman-style gap-checking. Adapts to the current project's architecture; read-only. |
| [`mentor`](skills/mentor/SKILL.md) | Mentor/teacher that helps you learn and understand any topic (technical lean) — gist first, deepens or guides Socratically on demand, always ends with a recall check. Read-only on your code; study files only on request. |
| [`setup-spovishun-config`](skills/setup-spovishun-config/SKILL.md) | Configures a cloned [spovishun-skills](https://www.npmjs.com/package/spovishun-skills) project's gitignored `spovishun-skills.config.yaml` by harvesting the project's Notion ids with its `bootstrap-config.js`, sourcing the non-notion fields from the committed example or the `init` wizard, and verifying with `doctor`. |
| [`grill-me`](skills/grill-me/SKILL.md) | Interviews you relentlessly about a plan or design, working the decision tree in **rounds** — every question whose prerequisites are settled comes at once, each with a recommended answer — until nothing is left silently assumed. _Not my skill — see [Credits](#credits)._ |
| [`wait-what`](skills/wait-what/SKILL.md) | Three lines. Type `/wait-what` the moment a message doesn't land and it gets re-pitched — a little context, plain technical Ukrainian, and the project's own vocabulary. _Not my skill — see [Credits](#credits)._ |
| [`teach`](skills/teach/SKILL.md) | Teaches you a topic over multiple sessions in a stateful workspace — grounds every lesson in your mission, tracks progress with learning records and a glossary, and produces beautiful HTML lessons + quick-reference docs pitched at your zone of proximal development. Invoke with `/teach`. _Not my skill — see [Credits](#credits)._ |
| [`create-new-project`](skills/create-new-project/SKILL.md) | Bootstraps a new project end-to-end: duplicates the Notion project template, extracts anchor IDs, writes `spovishun-skills.config.yaml`, installs the `.claude/` stack, fills the root page, sets up git (`main`/`develop`) with optional GitHub remote, and validates with `doctor`. **Requires [`spovishun-skills`](https://www.npmjs.com/package/spovishun-skills)** — see [create-new-project requirements](#create-new-project-requirements). |
| [`thermo-nuclear-code-quality-review`](skills/thermo-nuclear-code-quality-review/SKILL.md) | An unusually strict maintainability review — hunts "code-judo" restructurings, enforces the 1k-line rule, and flags spaghetti conditionals, boundary leaks, and needless abstractions. Invoke explicitly with `/thermo-nuclear-code-quality-review`. _Not my skill — see [Credits](#credits)._ |
| [`wayfinder`](skills/wayfinder/SKILL.md) | Plans an effort too big for one session as a **map** of decision tickets on the project's issue tracker, then resolves them one per session until the way to the destination is clear. Auto-detects the tracker — see [wayfinder trackers](#wayfinder-trackers). Invoke explicitly with `/wayfinder`. _Not my skill — see [Credits](#credits)._ |
| [`research`](skills/research/SKILL.md) | Delegates a question to a background agent that reads **primary sources** only and captures cited findings as a Markdown file in the repo. Used standalone or by `wayfinder` for `research` tickets. _Not my skill — see [Credits](#credits)._ |
| [`prototype`](skills/prototype/SKILL.md) | Builds throwaway code that answers one design question — a single shareable HTML demo of a state model (or a scratch Kotlin `main()` where the logic must lift into the real code), or several radically different UI variants behind a switcher. Used standalone or by `wayfinder` for `prototype` tickets. _Not my skill — see [Credits](#credits)._ |
| [`domain-modeling`](skills/domain-modeling/SKILL.md) | Sharpens the project's ubiquitous language while you design — challenges fuzzy terms, keeps `CONTEXT.md` current, and offers an ADR only when a decision is hard to reverse, surprising, and a real trade-off. _Not my skill — see [Credits](#credits)._ |

## wayfinder trackers

`wayfinder` keeps its map and tickets in whatever tracker the project already has. The tracker is
resolved once, at the top of every session, first match wins:

1. **The map's own Notes** — a map handed to you never migrates trackers.
2. **[Notion](skills/wayfinder/trackers/notion.md)** — `spovishun-skills.config.yaml` with a
   `notion.database_id`, plus the Notion MCP connector. Map and tickets are pages in the project's
   **Tasks** DB, prefixed `WF · <effort> ·`; the property mapping (status / assignee / relations)
   is discovered from the DB schema and cached in the map's Notes.
3. **[GitHub Issues](skills/wayfinder/trackers/github.md)** — authenticated `gh` and a GitHub
   remote. Uses sub-issues and native issue dependencies, so the frontier renders in GitHub's UI.
4. **[Local markdown](skills/wayfinder/trackers/local.md)** — always available:
   `.scratch/<effort>/map.md` plus one file per ticket. No external dependency, no team-visible UI.

`wayfinder` delegates ticket work to `grill-me` (grilling tickets), `domain-modeling`, `research`,
and `prototype` — all four live in this repo, so no extra setup is needed.

## create-new-project requirements

Unlike the other skills here, `create-new-project` is an orchestration skill — it drives
external tooling and only works when its environment is in place:

- **[`spovishun-skills`](https://www.npmjs.com/package/spovishun-skills) (npm)** — the skill
  runs `npx spovishun-skills install / sync / doctor` and the Notion CLI scripts the plugin
  generates under `.claude/scripts/notion/`. Node.js 18+ required.
- **Notion MCP connector** — template duplication, ID extraction, and root-page editing go
  through Notion MCP tools (`notion-fetch`, `notion-duplicate-page`, `notion-update-page`,
  `notion-search`).
- **A "TEMPLATE — New Project" page** in your Notion Projects database — the duplicatable
  skeleton (Board + Tasks DB, Documentation with category pages, Epics DB) that the skill
  clones for each new project. The skill finds it by title or accepts a URL.
- **`NOTION_TOKEN`** — a Notion internal-integration secret. The skill **never touches your
  `.env`**: it pauses mid-flow and asks you to create `.env` and export the variable yourself,
  then verifies only that the env var is set.
- **`gh` CLI** (optional) — only if you want the skill to create a private GitHub remote.

Flow in one line: duplicate template → extract anchor IDs → write config → *(you set up the
token)* → install `.claude/` stack → fill root page + archive placeholders → `CLAUDE.md`
skeleton → `git init` + `main`/`develop` (+ optional GitHub) → `doctor` must pass.

## Credits

Which upstream commit each vendored copy is pinned to, and every way the local copy deliberately
differs, is recorded in [UPSTREAM.md](UPSTREAM.md).

- [`grill-me`](skills/grill-me/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Sources: [skills/productivity/grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) and [skills/productivity/grilling](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md). Licensed under MIT; upstream `grill-me` is a wrapper that runs `grilling`, and here that body is inlined into one skill and adapted to respond in Ukrainian. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`wait-what`](skills/wait-what/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/productivity/wait-what/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/wait-what/SKILL.md). Licensed under MIT; adapted here to ask for plain technical Ukrainian instead of ASD-STE100 Simplified Technical English, and to treat `CONTEXT.md` as optional. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`teach`](skills/teach/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/productivity/teach/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/teach/SKILL.md). Licensed under MIT; adapted here to teach in Ukrainian (see the `## Language` section in its `SKILL.md`). Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`wayfinder`](skills/wayfinder/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/engineering/wayfinder/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md). Licensed under MIT; adapted here to communicate in Ukrainian, to resolve the issue tracker itself (Notion / GitHub / local markdown — the original delegates this to `setup-matt-pocock-skills`), and to call this repo's `/grill-me` in place of `/grilling`. The tracker docs under `trackers/` are derived from the same repo's `issue-tracker-*.md`. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`research`](skills/research/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/engineering/research/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/research/SKILL.md). Licensed under MIT; adapted with Ukrainian triggers and a `wayfinder` hand-off section. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`prototype`](skills/prototype/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/engineering/prototype/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/prototype/SKILL.md). Licensed under MIT; adapted with Ukrainian triggers, a Clean Architecture note, Compose/Android and Kotlin/KMP sections, and a `wayfinder` hand-off section. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`domain-modeling`](skills/domain-modeling/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/engineering/domain-modeling/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md). Licensed under MIT; adapted with Ukrainian triggers, a Notion-documentation mirroring note, and a `wayfinder` hand-off section. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`thermo-nuclear-code-quality-review`](skills/thermo-nuclear-code-quality-review/SKILL.md) — created by **Cursor** ([@cursor](https://github.com/cursor)). Source: [cursor/plugins · cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md). Licensed under MIT; adapted here only to deliver the review report in Ukrainian (see the `## Language` section in its `SKILL.md`). Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

## Install

```sh
git clone https://github.com/Astrumon/astrum-skills.git
cd astrum-skills
```

**Windows (PowerShell):**

```powershell
./install.ps1          # directory junction (no admin / Developer Mode needed)
./install.ps1 -Copy    # copy instead
```

**macOS / Linux (and Git Bash / WSL):**

```sh
chmod +x install.sh    # first time only
./install.sh           # symlink (no elevation needed)
./install.sh --copy    # copy instead
```

Both scripts link each folder under `skills/` into `~/.claude/skills/`.

- **Link mode (default)** — single source of truth: edits in this repo are picked up by
  Claude Code on the next session. On Windows the `.ps1` uses a **directory junction**
  (no admin rights or Developer Mode needed; works across drives) and falls back to copy
  only if that fails. On Unix the `.sh` uses a symlink, which needs no elevation either.
- **Copy mode** — pass `-Copy` / `--copy`. Re-run install after editing a skill to
  propagate changes.

Restart Claude Code after installing so the new skills are loaded.

## Layout

```
astrum-skills/
├── skills/
│   └── <skill-name>/
│       └── SKILL.md
├── install.ps1
├── UPSTREAM.md      # upstream pins + standing deltas for vendored skills
└── README.md
```

## Adding a skill

1. Create `skills/<name>/SKILL.md` with valid frontmatter (`name`, `description`).
2. Run `./install.ps1` (Windows) or `./install.sh` (macOS/Linux).
3. Restart Claude Code and invoke with `/<name>`.

> Each skill folder must contain a `SKILL.md` directly — Claude Code does not read
> packaged `.skill` archives. Unzip any `.skill` bundle before committing.

## License

[MIT](LICENSE) © Astrumon — except for third-party skills, which keep their
original licenses (see [Credits](#credits) and [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md)).
