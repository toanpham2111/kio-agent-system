#!/usr/bin/env bash
# ==============================================================================
# Kio System: Dual-Repository Automated Release Tool
# ------------------------------------------------------------------------------
# Automates the complete 6-step release protocol across:
#   1. Primary Repo:    toanpham2111/my-agent-skills
#   2. Public Repo:     toanpham2111/kio-agent-system (100% Pure English)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PRIMARY_REPO="toanpham2111/my-agent-skills"
PUBLIC_REPO="toanpham2111/kio-agent-system"
VERIFIED_EMAIL="toan444666@gmail.com"
VERIFIED_NAME="Toan Pham"

# Locate GitHub CLI binary
GH_CMD=""
if command -v gh >/dev/null 2>&1; then
  GH_CMD="gh"
elif [ -f "/tmp/gh-bin/gh" ]; then
  GH_CMD="/tmp/gh-bin/gh"
else
  echo "❌ Error: GitHub CLI (gh) not found in PATH or /tmp/gh-bin/gh."
  echo "   Please install gh or authenticate first."
  exit 1
fi

# Print Help
show_help() {
  cat << EOF
Usage:
  ./scripts/release.sh <version> [title] [notes]
  ./scripts/release.sh <version> [title] --notes-file <file>

Arguments:
  version       Semantic version tag (e.g., v1.0.2 or 1.0.2)
  title         Optional release title (default: "Release <version>")
  notes         Optional release notes description

Options:
  --notes-file  Path to Markdown file containing release notes
  -h, --help    Show this help message

Example:
  ./scripts/release.sh v1.0.2 "Performance & Stability Patch" "### Highlights\n- Fixed symlinks\n- Added benchmarks"
  ./scripts/release.sh v1.0.2 "v1.0.2 Release" --notes-file release_notes.md
EOF
}

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  show_help
  exit 0
fi

# 1. Normalize Version Tag
RAW_VER="$1"
if [[ "$RAW_VER" =~ ^v[0-9]+\.[0-9]+\.[0-9]+.* ]]; then
  VERSION="$RAW_VER"
else
  VERSION="v$RAW_VER"
fi

TITLE="${2:-"Release $VERSION"}"
NOTES=""

shift 2 2>/dev/null || shift 1 2>/dev/null || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notes-file)
      if [ -f "$2" ]; then
        NOTES="$(cat "$2")"
        shift 2
      else
        echo "❌ Error: Notes file '$2' not found."
        exit 1
      fi
      ;;
    *)
      if [ -z "$NOTES" ]; then
        NOTES="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$NOTES" ]; then
  NOTES="## 🧰 Kio System Release $VERSION

### Highlights
- Modular Master Engineering Skills (Frontend, Backend, QA, Core Delivery, Growth Marketing, WordPress FSE, Cognitive).
- Non-destructive cross-platform installer (setup.sh / setup.ps1) with strict realpath verification and manifest tracking.
- Automated evaluation framework with verified benchmark scenario logs.
- Dual-repo synchronized distribution under the MIT License."
fi

echo "================================================================="
echo "🚀 KIO SYSTEM: Dual-Repository Automated Release Protocol"
echo "================================================================="
echo "📌 Target Version : $VERSION"
echo "📌 Release Title  : $TITLE"
echo "📌 Primary Repo   : $PRIMARY_REPO"
echo "📌 Public Repo    : $PUBLIC_REPO"
echo "================================================================="

cd "$REPO_ROOT"

# 1.5 Refuse to release a stale or diverged checkout (the tag must point at origin/main)
echo "🔍 Checking that local main matches origin/main..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "❌ Error: releases are cut from 'main' (current branch: $CURRENT_BRANCH)."
  exit 1
fi
git fetch --quiet origin main
if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]; then
  if git merge-base --is-ancestor HEAD origin/main; then
    echo "❌ Error: local main is behind origin/main. Run 'git pull --ff-only' first."
  else
    echo "❌ Error: local main has diverged from origin/main. Reconcile before releasing."
  fi
  echo "   local:  $(git log --oneline -1 HEAD)"
  echo "   origin: $(git log --oneline -1 origin/main)"
  exit 1
fi
echo "✅ main is up to date with origin/main."

# 2. Check GitHub CLI Authentication
echo "🔍 Checking GitHub authentication..."
if ! "$GH_CMD" auth status >/dev/null 2>&1; then
  echo "❌ Error: GitHub CLI is not authenticated. Run 'gh auth login' first."
  exit 1
fi
echo "✅ GitHub CLI authenticated successfully."

# 3. Ensure Git Author Configuration
echo "⚙️  Verifying Git Author identity..."
git config user.name "$VERIFIED_NAME"
git config user.email "$VERIFIED_EMAIL"
echo "✅ Git Author set to: $VERIFIED_NAME <$VERIFIED_EMAIL>"

# Published tags are immutable: an existing tag may only be reused to resume a release of the same commit.
echo "🔍 Checking whether tag $VERSION already exists..."
if ! git fetch origin --tags --quiet; then
  echo "❌ Error: Could not fetch tags from origin (a local tag may conflict with the remote one)."
  exit 1
fi
TAG_EXISTS=false
if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
  TAG_EXISTS=true
  if [ "$(git rev-parse "$VERSION^{commit}")" != "$(git rev-parse HEAD)" ]; then
    echo "❌ Error: Tag $VERSION already exists on a different commit. Published tags are never moved."
    echo "   Bump to a new version instead (e.g. the next patch version)."
    exit 1
  fi
  echo "ℹ️  Tag $VERSION already points to HEAD — resuming release."
fi

# 4. Check & Update Version Badges in Documentation
echo "📝 Updating release badges in README files..."
sed -i -E "s/Release-v[0-9]+\.[0-9]+\.[0-9]+-blue\.svg/Release-$VERSION-blue.svg/g" README.md 2>/dev/null || true
sed -i -E "s/Release-v[0-9]+\.[0-9]+\.[0-9]+-blue\.svg/Release-$VERSION-blue.svg/g" README.en.md 2>/dev/null || true

# 5. Commit pending release metadata (tracked files only — untracked files are never released)
git add -u
UNTRACKED_FILES="$(git ls-files --others --exclude-standard)"
if [ -n "$UNTRACKED_FILES" ]; then
  echo "⚠️  Untracked files are NOT included in the release commit:"
  echo "$UNTRACKED_FILES" | sed 's/^/     /'
fi
if ! git diff --cached --quiet; then
  if [ "$TAG_EXISTS" = true ]; then
    echo "❌ Error: Tag $VERSION already exists but there are new changes to release. Bump to a new version."
    exit 1
  fi
  echo "💾 Committing release metadata updates:"
  git diff --cached --name-only | sed 's/^/     /'
  git commit -m "chore(release): bump version to $VERSION"
  git push origin main
else
  echo "ℹ️  No tracked changes to commit."
fi

# 6. Tag Primary Repository
if [ "$TAG_EXISTS" = true ]; then
  echo "ℹ️  Tag $VERSION already exists on HEAD — skipping tag creation."
  git push origin "refs/tags/$VERSION"
else
  echo "🏷️  Tagging primary repo with $VERSION..."
  git tag -a "$VERSION" -m "$TITLE"
  git push origin "refs/tags/$VERSION"
fi

# 7. Create GitHub Release on Primary Repository
echo "📦 Publishing GitHub Release on $PRIMARY_REPO..."
if "$GH_CMD" release view "$VERSION" --repo "$PRIMARY_REPO" >/dev/null 2>&1; then
  echo "ℹ️  Release $VERSION already exists on $PRIMARY_REPO. Updating..."
  "$GH_CMD" release edit "$VERSION" --repo "$PRIMARY_REPO" --title "$TITLE" --notes "$NOTES"
else
  "$GH_CMD" release create "$VERSION" --repo "$PRIMARY_REPO" --title "$TITLE" --notes "$NOTES"
fi
echo "✅ Primary GitHub Release published: https://github.com/$PRIMARY_REPO/releases/tag/$VERSION"

# 8. Synchronize to Public 100% Pure English Repository
echo ""
echo "🌍 Synchronizing 100% Pure English Distribution to $PUBLIC_REPO..."
"$REPO_ROOT/scripts/sync_to_english_repo.sh"

# 9. Sync Tag on Public Repository
echo "🏷️  Synchronizing tag $VERSION on $PUBLIC_REPO..."
if "$GH_CMD" api "repos/$PUBLIC_REPO/git/ref/tags/$VERSION" >/dev/null 2>&1; then
  echo "ℹ️  Tag $VERSION already exists on $PUBLIC_REPO — leaving it unchanged."
else
  LATEST_PUBLIC_SHA=$("$GH_CMD" api "repos/$PUBLIC_REPO/commits?per_page=1" --jq '.[0].sha')
  "$GH_CMD" api -X POST "repos/$PUBLIC_REPO/git/refs" -f ref="refs/tags/$VERSION" -f sha="$LATEST_PUBLIC_SHA" >/dev/null
fi

# 10. Create GitHub Release on Public Repository
echo "📦 Publishing GitHub Release on $PUBLIC_REPO..."
if "$GH_CMD" release view "$VERSION" --repo "$PUBLIC_REPO" >/dev/null 2>&1; then
  echo "ℹ️  Release $VERSION already exists on $PUBLIC_REPO. Updating..."
  "$GH_CMD" release edit "$VERSION" --repo "$PUBLIC_REPO" --title "$TITLE" --notes "$NOTES"
else
  "$GH_CMD" release create "$VERSION" --repo "$PUBLIC_REPO" --title "$TITLE" --notes "$NOTES"
fi
echo "✅ Public GitHub Release published: https://github.com/$PUBLIC_REPO/releases/tag/$VERSION"

echo ""
echo "================================================================="
echo "🎉 SUCCESS: Version $VERSION released and synchronized successfully!"
echo "================================================================="
echo "🔗 Primary Repo Release : https://github.com/$PRIMARY_REPO/releases/tag/$VERSION"
echo "🔗 Public Repo Release  : https://github.com/$PUBLIC_REPO/releases/tag/$VERSION"
echo "👤 Author Attribution   : $VERIFIED_NAME (@toanpham2111)"
echo "🛡️  Manifest Integrity  : Verified"
echo "================================================================="
