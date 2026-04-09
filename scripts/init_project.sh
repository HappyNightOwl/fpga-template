#!/usr/bin/env bash
set -euo pipefail

# Initialize this FPGA workflow into another folder.
# Usage:
#   ./scripts/init_project.sh /path/to/new_project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="${1:-}"

if [[ -z "${TARGET_DIR}" ]]; then
    echo "Usage: $0 /path/to/new_project" >&2
    exit 1
fi

mkdir -p "${TARGET_DIR}/rtl" "${TARGET_DIR}/constr" "${TARGET_DIR}/scripts" "${TARGET_DIR}/build" "${TARGET_DIR}/.vscode"

cp "${SOURCE_ROOT}/scripts/build.tcl" "${TARGET_DIR}/scripts/build.tcl"
cp "${SOURCE_ROOT}/scripts/build.sh" "${TARGET_DIR}/scripts/build.sh"
cp "${SOURCE_ROOT}/scripts/build_and_program.sh" "${TARGET_DIR}/scripts/build_and_program.sh"
cp "${SOURCE_ROOT}/.vscode/tasks.json" "${TARGET_DIR}/.vscode/tasks.json"
cp "${SOURCE_ROOT}/.vscode/launch.json" "${TARGET_DIR}/.vscode/launch.json"

if [[ ! -f "${TARGET_DIR}/fpga.env" ]]; then
    cp "${SOURCE_ROOT}/fpga.env" "${TARGET_DIR}/fpga.env"
fi

chmod +x "${TARGET_DIR}/scripts/build.sh" "${TARGET_DIR}/scripts/build_and_program.sh"

echo "Initialized FPGA workflow in: ${TARGET_DIR}"
echo "Next: edit ${TARGET_DIR}/fpga.env, then add your rtl/ and constr/ files."
