#!/usr/bin/env bash
set -euo pipefail

# End-to-end local workflow:
# 1. Check local and remote environment.
# 2. Sync local sources to the remote server.
# 3. Run the remote Vivado batch build.
# 4. Download the generated bitstream.
# 5. Program the locally connected FPGA with openFPGALoader.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_NAME="$(basename "${PROJECT_ROOT}")"

if [[ -f "${PROJECT_ROOT}/fpga.env" ]]; then
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/fpga.env"
fi

REMOTE_HOST="${REMOTE_HOST:-www.weitao-jiang.cn}"
REMOTE_PROJECT_DIR="${REMOTE_PROJECT_DIR:-/mnt/data/fpga/${PROJECT_NAME}}"
VIVADO_SETTINGS="${VIVADO_SETTINGS:-/mnt/data/Xilinx/2025.2/Vivado/settings64.sh}"
TOP_MODULE="${TOP_MODULE:-top}"
FPGA_PART="${FPGA_PART:-xc7a35tfgg484-2}"
BITSTREAM_NAME="${BITSTREAM_NAME:-${TOP_MODULE}.bit}"
BIT_FILE="${BIT_FILE:-${PROJECT_ROOT}/build/${BITSTREAM_NAME}}"
PROGRAMMER="${PROGRAMMER:-openFPGALoader}"

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_BLUE=$'\033[1;34m'
    C_CYAN=$'\033[1;36m'
    C_GREEN=$'\033[1;32m'
    C_YELLOW=$'\033[1;33m'
else
    C_RESET=""
    C_BLUE=""
    C_CYAN=""
    C_GREEN=""
    C_YELLOW=""
fi

print_banner() {
    local title="$1"
    printf "\n${C_BLUE}========================================${C_RESET}\n"
    printf "${C_CYAN}%s${C_RESET}\n" "${title}"
    printf "${C_BLUE}========================================${C_RESET}\n"
}

print_info() {
    printf "${C_YELLOW}%s${C_RESET}\n" "$1"
}

print_ok() {
    printf "${C_GREEN}%s${C_RESET}\n" "$1"
}

check_local_cmd() {
    local cmd="$1"
    if command -v "${cmd}" >/dev/null 2>&1; then
        print_ok "[local] OK: ${cmd}"
    else
        echo "[local] MISSING: ${cmd}" >&2
        exit 1
    fi
}

print_banner "STEP 1: CHECK LOCAL TOOLS"
check_local_cmd "${PROGRAMMER}"
check_local_cmd rsync
check_local_cmd scp
check_local_cmd ssh

print_banner "STEP 2: CHECK REMOTE ENVIRONMENT"
print_info "Checking remote host: ${REMOTE_HOST}"
ssh "${REMOTE_HOST}" "bash -lc '
    set -e
    if [[ ! -f \"${VIVADO_SETTINGS}\" ]]; then
        echo \"[remote] MISSING: ${VIVADO_SETTINGS}\" >&2
        exit 1
    fi
    mkdir -p \"${REMOTE_PROJECT_DIR}/rtl\" \"${REMOTE_PROJECT_DIR}/constr\" \"${REMOTE_PROJECT_DIR}/scripts\" \"${REMOTE_PROJECT_DIR}/build\"
    echo \"[remote] OK: ${VIVADO_SETTINGS}\"
    echo \"[remote] OK: ${REMOTE_PROJECT_DIR}\"
'"

print_banner "STEP 3: SYNC PROJECT FILES"
print_info "Sync target: ${REMOTE_HOST}:${REMOTE_PROJECT_DIR}"
mkdir -p "${PROJECT_ROOT}/build"

rsync -av \
    "${PROJECT_ROOT}/rtl/" \
    "${REMOTE_HOST}:${REMOTE_PROJECT_DIR}/rtl/"

rsync -av \
    "${PROJECT_ROOT}/constr/" \
    "${REMOTE_HOST}:${REMOTE_PROJECT_DIR}/constr/"

rsync -av \
    "${PROJECT_ROOT}/scripts/build.tcl" \
    "${PROJECT_ROOT}/scripts/build.sh" \
    "${REMOTE_HOST}:${REMOTE_PROJECT_DIR}/scripts/"

if [[ -f "${PROJECT_ROOT}/fpga.env" ]]; then
    rsync -av \
        "${PROJECT_ROOT}/fpga.env" \
        "${REMOTE_HOST}:${REMOTE_PROJECT_DIR}/"
fi

print_banner "STEP 4: RUN REMOTE VIVADO BUILD"
ssh "${REMOTE_HOST}" "chmod +x '${REMOTE_PROJECT_DIR}/scripts/build.sh' && cd '${REMOTE_PROJECT_DIR}' && TOP_MODULE='${TOP_MODULE}' FPGA_PART='${FPGA_PART}' BITSTREAM_NAME='${BITSTREAM_NAME}' VIVADO_SETTINGS='${VIVADO_SETTINGS}' ./scripts/build.sh"

print_banner "STEP 5: FETCH BITSTREAM"
scp "${REMOTE_HOST}:${REMOTE_PROJECT_DIR}/build/${BITSTREAM_NAME}" "${PROJECT_ROOT}/build/${BITSTREAM_NAME}"

if [[ ! -f "${BIT_FILE}" ]]; then
    echo "Bitstream not found after fetch: ${BIT_FILE}" >&2
    exit 1
fi

print_ok "Fetched bitstream: ${BIT_FILE}"

print_banner "STEP 6: DETECT FPGA DEVICE"
"${PROGRAMMER}" --detect

print_banner "STEP 7: PROGRAM FPGA"
print_info "Programming bitstream: ${BIT_FILE}"
"${PROGRAMMER}" "${BIT_FILE}"

print_banner "DONE"
print_ok "Build, fetch, and programming completed successfully."
