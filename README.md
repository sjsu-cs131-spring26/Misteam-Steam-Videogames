Dataset
https://www.kaggle.com/datasets/artermiloff/steam-games-dataset

Goal
Project Title: Steam Game Recommendation System

Team Members:
Jhames Carigma (@C-Jhames) | Siyu Yan (@Siyu-YAN-YSY) | Samipya Bhusal (@bhusalsa) | Arnav Gupta (@arn3v) | Varun Shashivarnam (@varunshashivarnam)

High-Level Goal:
Build a personalized recommendation system that suggests Steam games to users based on game similarity, genres, tags, and ratings.

Problem Statement
Steam has thousands of games. Users often struggle to discover games they will enjoy. We want to design a system that recommends relevant games.

Key Questions We Want to Answer
How can we measure similarity between games?
Can we recommend “If you like X, you may like Y”?
Which tags/genres best describe player preferences?


Proposed Solution
We will:
Extract game features (genre, tags, description, rating)
Compute similarity between games
Implement recommendation algorithms

Core Features
Search a game
Show top 1~5 similar games
Recommendation list
Visualization of similarity scores


We may change this part (Technical Components). Not the final version.
Technical Components
Text/tag processing
Vectorization 
Cosine similarity
Content-based filtering


Deliverables
Recommendation engine
Interactive demo
Evaluation of recommendation quality

# DATACARD 
## Steam Games Dataset

### 1. Source & Provenance
* **Source:** https://www.kaggle.com/datasets/artermiloff/steam-games-dataset
	Dataset has been converted to tsv format for better access after downloading from Kaggle.
* **Format:** TSV

### 2. Physical Statistics
| File Name | Size (`ls -lh`) | Line Count (`wc -l`) |
| :--- | :--- | :--- |
| `steam_games_dataset_cleaned.tsv` | 446MB | 89,619 (inc. header) |

### 3. Structural Metadata
* **Delimiter:** Tab (`		`)
* **Header:** Present (Line 1)
* **Columns:** 47 total
	app_id: Unique identifier for all the data

### 4. Quality Notes
* **Missing Data:** 
	`reviews` column is missing 79.2 K data
	`score_rank` column is missing all the data

* **Anomalies:** All columns that have multiple data entries are in the format ['','',...]. 
		`reviews` text are not inside double quotation "" and contain internal new lines.
