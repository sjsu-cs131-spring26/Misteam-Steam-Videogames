#!/usr/bin/env bash
set -u

# CS 131 Sprint 3 Evidence Pack Script
# Usage:
# ./scripts/run_sprint3.sh <DATASET_PATH> <DELIM>
#
# Example:
# ./scripts/run_sprint3.sh data/samples/steam_games_datasets_1000.tsv $'\t'

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <DATASET_PATH> <DELIM>" >&2
  exit 1
fi

DATASET_PATH="$1"
DELIM="$2"

OUT_DIR="out"
EVID_DIR="${OUT_DIR}/evidence"
LOG="${OUT_DIR}/run_sprint3.log"
ERR="${OUT_DIR}/errors.log"

mkdir -p "${EVID_DIR}"
: > "${LOG}"
: > "${ERR}"

exec > >(tee -a "${LOG}") 2> >(tee -a "${ERR}" >&2)

echo "Sprint 3 evidence pack run"
date
echo "Dataset: ${DATASET_PATH}"
echo "Delimiter: '${DELIM}'"
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

# 1-based indexing for cut
FIELD_ID=1
FIELD_CATEGORY=29
FIELD_TEXT=9

echo "Using fields"
echo "FIELD_ID=${FIELD_ID} (appid)"
echo "FIELD_CATEGORY=${FIELD_CATEGORY} (genres)"
echo "FIELD_TEXT=${FIELD_TEXT} (short_description)"
echo

echo "Generating top_genres.txt"
cut -d "${DELIM}" -f "${FIELD_CATEGORY}" "${DATASET_PATH}" \
  | tail -n +2 \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 20 \
  | tee "${EVID_DIR}/top_genres.txt"
echo

echo "Generating top_appids.txt"
cut -d "${DELIM}" -f "${FIELD_ID}" "${DATASET_PATH}" \
  | tail -n +2 \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 20 \
  | tee "${EVID_DIR}/top_appids.txt"
echo

KEYWORDS_REGEX="horror|survival|multiplayer|puzzle|adventure|action|retro|simulation"

echo "Generating keyword_hits_summary.txt"
cut -d "${DELIM}" -f "${FIELD_TEXT}" "${DATASET_PATH}" \
  | tail -n +2 \
  | awk 'BEGIN{IGNORECASE=1; count=0} /horror|survival|multiplayer|puzzle|adventure|action|retro|simulation/ {count++} END{print "keyword_hit_rows=" count}' \
  | tee "${EVID_DIR}/keyword_hits_summary.txt"
echo "keywords=${KEYWORDS_REGEX}" | tee -a "${EVID_DIR}/keyword_hits_summary.txt"
echo

echo "Generating trust_check_genres_missing_tokens.txt"
{
  echo "Field checked: FIELD_CATEGORY=${FIELD_CATEGORY} (genres)"
  echo "Counts for common missing tokens:"
  cut -d "${DELIM}" -f "${FIELD_CATEGORY}" "${DATASET_PATH}" \
    | tail -n +2 \
    | awk '
      BEGIN { na=0; empty=0; nulls=0; blanks=0 }
      $0=="NA" || $0=="N/A" { na++ }
      $0=="null" || $0=="NULL" || $0=="None" || $0=="none" { nulls++ }
      $0=="[]" { blanks++ }
      $0=="" { empty++ }
      END {
        print "empty_rows=" empty
        print "na_rows=" na
        print "null_like_rows=" nulls
        print "empty_list_rows=" blanks
      }'
} | tee "${EVID_DIR}/trust_check_genres_missing_tokens.txt"
echo

echo "Generating assumption_test_appid_repeats_top20.txt"
cut -d "${DELIM}" -f "${FIELD_ID}" "${DATASET_PATH}" \
  | tail -n +2 \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 20 \
  | tee "${EVID_DIR}/assumption_test_appid_repeats_top20.txt"
echo

echo "Generating assumption_test_genres_distinct_sample.txt"
cut -d "${DELIM}" -f "${FIELD_CATEGORY}" "${DATASET_PATH}" \
  | tail -n +2 \
  | sort -u \
  | head -n 50 \
  | tee "${EVID_DIR}/assumption_test_genres_distinct_sample.txt"
echo

echo "Generating monthly_price_summary.tsv"
bash scripts/siyu_monthly_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo
echo "Generating games_keywords.tsv"
bash scripts/siyu_keywords_summary.sh "${DATASET_PATH}" "${OUT_DIR}"
echo
echo "Done"
date
