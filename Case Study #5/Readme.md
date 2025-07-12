
<p align="center">
  <img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/18134133-95ba-4478-9195-6dad63557241" />
</p>
<h2>📌 Introduction</h2>

<h3>🛒 Data Mart – Sales & Sustainability Analytics</h3>

<p>
Data Mart is Danny’s latest venture — an international online supermarket that specializes in fresh produce. After scaling up operations globally, Danny is now seeking analytical support to review and improve sales performance.
</p>

<p>
In <strong>June 2020</strong>, significant supply chain changes were implemented at Data Mart. From that point forward, all products have adopted <strong>sustainable packaging</strong> practices at every stage — from farm to customer delivery.
</p>

<p>
This case study focuses on evaluating sales data, identifying performance trends, and understanding the impact of the company’s sustainability-driven operational shift.
</p>


<h2>📈 Problem Statement</h2>

<p>
In June 2020, Data Mart implemented a major operational change by adopting sustainable packaging across its entire supply chain. Danny now wants to understand the <strong>impact of this change on sales performance</strong> across the business.
</p>

<p>
Your task is to support Data Mart in quantifying the effects of this change and to provide insights that will guide future sustainability initiatives.
</p>

<p><strong>Key business questions:</strong></p>

<ul>
  <li>What was the quantifiable impact of the changes introduced in June 2020?</li>
  <li>Which <strong>platforms</strong>, <strong>regions</strong>, <strong>segments</strong>, and <strong>customer types</strong> were most affected by the change?</li>
  <li>What strategies can be implemented to <strong>minimize the negative impact on sales</strong> during future sustainability-related transitions?</li>
</ul>

<p>
Below is the entity relationship diagram for the data provided:
</p>
<img width="452" height="356" alt="image" src="https://github.com/user-attachments/assets/31494d79-2568-4fce-95dd-4314a31a16d2" />
</p>

<h2>📚 Case Study Questions</h2>

<p>
This case study explores the impact of sustainability changes at Data Mart through a series of data cleansing, exploration, and comparative analysis steps.
</p>

<h3>1️⃣ Data Cleansing Steps</h3>

<p>
Create a new table <code>data_mart.clean_weekly_sales</code> by performing the following transformations in a single SQL query:
</p>

<ul>
  <li>Convert <code>week_date</code> to DATE format</li>
  <li>Add a <code>week_number</code> column: e.g., Jan 1–7 → week 1, Jan 8–14 → week 2, etc.</li>
  <li>Add a <code>month_number</code> column for calendar month</li>
  <li>Add a <code>calendar_year</code> column (values: 2018, 2019, 2020)</li>
  <li>Add an <code>age_band</code> column based on <code>segment</code>:
    <ul>
      <li>1 → Young Adults</li>
      <li>2 → Middle Aged</li>
      <li>3 or 4 → Retirees</li>
    </ul>
  </li>
  <li>Add a <code>demographic</code> column based on first letter in <code>segment</code>:
    <ul>
      <li>C → Couples</li>
      <li>F → Families</li>
    </ul>
  </li>
  <li>Replace any null or empty strings with <code>'unknown'</code> in <code>segment</code>, <code>age_band</code>, and <code>demographic</code></li>
  <li>Add a new column <code>avg_transaction</code> = <code>sales / transactions</code>, rounded to 2 decimal places</li>
</ul>

<h3>2️⃣ Data Exploration</h3>

<ol>
  <li>What day of the week is used for each <code>week_date</code> value?</li>
  <li>What range of <code>week_number</code> values are missing from the dataset?</li>
  <li>How many total transactions were recorded for each year?</li>
  <li>What is the total sales for each region per month?</li>
  <li>What is the total count of transactions for each platform?</li>
  <li>What is the percentage of sales for Retail vs Shopify for each month?</li>
  <li>What is the percentage of sales by demographic for each year?</li>
  <li>Which <code>age_band</code> and <code>demographic</code> combinations contribute the most to Retail sales?</li>
  <li>Can the <code>avg_transaction</code> column be used to calculate average transaction size per year for Retail vs Shopify? If not, how should it be calculated?</li>
</ol>

<h3>3️⃣ Before & After Analysis</h3>

<p>
Use <strong>2020-06-15</strong> as the baseline week when sustainable packaging was introduced.
</p>

<p>
All <code>week_date</code> values on or after this date are considered the "after" period, and all prior dates are the "before" period.
</p>

<ol>
  <li>What are the total sales for the 4 weeks before and after 2020-06-15? What is the actual and percentage change?</li>
  <li>What about the entire 12 weeks before and after the change?</li>
  <li>How do the sales metrics for these two periods compare with the same periods in 2018 and 2019?</li>
</ol>




