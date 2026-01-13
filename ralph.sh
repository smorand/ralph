#!/usr/bin/env bash
set -euo pipefail;

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";

# Detect OS for install instructions
if [[ "$(uname -s)" == "Darwin" ]]; then
  OS="mac";
else
  OS="linux";
fi;

# Check required CLI tools are installed
check_command() {
  local cmd="$1";
  local install_mac="$2";
  local install_linux="$3";

  if ! command -v "${cmd}" &> /dev/null; then
    echo "ERROR: '${cmd}' is not installed.";
    if [[ "${OS}" == "mac" ]]; then
      echo "To install on macOS: ${install_mac}";
    else
      echo "To install on Linux: ${install_linux}";
    fi;
    exit 1;
  fi;
}

check_command "yq" \
  "brew install yq" \
  "sudo apt install yq  OR  sudo snap install yq  OR  go install github.com/mikefarah/yq/v4@latest";

check_command "git" \
  "brew install git" \
  "sudo apt install git";

# Check claude CLI (extract binary name from config, handle arguments)
AGENT_CMD="$(cat "${SCRIPT_DIR}/ralph.yaml" | yq -r ".agent")";
AGENT_BIN="${AGENT_CMD%% *}";

if ! command -v "${AGENT_BIN}" &> /dev/null; then
  echo "ERROR: '${AGENT_BIN}' is not installed.";
  echo "To install: npm install -g @anthropic-ai/claude-code";
  exit 1;
fi;

echo "All required tools are installed.";

AGENT_BIN="${AGENT_CMD}";
MAX_ITERATIONS="$(cat "${SCRIPT_DIR}/ralph.yaml" | yq -r ".max_iterations")";
PROMPT="$(cat "${SCRIPT_DIR}/ralph.yaml" | yq -r ".instructions")";
US_ID_REGEXP=$(cat "${SCRIPT_DIR}/ralph.yaml" | yq -r ".user_story_id_regex");

# User stories must have valid ID, title and tests at least. Passes must exist or be forced to false if missing.

STORIES_FILE="${SCRIPT_DIR}/stories.yaml";

# Validate stories and add missing passes field
echo "Validating user stories...";

STORY_COUNT=$(yq -r 'length' "${STORIES_FILE}");
for i in $(seq 0 $((STORY_COUNT - 1))); do
  STORY_ID=$(yq -r ".[$i].id // \"\"" "${STORIES_FILE}");
  STORY_TITLE=$(yq -r ".[$i].title // \"\"" "${STORIES_FILE}");
  TESTS_COUNT=$(yq -r ".[$i].tests | length" "${STORIES_FILE}");
  HAS_PASSES=$(yq -r ".[$i] | has(\"passes\")" "${STORIES_FILE}");

  # Validate story ID format
  if [[ -z "${STORY_ID}" ]] || ! [[ "${STORY_ID}" =~ ${US_ID_REGEXP} ]]; then
    echo "ERROR: Story at index ${i} has invalid ID '${STORY_ID}' (must match ${US_ID_REGEXP})";
    exit 1;
  fi;

  # Validate title exists
  if [[ -z "${STORY_TITLE}" ]]; then
    echo "ERROR: Story ${STORY_ID} is missing a title";
    exit 1;
  fi;

  # Validate tests section has at least one test
  if [[ "${TESTS_COUNT}" -lt 1 ]]; then
    echo "ERROR: Story ${STORY_ID} must have at least one test in the tests section";
    exit 1;
  fi;

  # Add passes: false if missing
  if [[ "${HAS_PASSES}" == "false" ]]; then
    echo "Adding passes: false to story ${STORY_ID}";
    yq -i ".[$i].passes = false" "${STORIES_FILE}";
  fi;
done;

echo "All ${STORY_COUNT} stories validated successfully";

echo "Starting agent";
for i in $(seq 1 $MAX_ITERATIONS); do
  echo "═══════ Iteration ${i} ═══════";
  
  OUTPUT=$(echo "${PROMPT}" | ${AGENT_BIN} 2>&1 | tee /dev/stderr) || true;
  
  if echo "${OUTPUT}" | grep -q "<promise>COMPLETE</promise>";
  then
    echo "Done!";
    exit 0;
  fi;
  
  sleep 2;

done;

echo "Max iterations reached";
exit 1;
