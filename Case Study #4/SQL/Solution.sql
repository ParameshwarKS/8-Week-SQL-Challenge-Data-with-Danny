SET search_path = data_bank;

--1)

select count(distinct node_id) as no_of_unique_nodes
from customer_nodes;

--2)

select region_id, count(distinct node_id) as no_of_nodes
from customer_nodes
group by region_id;

--3)

select r.region_name, count(distinct customer_id)
from customer_nodes as c
join regions as r
on r.region_id = c.region_id
group by 1;

--4)

select ceil(avg(date_part('day',end_date::timestamp-start_date::timestamp))+1) as no_of_avg_days
from
(
select customer_id, region_id, node_id, min(start_date) as start_date, max(end_date) as end_date, rn
from
(
  select customer_id, region_id, node_id, start_date, end_date, row_number() over(partition by customer_id, region_id order by start_date) - row_number() over(partition by customer_id, region_id, node_id order by start_date) as rn
  from customer_nodes
  where extract(year from end_date) != 9999
) as t
group by 1,2,3,6
) as x;

--5)

select percentile_cont(0.5) within group (order by no_of_days asc) as median, percentile_cont(0.8) within group (order by no_of_days asc) as percentile_80,
percentile_cont(0.95) within group (order by no_of_days asc) as percentile_95
from
(
  select date_part('day',end_date::timestamp-start_date::timestamp)+1 as no_of_days
  from
  (
  select customer_id, region_id, node_id, min(start_date) as start_date, max(end_date) as end_date, rn
  from
  (
    select customer_id, region_id, node_id, start_date, end_date, row_number() over(partition by customer_id, region_id order by start_date) - row_number() over(partition by customer_id, region_id, node_id order by start_date) as rn
    from customer_nodes
    where extract(year from end_date) != 9999
  ) as t
  group by 1,2,3,6
  ) as x
) as y;

--part B

--1)

select txn_type, count(*) as no_of_txns
from
(
  select customer_id, txn_date, txn_type
  from Customer_transactions
  group by 1,2,3
) as t
group by 1;

--2)

select customer_id, count(*) as no_of_deposits, round(avg(txn_amount),2) as avg_amount
from customer_transactions
where txn_type = 'deposit'
group by 1;

--3)

select count(*) as no_of_req_customers
from
(
  select customer_id, sum(case when txn_type = 'deposit' then 1 else 0 end) as no_of_deposits, sum(case when txn_type = 'purchase' then 1 else 0 end) as no_of_purchases, sum(case when txn_type = 'withdrawal' then 1 else 0 end) as no_of_withdrawals
  from customer_transactions
  group by 1
) as t
where no_of_deposits>1 and (no_of_purchases>0 or no_of_withdrawals>0);

--4)

select customer_id, year, month, sum(txn_month) over(partition by customer_id order by month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as tot_amount
from
(
  select customer_id, extract(year from txn_date) as year, extract(month from txn_date) as month, sum(case when txn_type = 'deposit' then txn_amount else -1*txn_amount end) as txn_month
  from customer_transactions
  group by 1,2,3
  order by 1,2,3
) as t;

--5)

with cte1 as 
(
  select customer_id, year, month, sum(txn_month) over(partition by customer_id order by month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as tot_amount
  from
  (
    select customer_id, extract(year from txn_date) as year, extract(month from txn_date) as month, sum(case when txn_type = 'deposit' then txn_amount else -1*txn_amount end) as txn_month
    from customer_transactions
    group by 1,2,3
    order by 1,2,3
  ) as t
),

cte2 as
(
  select customer_id, min(month) as start_month, max(month) as end_month
  from cte1
  group by 1
)

select 100*count(*)/(select count(*) from cte2) as percent_of_customers
from
(
select t.customer_id, 100.0*(tot_amount - start_amount)/(start_amount) as percent_increase
from
(
  select cte1.customer_id, cte2.end_month, tot_amount as start_amount
  from cte1
  join cte2
  on (cte1.customer_id = cte2.customer_id) and (cte2.start_month = cte1.month)
) as t
join cte1
on t.customer_id = cte1.customer_id and t.end_month = cte1.month
) as x
where percent_increase>5; 

--Part C

--balance remaining at each transaction

select customer_id, txn_date, txn_type, txn_amount, sum(txn_amount) over(partition by customer_id order by txn_date rows between unbounded preceding and current row) as balance
from
(
  select customer_id, txn_date, txn_type,
  case
  when txn_type = 'withdrawal' or txn_type = 'purchase' then -1*txn_amount
  else txn_amount
  end as txn_amount
  from customer_transactions
) as t;

--balance at the end of each month

with recursive cte as
(
  select 1 as month
  union all
  select month+1 as month
  from cte
  where month<12
),

cte2 as 
(
select customer_id, cte.month
from customer_transactions
cross join cte
group by 1,2
)

select customer_id, month, sum(txn_month) over(partition by customer_id order by month rows between unbounded preceding and current row) as monthly_balance 
from
(
  select customer_id, month, sum(txn_amount) as txn_month
  from
  (
    select cte2.customer_id, txn_date, txn_type, cte2.month,
    case
    when txn_type = 'withdrawal' or txn_type = 'purchase' then -1*txn_amount
    when txn_type is NULL then 0
    else txn_amount
    end as txn_amount
    from customer_transactions as c
    right join cte2
    on extract(month from txn_date) = cte2.month and cte2.customer_id = c.customer_id 
    order by 1,2,4
  ) as t
  group by 1,2
) as y;

-- min, max and avg of each customer 

select customer_id, min(balance) as min_balance, max(balance) as max_balance, avg(balance) as avg_balance
from
(
  select customer_id, txn_date, txn_type, txn_amount, sum(txn_amount) over(partition by customer_id order by txn_date rows between unbounded preceding and current row) as balance
  from
  (
    select customer_id, txn_date, txn_type,
    case
    when txn_type = 'withdrawal' or txn_type = 'purchase' then -1*txn_amount
    else txn_amount
    end as txn_amount
    from customer_transactions
  ) as t
) as x
group by customer_id;
