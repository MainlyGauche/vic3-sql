#!/bin/bash

# Generates a directory of CSVs from a Vic3 save, via DuckDB.
# Each top-level key in the munged JSON becomes a table (and a CSV),
# then each .sql file in queries/ is run and its result is also exported.

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <input.v3> <output_dir>" >&2
    echo "  input.v3: Vic3 save file" >&2
    echo "  output_dir: Output directory for CSV files" >&2
    exit 1
fi

INPUT_SAVE="$1"
OUTPUT_DIR="$2"
SCRIPT_DIR="$(dirname "$0")"
QUERIES_DIR="$SCRIPT_DIR/queries"

if [ ! -f "$INPUT_SAVE" ]; then
    echo "Error: Input file '$INPUT_SAVE' not found" >&2
    exit 1
fi

for cmd in rakaly jq duckdb; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed" >&2
        exit 1
    fi
done

rm -rf "$OUTPUT_DIR"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Parse the save file into JSON
echo "Parsing..."
rakaly json --duplicate-keys group "$INPUT_SAVE" > "$TEMP_DIR/raw.json"

# Munge into flat tables
echo "Munging..."
jq -c -f "$SCRIPT_DIR/munge.jq" "$TEMP_DIR/raw.json" > "$TEMP_DIR/munged.json"

# Extract each table's array to a newline-delimited JSON file
TABLE_NAMES=$(jq -r 'keys_unsorted[]' "$TEMP_DIR/munged.json")

for TABLE in $TABLE_NAMES; do
    TABLE="${TABLE//$'\r'/}"
    jq -c ".${TABLE}[]" "$TEMP_DIR/munged.json" > "$TEMP_DIR/$TABLE.json"
done

# Build a single DuckDB SQL script
OUTPUT_WIN="$(cygpath -m "$OUTPUT_DIR")"
TEMP_WIN="$(cygpath -m "$TEMP_DIR")"

SQL=""

for TABLE in $TABLE_NAMES; do
    TABLE="${TABLE//$'\r'/}"
    SQL+="create table \"$TABLE\" as select * from read_json_auto('${TEMP_WIN}/${TABLE}.json', format='newline_delimited');"$'\n'
    SQL+="copy \"$TABLE\" to '${OUTPUT_WIN}/${TABLE}.csv' (header, delimiter ',');"$'\n'
    SQL+="select '  ✓ Processed ' || count(*) || ' $TABLE' from \"$TABLE\";"$'\n'
done

# Run each query in queries/ and export its result
for QUERY_FILE in "$QUERIES_DIR"/*.sql; do
		QUERY_NAME=$(basename "$QUERY_FILE" .sql)
		QUERY=$(cat "$QUERY_FILE")
		SQL+="copy (${QUERY}) to '${OUTPUT_WIN}/${QUERY_NAME}.csv' (header, delimiter ',');"$'\n'
		SQL+="select '  ✓ Derived $QUERY_NAME';"$'\n'
done

mkdir -p "$OUTPUT_DIR"
duckdb -noheader -list :memory: "$SQL"
