#!/bin/bash

# Converts a JSON object to a SQLite database.
# Each top-level key becomes a table, with each entry in the value array becoming a row in that table.

set -e  # Exit on error

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input.json> <output.db>" >&2
    echo "  input.json: JSON file with top-level keys as table names" >&2
    echo "  output.db: Output SQLite database file" >&2
    exit 1
fi

INPUT_JSON="$1"
OUTPUT_DB="$2"

# Check if input file exists
if [ ! -f "$INPUT_JSON" ]; then
    echo "Error: Input file '$INPUT_JSON' not found" >&2
    exit 1
fi

# Check if miller is installed
if ! command -v mlr &> /dev/null; then
    echo "Error: Miller (mlr) is not installed" >&2
    echo "Install it with: winget install miller.miller" >&2
    exit 1
fi

# Check if sqlite3 is installed
if ! command -v sqlite3 &> /dev/null; then
    echo "Error: sqlite3 is not installed" >&2
    echo "Install it with: winget install sqlite.sqlite" >&2
    exit 1
fi

# Check if jq is installed (for extracting table names)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed" >&2
    echo "Install it with: winget install jq" >&2
    exit 1
fi

# Resolve schema.sql relative to this script
SCRIPT_DIR="$(dirname "$0")"
SCHEMA_FILE="$SCRIPT_DIR/schema.sql"
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file '$SCHEMA_FILE' not found" >&2
    exit 1
fi

rm -f "$OUTPUT_DB"
sqlite3 "$OUTPUT_DB" < "$SCHEMA_FILE"

# For CSV files
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Extract all top-level keys (table names)
TABLE_NAMES=$(jq -r 'keys_unsorted[]' "$INPUT_JSON")

for TABLE in $TABLE_NAMES; do
    # Remove carriage returns from TABLE (jq yields them on Windows)
    TABLE="${TABLE//$'\r'/}"
    CSV_FILE="$TEMP_DIR/$TABLE.csv"
    WIN_CSV=$(cygpath -m "$CSV_FILE")
    
    jq -c ".${TABLE}[]" "$INPUT_JSON" | \
		# Currently world_db doesn't pass sparse objects, but if it ever does we won't want them
		mlr --ijson --ocsv unsparsify --fill-with null \
		> "$CSV_FILE"
    
    sqlite3 "$OUTPUT_DB" <<EOF
.mode csv
.import "$WIN_CSV" "$TABLE"
EOF
    
    echo "  ✓ Loaded $(sqlite3 "$OUTPUT_DB" "SELECT COUNT(*) FROM $TABLE;") $TABLE"
done
