CREATE TABLE IF NOT EXISTS "pops"(
  "id" INTEGER,
  "type" TEXT,
  "workforce" INTEGER,
  "dependents" INTEGER,
  "location" INTEGER,
  "culture" INTEGER,
  "workplace" INTEGER,
  "religion" TEXT,
  "num_literate" INTEGER,
  "wealth" INTEGER,
  "social_class" TEXT,
  "food_security" REAL,
  "starvation" REAL
);
CREATE TABLE IF NOT EXISTS "countries"(
  "id" INTEGER,
  "definition" TEXT,
  "capital" INTEGER
);
CREATE TABLE IF NOT EXISTS "states"(
  "id" INTEGER,
  "country" INTEGER,
  "region" TEXT,
  "arable_land" INTEGER,
  "incorporated" INTEGER
);
CREATE TABLE IF NOT EXISTS "buildings"(
  "id" INTEGER,
  "building" TEXT,
  "state" INTEGER,
  "staffing" REAL
);
CREATE TABLE IF NOT EXISTS "building_ownership"(
  "levels" INTEGER,
  "owned_building" INTEGER,
  "owning_country" INTEGER,
  "owning_building" INTEGER
);
CREATE TABLE IF NOT EXISTS "laws"("country" INTEGER, "law" TEXT);
CREATE TABLE IF NOT EXISTS "technologies"("country" INTEGER, "technology" TEXT);
CREATE TABLE IF NOT EXISTS "relations"(
  "relations" INTEGER,
  "first_country" INTEGER,
  "first_country_obliged" INTEGER,
  "second_country" INTEGER,
  "second_country_obliged" INTEGER
);
