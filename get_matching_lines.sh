#!/bin/bash

#cp data.csv file_A.csv

grep -v -i -f noalcohol_keywords.csv data.csv > data_no_noalcohol_matches.csv

FILE1="file_A.csv"
FILE2="file_B.csv"

#rm matching_line_numbers.csv
cat noalcohol_keywords.csv | while read p
do
	echo Eliminating ${p}: Copying from $FILE1 to $FILE2
	#awk "/${p}/ {print NR}" data.csv >> matching_line_numbers.csv
	grep -v -i "\b${p}\b" $FILE1 > $FILE2
	TEMP=$FILE2
	FILE2=$FILE1
	FILE1=$TEMP
done

cat alcohol_keywords.csv | while read p
do
	echo Finding ${p}
	grep -i "\b${p}\b" $FILE2 >> data_alcohol_matches.csv
done

	