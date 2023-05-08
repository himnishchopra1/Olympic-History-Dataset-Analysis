-- problem 1
select 
  count(distinct games) as olympic_games_count 
from 
  olympics_history;


-- problem 2
select 
  distinct year, 
  season, 
  city 
from 
  olympics_history 
order by 
  year;


-- problem 3
with all_countries as (
  select 
    distinct games, 
    region 
  from 
    olympics_history 
    left join olympics_history_noc_regions on olympics_history.noc = olympics_history_noc_regions.noc
) 
select 
  games, 
  count(1) as total_countries 
from 
  all_countries 
group by 
  games 
order by 
  games;



-- problem 4
with countries_comp as (
  select 
    games, 
    region 
  from 
    olympics_history oh 
    join olympics_history_noc_regions ohnoc on oh.noc = ohnoc.noc 
  group by 
    games, 
    region
), 
total_countries as (
  select 
    games, 
    count(1) as tally 
  from 
    countries_comp 
  group by 
    games 
  order by 
    games
) 
select 
  distinct concat(
    first_value(games) over (
      order by 
        tally
    ), 
    ' - ', 
    first_value(tally) over (
      order by 
        tally
    )
  ) as least_countries, 
  concat(
    first_value(games) over (
      order by 
        tally desc
    ), 
    ' - ', 
    first_value(tally) over (
      order by 
        tally desc
    )
  ) as most_countries 
from 
  total_countries;


-- problem 5
with t1 as (
  select 
    games, 
    region 
  from 
    olympics_history oh 
    join olympics_history_noc_regions ohnoc on oh.noc = ohnoc.noc 
  group by 
    games, 
    region
), 
t2 as (
  select 
    region, 
    count(1) as times_competed 
  from 
    t1 
  group by 
    region
) 
select 
  * 
from 
  t2 
where 
  times_competed = 51;



-- PROBLEM 6
with t1 as (
  select 
    count(distinct games) as total_games 
  from 
    olympics_history 
  where 
    season = 'Summer'
), 
t2 as (
  select 
    distinct games, 
    sport 
  from 
    olympics_history 
  where 
    season = 'Summer'
), 
t3 as (
  select 
    sport, 
    count(1) as no_of_games 
  from 
    t2 
  group by 
    sport
) 
select 
  * 
from 
  t3 
  join t1 on t3.no_of_games = t1.total_games;


-- problem 7
with t1 as (
  select 
    distinct games, 
    sport 
  from 
    olympics_history 
  group by 
    games, 
    sport
), 
t2 as (
  select 
    sport, 
    count(1) as times_played 
  from 
    t1 
  group by 
    sport
) 
select 
  t2.sport, 
  times_played, 
  games 
from 
  t2 
  join t1 on t1.sport = t2.sport 
where 
  times_played = 1 
order by 
  games;


-- problem 8
with t1 as (
  select 
    distinct games, 
    sport 
  from 
    olympics_history
) 
select 
  games, 
  count(sport) 
from 
  t1 
group by 
  games 
order by 
  games;
-- problem 9
with t1 as (
  select 
    name, 
    sex, 
    cast(
      case when age = 'NA' then '0' else age end as int
    ) as age, 
    team, 
    games, 
    city, 
    sport, 
    event, 
    medal 
  from 
    olympics_history
), 
t2 as (
  select 
    * 
  from 
    t1 
  where 
    medal = 'Gold'
) 
select 
  * 
from 
  t2 
where 
  age = (
    select 
      max(age) 
    from 
      t2
  );
-- problem 10
select 
  concat(
    '1:', 
    round(
      sum(case when sex = 'M' then 1 else 0 end)* 1.0 / sum(case when sex = 'F' then 1 else 0 end), 
      2
    )
  ) as ratio 
from 
  olympics_history;
-- problem 11
select 
  name, 
  team, 
  count(1) 
from 
  olympics_history 
where 
  medal = 'Gold' 
group by 
  name, 
  team 
order by 
  3 desc 
limit 
  10;
--problem 12
select 
  name, 
  team, 
  count(1) 
from 
  olympics_history 
where 
  medal != 'NA' 
group by 
  name, 
  team 
order by 
  3 desc 
limit 
  10;
-- problem 13
with reg as (
  select 
    region, 
    oh.* 
  from 
    olympics_history oh 
    join olympics_history_noc_regions ohnoc on oh.noc = ohnoc.noc
) 
select 
  region, 
  count(1) as medal_count, 
  dense_rank() over(
    order by 
      count(1) desc
  ) as rnk 
from 
  reg 
where 
  medal != 'NA' 
group by 
  1 
order by 
  2 desc;
-- problem 14
with t1 as (
  select 
    region, 
    medal 
  from 
    olympics_history oh 
    join olympics_history_noc_regions ohnoc on oh.noc = ohnoc.noc 
  where 
    medal != 'NA'
), 
t2 as (
  select 
    *, 
    case when medal = 'Gold' then 1 else 0 end as gcount, 
    case when medal = 'Silver' then 1 else 0 end as scount, 
    case when medal = 'Bronze' then 1 else 0 end as bcount 
  from 
    t1
) 
select 
  region, 
  sum(gcount) as gold_medals, 
  sum(scount) as silver_medals, 
  sum(bcount) as bronze_medals 
from 
  t2 
group by 
  region 
order by 
  2 desc, 
  3 desc, 
  4 desc;
-- problem 15
with t1 as (
  select 
    * 
  from 
    olympics_history oh 
    join olympics_history_noc_regions ohnoc on oh.noc = ohnoc.noc 
  where 
    medal != 'NA'
), 
t2 as (
  select 
    *, 
    case when medal = 'Gold' then 1 else 0 end as gcount, 
    case when medal = 'Silver' then 1 else 0 end as scount, 
    case when medal = 'Bronze' then 1 else 0 end as bcount 
  from 
    t1
) 
select 
  games, 
  region, 
  sum(gcount), 
  sum(scount), 
  sum(bcount) 
from 
  t2 
group by 
  1, 
  2 
order by 
  1, 
  2;









