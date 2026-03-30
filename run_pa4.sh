#!/usr/bin/env bash
set -u

# CS 131 Sprint 4 Evidence Pack Script
# Usage:
# bash run_pa4.sh <INPUT>
#
# Example:
# bash run_pa4.sh data/samples/steam_games_datasets_1000.tsv

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <DATASET_PATH>" >&2
  exit 1
fi

DATASET_PATH="$1"

OUT_DIR="out"
LOG="${OUT_DIR}/run_sprint4.log"
ERR="${OUT_DIR}/errors.log"

mkdir -p "${LOG}"
: > "${ERR}"

exec > >(tee -a "${LOG}") 2> >(tee -a "${ERR}" >&2)

echo "Sprint 4 evidence pack run"
date
echo "Dataset: ${DATASET_PATH}"
echo

if [[ ! -f "${DATASET_PATH}" ]]; then
  echo "ERROR: dataset not found at: ${DATASET_PATH}" >&2
  exit 2
fi

echo "File size"
ls -lh "${DATASET_PATH}" | tee "${EVID_DIR}/file_size.txt"
echo

echo "Header preview"
head -n 3 "${DATASET_PATH}" | tee "${EVID_DIR}/header_preview.txt"
echo

echo "Row count"
wc -l "${DATASET_PATH}" | tee "${EVID_DIR}/row_count.txt"
echo

echo "Generating monthly_price_summary.tsv"
bash scripts/siyu_monthly_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo
echo "Generating games_keywords.tsv"
bash scripts/siyu_keywords_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo
echo "Done"
date
