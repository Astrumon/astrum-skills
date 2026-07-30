# Issue tracker: Notion (spovishun projects)

The map and its tickets live as pages in the project's **Tasks** database in Notion. All
operations go through the Notion MCP tools (`notion-fetch`, `notion-query-data-sources`,
`notion-create-pages`, `notion-update-page`, `notion-create-comment`, `notion-get-users`).
Never edit Notion by hand-crafting REST calls, and never touch `.env`.

## Locate the database

`spovishun-skills.config.yaml` in the project root is the source of truth:

| Config key | Use |
|---|---|
| `notion.database_id` | the **Tasks** database — every map and ticket is a page in it |
| `notion.root_page_id` | the project root page — link the map from narration, don't write to it |
| `notion.token_env` | name of the env var holding the token (usually `NOTION_TOKEN`) |

The config is gitignored, so it may be missing on a fresh clone — in that case tell the user to
run `/setup-spovishun-config` first, and fall back to the local-markdown tracker for now rather
than inventing ids.

## Resolve the property mapping (once per effort)

The Tasks DB schema differs per project, so the roles below must be **discovered, not assumed**.
`notion-fetch` the database, read its property schema, and bind each role to a real property:

| Role | Look for | If absent |
|---|---|---|
| **Status** | a `status` or `select` property (`Status`) | fall back to a checkbox `Done`; if there is none, stop and ask |
| **Assignee** (claim) | a `people` property (`Assignee`, `Owner`, `Виконавець`) | claim by moving Status to the in-progress option, and say so — concurrency is weaker |
| **Parent link** | a self-relation (`Parent task` / `Sub-tasks`) | the title prefix below carries the linkage |
| **Labels** | a `multi_select` (`Tags`, `Labels`, `Type`) | a `Labels:` line at the top of the page body |
| **Blocking** | a self-relation named `Blocked by` / `Blocks` | a `Blocked by:` line at the top of the page body |
| **Stage** | whatever `notion.picker.stage_filter` names (often `Sprint`) | ignore |

Write the resolved mapping into the map's `## Notes` as a fenced block, so every later session
reads it instead of re-deriving it:

```
tracker: notion
tasks_db: <database id>
status: Status (open: Not started, In progress | closed: Done)
assignee: Assignee (people)
parent: Sub-tasks relation
labels: body line (no multi-select in this DB)
blocking: body line
```

## Naming — the effort prefix

Notion has no repo-scoped label namespace, and one Tasks DB holds ordinary project work too.
Every wayfinder page therefore carries the effort slug in its **title**:

- Map: `WF · <effort-slug> · Map — <effort name>`
- Ticket: `WF · <effort-slug> · <question gist>`

The prefix is what makes the frontier query possible when the DB has no parent relation, so it is
mandatory even when the relation exists. Keep the slug short, lowercase-kebab, stable for the life
of the effort.

## Wayfinding operations

- **Map**: a page in the Tasks DB created with `notion-create-pages`, titled with the `· Map` form
  above, Status set to the in-progress option. Its body is the standard map body (Destination /
  Notes / Decisions so far / Not yet specified / Out of scope). Label it `wayfinder:map` — as a
  multi-select value where one exists, otherwise as a `Labels: wayfinder:map` line at the top of
  the body.
- **Child ticket**: a page in the same Tasks DB, titled with the effort prefix, body:
  ```markdown
  Labels: wayfinder:<type>
  Blocked by: <ticket name>, <ticket name>
  Part of: <map name (link)>

  ## Question

  <the decision this ticket resolves>
  ```
  Set the parent relation to the map where the DB has one; the `Part of:` line stays regardless —
  it is what a human reads. Drop the `Blocked by:` line entirely when nothing blocks it.
- **Blocking**: the `Blocked by` relation where the DB has one — it renders in Notion's own UI,
  which is the point. Otherwise the `Blocked by:` body line, listing ticket **names as links**.
  A ticket is unblocked when every blocker's Status is closed.
- **Frontier query**: `notion-query-data-sources` on the Tasks DB, filtered to title contains
  `WF · <effort-slug> ·` and Status not closed; drop the map itself, then drop any ticket with an
  unresolved blocker or a set Assignee. First in creation order wins.
- **Claim**: `notion-update-page` setting the Assignee people property to the driving dev — resolve
  their Notion user with `notion-get-users` once and cache it in the map Notes. This is the
  session's first write, before any work.
- **Resolve**: post the answer as a page comment with `notion-create-comment` (that is the
  resolution comment), set Status to the closed option with `notion-update-page`, then append the
  context pointer to the map.
- **Append to the map**: re-fetch the map with `notion-fetch` immediately before writing, insert the
  new line under `## Decisions so far` (or the fog / out-of-scope section), and write it back with
  `notion-update-page`. Concurrent sessions edit the same page — never write from a body you loaded
  earlier in the session.

## Gotchas

- **Async writes.** Pages created by `notion-create-pages` are available immediately, but content
  written to a just-created page can lag. Re-fetch before wiring relations in the second pass.
- **Database vs data source ids.** `notion.database_id` is the database id; some query tools want
  the data source id (`collection://…`) that `notion-fetch` returns for it. Use whichever the tool
  asks for — don't paste one where the other belongs.
- **Integration access.** A `notion-fetch` that 404s on a valid id usually means the integration
  isn't shared with the page. Tell the user to share it; don't retry blindly.
- **Never archive a ticket to close it.** Archived pages vanish from queries, taking the route's
  history with them. Closing is a Status change.
