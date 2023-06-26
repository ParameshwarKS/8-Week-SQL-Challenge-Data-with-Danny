-- Setting the path towards the schema

set search_path = foodie_fi;

-- Question A
-- Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

select *
from subscriptions 
where customer_id in (1,2,11,13,15,16,18,19)
order by customer_id;

-- customer 1 has started the trial on 2020-08-01 and decided to take the subscription of basic monthly plan on 2020-08-08 which has been continued till date. 

-- customer 2 has started the trial on 2020-09-20 and chose to continue with the subscription of pro annual plan on 2020-09-27 that is being continued till date.

-- customer 11 has tried the trail for a week from 2020-11-19 to 2020-11-26 and chose to discontinue with the application on 2020-11-26.

-- customer 13 has started the trial on 2020-12-15 and chose the basic monthly plan after the trial period i.e. on 2020-12-22 which has been continued upto 2021-03-29 (97 days) and then finally chose to switch to the pro monthly plan on 2021-03-29 which has been continued till date.

-- customer 15 has started the trial on 2020-03-17 and was by default added into the pro monthly plan on 2020-03-24 that has been continued upto 2020-04-29 (36 days) and has finally churned on 2020-04-29.

-- customer 16 has started the trial on 2020-05-31 and chose the basic monthly plan on 2020-06-07 that has continued upto 2020-10-21 (136 days) and then finally chose to switch to the pro annual plan on 2020-07-13 which has been continued till date.

-- customer 18 has started the trial on 2020-07-06 and was by default added into the pro monthly plan on 2020-07-13 that is still being continued till date.

-- customer 19 has started the trial on 2020-06-29 and was moved to pro monthly plan plan on 2020-06-29 that has been continued upto 2020-08-29 (61 days) and then finally switched to the pro annual plan which is been continued till date.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Question B 
---Data Analysis Questions

---1) How many customers has Foodie-Fi ever had?

select count(distinct customer_id)
from subscriptions;


---2) What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

with cte as 
(
    select count(*) as c
    from subscriptions
    where plan_id=0
)

select extract(month from start_date) as month, (1.0*count(*))/(select c from cte)*100 as no_of_trails
from subscriptions
where plan_id=0
group by extract(month from start_date);


---3) What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select plan_id, count(*) as count
from subscriptions
where extract(year from start_date)>2020
group by plan_id
order by 1;


---4) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with cte as (select count(distinct customer_id) as c
from subscriptions)

select round(100.0*count(distinct customer_id)/(select c from cte),1) as percentage_of_churns
from subscriptions
where plan_id=4;


---5) How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

select round(100.0*count(distinct customer_id)/(select count(distinct customer_id) from subscriptions),2) as c
from
(
    select customer_id, plan_id, rank() over(partition by customer_id order by start_date) as r
    from subscriptions
    where customer_id in
     (
         select distinct customer_id
         from subscriptions
         where plan_id=0
      )
) as t
where r=2 and plan_id=4;


---6) What is the number and percentage of customer plans after their initial free trial?

select count(customer_id) as no_of_customers, round(100.0*count(customer_id)/(select count(distinct customer_id) from subscriptions),2) as percentage, plan_id
from
(
    select customer_id, plan_id, rank() over(partition by customer_id order by 		start_date) as r
	  from subscriptions
 ) as t
 where r=2
 group by plan_id;


---7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with cte as
(                                    
    select plan_id, count(customer_id) as no_of_customers
    from
    (
        select customer_id, plan_id, start_date, lead(start_date) over(partition by customer_id order by start_date) as next_date
        from subscriptions
    ) as t
    where ((start_date<='2020-12-31' and next_date>'2020-12-31') or (start_date<='2020-12-31' and next_date is NULL))
    group by plan_id
)

select plan_id, no_of_customers, round(100.0*no_of_customers/(select sum(no_of_customers) from cte),2) as percentage
from cte; 


---8) How many customers have upgraded to an annual plan in 2020?

select count(distinct customer_id) as no_of_annual_subscribers_in_2020
from subscriptions
where extract(year from start_date)=2020 and plan_id=3;	


---9) How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with cte as 
(
    select customer_id, start_date
    from subscriptions
    where plan_id=3
)

select avg(cte.start_date - t.start_date) as avg_days_to_switch_to_annual
from subscriptions as t
join cte
on cte.customer_id=t.customer_id and t.plan_id=0;


---10) Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

with recursive cte3 as
(
    select 0 as days
    union
    select days+30
    from cte3
    where (days-30) <=
    (
      select max(difference) 
      from 
      (
          select cte1.customer_id, (cte1.start_date - t.start_date) as difference
          from subscriptions as t
          join 
          (
              select customer_id, start_date
              from subscriptions
              where plan_id=3
          ) as cte1
          on cte1.customer_id=t.customer_id and t.plan_id=0
      ) as x
    )
),
  
cte1 as 
(
    select customer_id, start_date
    from subscriptions
    where plan_id=3
),

cte2 as 
(
    select cte1.customer_id, (cte1.start_date - t.start_date) as difference
    from subscriptions as t
    join 
    (
        select customer_id, start_date
        from subscriptions
        where plan_id=3
    ) as cte1
    on cte1.customer_id=t.customer_id and t.plan_id=0
)

select count(distinct customer_id) as count_of_subscribers_to_switch , concat(days::varchar,'-',(days+30)::varchar) as "days_period" 
from cte2
join cte3
on cte2.difference>cte3.days and cte2.difference<=cte3.days+30
group by days;


---11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with cte as 
(
    select customer_id, start_date
    from subscriptions
    where plan_id=2
)

select count(distinct t.customer_id) as no_of_down_graders
from subscriptions as t
join cte
on t.customer_id = cte.customer_id and t.plan_id=1 and t.start_date>cte.start_date
where extract(year from t.start_date)=2020;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Question C
--- Challenge Payment Question

-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
-- once a customer churns they will no longer make payments


with recursive cte as
(
    (
        select customer_id, plan_id, start_date::timestamp, (Lead(start_date,1,'2020-12-31') over(partition by customer_id order by start_date))::timestamp as end_date
        from subscriptions
        where extract(year from start_date) = 2020 and plan_id!=0
        order by customer_id
    )
    Union all
    (
        select customer_id, plan_id, 
        case 
        when plan_id=1 or plan_id=2 then (start_date+Interval '1 month')
        else (start_date+Interval '1 year') 
        end as start_date, end_date
        from cte
        where start_date+Interval '1 month' <end_date and extract(year from start_date)=2020
    )
),
 
 x as 
 (
    select cte.customer_id, cte.start_date, cte.plan_id, p.price, p.plan_name, lag(cte.plan_id,1,cte.plan_id) over(partition by customer_id order by start_date) as prev_plan 
    from cte
    join plans as p
    on p.plan_id = cte.plan_id
    where extract(year from start_date) = 2020
    order by customer_id, start_date
 )
 
 select customer_id, plan_id, plan_name, start_date as payment_date, 
 case 
 when (Lag(plan_id,1,plan_id) over(partition by customer_id order by start_date)=plan_id) or ((Lag(plan_id,1,plan_id) over(partition by customer_id order by start_date)!=plan_id) and extract(month from Lag(start_date,1,start_date) over(partition by customer_id order by start_date))!=extract(month from start_date)) then price
 else price-lag(price,1) over(partition by customer_id order by start_date)
 end as amount, rank() over(partition by customer_id order by start_date) as payment_order
 from x
 where plan_id!=4;

