set search_path = clique_bait;

--2

----1)

select count(distinct user_id) as no_of_users 
from users;

----2)

select ceil(avg(no_of_cookies)) as cookies_per_user
from
(
  select user_id, count(distinct cookie_id) as no_of_cookies 
  from users
  group by 1
) as t;

----3)

select extract(month from event_time) as month_number, count(distinct visit_id) as no_of_visits
from events
group by 1
order by 1;

----4)

select event_type, count(*) as no_of_events
from events
group by 1;

----5)

with cte as
(
  select e.event_type, ei.event_name, count(distinct visit_id) as no_of_visits
  from events as e
  join event_identifier as ei
  on e.event_type = ei.event_type
  group by 1,2
)

select round(100.0*(select no_of_visits from cte where event_name = 'Purchase')/(select count(distinct visit_id) from events),2) as percent_of_purchases;

----6)

with cte as
(
  select distinct visit_id
  from events as e
  join event_identifier as ei
  on e.event_type = ei.event_type  
  where event_name = 'Purchase'
),

cte2 as
(
  select distinct visit_id
  from events as e
  join page_hierarchy as p
  on e.page_id = p.page_id
  join event_identifier as ei
  on ei.event_type = e.event_type
  where p.page_name = 'Checkout' and ei.event_name = 'Page View'
)

select round(100.0*count(distinct visit_id)/(select count(distinct visit_id) from cte2),2) as percent_of_visits_with_no_purchase
from cte2
where visit_id not in (select distinct visit_id from cte);

----7)

select p.page_id, p.page_name, count(*) as no_of_visit
from events as e
join page_hierarchy as p
on p.page_id = e.page_id
join event_identifier as ei
on e.event_type = ei.event_type
where event_name = 'Page View'
group by 1,2
order by 3 desc
limit 3;

----8)

select product_category, sum(case when event_name = 'Page View' then 1 else 0 end) as no_of_views, sum(case when event_name = 'Add to Cart' then 1 else 0 end) as no_of_add_to_cart
from page_hierarchy as p
join events as e
on p.page_id = e.page_id
join event_identifier as ei
on ei.event_type = e.event_type
where product_category != 'null'
group by 1;

----9)

select product_id, page_name, count(*) as no_of_purchases
from events as e
join page_hierarchy as p
on e.page_id = p.page_id
join event_identifier as ei
on ei.event_type = e.event_type
where visit_id in
(
select distinct visit_id
from events as e
join event_identifier as ei
on e.event_type = ei.event_type
where event_name = 'Purchase') and event_name = 'Add to Cart'
group by 1,2
order by 3 desc
limit 3;

--3)

with purchased as
(
  select product_id, page_name, product_category
  -- , count(*) as no_of_purchases
  from events as e
  join page_hierarchy as p
  on e.page_id = p.page_id
  join event_identifier as ei
  on ei.event_type = e.event_type
  where visit_id in
  (
    select distinct visit_id
    from events as e
    join event_identifier as ei
    on e.event_type = ei.event_type
    where event_name = 'Purchase'
  ) and event_name = 'Add to Cart'
  -- group by 1,2
),

added_to_cart_but_no_purchase as
(
  select product_id, page_name, product_category
  -- , count(*) as abandoned
  from events as e
  join page_hierarchy as p
  on e.page_id = p.page_id
  join event_identifier as ei
  on ei.event_type = e.event_type
  where visit_id not in
  (
    select distinct visit_id
    from events as e
    join event_identifier as ei
    on e.event_type = ei.event_type
    where event_name = 'Purchase'
  ) and event_name = 'Add to Cart'
  -- group by 1,2
),

based_on_product_id as
(
  select x.product_id, x.page_name, x.no_of_views, x.no_of_add_to_carts, no_of_purchases, abandoned
  from
  (
    select product_id, page_name, sum(case when event_name = 'Page View' then 1 else 0 end) as no_of_views, sum(case when event_name = 'Add to Cart' then 1 else 0 end) as no_of_add_to_carts
    from events as e
    join page_hierarchy as p
    on e.page_id = p.page_id
    join event_identifier as ei
    on ei.event_type = e.event_type
    group by 1,2
  ) as x
  join 
  (
    select product_id, page_name, count(*) as no_of_purchases
  	from purchased
    group by 1,2
  ) as p
  on p.product_id = x.product_id
  join
  (
    select product_id, page_name, count(*) as abandoned
    from added_to_cart_but_no_purchase
    group by 1,2
  )as t
  on t.product_id = x.product_id
),

based_on_product_category as
(
  select x.product_category, x.no_of_views, x.no_of_add_to_carts, no_of_purchases, abandoned
  from
  (
    select product_category, sum(case when event_name = 'Page View' then 1 else 0 end) as no_of_views, sum(case when event_name = 'Add to Cart' then 1 else 0 end) as no_of_add_to_carts
    from events as e
    join page_hierarchy as p
    on e.page_id = p.page_id
    join event_identifier as ei
    on ei.event_type = e.event_type
    group by 1
  ) as x
  join 
  (
    select product_category, count(*) as no_of_purchases
  	from purchased
    group by 1
  ) as p
  on p.product_category = x.product_category
  join
  (
    select product_category, count(*) as abandoned
    from added_to_cart_but_no_purchase
    group by 1
  )as t
  on t.product_category = x.product_category
)

--1)

-- select *
-- from based_on_product_id
-- order by no_of_views desc, no_of_add_to_carts desc, no_of_purchases desc;

---- Oyster has the highest no of views, Lobster has the highest no of purchases and add to carts.  

--2)

-- select *
-- from based_on_product_id
-- order by abandoned desc;

---- Russian Caviar is the most abandoned product

--3)

-- select *, 100.0*no_of_purchases/no_of_views as percent_of_purchases_out_of_views
-- from based_on_product_id
-- order by percent_of_purchases_out_of_views desc;

---- Lobster has the most percent of purchases out of no of views

--4) 

-- select round(avg(100.0*no_of_add_to_carts/no_of_views),2) as avg_percent_of_add_to_carts_out_of_views
-- from based_on_product_id;

--5)

select round(avg(100.0*no_of_purchases/no_of_add_to_carts),2) as avg_percent_of_purchases_out_of_add_to_carts
from based_on_product_id;

----3)

DROP TABLE IF EXISTS visit_id_records;
CREATE TABLE visit_id_records (
  "user_id" INTEGER,
  "visit_id" VARCHAR(6),
  "visit_start_time" TIMESTAMP,
  "page_views" INTEGER,
  "cart_adds" INTEGER,
  "purchase" INTEGER,
  "campaign_name" VARCHAR(33), 
  "impression" INTEGER,
  "click" INTEGER,
  "cart_products" text
);

with cte as
(
  select visit_id, string_agg(page_name, ', ' order by sequence_number) as cart_products
  from
  (
    select visit_id, page_name, sequence_number
    from events as e
    join page_hierarchy as p
    on e.page_id = p.page_id
    where event_type = '2'
  ) as t
  group by 1
),

cte2 as 
(
   select user_id, t.visit_id, visit_start_time, page_views, cart_adds, purchase, ci.campaign_name, impression, click, cart_products
  from
  (
    select user_id, visit_id, min(event_time) as visit_start_time, count(distinct page_id) as page_views, sum(case when event_name = 'Add to Cart' then 1 else 0 end) as cart_adds,
    case
    when sum(case when event_name = 'Purchase' then 1 else 0 end)>0 then 1
    else 0
    end as purchase,
    sum(case when event_name = 'Ad Impression' then 1 else 0 end) as impression,
    sum(case when event_name = 'Ad Click' then 1 else 0 end) as click
    from events as e
    join users as u
    on e.cookie_id = u.cookie_id
    join event_identifier as ei
    on e.event_type = ei.event_type
    group by 1,2
  ) as t
  left join campaign_identifier as ci
  on t.visit_start_time>=ci.start_date and visit_start_time<=ci.end_date
  left join cte
  on t.visit_id = cte.visit_id
)

insert into visit_id_records
select * from cte2;

-- select * from visit_id_records;

select round(100.0*sum(case when click = 1 and purchase = 1 then 1 else 0 end)/sum(case when click = 1 then 1 else 0 end),2) as no_of_purchases_after_click, round(100.0*sum(case when click = 0 and purchase = 1 then 1 else 0 end)/sum(case when click = 0 then 1 else 0 end),2) as no_of_purchases_without_clicks
from
(
  select visit_id, click, purchase
  from visit_id_records
) as t;

with cte as 
(
  select campaign_name, substring(products,1,1)::INTEGER as start_product, substring(products,3,1)::INTEGER as end_product, date_part('day',end_date-start_date) as no_of_on_campaign_days, (select date_part('day', max(event_time) - min(event_time)) from events) - date_part('day',end_date-start_date) as no_of_off_campaign_days
  from campaign_identifier
),

cte2 as
(
  select cart_product, product_id, sum(case when start_product is not null then 1 else 0 end) as purchases_in_campaign, sum(case when start_product is null then 1 else 0 end) as purchases_off_campaign
  from
  (
    select vr.campaign_name, cart_product, product_id, start_product
    from 
    (
      select campaign_name, unnest(string_to_array(cart_products,',')) as cart_product
      from visit_id_records
      where purchase=1
    )
    as vr
    right join page_hierarchy as ph
    on ph.page_name = vr.cart_product
    left join cte
    on cte.start_product<=product_id and cte.end_product>=product_id and cte.campaign_name = vr.campaign_name
  ) as t
  where cart_product is not null
  group by 1,2
  order by 2
),

cte3 as
(
  select cart_product, product_id, purchases_in_campaign, ceil(purchases_off_campaign*no_of_on_campaign_days/no_of_off_campaign_days) as normalized_purchases_off_campaign
  from cte2
  join cte
  on cte2.product_id>=cte.start_product and cte2.product_id<=cte.end_product
)

select cart_product, 100.0*purchases_in_campaign/(purchases_in_campaign+normalized_purchases_off_campaign) as percent_of_purchases_in_campaign, 100.0*normalized_purchases_off_campaign/(purchases_in_campaign+normalized_purchases_off_campaign) as percent_of_purchases_off_campaign
from cte3;

--checking the purchase percent of people who gave impression on the ads during the campaign and comparing it with the people who did give an impression on the ad

select 100.0*sum(case when purchase = 1 then 1 else 0 end)/(sum(case when purchase = 1 then 1 else 0 end) + sum(case when purchase = 0 then 1 else 0 end)) as percent_of_purchases
from visit_id_records
where impression > 0 and campaign_name is not NULL;

select 100.0*sum(case when purchase = 1 then 1 else 0 end)/(sum(case when purchase = 1 then 1 else 0 end) + sum(case when purchase = 0 then 1 else 0 end)) as percent_of_purchases
from visit_id_records
where impression = 0 and campaign_name is not NULL;

with cte as
(
  select visit_id, page_id, page_view_time
  from
  (
    select visit_id, page_id, ei.event_name, lead(e.event_type) over(partition by visit_id order by sequence_number) as next_event, lead(event_time) over(partition by visit_id order by sequence_number)- event_time as page_view_time
    from events as e
    join event_identifier as ei
    on e.event_type = ei.event_type
  ) as x
  where event_name = 'Page View' and next_event = 2
),

cte2 as
(
  select avg(page_view_time) as avg_page_view_time_for_purchasers
  from cte
  where visit_id in
  (
    select visit_id 
    from visit_id_records
    where purchase = 1
  )
)

select (select avg_page_view_time_for_purchasers from cte2) as avg_page_view_time_for_purchasers, avg(page_view_time) as avg_page_view_time_for_non_purchasers
from cte
where visit_id in
(
  select visit_id 
  from visit_id_records
  where purchase = 0
);

-- checking the no. of impressions during campaign and during non-camapign days

select sum(case when campaign_name is not null then impression else 0 end) as no_of_impessions_during_capaign, sum(case when campaign_name is null then impression else 0 end) as no_of_impressions_off_campaign
from visit_id_records;
