## Data Model
A pop's population is its workforce plus its dependents.
One building level can employ 5000 workers, unless it's a kind of rice farm, in which case it can employ 10000.
Each state has exactly 1 subsistence building, which is a building with "subsistence" as a substring of its "building" column.
Each level of agricultural building in a state reduces its usable arable land, and its levels of subsistence building, by 1.
Each building has an integer number of levels. Each of those levels is owned by some building, which can be the building itself. The ownership graph is acyclic (and directed), and it's encoded in the building_ownerships table.
