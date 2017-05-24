---
layout: default
title:  "Queries and Performance Tuning"
permalink: /queries-and-performance-tuning
---



<h2  class='inline-header'>Queries and Performance Tuning</h2>

<p>This lesson provides an overview of how Greenplum Database processes queries. Understanding this process can be useful when writing and tuning queries.</p>

<p>Users issue queries to Greenplum Database as they would to any database management system. They connect to the database instance on the Greenplum master host using a client application such as psql and submit SQL statements. </p>

<h4>
<a id="understanding-query-planning-and-dispatch" class="anchor" href="#understanding-query-planning-and-dispatch" aria-hidden="true"><span class="octicon octicon-link"></span></a>Understanding Query Planning and Dispatch</h4>

<p>The master receives, parses, and optimizes the query. The resulting query plan is either parallel or targeted. The master dispatches parallel query plans to all segments, as shown in Figure 1. Each segment is responsible for executing local database operations on its own set of data.query plans.</p>

<p>Most database operations—such as table scans, joins, aggregations, and sorts—execute across all segments in parallel. Each operation is performed on a segment database independent of the data stored in the other segment databases.</p>

<p>Figure 1. Dispatching the Parallel Query Plan<br>
<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/dispatch.jpg" width="400" alt="Dispatching the Parallel Query Plan"></p>

<h4>
<a id="understanding-greenplum-query-plans" class="anchor" href="#understanding-greenplum-query-plans" aria-hidden="true"><span class="octicon octicon-link"></span></a>Understanding Greenplum Query Plans</h4>

<p>A query plan is the set of operations Greenplum Database will perform to produce the answer to a query. Each node or step in the plan represents a database operation such as a table scan, join, aggregation, or sort. Plans are read and executed from bottom to top.</p>

<p>In addition to common database operations such as tables scans, joins, and so on, Greenplum Database has an additional operation type called motion. A motion operation involves moving tuples between the segments during query processing.</p>

<p>To achieve maximum parallelism during query execution, Greenplum divides the work of the query plan into slices. A slice is a portion of the plan that segments can work on independently. A query plan is sliced wherever a motion operation occurs in the plan, with one slice on each side of the motion.</p>

<h4>
<a id="understanding-parallel-query-execution" class="anchor" href="#understanding-parallel-query-execution" aria-hidden="true"><span class="octicon octicon-link"></span></a>Understanding Parallel Query Execution</h4>

<p>Greenplum creates a number of database processes to handle the work of a query. On the master, the query worker process is called the query dispatcher (QD). The QD is responsible for creating and dispatching the query plan. It also accumulates and presents the final results. On the segments, a query worker process is called a query executor (QE). A QE is responsible for completing its portion of work and communicating its intermediate results to the other worker processes.</p>

<p>There is at least one worker process assigned to each slice of the query plan. A worker process works on its assigned portion of the query plan independently. During query execution, each segment will have a number of processes working on the query in parallel.</p>

<p>Related processes that are working on the same slice of the query plan but on different segments are called gangs. As a portion of work is completed, tuples flow up the query plan from one gang of processes to the next. This inter-process communication between the segments is referred to as the interconnect component of Greenplum Database.  </p>

<p>This section introduces some of the basic principles of query and performance tuning in a Greenplum database.</p>

<p>Some items to consider in performance tuning:  </p>

<ul>
<li>
<strong>VACUUM and ANALYZE</strong> </li>
<li><strong>Explain plans</strong></li>
<li><strong>Indexing</strong></li>
<li><strong>Column or row orientation</strong></li>
<li><strong>Set based vs. row based</strong></li>
<li><strong>Distribution and partitioning</strong></li>
</ul>

<h3>
<a id="exercises-4" class="anchor" href="#exercises-4" aria-hidden="true"><span class="octicon octicon-link"></span></a>Exercises</h3>

<h4>
<a id="analyze-the-tables" class="anchor" href="#analyze-the-tables" aria-hidden="true"><span class="octicon octicon-link"></span></a>Analyze the tables</h4>

<p>Greenplum uses Multiversion Concurrency Control (MVCC) to guarantee isolation, one of the ACID properties of relational databases. MVCC enables multiple users of the database to obtain consistent results for a query, even if the data is changing as the query is being executed. There can be multiple versions of rows in the database, but a query sees a snapshot of the database at a single point in time, containing only the versions of rows that were valid at that point in time. When a row is updated or deleted and no active transactions continue to reference it, it can be removed. The VACUUM command removes older versions that are no longer needed, leaving free space that can be reused.
    In a Greenplum database, normal OLTP operations do not create the need for vacuuming out old rows, but loading data while tables are in use may. It is a best practice to VACUUM a table after a load. If the table is partitioned, and only a single partition is being altered, then a VACUUM on that partition may suffice.<br>
    The VACUUM FULL command behaves much differently than VACUUM, and its use is not recommended in Greenplum databases. It can be expensive in CPU and I/O, cause bloat in indexes, and lock data for long periods of time.
    The ANALYZE command generates statistics about the distribution of data in a table. In particular it stores histograms about the values in each of the columns. The query optimizer depends on these statistics to select the best plan for executing a query. For example, the optimizer can use distribution data to decide on join orders. One of the optimizer’s goals in a join is to minimize the volume of data that must be analyzed and potentially moved between segments by using the statistics to choose the smallest result set to work with first.</p>

<ol>
<li>
<p>Run the ANALYZE command on each of the tables:  </p>

<blockquote>
<p><code>$ psql -U gpadmin tutorial</code> </p>

<pre><code>```
tutorial=# ANALYZE faa.d_airports;
ANALYZE
tutorial=# ANALYZE faa.d_airlines;
ANALYZE
tutorial=# ANALYZE faa.d_wac;
ANALYZE
tutorial=# ANALYZE faa.d_cancellation_codes;
ANALYZE
tutorial=# ANALYZE faa.faa_otp_load;
ANALYZE
tutorial=# ANALYZE faa.otp_r;
ANALYZE
tutorial=# ANALYZE faa.otp_c;
ANALYZE
```
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="view-explain-plans" class="anchor" href="#view-explain-plans" aria-hidden="true"><span class="octicon octicon-link"></span></a>View explain plans</h4>

<p>An explain plan explains the method the optimizer has chosen to produce a result set.  Depending on the query, there can be a variety of methods to produce a result set. The optimizer calculates the cost for each method and chooses the one with the lowest cost. In large queries, cost is generally measured by the amount of I/O to be performed.</p>

<p>An explain plan does not do any actual query processing work. Explain plans use statistics generated by the ANALYZE command, so plans generated before and after running ANALYZE can be quite different. This is especially true for queries with multiple joins, because the order of the joins can have a tremendous impact on performance.</p>

<p>In the following exercise, you will generate some small tables that you can query and view some explain plans.</p>

<ol>
<li>
<p>Enable timing so that you can see the effects of different performance tuning measures.</p>

<blockquote>
<p><code>tutorial=# \timing on</code></p>
</blockquote>
</li>
<li>
<p>View the create_sample_table.sql script, and then run it.</p>

<blockquote>
<p><code>tutorial=# \i create_sample_table.sql</code></p>

<pre><code>DROP TABLE
Time: 15.901 ms
SET
Time: 3.174 ms
psql:create_sample_table.sql:3: NOTICE:  CREATE TABLE will create implicit
sequence "sample_id_seq" for serial column "sample.id"
CREATE TABLE
Time: 24.421 ms
INSERT 0 1000000
Time: 14624.516 ms
UPDATE 1000000
Time: 1241.156 ms
UPDATE 50000
Time: 190.210 ms
UPDATE 1000000
Time: 1111.454 ms
</code></pre>
</blockquote>
</li>
<li>
<p>Request the explain plan for the COUNT() aggregate.</p>

<blockquote>
<p><code>tutorial=#  EXPLAIN SELECT COUNT(*) FROM sample WHERE id &gt; 100;</code></p>

<pre><code>                               QUERY PLAN
---------------------------------------------------------------------------
Aggregate  (cost=0.00..462.77 rows=1 width=8)
 -&gt;  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..462.77
  rows=1 width=8)
   -&gt;  Aggregate  (cost=0.00..462.76 rows=1 width=8)
     -&gt;  Table Scan on sample  (cost=0.00..462.76 rows=500687 width=1)
              Filter: id &gt; 100
Settings:  optimizer=on
Optimizer status: PQO version 1.597
(7 rows)
</code></pre>
</blockquote>

<p>Query plans are read from bottom to top. In this example, there are four steps.  First there is a sequential scan on each segment server to access the rows. Then there is an aggregation on each segment server to produce a count of the number of rows from that segment. Then there is a gathering of the count value to a single location. Finally, the counts from each segment are aggregated to produce the final result.</p>

<p>The cost number on each step has a start and stop value. For the sequential scan, this begins at time zero and goes until 13863.80. This is a fictional number created by the optimizer—it is not a number of seconds or I/O operations.</p>

<p>The cost numbers are cumulative, so the cost for the second operation includes the cost for the first operation. Notice that nearly all the time to process this query is in the sequential scan.</p>
</li>
<li>
<p>The EXPLAIN ANALYZE command actually runs the query (without returning te result set). The cost numbers reflect the actual timings. It also produces some memory and I/O statistics.</p>

<blockquote>
<p><code>tutorial=# EXPLAIN ANALYZE SELECT COUNT(*) FROM sample WHERE id &gt; 100;</code></p>

<pre><code>                             QUERY PLAN
-----------------------------------------------------------------------------
 Aggregate  (cost=0.00..462.77 rows=1 width=8)
   Rows out:  1 rows with 446 ms to end, start offset by 7.846 ms.
   -&gt;  Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..462.77
rows=1 width=8)
         Rows out:  2 rows at destination with 443 ms to first row,
446 ms to end, start offset by 7.860 ms.
         -&gt;  Aggregate  (cost=0.00..462.76 rows=1 width=8)
               Rows out:  Avg 1.0 rows x 2 workers.  Max 1 rows (seg0)
with 442 ms to end, start offset by 9.000 ms.
               -&gt;  Table Scan on sample  (cost=0.00..462.76 rows=500687
width=1)
                     Filter: id &gt; 100
                     Rows out: Avg 499950.0 rows x 2 workers. Max 499951 rows
(seg0) with 88 ms to first row, 169 ms to end, start offset by 9.007 ms.
 Slice statistics:
   (slice0)    Executor memory: 159K bytes.
   (slice1)    Executor memory: 177K bytes avg x 2 workers, 177K bytes max (seg0).
 Statement statistics:
   Memory used: 128000K bytes
 Settings:  optimizer=on
 Optimizer status: PQO version 1.597
 Total runtime: 453.855 ms
(17 rows)
</code></pre>
</blockquote>
</li>
</ol>
<h4>Changing optimizers</h4>

<p>By default, the sandbox instance disables the Pivotal Query
Optimizer and you may see "legacy query optimizer" listed in the
EXPLAIN output under "Optimizer status."</p>

<ol>
<li><p>Check whether the Pivotal Query Optimizer is enabled.</p>

<blockquote><p><code>$ gpconfig -s optimizer</code></p>

<pre><code>Values on all segments are consistent
GUC          : optimizer
Master  value: off
Segment value: off
</code></pre></blockquote></li>
<li><p>Enable the Pivotal Query Optimizer</p>

<blockquote><p><code>$ gpconfig -c optimizer -v on --masteronly</code></p>

<pre><code> 20151201:09:08:31:172854 gpconfig:gpdb-sandbox:gpadmin-[INFO]:-completed successfully
</code></pre></blockquote></li>
<li><p>Reload the configuration on master and segment instances.</p>

<blockquote><p><code>$ gpstop -u</code></p>

<pre><code>20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Starting gpstop with args: -u
20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Gathering information and validating the environment...
20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Obtaining Segment details from master...
20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 4.3.12.0'
20151201:09:08:49:172949 gpstop:gpdb-sandbox:gpadmin-[INFO]:-Signalling all postmaster processes to reload
.
</code></pre></blockquote></li>
</ol>
<h4>
<a id="indexes-and-performance" class="anchor" href="#indexes-and-performance" aria-hidden="true"><span class="octicon octicon-link"></span></a>Indexes and performance</h4>

<p>Greenplum Database does not depend upon indexes to the same degree as conventional data warehouse systems. Because the segments execute table scans in parallel, each segment scanning a small segment of the table, the traditional performance advantage from indexes is diminished. Indexes consume large amounts of space and require considerable CPU time to compute during data loads. There are, however, times when indexes are useful, especially for highly selective queries. When a query looks up a single row, an index can dramatically improve performance.</p>

<p>In this exercise, you first run a single row lookup on the sample table without an index, then rerun the query after creating an index. </p>

<ol>
<li>
<p>Select a single row and note the time to execute the query.  </p>

<blockquote>
<p><code>tutorial=# SELECT * from sample WHERE big = 12345;</code></p>

<pre><code>  id   |  big  | wee | stuff
-------+-------+-----+-------
 12345 | 12345 |   0 |
(1 row)
Time: 197.640 ms
</code></pre>
</blockquote>
</li>
<li>
<p>View the explain plan for the previous query:  </p>

<blockquote>
<p><code>tutorial=# EXPLAIN SELECT * from sample WHERE big = 12345;</code>  </p>

<pre><code>                                  QUERY PLAN
-----------------------------------------------------------------------
Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..459.04
rows=2 width=12)
   -&gt;  Table Scan on sample  (cost=0.00..459.04 rows=1 width=12)
         Filter: big = 12345
 Settings:  optimizer=on
 Optimizer status: PQO version 1.597
(5 rows)
Time: 19.719 ms
</code></pre>
</blockquote>
</li>
<li>
<p>Create an index on the sample table.</p>

<blockquote>
<p><code>tutorial=# CREATE INDEX sample_big_index ON sample(big);</code></p>

<pre><code>CREATE INDEX
Time: 1106.467 ms
</code></pre>
</blockquote>
</li>
<li>
<p>View the explain plan for the single-row select query with the new index in place:</p>

<blockquote>
<p><code>tutorial=# EXPLAIN SELECT * FROM sample WHERE big = 12345;</code></p>

<pre><code>                              QUERY PLAN
--------------------------------------------------------------------------
 Gather Motion 2:1  (slice1; segments: 2)  (cost=0.00..3.00 rows=2
width=12)
   -&gt;  Index Scan using sample_big_index on sample  (cost=0.00..3.00
rows=1 width=12)
         Index Cond: big = 12345
 Settings:  optimizer=on
 Optimizer status: PQO version 1.597
(5 rows)
</code></pre>
</blockquote>

<p>Time: 23.674 ms</p>

<pre><code></code></pre>
</li>
<li>
<p>Run the single-row SELECT query with the index in place and note the time.</p>

<blockquote>
<p><code>tutorial=# SELECT * FROM sample WHERE big = 12345;</code></p>

<pre><code>  id   |  big  | wee | stuff
-------+-------+-----+-------
 12345 | 12345 |   0 |
(1 row)
Time: 29.421 ms
</code></pre>

<p>Notice the difference in timing between the single-row SELECT with and without the index. The difference would have been much greater for a larger table. Not that even when there is a index, the optimizer can choose not to use it if it calculates a more efficient plan.</p>
</blockquote>
</li>
<li>
<p>View the following explain plans to compare plans for some other common types
of queries.</p>

<blockquote>
<pre><code>tutorial=# EXPLAIN SELECT * FROM sample WHERE big = 12345;
tutorial=# EXPLAIN SELECT * FROM sample WHERE big &gt; 12345;
tutorial=# EXPLAIN SELECT * FROM sample WHERE big = 12345 OR big = 12355;
tutorial=# DROP INDEX sample_big_index;
tutorial=# EXPLAIN SELECT * FROM sample WHERE big = 12345 OR big = 12355;
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="row-vs-column-orientation" class="anchor" href="#row-vs-column-orientation" aria-hidden="true"><span class="octicon octicon-link"></span></a>Row vs. column orientation</h4>

<p>Greenplum Database offers the ability to store a table in either row or column orientation. Both storage options have advantages, depending upon data compression characteristics, the kinds of queries executed, the row length, and the complexity and number of join columns.</p>

<p>As a general rule, very wide tables are better stored in row orientation, especially if there are joins on many columns. Column orientation works well to save space with compression and to reduce I/O when there is much duplicated data in columns.</p>

<p>In this exercise, you will create a column-oriented version of the fact table and compare it with the row-oriented version.</p>

<ol>
<li>
<p>Create a column-oriented version of the FAA On Time Performance fact table and insert the data from the row-oriented version.</p>

<blockquote>
<pre><code>tutorial=# CREATE TABLE FAA.OTP_C (LIKE faa.otp_r) WITH (appendonly=true,
orientation=column)
DISTRIBUTED BY (UniqueCarrier, FlightNum) PARTITION BY RANGE(FlightDate)
( PARTITION mth START('2009-06-01'::date) END ('2010-10-31'::date)
EVERY ('1 mon'::interval));
</code></pre>

<pre><code>tutorial=# INSERT INTO faa.otp_c SELECT * FROM faa.otp_r;
</code></pre>
</blockquote>
</li>
<li>
<p>Compare the definitions of the row and the column versions of the table.</p>

<blockquote>
<p><code>tutorial=# \d faa.otp_r</code></p>

<pre><code>                  Table "faa.otp_r"
        Column        |       Type       | Modifiers
----------------------+------------------+-----------
 flt_year             | smallint         |
 flt_quarter          | smallint         |
 flt_month            | smallint         |
 flt_dayofmonth       | smallint         |
 flt_dayofweek        | smallint         |
 flightdate           | date             |
 uniquecarrier        | text             |
 airlineid            | integer          |
 carrier              | text             |
 flightnum            | text             |
 origin               | text             |
 origincityname       | text             |
 originstate          | text             |
 originstatename      | text             |
 dest                 | text             |
 destcityname         | text             |
 deststate            | text             |
 deststatename        | text             |
 crsdeptime           | text             |
 deptime              | integer          |
 depdelay             | double precision |
 depdelayminutes      | double precision |
 departuredelaygroups | smallint         |
 taxiout              | smallint         |
 wheelsoff            | text             |
 wheelson             | text             |
 taxiin               | smallint         |
 crsarrtime           | text             |
 arrtime              | text             |
 arrdelay             | double precision |
 arrdelayminutes      | double precision |
 arrivaldelaygroups   | smallint         |
 cancelled            | smallint         |
 cancellationcode     | text             |
 diverted             | smallint         |
 crselapsedtime       | integer          |
 actualelapsedtime    | double precision |
 airtime              | double precision |
 flights              | smallint         |
 distance             | double precision |
 distancegroup        | smallint         |
 carrierdelay         | smallint         |
 weatherdelay         | smallint         |
 nasdelay             | smallint         |
 securitydelay        | smallint         |
 lateaircraftdelay    | smallint         |
Distributed by: (uniquecarrier, flightnum)
</code></pre>

<p>Notice that the column-oriented version is append-only and partitioned. It has seventeen child files for the partitions, one for each month from June 2009 through October 2010.
<code>tutorial=# \d faa.otp_c</code></p>

<pre><code>       Append-Only Columnar Table "faa.otp_c"
        Column        |       Type       | Modifiers
----------------------+------------------+-----------
 flt_year             | smallint         |
 flt_quarter          | smallint         |
 flt_month            | smallint         |
 flt_dayofmonth       | smallint         |
 flt_dayofweek        | smallint         |
 flightdate           | date             |
 uniquecarrier        | text             |
 airlineid            | integer          |
 carrier              | text             |
 flightnum            | text             |
 origin               | text             |
 origincityname       | text             |
 originstate          | text             |
 originstatename      | text             |
 dest                 | text             |
 destcityname         | text             |
 deststate            | text             |
 deststatename        | text             |
 crsdeptime           | text             |
 deptime              | integer          |
 depdelay             | double precision |
 depdelayminutes      | double precision |
 departuredelaygroups | smallint         |
 taxiout              | smallint         |
 wheelsoff            | text             |
 wheelson             | text             |
 taxiin               | smallint         |
 crsarrtime           | text             |
 arrtime              | text             |
 arrdelay             | double precision |
 arrdelayminutes      | double precision |
 arrivaldelaygroups   | smallint         |
 cancelled            | smallint         |
 cancellationcode     | text             |
 diverted             | smallint         |
 crselapsedtime       | integer          |
 actualelapsedtime    | double precision |
 airtime              | double precision |
 flights              | smallint         |
 distance             | double precision |
 distancegroup        | smallint         |
 carrierdelay         | smallint         |
 weatherdelay         | smallint         |
 nasdelay             | smallint         |
 securitydelay        | smallint         |
 lateaircraftdelay    | smallint         |
Checksum: t
Number of child tables: 17 (Use \d+ to list them.)
Distributed by: (uniquecarrier, flightnum)
</code></pre>
</blockquote>
</li>
<li>
<p>Compare the sizes of the tables using the pg_relation_size() and pg_total_relation_size() functions. The pg_size_pretty() function converts the size in bytes to human-readable units.  </p>

<blockquote>
<p><code>tutorial=# SELECT pg_size_pretty(pg_relation_size('faa.otp_r'));</code></p>

<pre><code>pg_size_pretty
----------------
 256 MB
(1 row)
</code></pre>

<p><code>tutorial=# SELECT pg_size_pretty(pg_total_relation_size('faa.otp_r'));</code></p>

<pre><code> pg_size_pretty
----------------
 256 MB
(1 row)
</code></pre>

<p><code>tutorial=# SELECT pg_size_pretty(pg_relation_size('faa.otp_c'));</code></p>

<pre><code> pg_size_pretty
----------------
 0 bytes
(1 row)
</code></pre>

<p><code>tutorial=# SELECT pg_size_pretty(pg_total_relation_size('faa.otp_c'));</code></p>

<pre><code> pg_size_pretty
----------------
 288 kB
(1 row)
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="check-for-even-data-distribution-on-segments" class="anchor" href="#check-for-even-data-distribution-on-segments" aria-hidden="true"><span class="octicon octicon-link"></span></a>Check for even data distribution on segments</h4>

<p>The faa.otp_r and faa.otp_c tables are distributed with a hash function on UniqueCarrier and FlightNum. These two columns were selected because they produce an even distribution of the data onto the segments. Also, with frequent joins expected on the fact table and dimension tables on these two columns, less data moves between segments, reducing query execution time.  When there is no advantage to co-locating data from different tables on the segments, a distribution based on a unique column ensures even distribution. Distributing on a column with low cardinality, such as Diverted, which has only two values, will yield a poor distribution.</p>

<ol>
<li>
<p>One of the goals of distribution is to ensure that there is approximately the same amount of data in each segment. The query below shows one way of determining this. Since the column-oriented and row-oriented tables are distributed by the same columns, the counts should be the same for each.</p>

<blockquote>
<pre><code>tutorial=# SELECT gp_segment_id, COUNT(*) FROM faa.otp_c GROUP BY
gp_segment_id ORDER BY gp_segment_id;
</code></pre>

<pre><code>gp_segment_id |  count
---------------+---------
         0 | 1028144
         1 | 1020960
(2 rows)
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="about-partitioning" class="anchor" href="#about-partitioning" aria-hidden="true"><span class="octicon octicon-link"></span></a>About partitioning</h4>

<p>Partitioning a table can improve query performance and simplify data administration. The table is divided into smaller child files using a range or a list value, such as a date range or a country code.</p>

<p>Partitions can improve query performance dramatically. When a query predicate filters on the same criteria used to define partitions, the optimizer can avoid searching partitions that do not contain relevant data.</p>

<p>A common application for partitioning is to maintain a rolling window of data based on date, for example, a fact table containing the most recent 12 months of data. Using the ALTER TABLE statement, an existing partition can be dropped by removing its child file. This is much more efficient than scanning the entire table and removing rows with a DELETE statement.</p>

<p>Partitions may also be subpartitioned. For example, a table could be partitioned by month, and the month partitions could be subpartitioned by week. Greenplum Database creates child files for the months and weeks. The actual data, however, is stored in the child files created for the week subpartitions—only child files at the leaf level hold data.</p>

<p>When a new partition is added, you can run ANALYZE on just the data in that partition. ANALYZE can run on the root partition (the name of the table in the CREATE TABLE statement) or on a child file created for a leaf partition. If ANALYZE has already run on the other partitions and the data is static, it is not necessary to run it again on those partitions.  </p>

<p>Greenplum Database supports:</p>

<ul>
<li>Range partitioning: division of data based on a numerical range, such as date or price.<br>
</li>
<li>List partitioning: division of data based on a list of values, such as sales territory or product line.<br>
</li>
<li>A combination of both types.<br>
</li>
</ul>

<p><img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/part.jpg" width="400" alt="Greenplum Database partitioning">  </p>

<p>The following exercise compares SELECT statements with WHERE clauses that do and
do not use a partitioned column.</p>

<ol>
<li>
<p>The column-oriented version of the fact table you created is partitioned by date.  First, execute a query that filters on a non-partitioned column and note the execution time.  </p>

<blockquote>
<p><code>tutorial=# \timing on</code></p>

<pre><code>Timing is on.
</code></pre>

<p><code>tutorial=# SELECT MAX(depdelay) FROM faa.otp_c WHERE UniqueCarrier = 'UA';</code></p>

<pre><code> max
------
 1360
(1 row)
Time: 641.574 ms
</code></pre>
</blockquote>
</li>
<li>
<p>Execute a query that filters on flightdate, the partitioned column. </p>

<blockquote>
<p><code>tutorial=# SELECT MAX(depdelay) FROM faa.otp_c WHERE flightdate ='2009-11-01';</code> </p>

<pre><code> max
-----
1201
(1 row)
Time: 30.658 ms
</code></pre>
</blockquote>

<p>The query on the partitioned column takes much less time to execute. If you compare the explain plans for the queries in this exercise, you will see that the first query scans each of the seventeen child files, while the second scans just one child file. The reduction in I/O and CPU time explains the improved execution time. </p>
</li>
</ol>

