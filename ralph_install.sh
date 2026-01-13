#!/usr/bin/env bash
set -euo pipefail;

# Ralph installer - copies ralph files to current directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
TARGET_DIR="$(pwd)";

# Check we're not installing into the ralph source directory
if [[ "${TARGET_DIR}" == "${SCRIPT_DIR}" ]]; then
  echo "ERROR: Cannot install into the ralph source directory.";
  echo "Run this script from your target project directory.";
  exit 1;
fi;

# Check required source files exist
for file in ralph.sh ralph.yaml stories.yaml.template; do
  if [[ ! -f "${SCRIPT_DIR}/${file}" ]]; then
    echo "ERROR: Missing source file '${file}' in ${SCRIPT_DIR}";
    exit 1;
  fi;
done;

# Check target files don't already exist
for file in ralph.sh ralph.yaml stories.yaml; do
  if [[ -f "${TARGET_DIR}/${file}" ]]; then
    echo "ERROR: '${file}' already exists in ${TARGET_DIR}";
    echo "Remove it first or use a different directory.";
    exit 1;
  fi;
done;

# Copy files
cp "${SCRIPT_DIR}/ralph.sh" "${TARGET_DIR}/ralph.sh";
cp "${SCRIPT_DIR}/ralph.yaml" "${TARGET_DIR}/ralph.yaml";
cp "${SCRIPT_DIR}/stories.yaml.template" "${TARGET_DIR}/stories.yaml";

chmod +x "${TARGET_DIR}/ralph.sh";

echo "Ralph installed successfully in ${TARGET_DIR}";
echo "";
echo "Next steps:";
echo "  1. Edit ralph.yaml to customize agent settings";
echo "  2. Edit stories.yaml to add your user stories";
echo "  3. Run './ralph.sh check' to validate your setup";
echo "  4. Run './ralph.sh run' to start implementation";
