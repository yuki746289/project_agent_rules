#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash ./pull_rules.sh

Examples:
  bash ./pull_rules.sh

The script pulls items from the latest .rules_v4 directory in the source
repository into the current repository's .rules directory.

Existing items under .rules are replaced only after confirmation.
Local-only items under .rules are kept.
USAGE
}

DEFAULT_SOURCE_REPO="yuki746289/product_agent_rules"
DEFAULT_RULE_DIR=".rules_v4"

normalize_repo_url() {
  local repo="$1"

  if [[ "$repo" == *"://"* || "$repo" == git@* ]]; then
    printf '%s\n' "$repo"
    return
  fi

  if [[ "$repo" == */* ]]; then
    printf 'https://github.com/%s.git\n' "$repo"
    return
  fi

  printf '%s\n' "$repo"
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Error: '$command_name' is required." >&2
    exit 1
  fi
}

confirm() {
  local prompt="$1"
  local answer

  while true; do
    read -r -p "$prompt [y/yes/n/no]: " answer
    case "${answer,,}" in
      y|yes)
        return 0
        ;;
      n|no|"")
        return 1
        ;;
      *)
        echo "Please answer y, yes, n, or no."
        ;;
    esac
  done
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$#" -gt 0 ]]; then
  echo "Error: arguments are not supported. Run: bash ./pull_rules.sh" >&2
  usage >&2
  exit 1
fi

require_command git

source_repo="$DEFAULT_SOURCE_REPO"

if [[ -z "$source_repo" ]]; then
  echo "Error: source repository is required." >&2
  usage >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this script inside the destination Git repository." >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
source_url="$(normalize_repo_url "$source_repo")"
tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

clone_args=(clone --depth 1)
clone_args+=("$source_url" "$tmp_dir/source")

echo "Cloning source repository..."
git "${clone_args[@]}" >/dev/null

selected_dir="$DEFAULT_RULE_DIR"
source_path="$tmp_dir/source/$selected_dir"

if [[ ! -d "$source_path" ]]; then
  echo "Error: '$selected_dir' was not found in the source repository." >&2
  exit 1
fi

destination_path="$repo_root/.rules"

mkdir -p "$destination_path"

echo
echo "Pulling items from '$selected_dir' into '.rules'."
echo "Existing items are replaced only after confirmation."
echo "Local-only items in '.rules' are kept."

copied_count=0
replaced_count=0
skipped_count=0
local_only_count=0

shopt -s dotglob nullglob

source_items=("$source_path"/*)

if [[ "${#source_items[@]}" -eq 0 ]]; then
  echo
  echo "No items found in '$selected_dir'."
fi

for source_item in "${source_items[@]}"; do
  item_name="$(basename "$source_item")"
  destination_item="$destination_path/$item_name"
  display_path=".rules/$item_name"

  if [[ -e "$destination_item" || -L "$destination_item" ]]; then
    echo
    if confirm "Replace '$display_path'?"; then
      rm -rf "$destination_item"
      cp -R "$source_item" "$destination_item"
      replaced_count=$((replaced_count + 1))
    else
      echo "Skipped '$display_path'."
      skipped_count=$((skipped_count + 1))
    fi
  else
    echo
    if confirm "Copy new '$display_path'?"; then
      cp -R "$source_item" "$destination_item"
      copied_count=$((copied_count + 1))
    else
      echo "Skipped '$display_path'."
      skipped_count=$((skipped_count + 1))
    fi
  fi
done

for destination_item in "$destination_path"/*; do
  item_name="$(basename "$destination_item")"
  if [[ ! -e "$source_path/$item_name" && ! -L "$source_path/$item_name" ]]; then
    if [[ "$local_only_count" -eq 0 ]]; then
      echo
      echo "Local-only items kept:"
    fi
    echo "  .rules/$item_name"
    local_only_count=$((local_only_count + 1))
  fi
done

shopt -u dotglob nullglob

echo
echo "Pull complete:"
echo "  $destination_path"
echo "  copied: $copied_count"
echo "  replaced: $replaced_count"
echo "  skipped: $skipped_count"
echo "  local-only kept: $local_only_count"
echo
echo "Review changes with:"
echo "  git status --short"
echo "  git diff --stat"
