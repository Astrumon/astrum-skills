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
| [`grill-me`](skills/grill-me/SKILL.md) | Interviews you relentlessly about a plan or design, walking down each branch of the decision tree one question at a time with a recommended answer for each — to stress-test a plan before implementation. _Not my skill — see [Credits](#credits)._ |
| [`teach`](skills/teach/SKILL.md) | Teaches you a topic over multiple sessions in a stateful workspace — grounds every lesson in your mission, tracks progress with learning records and a glossary, and produces beautiful HTML lessons + quick-reference docs pitched at your zone of proximal development. Invoke with `/teach`. _Not my skill — see [Credits](#credits)._ |
| [`create-new-project`](skills/create-new-project/SKILL.md) | Bootstraps a new project end-to-end: duplicates the Notion project template, extracts anchor IDs, writes `spovishun-skills.config.yaml`, installs the `.claude/` stack, fills the root page, sets up git (`main`/`develop`) with optional GitHub remote, and validates with `doctor`. **Requires [`spovishun-skills`](https://www.npmjs.com/package/spovishun-skills)** — see [create-new-project requirements](#create-new-project-requirements). |

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

- [`grill-me`](skills/grill-me/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/productivity/grill-me/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md). Licensed under MIT; adapted here only to respond in Ukrainian. Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).
- [`teach`](skills/teach/SKILL.md) — created by **Matt Pocock** ([@mattpocock](https://github.com/mattpocock)). Source: [mattpocock/skills · skills/productivity/teach/SKILL.md](https://github.com/mattpocock/skills/blob/main/skills/productivity/teach/SKILL.md). Licensed under MIT; adapted here to teach in Ukrainian (see the `## Language` section in its `SKILL.md`). Full license text in [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

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
