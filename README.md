# astrum-skills

Personal custom [Claude Code](https://claude.com/claude-code) skills by [@Astrumon](https://github.com/Astrumon).

These are user-global skills — they live in `~/.claude/skills/` and are available in
every project, independent of any project-specific skill set (e.g. `spovishun-skills`).

## Skills

| Skill | What it does |
|---|---|
| [`tech-digest`](skills/tech-digest/SKILL.md) | Live web-search digest of the latest Android/Kotlin/Ktor/KMP/AI/Claude news, plus context-aware picks based on the current repo stack, recent git activity, and memory files. |

## Install

```sh
git clone https://github.com/Astrumon/astrum-skills.git
cd astrum-skills
```

**Windows (PowerShell):**

```powershell
./install.ps1          # symlink (needs Developer Mode or admin)
./install.ps1 -Copy    # copy instead
```

**macOS / Linux (and Git Bash / WSL):**

```sh
chmod +x install.sh    # first time only
./install.sh           # symlink (no elevation needed)
./install.sh --copy    # copy instead
```

Both scripts link each folder under `skills/` into `~/.claude/skills/`.

- **Symlink mode (default)** — single source of truth: edits in this repo are picked up
  by Claude Code on the next session. On Windows this needs **Developer Mode** or an
  elevated shell (the `.ps1` falls back to copy automatically if not permitted); on Unix
  no elevation is required.
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
