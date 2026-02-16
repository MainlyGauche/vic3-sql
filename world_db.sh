#!/bin/bash

# Generates a SQLite database from a Vic3 save.

set -e  # Exit on error

if [ $# -lt 2 ]; then
    echo "Usage: $0 <input.v3> <output.db>" >&2
    echo "  input.v3: Vic3 save file" >&2
    echo "  output.db: SQLite database file" >&2
    exit 1
fi

INPUT_SAVE="$1"
OUTPUT_DB="$2"

if [ ! -f "$INPUT_SAVE" ]; then
    echo "Error: Input file '$INPUT_SAVE' not found" >&2
    exit 1
fi

if ! command -v json &> /dev/null; then
    echo "Error: json is not installed" >&2
    echo "Install it with: winget install rustup; cargo install jomini --features json" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed" >&2
    echo "Install it with: winget install jq" >&2
    exit 1
fi

rm -f "$OUTPUT_DB"

TEMP_RAW=$(mktemp)
TEMP_MUNGED=$(mktemp)
trap 'rm -f "$TEMP_RAW" "$TEMP_MUNGED"' EXIT

echo "Parsing..."

cat "$INPUT_SAVE" | \
	tail -n +2 | \
	json -g > "$TEMP_RAW"

echo "Munging..."

jq -f "$(dirname "$0")/munge.jq" "$TEMP_RAW" > "$TEMP_MUNGED"

"$(dirname "$0")/json_to_sqlite.sh" "$TEMP_MUNGED" "$OUTPUT_DB"
