def squish:
	if (.value | type) != "object" then empty 
	else {id: .key | tonumber} + .value
end;
def to_rows: to_entries | .[] | squish;
{
	pops : [.pops.database | to_rows | 
		select(.workforce + .dependents >= 0) | {
			id,
			type,
			workforce: .workforce // 0,
			dependents: .dependents // 0,
			location,
			culture,
			workplace,
			religion,
			num_literate: .num_literate // 0,
			wealth: .wealth // 0,
			social_class: .social_class.social_class,
			food_security: .food_security.value // 0,
			starvation: .food_security.starvation // 0,
	}], 
	countries : [.country_manager.database | to_rows | {
		id,
		definition,
		capital,
		market,
	}],
	country_rankings : [.country_rankings.country_rankings[] | {
		country,
		rank,
		target,
		score,
		prestige,
	}],
	markets : [.market_manager.database | to_rows | {
		id,
		owner,
	}],
	states : [.states.database | to_rows | {
		id,
		country,
		region,
		arable_land,
		incorporated: .incorporation | not | not,
	}],
	buildings : [.building_manager.database | to_rows | 
		select(.levels > 0) | {
			id,
			building,
			state,
			levels,
			staffing,
			dividends,
			gross: (.goods_sales // 0)  - (.goods_cost // 0),
			investment: (.profit_after_reserves // 0) - (.profit_after_investments // 0),
		}],
	building_ownership : [.building_ownership_manager.database | to_rows | 
		select(.levels > 0) | {
			levels,
			owned_building: .building,
			owning_country: .identity.country,
			owning_building: .identity.building,
		}],
	laws : [.laws.database | to_rows | 
		select(.active) | {
			country,
			law,
	}],
	technologies : [.technology.database | to_rows | 
		.country as $country | .acquired_technologies[] | {
			country: $country,
			technology: .,
	}],
	relations : [.relations.database | to_rows | 
		select((.relations | values) and (.first | values) and (.second | values)) | {
			relations,
			first_country: .first.country,
			first_country_obliged: .first.obligation // false,
			second_country: .second.country,
			second_country_obliged: .second.obligation // false,
	}],
}
