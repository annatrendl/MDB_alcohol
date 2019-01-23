# MDB_alcohol

Here is the ordering of actions:

1. Run make_keywords.R to produce files noalcohol_keywords.csv and alcohol_keywords.csv

2. Run split_data.sh to take the raw CSV of all MDB data into 20 smaller CSVs

3. Run ./remove_noalcohol_lines.sh to remove all lines matching an entry in noalcohol_keywords.csv.

4. Run ./get_alcohol_lines.sh to include all lines matching an entry in alcohol_keywords.csv.

5. cat data0*_no_noalcohol_matches.csv_alcohol_matches.csv > data_alcohol_matches.csv to merge back one CSV. Then run ./sort_and_uniq_matching_line_numbers.sh to make sure we don't have duplicate entries.

6. Finally run remove_by_tag.R to clean out transactions that have the wrong manual tag.


