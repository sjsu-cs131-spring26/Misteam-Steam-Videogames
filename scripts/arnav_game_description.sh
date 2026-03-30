#!/usr/bin/env bash

INPUT="${1:-data/samples/steam_games_datasets_1000.tsv}"
OUT_DIR="${2:-out}"

mkdir -p "$OUT_DIR"

cut -f1,2,7 $INPUT > $OUT_DIR/game_description_raw.tsv

(head -n 1 $OUT_DIR/game_description_raw.tsv && tail -n +2 $OUT_DIR/game_description_raw.tsv | awk -F'\t' 'NF==3 && $1!="" && $2!="" && $3!=""') > $OUT_DIR/tmp.tsv

mv $OUT_DIR/tmp.tsv $OUT_DIR/game_description_raw.tsv

(head -n 1 $OUT_DIR/game_description_raw.tsv && tail -n +2 $OUT_DIR/game_description_raw.tsv | awk -F'\t' 'BEGIN{IGNORECASE=1} !($2 ~ /demo|placeholder/ || $3 ~ /demo|placeholder/)') > $OUT_DIR/tmp.tsv

mv $OUT_DIR/tmp.tsv $OUT_DIR/game_description_raw.tsv

awk -F'\t' 'BEGIN{OFS="\t"} NR==1 {print $1,$2,$3; next} {gsub(/<[^>]*>/,"",$3); gsub(/"/,"",$3); gsub(/[[:space:]]+/," ",$3); sub(/^ +/,"",$3); sub(/ +$/,"",$3); print $1, tolower($2), tolower($3)}' $OUT_DIR/game_description_raw.tsv > $OUT_DIR/game_description_clean.tsv

echo "Generated: $OUT_DIR/game_description_raw.tsv, $OUT_DIR/game_description_clean.tsv" 
