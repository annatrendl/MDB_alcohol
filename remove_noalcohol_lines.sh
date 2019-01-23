#!/bin/bash

for f in data0*
do
	grep -v -i -f noalcohol_keywords.csv $f > ${f}_no_noalcohol_matches.csv &
	#echo ${f}_no_noalcohol_matches.csv
done

