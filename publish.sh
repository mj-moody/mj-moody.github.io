#!/usr/bin/env bash
#
# Publish the site: render, commit, push.
#
#   ./publish.sh "updated bio"
#   ./publish.sh                  (uses a dated default message)
#
# The rendered site lives in docs/ and is committed to git, so the render
# has to happen before the commit -- otherwise the live site silently
# disagrees with the .qmd sources. That is the whole reason this exists.

set -euo pipefail

cd "$(dirname "$0")"

MSG="${1:-Site update $(date '+%Y-%m-%d')}"

echo
echo "  Rendering site..."
if ! quarto render > /tmp/quarto-render.log 2>&1; then
    echo "  RENDER FAILED -- nothing was committed or pushed."
    echo
    tail -20 /tmp/quarto-render.log
    exit 1
fi
echo "  Rendering site...      done"

if [ -z "$(git status --porcelain)" ]; then
    echo
    echo "  No changes to publish. Site is already up to date."
    echo
    exit 0
fi

echo "  Committing..."
git add -A
git commit -q -m "$MSG"
echo "  Committing...          done"

echo "  Pushing to GitHub..."
if ! git push -q origin main 2>/tmp/git-push.log; then
    echo "  PUSH FAILED -- your work is committed locally but not uploaded."
    echo
    cat /tmp/git-push.log
    echo
    echo "  Fix the problem above, then just run ./publish.sh again."
    exit 1
fi
echo "  Pushing to GitHub...   done"

echo
echo "  Live at https://mj-moody.github.io in about a minute."
echo "  (hard-refresh with Cmd-Shift-R if you don't see the change)"
echo
