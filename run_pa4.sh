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

OUT_DIR="out1"
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
ls -lh "${DATASET_PATH}" 
echo

echo "Header preview"
head -1 "${DATASET_PATH}"
echo

echo "Row count"
wc -l "${DATASET_PATH}" 
echo

echo "Generating Cleaned Games Descrtiptions"
bash scripts/arnav_game_description.sh "${DATASET_PATH}" "${OUT_DIR}"
echo

bash scripts/varun_success_hidden_games.sh "${DATASET_PATH}" "${OUT_DIR}"


echo "Generating monthly_price_summary.tsv"
bash scripts/siyu_monthly_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo

echo "Generating games_keywords.tsv"
bash scripts/siyu_keywords_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo

echo "Done"
date
