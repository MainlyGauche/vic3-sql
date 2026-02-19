#!/bin/bash

# Generates a directory of CSVs from a Vic3 save, via DuckDB.
# Each top-level key in the munged JSON becomes a table (and a CSV),
# then each .sql file in queries/ is run and its result is also exported.

set -e

if [ $# -lt 3 ]; then
	echo "Usage: $0 <game> <input.v3> <output_dir>" >&2
	echo "  game: Game subdirectory (e.g. vic3)" >&2
	echo "  input.v3: Save file" >&2
	echo "  output_dir: Output directory for CSV files" >&2
	exit 1
fi

GAME="$1"
INPUT_SAVE="$2"
OUTPUT_DIR="$3"
SCRIPT_DIR="$(dirname "$0")"
QUERIES_DIR="$SCRIPT_DIR/$GAME/queries"

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
RAW_JSON="$TEMP_DIR/raw.json"
MUNGED_JSON="$TEMP_DIR/munged.json"

# Parse the save file into JSON
echo "Parsing..."
rakaly json --duplicate-keys group "$INPUT_SAVE" > "$RAW_JSON"

# Munge into flat tables
echo "Munging..."
jq -c -f "$SCRIPT_DIR/$GAME/munge.jq" "$RAW_JSON" > "$MUNGED_JSON"

# Build a single DuckDB SQL script
SQL=""
TEMP_WINDIR="$(cygpath -m "$TEMP_DIR")"
OUTPUT_WINDIR="$(cygpath -m "$OUTPUT_DIR")"

for TABLE in $(jq -c -r 'keys_unsorted[]' "$MUNGED_JSON"); do
	# Remove the carriage returns that jq sneaks in on Windows
	TABLE="${TABLE//$'\r'/}"
	# Tables need to come from disjoint files, so split the munged JSON into one file per table array
	TABLE_LEAF="$TABLE.json"
	jq -c ".${TABLE}" "$MUNGED_JSON" > "$TEMP_DIR/$TABLE_LEAF"

	SQL+="create table \"$TABLE\" as select * from read_json('${TEMP_WINDIR}/${TABLE_LEAF}');"$'\n'
	SQL+="copy \"$TABLE\" to '${OUTPUT_WINDIR}/${TABLE}.csv' (header, delimiter ',');"$'\n'
	SQL+="select '  ✓ Processed ' || count(*) || ' $TABLE' from \"$TABLE\";"$'\n'
done

# Run each query in queries/ and export its result
for QUERY_FILE in "$QUERIES_DIR"/*.sql; do
	QUERY_NAME=$(basename "$QUERY_FILE" .sql)
	QUERY=$(cat "$QUERY_FILE")
	SQL+="copy (${QUERY}) to '${OUTPUT_WINDIR}/${QUERY_NAME}.csv' (header, delimiter ',');"$'\n'
	SQL+="select '  ✓ Derived $QUERY_NAME';"$'\n'
done

mkdir -p "$OUTPUT_DIR"
duckdb -noheader -list :memory: "$SQL"
