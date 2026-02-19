# vic3-sql

Slurp .v3 saves into friendly CSVs and analyze them with PowerBI.

## Usage

If your save is `save.v3`, then from Bash,

```bash
world_db.sh save.v3 $USERPROFILE/vic3-world
```

This produces a directory of CSVs — one for each interesting top-level `database` in the save, plus some derived datasets generated from `queries/`.

Then, 

1. Open `vic3-world.pbip`
2. Click Home > Transform data > Edit parameters 
3. Edit the Root parameter to whatever `$USERPROFILE/vic3-world` expanded to on your machine, e.g. `C:\Users\middle-aged-autist\vic3-world`
4. Refresh at least the data. The button's right next to Transform data.
5. Bask in charts like the industrious businessfellow you are

## Dependencies

Install the [latest Rakaly](https://github.com/rakaly/cli/releases/latest) and add it to your `PATH`.

On Windows, get the other dependencies with 

```powershell
winget install Git.Git # for Bash
winget install jqlang.jq
winget install DuckDB.cli
winget install Microsoft.PowerBI
```

## Pipeline

1. **save.v3**: PDX save, text or compressed
2. **Rakaly**: PDX → JSON
3. **jq**: JSON → JSON (selects, flattens and filters game databases)
4. **DuckDB**: JSON → CSV (base tables + query results)
5. **PowerBI**: CSV → transformative value-add
