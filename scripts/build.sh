#!/usr/bin/env bash
set -euo pipefail

# Remote-side Vivado launcher.
# Override with environment variables if you later rename the project layout.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${PROJECT_ROOT}/fpga.env" ]]; then
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/fpga.env"
fi

VIVADO_SETTINGS="${VIVADO_SETTINGS:-/mnt/data/Xilinx/2025.2/Vivado/settings64.sh}"
TOP_MODULE="${TOP_MODULE:-top}"
FPGA_PART="${FPGA_PART:-xc7a35tfgg484-2}"
BITSTREAM_NAME="${BITSTREAM_NAME:-${TOP_MODULE}.bit}"

export TOP_MODULE
export FPGA_PART
export BITSTREAM_NAME

if [[ ! -f "${VIVADO_SETTINGS}" ]]; then
    echo "Vivado settings file not found: ${VIVADO_SETTINGS}" >&2
    exit 1
fi

cd "${PROJECT_ROOT}"
mkdir -p build
source "${VIVADO_SETTINGS}"
vivado -mode batch -source scripts/build.tcl 2>&1 | tee build/vivado.log
exit "${PIPESTATUS[0]}"
