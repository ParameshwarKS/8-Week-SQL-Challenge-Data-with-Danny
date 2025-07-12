
<p align="center">
  <img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/34ee8f48-6e31-4230-b51e-b2a75eef744a" />
</p>
<h2>📌 Introduction</h2>

<p><strong>Neo-banks</strong> are an emerging innovation in the financial industry — digital-only banks with no physical branches, offering seamless online banking experiences.</p>

<p>Danny, inspired by this trend and the rise of cryptocurrency and data technologies, decided to launch a new venture: <strong>Data Bank</strong>.</p>

<p><strong>Data Bank</strong> operates like a modern digital bank, but with a unique twist — in addition to handling financial transactions, it provides a <strong>secure, distributed cloud data storage platform</strong>. Storage limits are directly tied to customer account balances, making it a fusion of banking and data services.</p>


<h2>🧩 Problem Statement</h2>

<p>The management team now wants to expand its customer base and improve forecasting for future infrastructure needs. They need help analyzing how much data storage customers will require based on current financial activity and trends.</p>

<p>This case study focuses on:</p>
<ul>
  <li>Calculating key banking and data usage metrics</li>
  <li>Analyzing customer growth and account activity</li>
  <li>Forecasting future data storage requirements</li>
  <li>Helping the business make data-driven decisions for scaling</li>
</ul>
<p>
Below is the entity relationship diagram for the data provided:
</p>
<img width="815" height="284" alt="image" src="https://github.com/user-attachments/assets/5d1b10ee-d01f-4ac9-8098-08e07913462c" />
</p>

<h2>📚 Case Study Questions</h2>

<p>
The following case study questions begin with general data exploration and analysis for nodes and transactions, followed by core business-related queries, and conclude with a challenging data allocation scenario.
</p>

<h3>A. 🧭 Customer Nodes Exploration</h3>

<ol>
  <li>How many unique nodes are there on the Data Bank system?</li>
  <li>What is the number of nodes per region?</li>
  <li>How many customers are allocated to each region?</li>
  <li>How many days on average are customers reallocated to a different node?</li>
  <li>What is the median, 80th, and 95th percentile for this same reallocation days metric for each region?</li>
</ol>

<h3>B. 💸 Customer Transactions</h3>

<ol>
  <li>What is the unique count and total amount for each transaction type?</li>
  <li>What is the average total historical deposit counts and amounts for all customers?</li>
  <li>
    For each month, how many Data Bank customers make more than 1 deposit
    <strong>and</strong> either 1 purchase <strong>or</strong> 1 withdrawal in a single month?
  </li>
  <li>What is the closing balance for each customer at the end of the month?</li>
  <li>What is the percentage of customers who increase their closing balance by more than 5%?</li>
</ol>

<h3>C. 🧠 Data Allocation Challenge</h3>

<p>
The Data Bank team wants to test three different methods of allocating cloud data storage to customers:
</p>

<ul>
  <li><strong>Option 1:</strong> Based on the account balance at the end of the previous month</li>
  <li><strong>Option 2:</strong> Based on the average balance over the previous 30 days</li>
  <li><strong>Option 3:</strong> Real-time balance tracking</li>
</ul>

<p>To support this analysis, generate the following data points:</p>

<ul>
  <li>Running balance per customer, reflecting the impact of each transaction</li>
  <li>Customer balance at the end of each month</li>
  <li>Minimum, average, and maximum values of the running balance for each customer</li>
</ul>

<p>
Using the above data, calculate how much cloud data storage would be required for each option on a monthly basis.
</p>
