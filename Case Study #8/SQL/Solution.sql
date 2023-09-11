set search_path = fresh_segments;

--1)

create temp table interest_metrics_temp(
  "_month" VARCHAR(4),
  "_year" VARCHAR(4),
  "month_year" DATE,
  "interest_id" VARCHAR(5),
  "composition" FLOAT,
  "index_value" FLOAT,
  "ranking" INTEGER,
  "percentile_ranking" FLOAT
);

with cte as
(
  select _month, _year, 
  case
  when month_year is NULL then NULL
  else concat(_year,'-',_month,'-','01')::DATE 
  end as month_year,
  interest_id, composition, index_value, ranking, percentile_ranking
  from interest_metrics
)

INSERT INTO interest_metrics_temp
select * from cte;

TRUNCATE TABLE interest_metrics;

ALTER table interest_metrics
ALTER column month_year TYPE DATE USING month_year::DATE;

INSERT INTO interest_metrics
select * from interest_metrics_temp;

-- select * from interest_metrics;

--2)

select month_year, no_of_records
from
(
  select month_year, count(*) as no_of_records, 1 as rn
  from interest_metrics
  group by 1
  having month_year is NULL
  union
  (select month_year, count(*) as no_of_records, 2 as rn
  from interest_metrics
  group by 1
  having month_year is not NULL)
) as t
order by rn, month_year;

--3)

select 100.0*count(*)/(select count(*) from interest_metrics) as percent_of_nulls
from interest_metrics
where _month is NULL or _year is NULL or month_year is NULL or interest_id is NULL or composition is NULL or index_value is NULL or ranking is NULL or percentile_ranking is NULL;

-- the percentage of null values is very less so we can delete the rows of null values

--4)

select count(distinct metric.interest_id) as no_of_interest_ids_in_metric,  count(distinct maps.id) as no_of_interest_ids_in_maps, sum(case when metric.interest_id is NULL and maps.id is not NULL then 1 else 0 end) as ids_in_map_but_not_in_metric, sum(case when maps.id is NULL and metric.interest_id is not NULL then 1 else 0 end) as ids_in_metric_but_not_in_map
from interest_metrics as metric
full outer join interest_map as maps
on metric.interest_id::integer = maps.id;

--5)

select count(*) as total_no_of_records
from interest_map;

--6)

select interest_name, interest_summary, created_at, last_modified, _month, _year, month_year, interest_id, composition, index_value, ranking, percentile_ranking
from interest_map as maps
join interest_metrics as metrics
on maps.id = metrics.interest_id::integer
where metrics.interest_id = '21246' and metrics._month is not NULL;

--7)

select *
from
(
  select interest_name, interest_summary, created_at, last_modified, _month, _year, month_year, interest_id, composition, index_value, ranking, percentile_ranking
  from interest_map as maps
  join interest_metrics as metrics
  on maps.id = metrics.interest_id::integer
) as t
where month_year < created_at;

-- since earlier we have chose the date to be first of the given month hence we got these many rows where the month_year < created_at. So, the month_year dates need to be corrected accordingly. 

-------------------------------------------------

--1)

select interest_name
from
(
  select interest_id, count(distinct _year) as no_of_years
  from
  (
    select interest_id, _year, count(distinct _month) as no_of_months
    from interest_metrics
    where _month is not NULL and _year is not NULL
    group by 1,2
  ) as t
  where (_year = '2018' and no_of_months = 6) or (_year = '2019' and no_of_months = 8)
  group by 1
)as x
join interest_map as i
on x.interest_id::integer = i.id
where no_of_years = 2;

--2)

with cte as
(
  select no_of_months, count(distinct interest_id) as no_of_interests
  from
  (
    select interest_id, count(distinct month_year) as no_of_months
    from interest_metrics
    where month_year is not NULL
    group by 1
  ) as t
  group by 1
)

select sum(case when cumulative_percentage>=90 then 1 else 0 end) as total_months
from
(
  select no_of_months, no_of_interests, round(100 * sum(no_of_interests) over(order by no_of_months desc)/(sum(no_of_interests) over()),2) as cumulative_percentage
  from cte
) as t;

--3)

select count(*) as no_of_rows
from
(
  select interest_id
  from interest_metrics as im
  where month_year is not NULL and interest_id is not NULL
  group by 1
  having count(interest_id)<6
) as t;

--4)

with cte as
(
  select interest_id
  from interest_metrics
  where interest_id is not NULL
  group by 1
  having count(interest_id)<6
),

cte2 as 
(
  select month_year, count(*) as total_interests
  from interest_metrics
  where interest_id is not NULL and month_year is not NULL
  group by 1
)

select *, round(100.0*no_of_interests_included/total_interests,2) as percent_of_exclusion
from
(
  select im.month_year, count(interest_id) as  no_of_interests_included, total_interests
  from interest_metrics as im
  join cte2
  on im.month_year = cte2.month_year
  where interest_id in (select interest_id from cte) and im.month_year is not NULL
  group by 1,3
  order by im.month_year
) as t;

--5)

with cte as
(
  select interest_id
  from interest_metrics
  where interest_id is not NULL
  group by 1
  having count(interest_id)<6
),

cte2 as 
(
  select month_year, count(*) as total_interests
  from interest_metrics
  where interest_id is not NULL and month_year is not NULL
  group by 1
)

select im.month_year, total_interests-count(interest_id) as  no_of_interests_remaining
from interest_metrics as im
join cte2
on im.month_year = cte2.month_year
where interest_id in (select interest_id from cte) and im.month_year is not NULL
group by 1,total_interests
order by im.month_year;

-----------------------

--1)

-- no_of_interests >= 6

with cte as
(
  select interest_id
  from interest_metrics
  where interest_id is not NULL
  group by 1
  having count(interest_id)>=6
),

-- top 10 and bottom 10

cte2 as
(
  select interest_id, composition, month_year
  from
  (
    select interest_id, composition, month_year, rank() over(order by composition desc) as rk_desc, rank() over(order by composition) as rk_asc
    from
    (
      select interest_id, month_year, composition, rank() over(partition by interest_id order by composition desc) as rk_desc, rank() over(partition by interest_id order by composition) as rk_asc
      from interest_metrics 
      where interest_id is not NULL and interest_id in (select interest_id from cte)
    ) as t
    where rk_desc=1 or rk_asc=1
  ) as x
  where rk_desc<=10 or rk_asc<=10
),

cte3 as
(
  select interest_id, composition, month_year
  from
  (
    select interest_id, composition, month_year, rank() over(partition by interest_id order by composition desc) as rk
    from interest_metrics
    where interest_id is not null and month_year is not null and interest_id in (select interest_id from cte)
  ) as t
  where rk=1
)

select cte2.interest_id, m.interest_name, cte2.month_year, cte2.composition, cte3.composition as max_composition, cte3.month_year month_year_at_max_composition
from cte2
join cte3
on cte2.interest_id = cte3.interest_id
join interest_map as m
on cte3.interest_id::integer = m.id
order by 4 desc;

--2)

with cte2 as
(
  select interest_id
  from interest_metrics
  where interest_id is not NULL and month_year is not null
  group by 1
  having count(interest_id)>=6
)

select interest_name, avg_ranking
from
(
  select interest_id, avg_ranking, rank() over(order by avg_ranking) as r
  from
  (
    select interest_id, round(avg(ranking),2) as avg_ranking
    from interest_metrics
    where interest_id is not null and month_year is not null and interest_id in (select interest_id from cte2)
    group by 1
  ) as t
  order by r
)
as x
join interest_map as im
on im.id = x.interest_id::integer
order by 2
limit 5;

--3)

with cte2 as
(
  select interest_id
    from interest_metrics
    where interest_id is not NULL and month_year is not null
    group by 1
    having count(interest_id)>=6
),

cte as
(
  select interest_id, avg(percentile_ranking) as avg_percentile_ranking, count(*) as n
  from interest_metrics
  where interest_id is not NULL and month_year is not null and interest_id in (select interest_id from cte2)
  group by 1
)
 
select interest_id, interest_name
from
(
  select im.interest_id, sum((percentile_ranking-avg_percentile_ranking)*(percentile_ranking-avg_percentile_ranking))/n as variance
  from interest_metrics as im
  join cte 
  on im.interest_id = cte.interest_id
  where im.interest_id is not null and month_year is not null and im.interest_id in (select interest_id from cte2)
  group by im.interest_id, cte.avg_percentile_ranking, cte.n
) as t
join interest_map as m
on m.id = t.interest_id::integer
order by rank() over(order by variance desc)
limit 5;

--4)

with cte2 as
(
  select interest_id
  from interest_metrics
  where interest_id is not NULL and month_year is not null
  group by 1
  having count(interest_id)>=6
),

cte as
(
  select interest_id, avg(percentile_ranking) as avg_percentile_ranking, count(*) as n
  from interest_metrics
  where interest_id is not NULL and month_year is not null and interest_id in (select interest_id from cte2)
  group by 1
),

interests_with_higher_std as
(
  select interest_id
  from
  (
    select im.interest_id, sum((percentile_ranking-avg_percentile_ranking)*(percentile_ranking-avg_percentile_ranking))/n as variance
    from interest_metrics as im
    join cte 
    on im.interest_id = cte.interest_id
    where im.interest_id is not null and month_year is not null and im.interest_id in (select interest_id from cte2)
    group by im.interest_id, cte.avg_percentile_ranking, cte.n
  ) as t
  order by rank() over(order by variance desc)
  limit 5
)

select interest_id, interest_name, month_year, percentile_ranking
from
(
  select interest_id, month_year, percentile_ranking, rank() over(partition by interest_id order by percentile_ranking) as ra, rank() over(partition by interest_id order by percentile_ranking desc) as rd
  from interest_metrics 
  where interest_id in (select interest_id from interests_with_higher_std) and month_year is not null
) as t
join interest_map as m
on t.interest_id::integer = m.id
where ra = 1 or rd = 1;

--5)

-- The customers having higher demand on Technologies, live concerts, entertainments medias, trip and personalized gifts so I would suugest to show the customers within the above mentioned interests and would avoid any irrerelavent interests.

----Index Analysis

--1)

select month_year, interest_id, interest_name, avg_composition, r as rank_in_the_month
from
(
  select interest_id, month_year, avg_composition, rank() over(partition by month_year order by avg_composition desc) as r
  from
  (
    select interest_id, month_year, composition/index_value as avg_composition
    from interest_metrics
    where interest_id is not null and month_year is not null
  ) as t
) as x
join interest_map as m
on m.id = x.interest_id::integer
where r<=10
order by 1, r;

--2)

with cte as
(
  select month_year, interest_id, interest_name, avg_composition, r as rank_in_the_month
  from
  (
    select interest_id, month_year, avg_composition, rank() over(partition by month_year order by avg_composition desc) as r
    from
    (
      select interest_id, month_year, composition/index_value as avg_composition
      from interest_metrics
      where interest_id is not null and month_year is not null
    ) as t
  ) as x
  join interest_map as m
  on m.id = x.interest_id::integer
  where r<=10
  order by 1, r
)

select interest_name, count(*) as no_of_times_appeared
from cte
where rank_in_the_month = 1
group by 1
order by 2 desc;

--3)

with cte as
(
  select month_year, interest_id, interest_name, avg_composition, r as rank_in_the_month
  from
  (
    select interest_id, month_year, avg_composition, rank() over(partition by month_year order by avg_composition desc) as r
    from
    (
      select interest_id, month_year, composition/index_value as avg_composition
      from interest_metrics
      where interest_id is not null and month_year is not null
    ) as t
  ) as x
  join interest_map as m
  on m.id = x.interest_id::integer
  where r<=10
  order by 1, r
)

select month_year, avg(avg_composition) as avg_avg_composition
from cte
group by 1;

--4)

with cte as
(
  select month_year, interest_id, interest_name, avg_composition, r as rank_in_the_month
  from
  (
    select interest_id, month_year, avg_composition, rank() over(partition by month_year order by avg_composition desc) as r
    from
    (
      select interest_id, month_year, composition/index_value as avg_composition
      from interest_metrics
      where interest_id is not null and month_year is not null
    ) as t
  ) as x
  join interest_map as m
  on m.id = x.interest_id::integer
  where r<=10
  order by 1, r
)

select * 
from
(
  select month_year, interest_name, avg_composition as max_index_composition, avg(avg_composition) over(order by month_year rows between 2 preceding and current row) as three_month_moving_avg, concat(lag(interest_name) over(order by month_year),': ',lag(avg_composition) over(order by month_year)) as one_month_ago, concat(lag(interest_name,2) over(order by month_year),': ',lag(avg_composition,2) over(order by month_year)) as two_month_ago
  from cte
  where rank_in_the_month = 1
) as t
where month_year>='2018-09-01' and month_year<='2019-08-01';

