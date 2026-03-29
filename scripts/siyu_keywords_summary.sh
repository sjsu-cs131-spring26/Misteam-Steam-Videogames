#!/usr/bin/env bash

INPUT="${1:-data/samples/steam_games_datasets_1000.tsv}"
OUT_DIR="${2:-out}"

mkdir -p "$OUT_DIR"

awk -F'\t' '
NR==1 { next }

{
    text = tolower($7)

    if (text ~ /hard|challenging|difficult|punishing|permadeath|hardcore|souls-like/)
        difficulty++

    if (text ~ /easy|relaxing|accessible|casual/)
        easy_relaxed++

    if (text ~ /atmospheric|dark|cozy|vibrant|scary|horror|chill|retro|stylized|cinematic|immersive/)
        atmosphere++

    if (text ~ /free|f2p|microtransactions|dlc|season pass|subscription|affordable|premium|no-ads/)
        financial++

    if (text ~ /optimized|fps|controller support|multiplayer|co-op|early access|beta|bug-free|cross-platform/)
        technical++
}

END {
    print "family\tcount"
    print "difficulty\t" difficulty
    print "easy_relaxed\t" easy_relaxed
    print "atmosphere\t" atmosphere
    print "financial\t" financial
    print "technical\t" technical
}
' "$INPUT" > "$OUT_DIR/games_keywords.tsv"

echo "Generated: $OUT_DIR/games_keywords.tsv"
