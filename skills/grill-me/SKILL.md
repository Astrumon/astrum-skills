---
name: grill-me
description: >
  Grill the user relentlessly about a plan, decision, or idea until you reach a shared
  understanding. Works the design tree in rounds, asking the whole frontier at once and giving
  a recommended answer for each question. Use when the user wants to stress-test their thinking,
  or uses any 'grill' trigger phrase. Triggers on: "grill me", "stress-test my plan",
  "challenge my design", "загартуй мене", "перевір мій план", "постав мені питання".
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Each question should be formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Then put the same round through `AskUserQuestion` so the branches are clickable instead of retyped: one call, the round's questions as its questions, each question's branches as its options, the recommended branch first and suffixed `(Recommended)`. Set `multiSelect` when the branches are not mutually exclusive. The printed text carries the reasoning; the options carry the choice, so keep the labels short and let the body above do the explaining. `AskUserQuestion` takes at most 4 questions of at most 4 options each — a wider round is split across back-to-back calls, still one round. A question with no discrete branches (a name, a number, free-form recall) stays text-only.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

## Language

Communicate with the user exclusively in Ukrainian — questions, recommended answers, and the closing summary. Code, identifiers, and quoted material stay in their original language.
