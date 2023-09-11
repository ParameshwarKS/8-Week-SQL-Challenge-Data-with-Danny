set search_path = balanced_tree;

--1)

select sum(qty) as total_qunatity
from sales;

--2)

select sum(qty*price) as total_revenue_before_discount
from sales;

--3)

select sum(discount) as total_discount
from
(
  select txn_id, sum(qty*price)*avg(discount)/100 as discount
  from sales
  group by 1
) as t;

--1)

select count(distinct txn_id) as total_txns
from sales;

--2)

select avg(no_of_products) as avg_no_of_products
from
(
  select txn_id, count(distinct prod_id) as no_of_products
  from sales
  group by 1
) as t;

--3)

select percentile_cont(0.25) within group (order by revenue asc) as percentile_25, percentile_cont(0.50) within group (order by revenue asc) as percentile_50, percentile_cont(0.75) within group (order by revenue asc) as percentile_75
from
(
  select txn_id, sum(qty*price)*(100-avg(discount))/100 as revenue
  from sales
  group by txn_id
) as t;

--4)

select avg(0.01*discount*revenue) as avg_discount
from
(
  select txn_id, discount, sum(qty*price) as revenue
  from sales
  group by 1,2
) as t;

--5)

select member, count(distinct txn_id) as total_transactions
from sales
group by 1;

--6)

select member, avg(revenue) as avg_revenue
from
(
  select member, txn_id, (100 - avg(discount))*sum(qty*price)/100 as revenue
  from sales
  group by 1,2
) as t
group by 1;


--1)

select product_name, sum(qty*s.price) as total_revenue_before_discount
from sales as s
join product_details as p
on s.prod_id = p.product_id
group by 1
order by 2 desc
limit 3;

--2)

select segment_name, sum(qty) as total_quantity, sum(qty*s.price) as total_revenue, sum(qty*s.price*discount/100) as discount 
from sales as s
join product_details as p
on s.prod_id = p.product_id
group by 1;
  
--3)

select segment_name, product_name, qty
from
(
  select segment_name, product_name, sum(qty) as qty, rank() over(partition by segment_name order by sum(qty) desc) as r
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1,2
  order by 1,3 desc
) as t
where r = 1;

--4)

select category_name, sum(qty) as total_quantity, sum(qty*s.price) as total_revenue, sum(qty*s.price*discount/100) as discount 
from sales as s
join product_details as p
on s.prod_id = p.product_id
group by 1;

--5)

select category_name, product_name, qty
from
(
  select category_name, product_name, sum(qty) as qty, rank() over(partition by category_name order by sum(qty) desc) as r
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1,2
  order by 1,3 desc
) as t
where r = 1;

--6)

with cte as
(
  select segment_name, product_name, sum(qty*s.price)-sum(qty*s.price*discount/100) as revenue_with_discount 
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1,2
),

cte2 as
(
  select segment_name, sum(revenue_with_discount) as total_revenue
  from cte
  group by 1
)

select cte.segment_name, product_name, round(100*revenue_with_discount/cte2.total_revenue,2) as percent_of_split
from cte
join cte2
on cte.segment_name = cte2.segment_name
order by 1,3 desc;

--7)

with cte as
(
  select category_name, segment_name, sum(qty*s.price)-sum(qty*s.price*discount/100) as revenue_with_discount 
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1,2
),

cte2 as
(
  select category_name, sum(revenue_with_discount) as total_revenue
  from cte
  group by 1
)

select cte.category_name, segment_name, round(100*revenue_with_discount/cte2.total_revenue,2) as percent_of_split
from cte
join cte2
on cte.category_name = cte2.category_name
order by 1,3 desc;

--8)

with cte as
(
  select category_name, sum(qty*s.price)-sum(qty*s.price*discount/100) as revenue_with_discount 
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1
)

select category_name, 100*revenue_with_discount/(select sum(revenue_with_discount) from cte) as percent_of_split
from cte;

with cte as
(
  select count(distinct txn_id) as tot_txns
  from sales
)

select product_name, 1.0*count(distinct txn_id)/(select tot_txns from cte) as penetration
from sales as s
join product_details as p
on s.prod_id = p.product_id
group by 1;

--10)

with cte1 as
(
  select
  case
  when prod1<prod2 and prod1<prod3 then prod1
  when prod2<prod1 and prod2<prod3 then prod2
  else prod3
  end as prod1,
  case
  when (prod2<prod1 and prod1<prod3) or (prod3<prod1 and prod1<prod2) then prod1
  when (prod1<prod2 and prod2<prod3) or (prod3<prod2 and prod2<prod1) then prod2
  when (prod1<prod3 and prod3<prod2) or (prod2<prod3 and prod3<prod1) then prod3
  end as prod2,
  case
  when prod1>prod2 and prod1>prod3 then prod1
  when prod2>prod1 and prod2>prod3 then prod2
  else prod3
  end as prod3
  from
  (
    select s1.product_name as prod1, s2.product_name as prod2, s3.product_name as prod3
    from product_details as s1
    join product_details as s2
    on s1.product_id <> s2.product_id
    join product_details as s3
    on s3.product_id <> s1.product_id and s3.product_id <> s2.product_id
  ) as t
  group by 1,2,3
),

cte2 as
(
  select txn_id, string_agg(product_name, ', ' order by product_name) as product_purchased
  from sales as s
  join product_details as p
  on s.prod_id = p.product_id
  group by 1
)

select prod1, prod2, prod3, count(distinct txn_id) as no_of_purchases
from
(
  select txn_id, prod1, prod2, prod3, product_purchased
  from cte1
  join cte2
  on position(prod1 in product_purchased)>0 and position(prod2 in product_purchased)>0 and position(prod3 in product_purchased)>0
) as t
group by 1,2,3
order by 4 desc
limit 1;

select m, revenue_of_this_month, lag(revenue_of_this_month) over(order by m) previous_month_revenue
from
(
  select y,m,sum(amount) as revenue_of_this_month
  from
  (
    select y, m, txn_id, ceil(sum(amount)-avg(discount)) as amount
    from
    (
      select extract('year' from start_txn_time) as y, extract('month' from start_txn_time) as m, txn_id, price*qty as amount, discount
      from sales
    ) as t
    group by 1,2,3
  ) as x
  group by 1,2
) as y;
