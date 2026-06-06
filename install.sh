#!/usr/bin/env bash
#
# Installs the Astrum custom skills into the user-global Claude Code skills dir
# on macOS / Linux (and any POSIX shell, incl. Git Bash / WSL on Windows).
#
# For every skill folder under ./skills, creates a link at
# ~/.claude/skills/<name> pointing back to this repo, so edits in the repo
# are picked up by Claude Code on the next session start.
#
# Symlinks are the default (single source of truth) and need no elevation on
# Unix. Use --copy to copy instead; re-run after edits to propagate them.
#
# Usage:
#   ./install.sh
#   ./install.sh --copy

set -euo pipefail

COPY=false
for arg in "$@"; do
  case "$arg" in
    -c|--copy) COPY=true ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_SKILLS="$SCRIPT_DIR/skills"
TARGET_ROOT="${HOME}/.claude/skills"

if [ ! -d "$REPO_SKILLS" ]; then
  echo "No 'skills' folder found at $REPO_SKILLS" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"

shopt -s nullglob
skills=("$REPO_SKILLS"/*/)
if [ ${#skills[@]} -eq 0 ]; then
  echo "No skills to install under $REPO_SKILLS" >&2
  exit 0
fi

for skill_path in "${skills[@]}"; do
  skill_path="${skill_path%/}"
  name="$(basename "$skill_path")"
  target="$TARGET_ROOT/$name"

  rm -rf "$target"

  if [ "$COPY" = true ]; then
    cp -R "$skill_path" "$target"
    echo "copied  $name (re-run install after repo edits)"
  else
    ln -s "$skill_path" "$target"
    echo "linked  $name -> $skill_path"
  fi
done

echo ""
echo "Done. Restart Claude Code so it picks up the skills."
