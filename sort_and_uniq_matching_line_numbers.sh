#!/bin/bash
cat matching_line_numbers.csv | sort | uniq > "sorted_matching_line_numbers.csv"
