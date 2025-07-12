
<p align="center">
  <img width="512" height="512" alt="image" src="https://github.com/user-attachments/assets/0e2b61c1-9497-4efc-a75c-05381a886ad0" />
</p>
<h2>📌 Introduction</h2>

<h3>📊 Fresh Segments – Digital Interest Metrics Analysis</h3>

<p>
Fresh Segments is a digital marketing agency founded by Danny, focused on helping businesses analyze trends in online ad click behavior for their customer base.
</p>

<p>
Clients provide their customer lists to the Fresh Segments team, who then aggregate interest-based metrics and deliver a consolidated dataset for further analysis.
</p>

<p>
For each client, the dataset includes the composition and ranking of various interests, reflecting the proportion of customers who interacted with online assets tied to those interests across different months.
</p>

<p>
Danny has requested your support in analyzing this example client's aggregated interest metrics and generating high-level insights about their customer preferences and engagement trends.
</p>


<h2>🧩 Problem Statement</h2>

Danny, with prior experience as a data scientist, understood the importance of data collection in driving business growth. To support this, he designed a relational database and created an Entity Relationship Diagram (ERD) to structure and manage the data effectively.

While the initial database design is in place, he now requires assistance with:

- Data cleaning and transformation

- Basic analytical calculations

- Operational performance analysis


<h2>📚 Case Study Questions – Fresh Segments</h2>

<p>This case study explores customer interest metrics collected and aggregated by Fresh Segments. The questions below span data cleaning, interest behavior analysis, segment profiling, and index analysis to help uncover customer insights.</p>

<h3>🧼 Data Exploration and Cleansing</h3>
<ol>
  <li>Update the <code>month_year</code> column in <code>fresh_segments.interest_metrics</code> to a DATE format (start of the month).</li>
  <li>Count records for each <code>month_year</code> (nulls first), sorted chronologically.</li>
  <li>How should null <code>month_year</code> values be handled?</li>
  <li>How many <code>interest_id</code> values exist in <code>interest_metrics</code> but not in <code>interest_map</code>? What about the reverse?</li>
  <li>Summarize the <code>id</code> values in <code>interest_map</code> by total record count.</li>
  <li>What kind of JOIN should be used for analysis? Validate using <code>interest_id = 21246</code> and include all fields from <code>interest_metrics</code> and all except <code>id</code> from <code>interest_map</code>.</li>
  <li>Are there rows where <code>month_year</code> is before <code>created_at</code> from <code>interest_map</code>? Are they valid?</li>
</ol>

<h3>📈 Interest Analysis</h3>
<ol>
  <li>Which interests are present in <strong>all</strong> <code>month_year</code> periods?</li>
  <li>Using the <code>total_months</code> per interest, calculate cumulative percentage of total records. Which <code>total_months</code> value crosses 90%?</li>
  <li>If interests below that threshold are removed, how many data points are removed?</li>
  <li>Is it valid to remove interests with fewer months? Use an example of a 14-month interest and one that gets removed.</li>
  <li>After filtering, how many unique interests remain for each month?</li>
</ol>

<h3>👥 Segment Analysis</h3>
<ol>
  <li>For interests with ≥6 months of data, find the top 10 and bottom 10 interests by <code>max(composition)</code> with associated <code>month_year</code>.</li>
  <li>Which 5 interests have the lowest <strong>average ranking</strong>?</li>
  <li>Which 5 interests have the highest <strong>standard deviation</strong> in <code>percentile_ranking</code>?</li>
  <li>For those 5, report min and max <code>percentile_ranking</code> with their respective <code>month_year</code>. Describe the behavior.</li>
  <li>How would you describe the segment’s interests? What products/services would resonate or should be avoided?</li>
</ol>

<h3>📊 Index Analysis</h3>
<p>The <code>index_value</code> can reverse-calculate the average composition:</p>
<pre><code>average_composition = composition / index_value (rounded to 2 decimal places)</code></pre>

<ol>
  <li>What are the top 10 interests by average composition per month?</li>
  <li>Which interest appears most frequently among those top 10?</li>
  <li>What is the average of the monthly top-10 average compositions?</li>
  <li>Calculate a 3-month rolling average of <strong>max average composition</strong> from <strong>Sep 2018 to Aug 2019</strong>.</li>
  <li>What could cause fluctuations in <code>max average composition</code> from month to month? Could this indicate a flaw in the business model?</li>
</ol>

