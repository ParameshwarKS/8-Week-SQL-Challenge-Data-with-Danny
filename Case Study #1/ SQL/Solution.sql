
SET search_path = dannys_diner;

-- 1)
select customer_id, sum(price) as total_spendings
from sales as s
join menu as m
on s.product_id = m.product_id
group by customer_id
order by 1;

-- 2)

select customer_id, count(distinct order_date) as number_of_visits
from sales
group by customer_id
order by 1;

--3)

select customer_id, product_name
from 
(
  select customer_id, product_name, rank() over(partition by customer_id order by order_date) as rk 
  from sales as s
  join menu as m
  on m.product_id = s.product_id
) as x
 where rk=1;

--4)

select product_name, count(*) as no_of_purchases
from sales as s
join menu as m
on s.product_id = m.product_id
group by product_name
order by 2 desc;

--5)

select customer_id, product_name
from 
(
  select s.customer_id, m.product_name, count(*) as no_of_purchases, rank() over(partition by s.customer_id order by count(*) desc) as r
  from sales as s
  join menu as m
  on s.product_id = m.product_id
  group by s.customer_id, m.product_name
  order by 1,2
) as t
where r=1;

--6)

select t.customer_id, menu.product_name as first_order_name
from 
(
  select s.customer_id, s.product_id, s.order_date, dense_rank() over(partition by s.customer_id order by s.order_date) as rk
  from sales as s
  join members as m
  on s.customer_id = m.customer_id and s.order_date>=m.join_date
) as t join
menu
on menu.product_id=t.product_id
where rk=1
order by 1;

--7)

select t.customer_id, menu.product_name as order_just_before_becoming_member
from 
(
	select s.customer_id, s.product_id, s.order_date, dense_rank() over(partition by s.customer_id order by s.order_date desc) as rk
	from sales as s
	join members as m
	on s.customer_id = m.customer_id and s.order_date<m.join_date
) as t join
menu
on menu.product_id=t.product_id
where rk=1
order by 1;

--8)

select customer_id, sum(price) as total_spending_before_joining
from
(
  select s.customer_id, s.product_id, s.order_date, menu.price
  from sales s
  left join members m
  on s.customer_id = m.customer_id 
  join menu
  on menu.product_id = s.product_id
  where s.order_date<m.join_date or m.join_date is NULL
) as t
group by customer_id
order by 1;

--9)

with cte as 
(
  select product_id, product_name,
  case
  when product_name = 'sushi' then 20*price
  else 10*price
  end as points
  from menu
)

select customer_id, sum(points) as total_points
from sales as s
join cte
on cte.product_id = s.product_id
group by customer_id
order by 1;

--10)

select customer_id, sum(points) as total_points
from
(
	select s.customer_id,
  case 
  when s.order_date >= j.join_date and s.order_date <= j.join_date+7 then 20*m.price
  else 10*m.price
  end as points
  from sales as s
  left join members as j
  on s.customer_id = j.customer_id join
  menu as m
  on m.product_id = s.product_id
) as t
group by 1;


Bonus Questions:

select s.customer_id, s.order_date, m.product_name, m.price, 
case
when order_date>=j.join_date then 'Y'
else 'N'
end as member
from sales as s
left join members as j
on s.customer_id = j.customer_id
join menu as m
on s.product_id = m.product_id
order by 1,2;



(select s.customer_id, s.order_date, m.product_name, m.price, 'Y' as member, rank() over(partition by s.customer_id order by s.order_date) as rank
from sales as s
join members as j
on s.customer_id = j.customer_id
join menu as m
on s.product_id = m.product_id
where s.order_date>=j.join_date)
union all
(select s.customer_id, s.order_date, m.product_name, m.price, 'N' as member, NULL as rank
from sales as s
left join members as j
on s.customer_id = j.customer_id
join menu as m
on s.product_id = m.product_id
where s.order_date<j.join_date or j.join_date is NULL)
order by 1,2;

