#!/bin/bash
#run_project_2.sh
#Useage: bash - run_project2.sh &> project2.log
#Dataset: /mnt/scratch/CS131_jelenag/projects/team06_sec3/out/games_cleaned.tsv
#Delimiter: Tab-separated values (tsv)
#Assumptions: 
#	-Input data exists at the data path above

DATASET_PATH="/mnt/scratch/CS131_jelenag/projects/team06_sec3/out/games_cleaned.tsv"

#change directory so you can run from anywhere
#cd /mnt/scratch/CS131_jelenag/projects/team06_sec3/

#make the out directory
mkdir -p out

# Generate Sample
echo "generating sample..."
(head -1 $DATASET_PATH && tail -n+2 $DATASET_PATH | shuf -n 1000) > out/steam_games_datasets_1000.tsv 2>out/sample_errors.txt

#check if game dataset is 1k lines
echo "# of lines in steam_games_datasets_1000.tsv is: "
wc -l out/steam_games_datasets_1000.tsv  

# Create frequency table of publishers
echo "creating publishers frequency table..."
cut -f27 out/steam_games_datasets_1000.tsv | sort | uniq -c | sort -nr 2> out/freq_publishers_error.txt | tee out/freq_publishers_clean.txt


#Create second frequency table of genres
echo "creating genre frequency table..."
cut -f29 out/steam_games_datasets_1000.tsv | tail -n+2 | sort | uniq -c | sort -nr 2> out/freq_genres_error.txt | tee out/freq_genres.txt

#Create a Top 10 (Top-N) list of developers
echo "creating top list of developers..."
tail -n +2 out/steam_games_datasets_1000.tsv  '^\[\]$' | sort | uniq -c | sort -nr | head -n 10 2> out/top_10_developers_error.txt | tee out/top_10_developers_clean.txt

#Create a skinny table of game prices
echo "creating skinny table of game prices..."
cut -f1,2,5 out/steam_games_datasets_1000.tsv | sort -u 2> out/skinny_games_price_error.txt | tee out/skinny_games_price_clean.tsv

#Grep word screening and tee/ redirection demo
echo "creating grep count of games containing Action..."
grep -wi Action out/steam_games_datasets_1000.tsv 2> out/grep_errors.txt | wc -l  | tee out/grep_tee_action.txt

echo "creating grep count of games not containing Action..."
grep -vwi Action out/steam_games_datasets_1000.tsv 2>> out/grep_errors.txt | wc -l  | tee out/grep_tee_not_action.txt
