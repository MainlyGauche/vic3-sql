# vic3-sql

Slurp textformat .v3 saves into queryable CSVs via DuckDB.

## Usage

From Bash,

```bash
world_db.sh save.v3 out/
```

This produces a directory of CSVs — one for each interesting top-level `database` in the save, plus some derived datasets generated from `queries/`.

## Dependencies

Install the [latest Rakaly](https://github.com/rakaly/cli/releases/latest) and add it to your `PATH`.

On Windows, get the other dependencies with 

```bash
winget install jq
winget install DuckDB.cli
```

## Pipeline

1. **save.v3**: PDX textformat
2. **Rakaly**: PDX → JSON
3. **jq**: Flattens and filters game databases
4. **DuckDB**: JSON → CSV (base tables + query results)
