#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-borj-sefid}"
GITHUB_USER="${2:-}"

if [[ -z "$GITHUB_USER" ]]; then
  echo "Usage: ./deploy.sh [repo-name] [github-username]"
  echo "Example: ./deploy.sh borj-sefid your-username"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install: https://cli.github.com/"
  exit 1
fi

gh auth status >/dev/null

if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin main
else
  gh repo create "$GITHUB_USER/$REPO_NAME" --public --source=. --remote=origin --push
fi

gh api "repos/$GITHUB_USER/$REPO_NAME/pages" \
  -X POST \
  -f build_type=workflow \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null || true

echo
echo "Site will be available at:"
echo "https://$GITHUB_USER.github.io/$REPO_NAME/"
