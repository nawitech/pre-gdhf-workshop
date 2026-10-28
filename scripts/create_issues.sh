#!/usr/bin/env bash
# Creates the Nawi engineering issues from issues/*.md in the given repo.
# Usage: scripts/create_issues.sh nawitech/pre-gdhf-workshop
# Each file has a front-matter block with title and labels; the rest is the body.
set -euo pipefail
REPO="${1:?repo, e.g. nawitech/pre-gdhf-workshop}"
for f in issues/*.md; do
  title=$(sed -n 's/^title: "\(.*\)"$/\1/p' "$f")
  labels=$(sed -n 's/^labels: \(.*\)$/\1/p' "$f" | tr -d ' ')
  body=$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$f")
  for l in ${labels//,/ }; do gh label create "$l" --repo "$REPO" --force >/dev/null 2>&1 || true; done
  gh issue create --repo "$REPO" --title "$title" --label "$labels" --body "$body"
done
