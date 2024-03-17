#!/bin/bash

input_file=$1
output_file=$2
default_file=$3

if [[ ! -f $output_file ]]; then
    cp $default_file $output_file
fi    


# Loop through each line in the input file
while IFS= read -r line; do
    # Trim leading and trailing whitespace from the line
    trimmed_line="${line}" # initialize the trimmed line
    trimmed_line="${trimmed_line#"${trimmed_line%%[![:space:]]*}"}"   # remove leading whitespace
    trimmed_line="${trimmed_line%"${trimmed_line##*[![:space:]]}"}"   # remove trailing whitespace
    if [[ ! -z "$trimmed_line" ]]; then
        # Append the trimmed line to the output file
        echo "$trimmed_line" >> "$output_file"
    fi    
done < "$input_file"
