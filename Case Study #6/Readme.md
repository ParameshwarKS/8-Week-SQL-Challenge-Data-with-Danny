
<p align="center">
 <img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/4017a7a4-b82f-4406-be9a-230175ab5500" />
</p>
<h2>📌 Introduction</h2>

<h3>🐟 Clique Bait – E-Commerce Funnel Analysis</h3>

<p>
Clique Bait is not your typical online seafood store. Its founder and CEO, Danny, brings a background in digital data analytics and is combining his expertise with a passion for the seafood industry.
</p>

<p>
This case study challenges you to support Danny's vision by analyzing the Clique Bait e-commerce dataset and developing creative, data-driven solutions.
</p>

<p>
Your primary focus will be on calculating <strong>funnel fallout rates</strong> — tracking customer activity throughout the online purchase process and identifying where and why potential sales may be dropping off.
</p>

<h2>🧩 Problem Statement</h2>

Danny, with prior experience as a data scientist, understood the importance of data collection in driving business growth. To support this, he designed a relational database and created an Entity Relationship Diagram (ERD) to structure and manage the data effectively.

While the initial database design is in place, he now requires assistance with:

- Data cleaning and transformation

- Basic analytical calculations

- Operational performance analysis

These steps will help him better direct his delivery runners and optimize overall operations at Pizza Runner.

</p>

<h2>📚 Case Study Questions</h2>

<p>
This case study focuses on user behavior analysis, product funnel performance, and digital marketing campaign evaluation for Clique Bait, an online seafood store with a strong data-driven vision.
</p>

<h3>2️⃣ Digital Analysis</h3>

<p>Using the available datasets, answer each question with a single SQL query:</p>

<ol>
  <li>How many users are there?</li>
  <li>How many cookies does each user have on average?</li>
  <li>What is the unique number of visits by all users per month?</li>
  <li>What is the number of events for each event type?</li>
  <li>What is the percentage of visits which have a purchase event?</li>
  <li>What is the percentage of visits which view the checkout page but do not have a purchase event?</li>
  <li>What are the top 3 pages by number of views?</li>
  <li>What is the number of views and cart adds for each product category?</li>
  <li>What are the top 3 products by number of purchases?</li>
</ol>

<h3>3️⃣ Product Funnel Analysis</h3>

<p>
Using a single SQL query, create a new output table with the following metrics for each product:
</p>

<ul>
  <li>Number of times each product was viewed</li>
  <li>Number of times each product was added to cart</li>
  <li>Number of times each product was added to cart but not purchased (abandoned)</li>
  <li>Number of times each product was purchased</li>
</ul>

<p>Then, generate another aggregated output table with the same metrics grouped by <strong>product category</strong>.</p>

<p>Use these two tables to answer:</p>

<ol>
  <li>Which product had the most views, cart adds, and purchases?</li>
  <li>Which product was most likely to be abandoned?</li>
  <li>Which product had the highest view-to-purchase percentage?</li>
  <li>What is the average conversion rate from view to cart add?</li>
  <li>What is the average conversion rate from cart add to purchase?</li>
</ol>

<h3>4️⃣ Campaigns Analysis</h3>

<p>Create a table with one row per <code>visit_id</code> containing:</p>

<ul>
  <li><code>user_id</code></li>
  <li><code>visit_id</code></li>
  <li><code>visit_start_time</code>: earliest <code>event_time</code> per visit</li>
  <li><code>page_views</code>: count of page view events</li>
  <li><code>cart_adds</code>: count of cart add events</li>
  <li><code>purchase</code>: 1/0 flag for purchase event presence</li>
  <li><code>campaign_name</code>: mapped if <code>visit_start_time</code> falls between campaign <code>start_date</code> and <code>end_date</code></li>
  <li><code>impression</code>: count of ad impressions per visit</li>
  <li><code>click</code>: count of ad clicks per visit</li>
  <li><strong>(Optional)</strong> <code>cart_products</code>: comma-separated list of products added to cart sorted by <code>sequence_number</code></li>
</ul>

<h4>🧠 Analysis & Insights</h4>

<p>Use the above table to generate at least 5 insights for the Clique Bait team.</p>
<p><strong>Bonus:</strong> Design a 1-page A4 infographic for management reporting with your top insights.</p>

<p>Suggested areas of investigation:</p>

<ul>
  <li>Compare users who received campaign impressions vs. those who did not</li>
  <li>Does clicking on an impression lead to higher purchase rates?</li>
  <li>What is the uplift in purchase rate from:
    <ul>
      <li>Impression + click vs. no impression</li>
      <li>Impression + no click vs. no impression</li>
    </ul>
  </li>
  <li>What metrics can quantify the success or failure of each campaign?</li>
</ul>




