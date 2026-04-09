#!/usr/bin/env bash
set -euo pipefail

# Generate a compact build summary from Vivado and programmer logs.
# Usage:
#   ./scripts/extract_log_summary.sh build/vivado.log build/program.log build/build_summary.txt

VIVADO_LOG="${1:-}"
PROGRAM_LOG="${2:-}"
OUTPUT_FILE="${3:-}"

if [[ -z "${VIVADO_LOG}" || -z "${PROGRAM_LOG}" || -z "${OUTPUT_FILE}" ]]; then
    echo "Usage: $0 <vivado_log> <program_log> <output_file>" >&2
    exit 1
fi

if [[ ! -f "${VIVADO_LOG}" ]]; then
    echo "Vivado log not found: ${VIVADO_LOG}" >&2
    exit 1
fi

if [[ ! -f "${PROGRAM_LOG}" ]]; then
    echo "Program log not found: ${PROGRAM_LOG}" >&2
    exit 1
fi

mkdir -p "$(dirname "${OUTPUT_FILE}")"

extract_first() {
    local pattern="$1"
    local file="$2"
    grep -m 1 -E "${pattern}" "${file}" || true
}

extract_last() {
    local pattern="$1"
    local file="$2"
    grep -E "${pattern}" "${file}" | tail -n 1 || true
}

build_time="$(extract_last 'Start of session at:' "${VIVADO_LOG}")"
vivado_version="$(extract_first '^\*\*\*\*\*\* Vivado v' "${VIVADO_LOG}")"
part_line="$(extract_first 'Loading part:' "${VIVADO_LOG}")"
synth_status="$(extract_last 'synth_design completed successfully' "${VIVADO_LOG}")"
place_status="$(extract_last 'place_design completed successfully' "${VIVADO_LOG}")"
route_status="$(extract_last 'route_design completed successfully' "${VIVADO_LOG}")"
bitgen_status="$(extract_last 'Bitgen Completed Successfully|write_bitstream completed successfully' "${VIVADO_LOG}")"
timing_line="$(extract_last 'WNS=.*TNS=.*WHS=.*THS=' "${VIVADO_LOG}")"
error_count="$(grep -c 'ERROR:' "${VIVADO_LOG}" || true)"
critical_count="$(grep -c 'CRITICAL WARNING:' "${VIVADO_LOG}" || true)"
warning_count="$(grep -c '^WARNING:' "${VIVADO_LOG}" || true)"
detect_line="$(extract_last 'detect|Detect|Cable|JTAG|device' "${PROGRAM_LOG}")"
program_success="$(extract_last 'write to flash|Programmed|success|Done|completed' "${PROGRAM_LOG}")"

{
    echo "# Build Summary"
    echo
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo
    echo "## Vivado"
    [[ -n "${build_time}" ]] && echo "- Session: ${build_time}"
    [[ -n "${vivado_version}" ]] && echo "- Version: ${vivado_version}"
    [[ -n "${part_line}" ]] && echo "- Part: ${part_line}"
    [[ -n "${synth_status}" ]] && echo "- Synthesis: OK"
    [[ -n "${place_status}" ]] && echo "- Placement: OK"
    [[ -n "${route_status}" ]] && echo "- Routing: OK"
    [[ -n "${bitgen_status}" ]] && echo "- Bitstream: OK"
    [[ -n "${timing_line}" ]] && echo "- Timing: ${timing_line}"
    echo "- Errors: ${error_count}"
    echo "- Critical warnings: ${critical_count}"
    echo "- Warnings: ${warning_count}"
    echo
    echo "## Programming"
    [[ -n "${detect_line}" ]] && echo "- Detect: ${detect_line}"
    [[ -n "${program_success}" ]] && echo "- Program result: ${program_success}"
    echo
    echo "## Files"
    echo "- Vivado log: ${VIVADO_LOG}"
    echo "- Programmer log: ${PROGRAM_LOG}"
} > "${OUTPUT_FILE}"

echo "Summary written to ${OUTPUT_FILE}"
