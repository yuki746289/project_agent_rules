#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash ./pull_rules.sh

Examples:
  bash ./pull_rules.sh

The script lists .rules_* directories from the source repository and copies the
selected directory into the current repository as .rules.
USAGE
}

DEFAULT_SOURCE_REPO="yuki746289/project_agent_rules"

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

mapfile -t rule_dirs < <(
  find "$tmp_dir/source" -mindepth 1 -maxdepth 1 -type d -name '.rules_*' -printf '%f\n' | sort -V
)

if [[ "${#rule_dirs[@]}" -eq 0 ]]; then
  echo "Error: no .rules_* directories were found in the source repository." >&2
  exit 1
fi

echo
echo "pullするルールを選択して下さい。"
for index in "${!rule_dirs[@]}"; do
  printf '  %d. %s\n' "$((index + 1))" "${rule_dirs[$index]}"
done

echo
read -r -p "Select directory number: " selection

if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
  echo "Error: selection must be a number." >&2
  exit 1
fi

selected_index="$((selection - 1))"
if (( selected_index < 0 || selected_index >= ${#rule_dirs[@]} )); then
  echo "Error: selection is out of range." >&2
  exit 1
fi

selected_dir="${rule_dirs[$selected_index]}"
source_path="$tmp_dir/source/$selected_dir"
destination_path="$repo_root/.rules"

if [[ -e "$destination_path" ]]; then
  echo
  echo "'.rules' already exists and will be replaced with '$selected_dir'."
  echo "This removes the current '.rules' directory before copying the selected one."
  if ! confirm "Replace '.rules'?"; then
    echo "Canceled."
    exit 0
  fi
  rm -rf "$destination_path"
fi

cp -R "$source_path" "$destination_path"

echo
echo "Pulled '$selected_dir' into '.rules':"
echo "  $destination_path"
echo
echo "Review changes with:"
echo "  git status --short"
echo "  git diff --stat"
