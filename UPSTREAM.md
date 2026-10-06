# Upstream pins

Machine-readable record of where each **third-party** skill in this repo came from, which upstream
commit it was taken at, and how the local copy deliberately differs. Own skills (`tech-digest`,
`explain-code`, `mentor`, `setup-spovishun-config`, `create-new-project`) have no upstream and are
not listed.

For attribution and licensing see [Credits](README.md#credits) and
[THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md).

## Pins

| Skill | Upstream | Version | Commit | Synced |
|---|---|---|---|---|
| [`grill-me`](skills/grill-me/SKILL.md) | `mattpocock/skills` · `skills/productivity/grill-me` + `skills/productivity/grilling` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`wait-what`](skills/wait-what/SKILL.md) | `mattpocock/skills` · `skills/productivity/wait-what` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`teach`](skills/teach/SKILL.md) | `mattpocock/skills` · `skills/productivity/teach` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`wayfinder`](skills/wayfinder/SKILL.md) | `mattpocock/skills` · `skills/engineering/wayfinder` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`research`](skills/research/SKILL.md) | `mattpocock/skills` · `skills/engineering/research` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`prototype`](skills/prototype/SKILL.md) | `mattpocock/skills` · `skills/engineering/prototype` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`domain-modeling`](skills/domain-modeling/SKILL.md) | `mattpocock/skills` · `skills/engineering/domain-modeling` | 1.2.3 | `6acc160` | 2026-08-06 |
| [`retro`](skills/retro/SKILL.md) | `mattpocock/skills` · `skills/engineering/retro` | 1.3.1 | `6fd9479` | 2026-10-06 |
| [`writing-for-agents`](skills/writing-for-agents/SKILL.md) | `mattpocock/skills` · `skills/productivity/writing-for-agents` | 1.3.1 | `6fd9479` | 2026-10-06 |
| [`thermo-nuclear-code-quality-review`](skills/thermo-nuclear-code-quality-review/SKILL.md) | `cursor/plugins` · `cursor-team-kit/skills/thermo-nuclear-code-quality-review` | — | `6e3d2ea` | 2026-07-19 |

`cursor/plugins` has no release versioning, so the commit is the only pin.

## Standing deltas

These are re-applied on every sync. Everything **not** listed here should match upstream verbatim.

### Applies to every vendored skill

- **`## Language` section, last in the file.** Opens with `Communicate with the user exclusively in
  Ukrainian.`, followed by whatever the skill needs to say about the language of the *artifacts* it
  produces. Kept last so a sync is: replace the body with upstream → re-append the block → restore
  the description.
- **Ukrainian trigger phrases appended to `description`** — model-invoked skills only. A skill with
  `disable-model-invocation: true` is never matched on its description, so triggers there are dead
  weight and are not added.
- **`agents/openai.yaml` is not vendored.** Upstream ships Codex metadata beside every `SKILL.md`
  since 1.2.0; this repo installs into `~/.claude/skills/` only. Revisit if Codex enters the picture.

### Per skill

| Skill | Delta |
|---|---|
| `grill-me` | Upstream splits `grill-me` (a user-invoked wrapper) from `grilling` (the mechanism). Here the `grilling` body is **inlined** into `grill-me` and `disable-model-invocation` is **not** set — `wayfinder` invokes `/grill-me` itself, which a user-invoked skill could not serve. One consumer, so the indirection isn't earned. Plus a paragraph after the question-format block requiring each round to also go through `AskUserQuestion`: upstream's format block alone renders the round as plain text, so every branch has to be retyped by hand. |
| `wait-what` | `ASD-STE100 Simplified Technical English` → plain technical Ukrainian (short sentences, one idea each, no metaphors, terms left in the original). `CONTEXT.md` softened to "if it has one". No `## Language` section — the skill's whole design is that it is three lines long. |
| `prototype` | Extra sections: `## Clean Architecture projects`, `## When /wayfinder calls this`. `UI.md` adds `## Compose / Android projects` and Material 3 to the styling list. `LOGIC.md` adds `## Android / Kotlin / KMP projects` — the upstream HTML demo stays the default, but when the pure module has to lift into Kotlin the shell becomes a scratch `main()` behind a Gradle task. |
| `wayfinder` | Resolves the issue tracker itself (Notion / GitHub / local markdown) instead of delegating to `/setup-matt-pocock-skills`; `trackers/*.md` are derived from upstream's `issue-tracker-*.md`. Calls `/grill-me` where upstream calls `/grilling`. |
| `research` | `## When /wayfinder calls this` hand-off section. |
| `domain-modeling` | `## Notion-documented projects` (offer to mirror an accepted ADR onto the Notion Architecture page) and `## When /wayfinder calls this`. |
| `teach` | `## Language` only. |
| `retro` | `## Language` only. Depends on `writing-for-agents` (step 1 invokes it), so the two are vendored and synced together. |
| `writing-for-agents` | `## Language` only. |
| `thermo-nuclear-code-quality-review` | `## Language` only. |

## How to sync

1. Read the pin above for the skill you're updating.
2. Diff upstream between the pinned commit and its current `main`, scoped to the skill:
   `git diff <commit>..main -- skills/<bucket>/<name>` (or `gh api` the two blobs).
3. Apply the upstream changes on top of the local copy, re-applying the standing deltas above.
   Where an upstream change **removes or rewrites** the section a delta hangs off — as 1.2.0 did to
   `prototype/LOGIC.md` — that is a decision, not a merge conflict. Grill it before resolving.
4. Update the pin row (version, commit, date) and the delta row if the deltas changed.
5. Re-run `./install.ps1` (or `./install.sh`) so new skill folders are linked.
