# Issue tracker: Local Markdown

The fallback that always works: the map and its tickets are files in `.scratch/`. No external
service, no auth — but nothing renders in a team UI either, so prefer Notion or GitHub when the
project has one.

Add `.scratch/` to `.gitignore` if the effort is scratch-only; commit it if the map is meant to be
shared through the repo. Ask once, at charting time, and record the answer in the map's Notes.

## Layout

```
.scratch/<effort-slug>/
├── map.md
└── issues/
    ├── 01-<slug>.md
    ├── 02-<slug>.md
    └── 03-<slug>.md
```

## Wayfinding operations

- **Map**: `.scratch/<effort-slug>/map.md` — the Destination / Notes / Decisions-so-far /
  Not-yet-specified / Out-of-scope body, with `Labels: wayfinder:map` on the first line.
- **Child ticket**: `.scratch/<effort-slug>/issues/NN-<slug>.md`, numbered from `01`. Header lines
  before the body:
  ```markdown
  Labels: wayfinder:<type>
  Status: open | claimed | resolved
  Blocked by: 02, 05
  Part of: ../map.md

  ## Question

  <the decision this ticket resolves>
  ```
  Omit the `Blocked by:` line entirely when nothing blocks it.
- **Blocking**: the `Blocked by:` line, listing ticket numbers. A ticket is unblocked when every
  file it lists has `Status: resolved`.
- **Frontier query**: scan `.scratch/<effort-slug>/issues/` for files with `Status: open` whose
  blockers are all resolved; lowest number wins.
- **Claim**: set `Status: claimed` and save — before any work.
- **Resolve**: append the answer under an `## Answer` heading at the bottom of the ticket file, set
  `Status: resolved`, then append the context pointer (gist + relative link) to the map's
  Decisions-so-far.

## Gotchas

- **Names, not numbers, in narration.** The file number is the id; the `#` heading in the file is
  the name. Refer to tickets by name and link the path.
- **Re-read before editing `map.md`.** Parallel sessions edit the same file; never write from a copy
  loaded earlier in the session.
