#!/bin/bash
rm matching_line_numbers.csv
cat small_pub_names.csv | while read p
do
	echo ${p}
	awk "/${p}/ {print NR}" data.csv >> matching_line_numbers.csv
	# grep ${p} data.csv >> matching_lines.csv
done


