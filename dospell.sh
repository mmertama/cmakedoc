#!/bin/bash

# Enable exit on error
set -e
#set -x 

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

spell_directory=$1

grep_directory=$2

spell_words_file=$3

spell_file_type=$4

IFS=' ' read -r -a spell_file_exclude <<< "$5"

spell_command=$6

IFS=' ' read -r -a grep_exclude <<< "$7"

spell_config=$8

# Clean up spell_words.txt file (remove trailing whitespace or other invalid characters)
# Open spell_words.txt in a text editor and manually remove any invalid characters from each word

# Store find results in an array
mapfile -t files < <(find "$spell_directory" -type f -name "$spell_file_type" ${spell_file_exclude[@]})

# Create an array to store the output of aspell
declare -a aspell_output

# Loop through the array and process each file
for file in "${files[@]}"; do
    # Collect output of aspell into the aspell_output array
    while IFS= read -r line; do
        aspell_output+=("$line")
    # -H is HTML mode as doxygen provides HTML, -p personal dict    
    done < <($spell_command list --conf="$spell_config" -H -p "$spell_words_file" --extra-dicts=$SCRIPT_DIR/cplusplus.txt < "$file" || { echo "Error: Spelling failed. Exiting script."; exit 1; })

done

sorted_output=($(printf "%s\n" "${aspell_output[@]}" | sort -u))

# Loop through the sorted output and grep each word
for word in "${sorted_output[@]}"; do
    echo "Looking for $word:"
    if ! grep -r "${grep_exclude[@]}" -n -m 1 "$word" "$grep_directory"; then
        echo "not found $word"
    fi
    echo "Fix '$word' or add into dictionary!"    
done
