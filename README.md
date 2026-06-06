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
