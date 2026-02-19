-- Histogram: total workforce by market investment per capita
-- x-axis: investment / workforce rounded to the 4th demimal place
-- y-axis: sum of workforce of markets in that bucket
with market_investment as (
    select c.market,
        sum(b.investment) as investment
    from buildings b
        join states s on b.state = s.id
        join countries c on s.country = c.id
    group by 1
),
market_population as (
    select c.market,
        sum(p.workforce) as workforce
    from pops p
        join states s on p.location = s.id
        join countries c on s.country = c.id
    group by 1
)
select mp.market,
    round(coalesce(mi.investment, 0) / mp.workforce, 4) as investment_per_worker
    from market_population mp
    left join market_investment mi on mp.market = mi.market
where mp.workforce > 0