#!/usr/bin/env bash

INPUT="${1:-data/samples/steam_games_datasets_1000.tsv}"
OUT_DIR="${2:-out}"

mkdir -p "$OUT_DIR"

awk -F'\t' '
NR==1 { next }
$3 != "" && $5 != "" {
    month = substr($3, 1, 7)
    count[month]++
    sum[month] += $5
}
END {
    for (m in count) {
        avg = sum[m] / count[m]
        printf "%s\t%d\t%.2f\n", m, count[m], avg
    }
}
' "$INPUT" | sort | awk 'BEGIN {print "month\tcount\tavg_price"} {print}' > "$OUT_DIR/monthly_price_summary.tsv"

echo "Generated: $OUT_DIR/monthly_price_summary.tsv"
