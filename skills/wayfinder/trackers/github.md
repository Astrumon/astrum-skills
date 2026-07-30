# Issue tracker: GitHub Issues

The map and its tickets live as GitHub issues on the repo the current clone points at. Use the
`gh` CLI for every operation — it infers the repo from `git remote -v` when run inside the clone.

Check before the first write: `gh auth status`, and `gh label list` to see which `wayfinder:*`
labels already exist. Labels must be created before they can be applied:

```bash
gh label create "wayfinder:map" --color 5319E7 --description "Wayfinder map" 2>/dev/null || true
for t in research prototype grilling task; do
  gh label create "wayfinder:$t" --color BFD4F2 2>/dev/null || true
done
```

## Conventions

- **Create**: `gh issue create --title "..." --body "..."` — heredoc for multi-line bodies.
- **Read**: `gh issue view <n> --comments`.
- **Comment**: `gh issue comment <n> --body "..."`.
- **Label**: `gh issue edit <n> --add-label "..."` / `--remove-label "..."`.
- **Close**: `gh issue close <n> --comment "..."`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either — resolve with
`gh issue view 42` and fall back to `gh pr view 42`.

## Wayfinding operations

The **map** is a single issue with **child** issues as tickets.

- **Map**: an issue labelled `wayfinder:map`, holding the Destination / Notes / Decisions-so-far /
  Not-yet-specified / Out-of-scope body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub **sub-issue** (`gh api` on the sub-issues
  endpoint). Where sub-issues aren't enabled, add the child to a task list in the map body and put
  `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research` /
  `prototype` / `grilling` / `task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies** — the canonical, UI-visible representation:
  ```bash
  gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
    -F issue_id=<blocker-db-id>
  ```
  where `<blocker-db-id>` is the blocker's numeric **database id**
  (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`) — *not* the `#number` and *not* the
  `node_id`. GitHub then reports `issue_dependencies_summary.blocked_by` (open blockers only — the
  live gate). Where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at
  the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue list --state open`, scoped to the
  map's sub-issues / task list), drop any with an open blocker
  (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an
  assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me` — the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a
  context pointer (gist + link) to the map's Decisions-so-far with `gh issue edit <map> --body-file`
  — re-read the map body first, since other sessions may have edited it.

## Gotchas

- **Private repos and forks.** `gh` silently targets the fork's upstream in some clones. Confirm
  with `gh repo view --json nameWithOwner` before the first write.
- **Body rewrites are last-write-wins.** `gh issue edit --body` replaces the whole body; always
  re-read immediately before editing the map.
