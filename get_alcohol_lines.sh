#!/bin/bash

for f in data???_no_noalcohol_matches.csv
do
	grep -i -f alcohol_keywords.csv $f > ${f}_alcohol_matches.csv &
	#echo ${f}_no_noalcohol_matches.csv
done

