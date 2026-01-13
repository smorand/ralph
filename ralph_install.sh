#!/usr/bin/env bash
set -euo pipefail;

# Ralph installer - symlinks ralph files to current directory

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

# Track if already installed
ALREADY_INSTALLED=false;

# Create symlinks for ralph.sh and ralph.yaml if they don't exist
for file in ralph.sh ralph.yaml; do
  if [[ -e "${TARGET_DIR}/${file}" || -L "${TARGET_DIR}/${file}" ]]; then
    ALREADY_INSTALLED=true;
  else
    ln -s "${SCRIPT_DIR}/${file}" "${TARGET_DIR}/${file}";
  fi;
done;

# Copy stories.yaml only if it doesn't exist
if [[ -e "${TARGET_DIR}/stories.yaml" || -L "${TARGET_DIR}/stories.yaml" ]]; then
  echo "stories.yaml already exists, skipping.";
else
  cp "${SCRIPT_DIR}/stories.yaml.template" "${TARGET_DIR}/stories.yaml";
fi;

if [[ "${ALREADY_INSTALLED}" == "true" ]]; then
  echo "Ralph already installed in ${TARGET_DIR}, skipping.";
else
  echo "Ralph installed successfully in ${TARGET_DIR}";
fi;
echo "";
echo "Next steps:";
echo "  1. Edit ralph.yaml to customize agent settings";
echo "  2. Edit stories.yaml to add your user stories";
echo "  3. Run './ralph.sh check' to validate your setup";
echo "  4. Run './ralph.sh run' to start implementation";
