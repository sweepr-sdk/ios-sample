#!/bin/sh

#
# Sweepr Technologies Limited
#
# Script to generate "BuildConfig.swift" file out of environment definition.
# version: 1.0
#

set -e
set -o pipefail

function generate_content() {
    local script_name=$1
    local input_name=$2
    local output_name=${3:-BuildConfig.swift}
    local current_year=$(date +'%Y')
    local current_datetime=$(date +'%Y-%m-%d %H:%M:%S')

    local fields=""

    while IFS="" read -r p || [ -n "$p" ]
    do
        p=$(echo "$p" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
        case "$p" in
            "")
            continue
            ;;

            \#*)
            continue
            ;;
        esac

    local field_name=$(echo "$p" | sed -n -E 's/[ \t]*([A-Za-z_0-9]*)[ \t]*=.*/\1/p;')
    local field_value=$(echo "$p" | sed -n -E 's/.*=(.*)/\1/p;')

    if [ ! -z "$fields" ]; then
        fields+="\n"
    fi

    fields+="    @objc public static let $field_name: String = \"$field_value\""
done < "$input_name"

    cat <<EOF
//
//  $output_name
//
//  Copyright © $current_year Sweepr Technologies Limited. All rights reserved.
//

// Update the proper ".env.xxx" file and then run "$script_name .env.xxx" script to recreate.

//
// This file was auto-generated on $current_datetime.
// Used environment file: $input_name
//

import Foundation

@objc public class BuildConfig: NSObject {
$fields
}

EOF
}

if [ "$#" -eq 0 ]; then
    echo Error, missing input file with build-config entries
    echo
    cat <<EOF
Usage:
    sh $0 <environment_file_name> <output_file_name>

Format:
 Expected input file is a text-file with <key>=<value> format.
 Each entry should be specified in new line.
 Comments are allowed and require the line to start with '#' character.
 No processing or renaming is applied to "key", nor "value" fields.

 Generated output file will be a regular Swift 5.0 file with proper static fields and all string values.
EOF
    exit 1
fi

opt_test_content=
if [ "$1" == "--test" ]; then
    opt_test_content=YES
    shift
fi

input_file=$1
output_file=${2:-./Nuvo/Nuvo}

if [ ! -f "$input_file" ]; then
    echo "Input file \"$input_file\" doesn't exist"
    exit 1
fi

if [ -d "$output_file" ]; then
    output_file="$output_file/BuildConfig.swift"
fi

readonly output_basename=$(basename "$output_file")
readonly content=$(generate_content "$0" "$1" "$output_basename")

if [ "$opt_test_content" == "YES" ]; then
    echo "* * * * * Generated * * * * *"
    echo "$content"
    echo "* * * * * END * * * * *"
else
    if [ -f "$output_file" ]; then
        echo Updating the \'$output_file\' file...
    else
        echo Creating the \'$output_file\' file...
    fi

    echo "$content" > "$output_file"
fi

