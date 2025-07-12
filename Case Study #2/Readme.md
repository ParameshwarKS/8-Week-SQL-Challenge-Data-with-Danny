<p align="center">
  <img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/c11f4cc4-84d3-4c98-8c69-66d178d4ac90" />
</p>
<h2>📌 Introduction</h2>

<p>
Pizza Runner is a data case study designed to practice SQL and analytical thinking using a simplified pizza delivery business scenario.
The project involves analyzing order and delivery data to extract insights related to customer behavior, delivery performance, and operational efficiency.
</p>

<p>
To better understand his customers and improve business performance, Danny has collected some basic operational data. This repository explores that data to extract insights and help Danny make data-driven decisions to grow his restaurant.
</p>

<h2>🧩 Problem Statement</h2>

Danny, with prior experience as a data scientist, understood the importance of data collection in driving business growth. To support this, he designed a relational database and created an Entity Relationship Diagram (ERD) to structure and manage the data effectively.

While the initial database design is in place, he now requires assistance with:

- Data cleaning and transformation

- Basic analytical calculations

- Operational performance analysis

These steps will help him better direct his delivery runners and optimize overall operations at Pizza Runner.

💡 Note: All datasets are stored within the pizza_runner database schema. Please ensure to reference this schema in your SQL scripts when exploring and querying the data.
</p>
<p>
Below is the entity relationship diagram for the data provided:
</p>
<img width="723" height="375" alt="image" src="https://github.com/user-attachments/assets/7c6885f8-5d2d-4987-a2db-7718380c66ba" />
</p>

<h2>📚 Case Study Questions</h2>

<p>All questions are based on the <code>pizza_runner</code> schema. Be sure to reference the schema in your SQL queries (e.g., <code>SELECT * FROM pizza_runner.customer_orders;</code>).</p>

<h3>A. 🍕 Pizza Metrics</h3>

<ol>
  <li>How many pizzas were ordered?</li>
  <li>How many unique customer orders were made?</li>
  <li>How many successful orders were delivered by each runner?</li>
  <li>How many of each type of pizza was delivered?</li>
  <li>How many Vegetarian and Meatlovers were ordered by each customer?</li>
  <li>What was the maximum number of pizzas delivered in a single order?</li>
  <li>For each customer, how many delivered pizzas had at least 1 change and how many had no changes?</li>
  <li>How many pizzas were delivered that had both exclusions and extras?</li>
  <li>What was the total volume of pizzas ordered for each hour of the day?</li>
  <li>What was the volume of orders for each day of the week?</li>
</ol>

<h3>B. 🧑‍💼 Runner and Customer Experience</h3>

<ol>
  <li>How many runners signed up for each 1-week period? (Week starts on 2021-01-01)</li>
  <li>What was the average time (in minutes) it took each runner to arrive at Pizza Runner HQ to pick up the order?</li>
  <li>Is there any relationship between the number of pizzas and how long the order takes to prepare?</li>
  <li>What was the average distance traveled for each customer?</li>
  <li>What was the difference between the longest and shortest delivery times for all orders?</li>
  <li>What was the average speed for each runner for each delivery? Do you notice any trends?</li>
  <li>What is the successful delivery percentage for each runner?</li>
</ol>

<h3>C. 🧂 Ingredient Optimisation</h3>

<ol>
  <li>What are the standard ingredients for each pizza?</li>
  <li>What was the most commonly added extra?</li>
  <li>What was the most common exclusion?</li>
  <li>Generate an order item description for each record in the <code>customer_orders</code> table:<br/>
    e.g. <code>Meat Lovers - Exclude Beef</code>, <code>Vegetarian - Extra Cheese</code>
  </li>
  <li>Generate an alphabetically ordered, comma-separated ingredient list for each pizza order (use <code>2x</code> prefix for duplicates).<br/>
    Example: <code>Meat Lovers: 2xBacon, Beef, Salami</code>
  </li>
  <li>What is the total quantity of each ingredient used in all delivered pizzas, sorted by most frequent first?</li>
</ol>

<h3>D. 💰 Pricing and Ratings</h3>

<ol>
  <li>If Meat Lovers = $12, Vegetarian = $10, with no change or delivery charges, how much revenue was made?</li>
  <li>What if each pizza extra adds $1 to the price?</li>
  <li>Design a table schema for customer ratings (1–5) for successful deliveries. Insert sample data.</li>
  <li>Join the ratings with delivery data to produce a summary table with:<br/>
    <code>customer_id, order_id, runner_id, rating, order_time, pickup_time, time_diff, delivery_duration, average_speed, pizza_count</code>
  </li>
  <li>If runners are paid $0.30/km, calculate total profit after deducting runner payments from revenue.</li>
</ol>



