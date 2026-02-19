select * from (
values -- industry (high = 600)
  ('building_food_industry', 600),
  ('building_textile_mill', 600),
  ('building_furniture_manufactory', 600),
  ('building_glassworks', 600),
  ('building_tooling_workshop', 600),
  ('building_paper_mill', 600),
  ('building_shipyard', 600),
  ('building_arms_industry', 600),
  ('building_artillery_foundry', 600),
  -- industry (very_high = 800)
  ('building_chemical_plant', 800),
  ('building_explosives_factory', 800),
  ('building_synthetics_plant', 800),
  ('building_steel_mill', 800),
  ('building_motor_industry', 800),
  ('building_military_shipyard', 800),
  ('building_automotive_industry', 800),
  ('building_electrics_industry', 800),
  ('building_munition_plant', 800),
  -- farms (low = 200)
  ('building_rye_farm', 200),
  ('building_wheat_farm', 200),
  ('building_rice_farm', 200),
  ('building_maize_farm', 200),
  ('building_millet_farm', 200),
  ('building_livestock_ranch', 200),
  ('building_vineyard', 200),
  -- mines (medium = 400)
  ('building_iron_mine', 400),
  ('building_lead_mine', 400),
  ('building_sulfur_mine', 400),
  ('building_gold_mine', 400),
  -- plantations (low = 200)
  ('building_coffee_plantation', 200),
  ('building_cotton_plantation', 200),
  ('building_dye_plantation', 200),
  ('building_opium_plantation', 200),
  ('building_tea_plantation', 200),
  ('building_tobacco_plantation', 200),
  ('building_sugar_plantation', 200),
  ('building_banana_plantation', 200),
  ('building_silk_plantation', 200),
  ('building_rubber_plantation', 200),
  -- misc resources (low = 200)
  ('building_fishing_wharf', 200),
  ('building_whaling_station', 200),
  -- misc resources (medium = 400)
  ('building_oil_rig', 400),
  -- urban (medium = 400)
  ('building_art_academy', 400),
  ('building_power_plant', 400),
  ('building_university', 400),
  -- infrastructure (medium = 400)
  ('building_port', 400),
  -- infrastructure (very_high = 800)
  ('building_railway', 800),
  -- other buildings you probably want 0
) as building_costs(building, cost)