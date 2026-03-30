#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:?Usage: bash run_pa4.sh <INPUT>}"

mkdir -p out logs

if [[ ! -f "$INPUT" ]]; then
  echo "Error: input file not found: $INPUT" >&2
  exit 1
fi

if [[ ! -r "$INPUT" ]]; then
  echo "Error: input file is not readable: $INPUT" >&2
  exit 1
fi

chmod -R g+rX "$INPUT" 2>/dev/null || true

# 1) success ratio per game
awk -F'\t' 'BEGIN { OFS="\t" }
NR==1 {
  print "appid","name","estimated_owners","peak_ccu","success_ratio"
  next
}
{
  pos = $34 + 0
  neg = $35 + 0
  total = pos + neg

  if (total == 0) {
    ratio = 0
  } else {
    ratio = pos / total
  }

  print $1, $2, $36, $42, sprintf("%.4f", ratio)
}' "$INPUT" > out/games_success_ratio.tsv

# 2) bucket summary
awk -F'\t' 'BEGIN { OFS="\t" }
NR==1 { next }
{
  ratio = $5 + 0

  if (ratio == 0) {
    bucket = "ZERO"
  } else if (ratio < 0.70) {
    bucket = "LOW"
  } else if (ratio <= 0.90) {
    bucket = "MID"
  } else {
    bucket = "HIGH"
  }

  count[bucket]++
  sum[bucket] += ratio

  if (!(bucket in min) || ratio < min[bucket]) min[bucket] = ratio
  if (!(bucket in max) || ratio > max[bucket]) max[bucket] = ratio
}
END {
  print "bucket","count","avg_ratio","min_ratio","max_ratio"

  order[1] = "ZERO"
  order[2] = "LOW"
  order[3] = "MID"
  order[4] = "HIGH"

  for (i = 1; i <= 4; i++) {
    b = order[i]
    if (count[b] > 0) {
      avg = sum[b] / count[b]
      print b, count[b], sprintf("%.4f", avg), sprintf("%.4f", min[b]), sprintf("%.4f", max[b])
    }
  }
}' out/games_success_ratio.tsv > out/games_success_data.tsv

# 3) hidden positive games
awk -F'\t' 'BEGIN { OFS="\t" }
NR==1 {
  print "appid","name","success_ratio"
  next
}
{
  ccu = $4 + 0
  ratio = $5 + 0

  if (ratio > 0.90 && ccu < 25000) {
    print $1, $2, sprintf("%.4f", ratio)
  }
}' out/games_success_ratio.tsv > out/hidden_positive_games.tsv
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

echo "Generating monthly_price_summary.tsv"
bash scripts/siyu_monthly_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo

echo "Generating games_keywords.tsv"
bash scripts/siyu_keywords_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo

echo "Done"
date
