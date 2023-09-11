set search_path = data_mart;

create temp table temp_weekly_sales
(
  "week_date" text,
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(4),
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER
);

with cte as 
(
  select concat('20', spliter[3], '-', spliter[2], '-', spliter[1]) as week_date, region, platform, segment, customer_type, transactions, sales
  from
  (
    select string_to_array(week_date, '/') as spliter, *
    from weekly_sales
  ) as t
)

insert into temp_weekly_sales
select * from cte;

update temp_weekly_sales
set week_date = week_date::date;

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales (
  "week_date" text,
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(4),
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER
);

insert into clean_weekly_sales
select * from temp_weekly_sales;

alter table clean_weekly_sales
alter column week_date type date using week_date::date;

DROP TABLE IF EXISTS temp_weekly_sales;
CREATE TABLE temp_weekly_sales (
  "week_date" date,
  "week_number" INTEGER,
  "month_number" INTEGER,
  "calender_year" INTEGER,
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(10),
  "age_band" TEXT,
  "demographic" TEXT,
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER,
  "avg_transaction" DECIMAL
);

with cte as 
(
  select week_date, (mod(DATE_PART('day', week_date::timestamp - '2018-01-01'::timestamp)::integer,365))/7 + 1 as week_number, extract(month from week_date) as month_number, extract(year from week_date) as calender_year, region, platform, 
  case 
  when segment is null or segment = 'null' then 'unknown'
  else segment
  end as segment, 
  case
  when segment is null or segment = 'null' then 'unknown'
  when substring(segment,2) = '1' then 'Young Adults'
  when substring(segment,2) = '2' then 'Middle Aged'
  when substring(segment,2) = '3' or substring(segment,2) = '4' then 'Retirees'
  end as age_band, 
  case
  when segment is null or segment = 'null' then 'unknown'
  when substring(segment from 1 for 1) = 'C' then 'Couples'
  when substring(segment from 1 for 1) = 'F' then 'Families'
  end as demographic,
  customer_type, transactions, sales, round(1.0*sales/transactions,2) as avg_transaction
  from clean_weekly_sales
)  

insert into temp_weekly_sales
select * from cte;

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales (
  "week_date" date,
  "week_number" INTEGER,
  "month_number" INTEGER,
  "calender_year" INTEGER,
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(10),
  "age_band" TEXT,
  "demographic" TEXT,
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER,
  "avg_transaction" DECIMAL
);

insert into clean_weekly_sales
select * from temp_weekly_sales;

select * from clean_weekly_sales;

--2)

----1)

select extract(dow from week_date) as "day", week_date
from clean_weekly_sales;

----2)

with recursive cte as
(
  select 1 as x
  union 
  select 1+x as x
  from cte
  where x<52
)

select min(not_in_data) as start, max(not_in_data) as end
from
(
  select not_in_data, not_in_data-row_number() over(order by not_in_data) as r
  from
  (
    select x as not_in_data
    from cte
    where x not in (select distinct week_number from clean_weekly_sales)
  ) as t
) as x
group by r;

----3)

select calender_year, count(*) as no_of_transactions
from clean_weekly_sales
group by 1;

----4)

select region, month_number, sum(sales) as total_sales
from clean_weekly_sales
group by 1,2
order by 1,2;

----5)

select platform, count(*) as no_of_transactions
from clean_weekly_sales
group by 1;

----6)

select month_number, round(100.0*no_of_retail/(no_of_retail + no_of_shopify),2) as percent_of_retail, round(100.0*no_of_shopify/(no_of_retail + no_of_shopify),2) as percent_of_shopify
from
(
  select month_number, sum(case when platform = 'Retail' then 1 else 0 end) as no_of_retail, sum(case when platform = 'Shopify' then 1 else 0 end) as no_of_shopify
  from clean_weekly_sales
  group by 1
) as t;

----7)

select calender_year, round(100.0*sales_of_unknown/(sales_of_unknown+sales_of_couples+sales_of_families),2) as percent_of_unknown, round(100.0*sales_of_couples/(sales_of_unknown+sales_of_couples+sales_of_families),2) as percent_of_couples, round(100.0*sales_of_families/(sales_of_unknown+sales_of_couples+sales_of_families),2) as percent_of_families
from
(
  select calender_year, sum(case when demographic = 'unknown' then sales else 0 end) as sales_of_unknown, sum(case when demographic = 'Couples' then sales else 0 end) as sales_of_couples, sum(case when demographic = 'Families' then sales else 0 end) as sales_of_families
  from clean_weekly_sales
  group by 1
) as t;

----8)

select age_band, demographic, sum(sales) as sales
from clean_weekly_sales
where platform = 'Retail'
group by 1,2
order by 3 desc
limit 2;

----9)

select calender_year, platform, sum(sales)/sum(transactions) as average_transaction_size
from clean_weekly_sales
group by 1,2
order by 1,2;

--3)

----1)

-- total sales before and after
select
case
when '2020-06-15'::date > week_date then 'before'
else 'after'
end as before_or_after_change,
sum(sales) as tot_sales
from
(
  select *
  from clean_weekly_sales
  where ('2020-06-15'::date-28) <= week_date and week_date <= ('2020-06-15'::date+21)
) as t
group by 1;

-- growth or reduction

with cte as 
(
  select 
  case
  when '2020-06-15'::date > week_date then 'before'
  else 'after'
  end as before_or_after_change,
  sum(sales) as sales
  from
  (
    select *
    from clean_weekly_sales
    where ('2020-06-15'::date-28) <= week_date and week_date <= ('2020-06-15'::date+21)
  ) as t
  group by 1
)

select
case 
when ((select sales from cte where  before_or_after_change = 'after') > (select sales from cte where  before_or_after_change = 'before')) then 'growth'
when ((select sales from cte where  before_or_after_change = 'after') = (select sales from cte where  before_or_after_change = 'before')) then 'no change'
else 'reduction'
end as growth_or_reduction, max(sales) - min(sales) as difference_in_sales,
round(100.0*(max(sales) - min(sales))/(select sales from cte where  before_or_after_change = 'before'),2) as percent_change
from cte;

----2)

-- total sales before and after
select
case
when '2020-06-15'::date > week_date then 'before'
else 'after'
end as before_or_after_change,
sum(sales) as tot_sales
from
(
  select *
  from clean_weekly_sales
  where ('2020-06-15'::date-7*12) <= week_date and week_date <= ('2020-06-15'::date+11*7)
) as t
group by 1;

-- growth or reduction

with cte as 
(
  select 
  case
  when '2020-06-15'::date > week_date then 'before'
  else 'after'
  end as before_or_after_change,
  sum(sales) as sales
  from
  (
    select *
    from clean_weekly_sales
    where ('2020-06-15'::date-7*12) <= week_date and week_date <= ('2020-06-15'::date+7*11)
  ) as t
  group by 1
)

select
case 
when ((select sales from cte where  before_or_after_change = 'after') > (select sales from cte where  before_or_after_change = 'before')) then 'growth'
when ((select sales from cte where  before_or_after_change = 'after') = (select sales from cte where  before_or_after_change = 'before')) then 'no change'
else 'reduction'
end as growth_or_reduction, max(sales) - min(sales) as difference_in_sales,
round(100.0*(max(sales) - min(sales))/(select sales from cte where  before_or_after_change = 'before'),2) as percent_change
from cte;

----3)

select distinct week_number 
from clean_weekly_sales
where week_date = '2020-06-15'::date;

-- so the week_number for the date of '2020-06-15' is 24. we need to check sales of every year before and after this week_number for each year.

-- consindering interval of 4 months

with cte as 
(
  select calender_year, sum(case when week_number<24 then sales else 0 end) as before_sales, sum(case when week_number>=24 then sales else 0 end) as after_sales
  from
  (
    select *
    from clean_weekly_sales
    where week_number >=20 and week_number <= 27
  ) as t
  group by 1
)

select *,
case
when after_sales>before_sales then 'growth'
else 'reduction'
end as growth_or_reduction,
after_sales - before_sales as difference_in_sales,
round(100.0*(after_sales - before_sales)/before_sales,2) as percent_change
from cte;
