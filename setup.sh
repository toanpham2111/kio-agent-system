#!/usr/bin/env bash
# ==============================================================================
# Kio: Open Source AI Skills Installer & Manager
# ------------------------------------------------------------------------------
# Principles:
# 1. Install Skills: Install all 7 skills or specific selected skills.
# 2. Preserve Existing Skills: Never delete or overwrite user's own skills.
# 3. Update Skills: Only refresh symlinks that strictly verify to Kio repo.
# 4. Uninstall Kio: Safely remove ONLY components verified to belong to Kio.
# 5. Ownership Manifest: Track all Kio-created symlinks in ~/.kio/manifest.json.
# ==============================================================================

set -e

KIO_CONFIG_DIR="$HOME/.kio"
KIO_REPO_DIR="$KIO_CONFIG_DIR/repo"
KIO_REPO_URL="${KIO_REPO_URL:-https://github.com/toanpham2111/kio-agent-system.git}"
[ -n "${KIO_TARBALL_URL:-}" ] && KIO_TARBALL_URL_SET=1
KIO_TARBALL_URL="${KIO_TARBALL_URL:-https://github.com/toanpham2111/kio-agent-system/archive/refs/heads/main.tar.gz}"
KIO_UPDATE_FAILED=false
MANIFEST_FILE="$KIO_CONFIG_DIR/manifest.json"

USING_MANAGED_REPO=false
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  CANDIDATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -d "$CANDIDATE_DIR/skills/kio-frontend-craft" ]; then
    SCRIPT_DIR="$CANDIDATE_DIR"
    SKILLS_SRC_DIR="$SCRIPT_DIR/skills"
  else
    USING_MANAGED_REPO=true
    SCRIPT_DIR="$KIO_REPO_DIR"
    SKILLS_SRC_DIR="$KIO_REPO_DIR/skills"
  fi
else
  USING_MANAGED_REPO=true
  SCRIPT_DIR="$KIO_REPO_DIR"
  SKILLS_SRC_DIR="$KIO_REPO_DIR/skills"
fi

# 7 Core Kio Skills
ALL_KIO_SKILLS=(
  "kio-core-delivery"
  "kio-frontend-craft"
  "kio-backend-cloud"
  "kio-qa-security"
  "kio-growth-marketing"
  "kio-wordpress-fse"
  "kio-cognitive"
)

# AI Tool skill destinations
TARGET_SKILLS_DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.cursor/skills"
  "$HOME/.gemini/config/skills"
  "$HOME/.codex/skills"
  "$HOME/.agents/skills"
)

# Resolve real path portably (Linux / macOS)
resolve_path() {
  local target="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath "$target" 2>/dev/null || echo "$target"
  elif command -v readlink >/dev/null 2>&1; then
    readlink -f "$target" 2>/dev/null || readlink "$target" 2>/dev/null || echo "$target"
  else
    python3 -c "import os, sys; print(os.path.realpath(sys.argv[1]))" "$target" 2>/dev/null || echo "$target"
  fi
}

# Ownership Manifest Management
init_manifest() {
  mkdir -p "$KIO_CONFIG_DIR"
  if [ ! -f "$MANIFEST_FILE" ]; then
    echo '{"version":"1.0","managed_links":[]}' > "$MANIFEST_FILE"
  fi
}

record_manifest() {
  local link_path="$1"
  local target_path="$2"
  init_manifest
  python3 -c "
import json, os, sys
m_path = sys.argv[1]
l_path = os.path.abspath(sys.argv[2])
t_path = os.path.abspath(sys.argv[3])
try:
    with open(m_path, 'r') as f:
        data = json.load(f)
except Exception:
    data = {'version': '1.0', 'managed_links': []}

links = [entry for entry in data.get('managed_links', []) if entry.get('link') != l_path]
links.append({'link': l_path, 'target': t_path})
data['managed_links'] = links

with open(m_path, 'w') as f:
    json.dump(data, f, indent=2)
" "$MANIFEST_FILE" "$link_path" "$target_path" 2>/dev/null || true
}

remove_from_manifest() {
  local link_path="$1"
  [ -f "$MANIFEST_FILE" ] || return 0
  python3 -c "
import json, os, sys
m_path = sys.argv[1]
l_path = os.path.abspath(sys.argv[2])
try:
    with open(m_path, 'r') as f:
        data = json.load(f)
    data['managed_links'] = [e for e in data.get('managed_links', []) if e.get('link') != l_path]
    with open(m_path, 'w') as f:
        json.dump(data, f, indent=2)
except Exception:
    pass
" "$MANIFEST_FILE" "$link_path" 2>/dev/null || true
}

is_in_manifest() {
  local link_path="$1"
  [ -f "$MANIFEST_FILE" ] || return 1
  python3 -c "
import json, os, sys
m_path = sys.argv[1]
l_path = os.path.abspath(sys.argv[2])
try:
    with open(m_path, 'r') as f:
        data = json.load(f)
    match = any(e.get('link') == l_path for e in data.get('managed_links', []))
    sys.exit(0 if match else 1)
except Exception:
    sys.exit(1)
" "$MANIFEST_FILE" "$link_path" 2>/dev/null
}

is_recorded_kio_target() {
  local link_path="$1"
  local actual_dest="$2"
  local skill_name="$3"
  [ -f "$MANIFEST_FILE" ] || return 1
  python3 -c "
import json, os, sys
m_path = sys.argv[1]
l_path = os.path.abspath(sys.argv[2])
a_dest = os.path.realpath(sys.argv[3])
s_name = sys.argv[4]
try:
    with open(m_path, 'r') as f:
        data = json.load(f)
    for e in data.get('managed_links', []):
        if e.get('link') == l_path:
            rec_target = os.path.realpath(e.get('target', ''))
            if rec_target == a_dest and os.path.basename(a_dest) == s_name:
                sys.exit(0)
    sys.exit(1)
except Exception:
    sys.exit(1)
" "$MANIFEST_FILE" "$link_path" "$actual_dest" "$skill_name" 2>/dev/null
}

# Resolve which version of Kio to install into ~/.kio/repo.
# KIO_REF (a tag such as v1.2.0, or a branch such as main) wins; otherwise the
# newest released v* tag is used, so a piped install never picks up unreleased work.
resolve_kio_ref() {
  if [ -n "${KIO_REF:-}" ]; then
    echo "$KIO_REF"
    return 0
  fi
  local latest=""
  if command -v git >/dev/null 2>&1; then
    latest=$(git ls-remote --tags --refs --sort=-v:refname "$KIO_REPO_URL" 'v*' 2>/dev/null \
      | head -n 1 | sed 's#.*refs/tags/##')
  fi
  if [ -n "$latest" ]; then
    echo "$latest"
  else
    echo "⚠️  Could not list Kio release tags from $KIO_REPO_URL; falling back to 'main'." >&2
    echo "main"
  fi
}

# Ensure Kio repository exists locally when executed via curl | bash
ensure_kio_repo_source() {
  if [ "$USING_MANAGED_REPO" = false ] && [ -d "$SKILLS_SRC_DIR/kio-frontend-craft" ]; then
    return 0
  fi

  mkdir -p "$KIO_CONFIG_DIR"
  local ref
  ref=$(resolve_kio_ref)

  if [ -d "$KIO_REPO_DIR/.git" ] && command -v git >/dev/null 2>&1; then
    echo "🔄 Updating managed Kio repository in $KIO_REPO_DIR to '$ref'..."
    local fetch_log
    if fetch_log=$(git -C "$KIO_REPO_DIR" fetch --depth 1 --force origin "$ref" 2>&1) \
       && fetch_log=$(git -C "$KIO_REPO_DIR" checkout --quiet --force --detach FETCH_HEAD 2>&1); then
      case "$ref" in v[0-9]*) git -C "$KIO_REPO_DIR" tag -f "$ref" HEAD >/dev/null 2>&1 || true ;; esac
      echo "   └── ✅ Now at $ref ($(git -C "$KIO_REPO_DIR" rev-parse --short HEAD))"
    else
      echo "❌ ERROR: could not update $KIO_REPO_DIR to '$ref'." >&2
      echo "$fetch_log" | sed 's/^/      /' >&2
      echo "   Skills will keep using the copy already on disk ($(git -C "$KIO_REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown))." >&2
      echo "   Fix the problem above, or delete $KIO_REPO_DIR and run the installer again." >&2
      KIO_UPDATE_FAILED=true
    fi
  elif [ ! -d "$KIO_REPO_DIR/skills/kio-frontend-craft" ]; then
    echo "🌐 Piped/standalone install detected — fetching Kio '$ref' to $KIO_REPO_DIR..."
    rm -rf "$KIO_REPO_DIR"
    if command -v git >/dev/null 2>&1; then
      if ! git clone --quiet --depth 1 --branch "$ref" "$KIO_REPO_URL" "$KIO_REPO_DIR"; then
        echo "❌ Error: git clone of '$ref' from $KIO_REPO_URL failed." >&2
        exit 1
      fi
    elif command -v curl >/dev/null 2>&1 && command -v tar >/dev/null 2>&1; then
      local tarball_url="$KIO_TARBALL_URL"
      if [ -z "${KIO_TARBALL_URL_SET:-}" ]; then
        case "$ref" in
          v[0-9]*) tarball_url="https://github.com/toanpham2111/kio-agent-system/archive/refs/tags/$ref.tar.gz" ;;
          *)       tarball_url="https://github.com/toanpham2111/kio-agent-system/archive/refs/heads/$ref.tar.gz" ;;
        esac
      fi
      mkdir -p "$KIO_REPO_DIR"
      if ! curl -fsSL "$tarball_url" | tar -xz --strip-components=1 -C "$KIO_REPO_DIR"; then
        echo "❌ Error: downloading $tarball_url failed." >&2
        exit 1
      fi
    else
      echo "❌ Error: Neither 'git' nor 'curl + tar' is available to download Kio skills."
      exit 1
    fi
  fi

  SCRIPT_DIR="$KIO_REPO_DIR"
  SKILLS_SRC_DIR="$KIO_REPO_DIR/skills"
}

# Strict Ownership Verification:
# A symlink is ONLY considered Kio-owned if its actual destination points to
# the expected Kio skill folder (local clone, ~/.kio/repo, or recorded manifest target).
# If user replaced it or target points elsewhere, we prune any stale manifest entry and return 1 (PRESERVE).
verify_kio_ownership() {
  local link_path="$1"
  local skill_name="$2"

  [ -L "$link_path" ] || return 1

  local actual_dest
  actual_dest=$(resolve_path "$link_path")
  local expected_dest
  expected_dest=$(resolve_path "$SKILLS_SRC_DIR/$skill_name")
  local managed_dest
  managed_dest=$(resolve_path "$KIO_REPO_DIR/skills/$skill_name")

  # Exact target match with boundary check
  if [ -n "$actual_dest" ] && { [ "$actual_dest" = "$expected_dest" ] || [ "$actual_dest" = "$managed_dest" ] || is_recorded_kio_target "$link_path" "$actual_dest" "$skill_name"; }; then
    return 0
  else
    # Mismatch: User pointed this link elsewhere! Prune stale manifest entry.
    remove_from_manifest "$link_path"
    return 1
  fi
}

# Helper: Resolve skill shortcut or name
resolve_skill_name() {
  local input="$1"
  case "$input" in
    frontend|fe|craft|kio-frontend-craft)
      echo "kio-frontend-craft" ;;
    backend|be|cloud|kio-backend-cloud)
      echo "kio-backend-cloud" ;;
    qa|test|security|kio-qa-security)
      echo "kio-qa-security" ;;
    core|delivery|sdd|kio-core-delivery)
      echo "kio-core-delivery" ;;
    marketing|growth|seo|kio-growth-marketing)
      echo "kio-growth-marketing" ;;
    wordpress|wp|fse|kio-wordpress-fse)
      echo "kio-wordpress-fse" ;;
    cognitive|think|why|kio-cognitive)
      echo "kio-cognitive" ;;
    *)
      if [ -d "$SKILLS_SRC_DIR/$input" ]; then
        echo "$input"
      else
        echo ""
      fi
      ;;
  esac
}

# Action: List available skills
list_skills() {
  echo "================================================================="
  echo "🧰 Kio: Available Engineering Skills (7 Master Skills)"
  echo "================================================================="
  echo "1. kio-frontend-craft   (shortcut: frontend, fe)  - UI/UX, 79 styles, 192 palettes, Lenis"
  echo "2. kio-backend-cloud    (shortcut: backend, be)   - REST/GraphQL APIs, RLS, Docker, Cloud"
  echo "3. kio-qa-security      (shortcut: qa, test)      - Test matrix, Unit tests (Vitest/Pytest), Playwright"
  echo "4. kio-core-delivery    (shortcut: core)          - Atomic tasks (2-5m), SDD spec-kit templates"
  echo "5. kio-growth-marketing (shortcut: growth, seo)   - 53 CRO frameworks, technical SEO modules"
  echo "6. kio-wordpress-fse    (shortcut: wp, fse)       - S0-S8 clean Gutenberg block themes pipeline"
  echo "7. kio-cognitive        (shortcut: cognitive)     - First-principles, architecture rationale"
  echo "================================================================="
}

# Slash commands (/kio-fe, /kio-spec-specify, ...). Command files are COPIED (file
# symlinks need admin rights on Windows, so both installers copy) and carry the marker
# below; only files with the marker are ever replaced or removed.
KIO_CMD_MARK="kio-command:"
TARGET_COMMAND_DIRS=(
  "$HOME/.claude/commands"
  "$HOME/.codex/prompts"
  "$HOME/.cursor/commands"
)
GEMINI_COMMAND_DIR="$HOME/.gemini/commands"

kio_command_to_toml() {
  # Gemini CLI commands are TOML: description + prompt, with {{args}} for the arguments.
  local src="$1"
  local desc
  desc=$(sed -n 's/^description: //p' "$src" | head -1)
  echo "# $KIO_CMD_MARK managed by the Kio installer; local edits are replaced on update"
  echo "description = $desc"
  echo "prompt = '''"
  awk 'f==2 {print; next} /^---[[:space:]]*$/ {f++}' "$src" | sed 's/\$ARGUMENTS/{{args}}/g' | grep -v "$KIO_CMD_MARK"
  echo "'''"
}

install_commands() {
  local src_dir="$SCRIPT_DIR/commands"
  if [ ! -d "$src_dir" ]; then
    echo "   └── ⚠️ No commands/ folder in $SCRIPT_DIR (skipping slash commands)"
    return 0
  fi
  local installed=0 kept=0 dir ext old name src dest
  for dir in "${TARGET_COMMAND_DIRS[@]}" "$GEMINI_COMMAND_DIR"; do
    mkdir -p "$dir"
    ext="md"; [ "$dir" = "$GEMINI_COMMAND_DIR" ] && ext="toml"
    # drop Kio commands that no longer exist upstream
    for old in "$dir"/kio*."$ext"; do
      [ -e "$old" ] || continue
      name=$(basename "$old" ".$ext")
      if [ ! -f "$src_dir/$name.md" ] && grep -q "$KIO_CMD_MARK" "$old"; then rm -f "$old"; fi
    done
    for src in "$src_dir"/*.md; do
      [ -e "$src" ] || continue
      name=$(basename "$src" .md)
      dest="$dir/$name.$ext"
      if [ -e "$dest" ] && ! grep -q "$KIO_CMD_MARK" "$dest"; then
        kept=$((kept + 1)); continue   # the user's own file with this name: never overwritten
      fi
      if [ "$ext" = "toml" ]; then kio_command_to_toml "$src" > "$dest"; else cp "$src" "$dest"; fi
      installed=$((installed + 1))
    done
  done
  echo "⌨️  Slash commands: $installed file(s) written to ~/.claude/commands, ~/.codex/prompts, ~/.cursor/commands, ~/.gemini/commands"
  if [ "$kept" -gt 0 ]; then echo "   └── 🛡️ $kept existing file(s) with the same name are yours and were left untouched"; fi
  return 0
}

uninstall_commands() {
  local removed=0 dir f
  for dir in "${TARGET_COMMAND_DIRS[@]}" "$GEMINI_COMMAND_DIR"; do
    for f in "$dir"/kio*.md "$dir"/kio*.toml; do
      [ -e "$f" ] || continue
      if grep -q "$KIO_CMD_MARK" "$f"; then rm -f "$f"; removed=$((removed + 1)); fi
    done
  done
  echo "⌨️  Removed $removed Kio slash command file(s)"
}

# Action: Install / Update selected skills
install_skills() {
  local selected_skills=("$@")
  echo "================================================================="
  echo "⬇️  Kio Skills Installer: Safe & Non-Destructive Mode"
  echo "================================================================="

  ensure_kio_repo_source
  init_manifest

  for target_dir in "${TARGET_SKILLS_DIRS[@]}"; do
    mkdir -p "$target_dir"
    echo "📦 Checking directory: $target_dir"

    for skill_name in "${selected_skills[@]}"; do
      local skill_path="$SKILLS_SRC_DIR/$skill_name"
      if [ ! -d "$skill_path" ]; then
        echo "   └── ⚠️ Skill source not found: $skill_name"
        continue
      fi

      local target_skill="$target_dir/$skill_name"

      # Preserve Existing Skills Rule:
      if [ -L "$target_skill" ]; then
        # Strictly verify ownership by comparing real target
        if verify_kio_ownership "$target_skill" "$skill_name"; then
          ln -sfn "$skill_path" "$target_skill"
          record_manifest "$target_skill" "$skill_path"
          echo "   └── 🔄 Updated verified Kio symlink: $skill_name"
        else
          local external_dest
          external_dest=$(readlink "$target_skill" 2>/dev/null || true)
          echo "   └── 🛡️ PRESERVED: $target_skill is a custom user symlink -> '$external_dest' (Skipped, not modified)"
        fi
      elif [ -e "$target_skill" ]; then
        # Regular directory or file owned by user - NEVER OVERWRITE
        echo "   └── 🛡️ PRESERVED: $target_skill is a user folder (Skipped, not modified)"
      else
        # Target does not exist, create safe symlink and record in manifest
        ln -s "$skill_path" "$target_skill"
        record_manifest "$target_skill" "$skill_path"
        echo "   └── 🔗 Linked skill: $skill_name"
      fi
    done
  done

  install_commands
  echo ""
  echo "================================================================="
  if [ "$KIO_UPDATE_FAILED" = true ]; then
    echo "⚠️  Links are in place, but the Kio update FAILED (see the error above)."
    echo "   Your skills still point at the previous version on disk."
    echo "================================================================="
    exit 2
  fi
  echo "✅ SUCCESS: Selected Kio skills installed/updated!"
  echo "   Ownership: Tracked in $MANIFEST_FILE"
  echo "   Preserved: All existing user skills untouched."
  echo "================================================================="
}

# Action: Uninstall only Kio skills
uninstall_kio() {
  echo "================================================================="
  echo "🗑️  Uninstalling Kio Skills..."
  echo "   (Only components strictly verified to belong to Kio will be removed)"
  echo "================================================================="

  local removed_count=0

  for target_dir in "${TARGET_SKILLS_DIRS[@]}"; do
    [ -d "$target_dir" ] || continue
    echo "🔍 Checking: $target_dir"

    for skill_name in "${ALL_KIO_SKILLS[@]}"; do
      local target_skill="$target_dir/$skill_name"

      if [ -L "$target_skill" ]; then
        # Strictly verify that actual target points to Kio
        if verify_kio_ownership "$target_skill" "$skill_name"; then
          rm -f "$target_skill"
          remove_from_manifest "$target_skill"
          echo "   └── 🗑️ Removed verified Kio symlink: $skill_name"
          removed_count=$((removed_count + 1))
        else
          local external_dest
          external_dest=$(readlink "$target_skill" 2>/dev/null || true)
          echo "   └── 🛡️ PRESERVED: $target_skill points to external location '$external_dest' (Not touched)"
        fi
      elif [ -e "$target_skill" ]; then
        echo "   └── 🛡️ PRESERVED: $target_skill is a regular folder (Not touched)"
      fi
    done
  done

  uninstall_commands
  echo ""
  echo "================================================================="
  echo "✅ SUCCESS: Kio skills uninstalled ($removed_count symlinks removed)."
  echo "   All other user skills remain completely untouched."
  echo "================================================================="
}

# Action: Interactive Menu
interactive_menu() {
  list_skills
  echo ""
  echo "Please select an option:"
  echo "  1) Install All 7 Kio Skills (Recommended)"
  echo "  2) Choose Specific Skill(s) to Install"
  echo "  3) Update Existing Kio Skills"
  echo "  4) Uninstall Kio Skills"
  echo "  5) Exit"
  echo ""
  read -r -p "Enter choice [1-5]: " choice

  case "$choice" in
    1)
      install_skills "${ALL_KIO_SKILLS[@]}"
      ;;
    2)
      echo "Enter skill name(s) or shortcuts (e.g. frontend, backend, qa, all):"
      read -r -p "Skills to install: " input_skills
      parse_and_install "$input_skills"
      ;;
    3)
      install_skills "${ALL_KIO_SKILLS[@]}"
      ;;
    4)
      read -r -p "Are you sure you want to remove Kio skills? [y/N]: " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        uninstall_kio
      else
        echo "Canceled."
      fi
      ;;
    5|*)
      echo "Exiting."
      exit 0
      ;;
  esac
}

# Parse comma-separated or space-separated skill list
parse_and_install() {
  local raw_input="$1"
  local resolved_skills=()
  
  # Replace commas with spaces
  raw_input="${raw_input//,/ }"

  for item in $raw_input; do
    [ -n "$item" ] || continue
    if [ "$item" = "all" ]; then
      resolved_skills=("${ALL_KIO_SKILLS[@]}")
      break
    fi
    local resolved
    resolved=$(resolve_skill_name "$item")
    if [ -n "$resolved" ]; then
      resolved_skills+=("$resolved")
    else
      echo "⚠️ Unknown skill shortcut: '$item'. Run './setup.sh --list' to see valid names."
    fi
  done

  if [ ${#resolved_skills[@]} -eq 0 ]; then
    echo "No valid skills selected for installation."
    exit 1
  fi

  install_skills "${resolved_skills[@]}"
}

# Print CLI help
show_help() {
  echo "Kio Skills Installer & Manager"
  echo ""
  echo "Usage:"
  echo "  ./setup.sh                         Install / update all 7 skills safely"
  echo "  ./setup.sh --skill <name>          Install specific skill(s) (comma-separated)"
  echo "  ./setup.sh --list                  List all available skills & shortcuts"
  echo "  ./setup.sh --uninstall             Safely remove Kio skills (preserves user skills)"
  echo "  ./setup.sh --interactive           Open interactive menu"
  echo "  ./setup.sh --help                  Show this help"
  echo ""
  echo "Environment:"
  echo "  KIO_REF=v1.2.0 | main              Version for piped installs (default: latest release tag)"
  echo "  KIO_REPO_URL=<git url>             Alternative repository"
  echo ""
  echo "Examples:"
  echo "  ./setup.sh --skill frontend"
  echo "  ./setup.sh --skill frontend,qa,backend"
  echo "  ./setup.sh --uninstall"
}

# Argument parsing
DO_LIST=false
DO_UNINSTALL=false
DO_INTERACTIVE=false
SKILL_ARGS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list|-l)
      DO_LIST=true
      shift
      ;;
    --uninstall|-u)
      DO_UNINSTALL=true
      shift
      ;;
    --interactive|-i)
      DO_INTERACTIVE=true
      shift
      ;;
    --skill|-s)
      SKILL_ARGS="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      # Treat raw arguments like 'frontend,qa' as --skill
      if [ -z "$SKILL_ARGS" ]; then
        SKILL_ARGS="$1"
      fi
      shift
      ;;
  esac
done

if [ "$DO_LIST" = true ]; then
  list_skills
  exit 0
fi

if [ "$DO_UNINSTALL" = true ]; then
  uninstall_kio
  exit 0
fi

if [ "$DO_INTERACTIVE" = true ]; then
  interactive_menu
  exit 0
fi

if [ -n "$SKILL_ARGS" ]; then
  parse_and_install "$SKILL_ARGS"
  exit 0
fi

# Default: install all skills non-destructively
install_skills "${ALL_KIO_SKILLS[@]}"
