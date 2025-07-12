set search_path = pizza_runner;

-- Data Cleaning

CREATE TABLE temp_customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP,
  "pizza_number" INTEGER
);

with cte as
(
  select order_id, customer_id, pizza_id, exclusions, unnest(string_to_array(extras,', ')) as extras, order_time, pizza_number
  from
  (
      select order_id, customer_id, pizza_id,  unnest(string_to_array(exclusions,', ')) as exclusions, extras, order_time, pizza_number
     from
     (
        select order_id, customer_id, pizza_id, 
        case 
        when exclusions = ''  or exclusions is NULL then 'null'
        else exclusions 
        end as exclusions,
        case 
        when extras = ''  or extras is NULL then 'null'
        else extras
        end as extras,
        order_time, row_number() over(partition by order_id order by order_time) as pizza_number
        from customer_orders
      ) as t
  ) as x
)

INSERT INTO temp_customer_orders
select * from cte;

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP,
  "pizza_number" INTEGER
);

INSERT INTO customer_orders
select * from temp_customer_orders;

CREATE TABLE temp_runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

with cte as
(
  select order_id, runner_id, pickup_time, 
  case 
  when position('k' in distance) = 0 then distance
  else substring(distance,0,position('k' in distance)) 
  end as distance,
  case
  when position('m' in duration) = 0 then duration
  else substring(duration,0,position('m' in duration))
  end as duration, cancellation
  from runner_orders
)

INSERT INTO temp_runner_orders
select * from cte;

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
select * from temp_runner_orders;

CREATE TABLE temp_pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" INTEGER
);

with cte as
(
  select pizza_id, unnest(string_to_array(toppings,', '))::integer as toppings
  from pizza_recipes
)

INSERT INTO temp_pizza_recipes
select * from cte;

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" INTEGER
);

INSERT INTO pizza_recipes
select * from temp_pizza_recipes;


----A)

--1)

select count(distinct (order_id, pizza_number)) as no_of_pizzas_ordered
from customer_orders;

--2)

select customer_id, count(distinct order_id) as no_of_unique_orders
from customer_orders
group by 1;

--3)

select runner_id, sum(case when cancellation like '%Cancellation' then 0 else 1 end) as no_of_successful_deliveries
from runner_orders
group by 1
order by 1;

--4)

select pizza_name, count(*) as no_of_orders
from
(
  select n.pizza_name, customer_id, pizza_number, c.order_id
  from customer_orders as c
  join runner_orders as r
  on c.order_id = r.order_id
  join pizza_names as n
  on c.pizza_id = n.pizza_id
  where r.pickup_time != 'null'
  group by 1,2,3,4
) as t
group by 1
order by 1;

--5)

select customer_id, sum(case when pizza_id = 1 then 1 else 0 end) as Meatlovers, sum(case when pizza_id = 2 then 1 else 0 end) as Vegetarian
from
(
  select customer_id, pizza_id, order_time
  from customer_orders
  group by 1,2,3
) as t
group by 1;

--6)

select order_id, pizza_ordered
from
(
  select c.order_id, max(pizza_number) as pizza_ordered
  from customer_orders as c
  join runner_orders as r
  on r.order_id = c.order_id
  where r.pickup_time <> 'null'
  group by 1
  order by 2 desc
  limit 1
) as t;

--7)

select customer_id, sum(case when exclusions = 0 and extras = 0 then 1 else 0 end) as no_of_pizzas_without_change, sum(case when exclusions <> 0 or extras <> 0 then 1 else 0 end) as no_of_pizzas_with_change
from
(
  select order_id, customer_id, pizza_number, sum(case when exclusions <> 'null' then 1 else 0 end) as exclusions, sum(case when extras <> 'null' then 1 else 0 end) as extras
  from customer_orders
  group by 1,2,3
  order by 2,3
) as t
group by 1;

--8)

select count(*) as no_of_pizzas_having_both_extras_nd_exclusions
from
(
  select order_id, customer_id, pizza_number, sum(case when exclusions <> 'null' then 1 else 0 end) as exclusions, sum(case when extras <> 'null' then 1 else 0 end) as extras
  from customer_orders
  group by 1,2,3
  order by 2,3
) as t
where exclusions>0 and extras>0;

--9)

select hour_time, count(*) as no_of_orders
from
(
  select extract(hour from order_time) as hour_time, order_id, customer_id, pizza_number
  from customer_orders
  group by 1,2,3,4
) as t
group by 1
order by 1;

--10)

select week_day, count(*) as no_of_orders
from
(
  select extract(dow from order_time) as week_day, order_id, customer_id, pizza_number
  from customer_orders
  group by 1,2,3,4
) as t
group by 1
order by 1;

----B)

--1)

with recursive cte as
(
  select '2021-01-01'::Date as week_date
  union
  select week_date+7 as week_date
  from cte
  where week_date<=(select max(registration_date) from runners)
)

select week_start_date, week_end_date, count(*) as no_of_runners_registered
from
(
  select runner_id, week_start_date, week_end_date
  from
  (
    select week_date as week_start_date, lead(week_date) over(order by week_date) as week_end_date
    from cte
  ) as t
  join runners as r
  on r.registration_date>=t.week_start_date and r.registration_date<t.week_end_date
) as x
group by 1,2
order by 1;

--2)

select runner_id, avg(pickup_time::timestamp-order_time) as avg_time_to_pickup
from
(
  select c.order_id, runner_id, pickup_time, order_time
  from customer_orders as c
  join runner_orders as r
  on c.order_id = r.order_id
  group by 1,2,3,4
) as t
where pickup_time <> 'null'
group by 1
order by 1;

--3)

select no_of_pizzas, avg(preparation_time) as avg_preparation_time
from
(
  select r.order_id, no_of_pizzas, pickup_time::timestamp-order_time as preparation_time
  from
  (
    select order_id, order_time, count(distinct pizza_number) as no_of_pizzas
    from customer_orders
    group by 1,2
  ) as c
  join runner_orders as r
  on c.order_id = r.order_id
  where pickup_time<>'null'
) as t
group by 1
order by 1;

-- it can be observed that the average pickup time for 1 pizza is 12 minutes 21 sec, for 2 pizzas is 18 minutes 22 seconds and for 3 pizzas is 29 min 17 sec. So the time is increasing with the no_of_pizzas

--4)

select customer_id, round(avg(distance::numeric),2) as avg_distance
from
(
  select customer_id, order_id
  from customer_orders
  group by 1,2
) as c
join runner_orders as r
on c.order_id = r.order_id
where distance<>'null'
group by 1;

--5)

select max(duration::numeric) - min(duration::numeric) as diff_long_short_duration
from runner_orders
where distance<>'null';

--6)

select runner_id, order_id, round(60*distance::numeric/duration::numeric,2) as avg_speed
from runner_orders
where distance<>'null'
order by 1;

--7)

select runner_id, count(*) as total_no_of_deliveries, sum(case when success=1 then 1 else 0 end) as no_of_successful_deliveries, sum(case when success=0 then 1 else 0 end) as no_of_unsuccessful_deliveries, round(100.0*sum(case when success=1 then 1 else 0 end)/count(*),2) as success_percent
from
(
  select runner_id, 
  case
  when cancellation like '%Cancellation' then 0
  else 1
  end as success
  from runner_orders
) as t
group by 1;

----C)

--1)
 
select pizza_name, string_agg(topping_name,', ') as ingredients
from pizza_recipes as r
join pizza_names as n
on r.pizza_id = n.pizza_id
join pizza_toppings as pt
on pt.topping_id = r.toppings
group by 1;

--2)

select topping_name as extra_name, count(distinct (order_id,pizza_number)) as no_of_pizzas
from customer_orders as c
join pizza_toppings as t
on c.extras::integer = t.topping_id
where extras<>'null'
group by 1
order by 2 desc;

--Bacon is found to be the most common extra

--3)

select topping_name as exclusion_name, count(distinct (order_id,pizza_number)) as no_of_pizzas
from customer_orders as c
join pizza_toppings as t
on c.exclusions::integer = t.topping_id
where exclusions<>'null'
group by 1
order by 2 desc;

--Cheese is found to be the most common exclusion

--4)

select order_id, 
case
when exclusions is not NULL and extras is not NULL then concat(pizza_name,' - Exclude ',exclusions, ' - Extra ', extras) 
when exclusions is not NULL then concat(pizza_name,' - Exclude ',exclusions)
when extras is not NULL then concat(pizza_name,' - Extra ', extras)
else pizza_name
end as order_item
from
(
  select order_id, pizza_name, string_agg(distinct exclusions,', ') as exclusions, string_agg(distinct extras,', ') as extras
  from
  (
      select order_id, pizza_number, pizza_name, t1.topping_name as exclusions, t2.topping_name as extras
      from customer_orders as c
      join pizza_names as n
      on c.pizza_id = n.pizza_id
      left join pizza_toppings as t1
      on c.exclusions = t1.topping_id::VARCHAR(4)
      left join pizza_toppings as t2
      on c.extras = t2.topping_id::VARCHAR(4)
  ) as t
  group by order_id, pizza_number, pizza_name
) as x
order by 1;

-- 5)

with cte as
(
    select c.order_id, c.pizza_number, n.pizza_name, t.topping_name as ingredient, t1.topping_name as exclusion, t2.topping_name as extra
    from customer_orders as c
    join pizza_names as n
    on c.pizza_id = n.pizza_id
    join pizza_recipes as r
    on c.pizza_id = r.pizza_id
    join pizza_toppings as t
    on r.toppings = t.topping_id
    left join pizza_toppings as t1
    on c.exclusions = t1.topping_id::VARCHAR(4)
    left join pizza_toppings as t2
    on c.extras = t2.topping_id::VARCHAR(4)
    where t.topping_name<>t1.topping_name or t1.topping_name is NULL
),

cte2 as
(
  select order_id, pizza_number, max(c) as max_c
  from
  (
    select order_id, pizza_number, pizza_name, ingredient, count(*) as c
    from cte
    group by 1,2,3,4
  ) as t
  group by 1,2
),

cte3 as
(
  select order_id, pizza_number, pizza_name, ingredient, count(*) as no_of_extras
  from
  (
    select t.order_id, t.pizza_number, pizza_name, ingredient
    from
    (
      select order_id, pizza_number, pizza_name, ingredient, count(*) as c
      from cte
      group by 1,2,3,4
      order by 1,2
    ) as t
    join cte2
    on cte2.order_id = t.order_id and cte2.pizza_number = t.pizza_number
    where c=max_c
    union all
    select order_id, pizza_number, pizza_name, extra as ingredient
    from cte
    group by 1,2,3,4
  ) as t
  group by 1,2,3,4
)

select order_id, concat(pizza_name, ': ', ingredient) as order_item
from
(
  select order_id, pizza_number, pizza_name, string_agg(ingredient,', ' order by ingredient) as ingredient
  from
  (
    select order_id, pizza_number, pizza_name,
    case
    when no_of_extras>1 then concat(no_of_extras::varchar(2),'x',ingredient)
    else ingredient
    end as ingredient
    from cte3
  ) as t
  group by 1,2,3
) as x;

--6)

with cte as
(
    select c.order_id, c.pizza_number, n.pizza_name, t.topping_name as ingredient, t1.topping_name as exclusion, t2.topping_name as extra
    from customer_orders as c
    join pizza_names as n
    on c.pizza_id = n.pizza_id
    join pizza_recipes as r
    on c.pizza_id = r.pizza_id
    join pizza_toppings as t
    on r.toppings = t.topping_id
    left join pizza_toppings as t1
    on c.exclusions = t1.topping_id::VARCHAR(4)
    left join pizza_toppings as t2
    on c.extras = t2.topping_id::VARCHAR(4)
    where t.topping_name<>t1.topping_name or t1.topping_name is NULL
),

cte2 as
(
  select order_id, pizza_number, max(c) as max_c
  from
  (
    select order_id, pizza_number, pizza_name, ingredient, count(*) as c
    from cte
    group by 1,2,3,4
  ) as t
  group by 1,2
),

cte3 as
(
  select order_id, pizza_number, pizza_name, ingredient, count(*) as no_of_extras
  from
  (
    select t.order_id, t.pizza_number, pizza_name, ingredient
    from
    (
      select order_id, pizza_number, pizza_name, ingredient, count(*) as c
      from cte
      group by 1,2,3,4
      order by 1,2
    ) as t
    join cte2
    on cte2.order_id = t.order_id and cte2.pizza_number = t.pizza_number
    where c=max_c
    union all
    select order_id, pizza_number, pizza_name, extra as ingredient
    from cte
    group by 1,2,3,4
  ) as t
  group by 1,2,3,4
)

select ingredient, sum(no_of_extras) as quantity
from
(
  select cte3.order_id, pizza_number, pizza_name, ingredient, no_of_extras
  from cte3
  left join runner_orders as r
  on cte3.order_id = r.order_id
  where (cancellation not like '%Cancellation' or cancellation is NULL) and ingredient is not null
  order by 1,2
) as t
group by 1;

----D)

--1)

select sum(case when pizza_name = 'Meatlovers' then 12 when pizza_name = 'Vegetarian' then 10 end) as total_revenue
from
(
  select order_id, pizza_number, pizza_name
  from customer_orders as c
  join pizza_names as n
  on c.pizza_id = n.pizza_id
  where c.order_id in (select order_id from runner_orders where cancellation not like'%Cancellation' or cancellation is null)
  group by 1,2,3
  order by 1,2,3
) as t;

--2)

select sum(case when pizza_name = 'Meatlovers' then 12 + extra when pizza_name = 'Vegetarian' then 10 + extra end) as total_revenue
from
(
  select order_id, pizza_number, pizza_name, sum(case when extra='Cheese' then 2 when extra is null then 0 else 1 end) as extra
  from
  (
    select order_id, pizza_number, pizza_name, t.topping_name as extra
    from customer_orders as c
    left join pizza_toppings as t
    on t.topping_id::VARCHAR(4) = c.extras
    join pizza_names as n
    on n.pizza_id = c.pizza_id
    where c.order_id in (select order_id from runner_orders where cancellation not like'%Cancellation' or cancellation is null)
    group by 1,2,3,4
  ) as x
  group by 1,2,3
  order by 1,2,3
) as y;

--3)

CREATE TABLE customer_ratings (
  "customer_id" INTEGER,
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "rating" INTEGER
);

INSERT INTO customer_ratings
 ("customer_id", "order_id", "runner_id", "rating")
VALUES
  ('101','1', '1', '3'),
  ('101','2', '1', '4'),
  ('102','3', '1', '4'),
  ('103','4', '2', '2'),
  ('104','5', '3', '3'),
  ('101','6', '3', '0'),
  ('105','7', '2', '4'),
  ('102','8', '2', '5'),
  ('103','9', '2', '0'),
  ('104','10', '1', '4');  
  
select * from customer_ratings;

--4)

with cte as
(
  select order_id, max(pizza_number) as no_of_pizzas
  from customer_orders 
  group by 1
)

select r.customer_id, r.order_id, r.runner_id, r.rating, c.order_time, ro.pickup_time,
case
when ro.pickup_time='null' or ro.pickup_time is NULL then NULL
else ro.pickup_time::timestamp - c.order_time
end as time_diff_between_order_pickup,
ro.duration, 
case 
when distance='null' or ro.distance is NULL then NULL
else round(60*distance::numeric/duration::numeric,2)
end as avg_speed, 
cte.no_of_pizzas
from customer_ratings as r
join 
(
  select order_id, order_time 
  from customer_orders
  group by 1,2
) as c
on c.order_id = r.order_id
join runner_orders as ro
on r.order_id = ro.order_id
join cte 
on r.order_id = cte.order_id;

--5)

select sum(pizza_charge+delivery_charge) as total_revenue
from
(
  select t.order_id, sum(case when pizza_name = 'Meatlovers' then 12 when pizza_name = 'Vegetarian' then 10 end) as pizza_charge, 0.3*distance::numeric as delivery_charge
  from
  (
    select order_id, pizza_number, pizza_name
    from customer_orders as c
    join pizza_names as n
    on c.pizza_id = n.pizza_id
    where c.order_id in (select order_id from runner_orders where cancellation not like'%Cancellation' or cancellation is null)
    group by 1,2,3
    order by 1,2,3
  ) as t
  join runner_orders as r
  on t.order_id = r.order_id
  group by 1, r.distance
) as x;
