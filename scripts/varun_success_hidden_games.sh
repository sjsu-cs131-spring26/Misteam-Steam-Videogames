#!/usr/bin/env bash

INPUT="${1:-data/samples/steam_games_datasets_1000.tsv}"
OUT_DIR="${2:-out}"

mkdir -p "$OUT_DIR"

echo "Finding Games Success Ratio"
echo

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
}' "$INPUT" > $OUT_DIR/games_success_ratio.tsv

echo "Generate $OUT_DIR/games_success_ratio.tsv"
echo

echo "Calculating Games success data"
echo

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
}' $OUT_DIR/games_success_ratio.tsv > $OUT_DIR/games_success_data.tsv

echo "Generated $OUT_DIR/games_success_data.tsv"
echo

echo "Finding Hidden games with high success rate but low ccu"
echo

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
}' $OUT_DIR/games_success_ratio.tsv > $OUT_DIR/hidden_positive_games.tsv

echo "Generated $OUT_DIR/hidden_positive_games.tsv"
