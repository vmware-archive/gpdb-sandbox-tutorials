---
layout: default
title:  "Create Tables"
permalink: /create-tables
---

<h2 class='inline-header'>Create Tables</h2>

<p>The CREATE TABLE SQL statement creates a table in the database.</p>

<h4>
<a id="about-the-distribution-policy" class="anchor" href="#about-the-distribution-policy" aria-hidden="true"><span class="octicon octicon-link"></span></a>About the distribution policy</h4>

<p>The definition of a table includes the distribution policy for the data, which has great bearing on system performance. The goals for the distribution policy are to:  </p>

<ul>
<li>distribute the volume of data and query execution work evenly among the
segments, and to<br>
</li>
<li>enable segments to accomplish the most expensive query processing steps locally.<br>
</li>
</ul>

<p>The distribution policy determines how data is distributed among the segments. Defining an effective distribution policy requires an understanding of the data’s characteristics, the kinds of queries that will be run once the data is loaded into the database, and what distribution strategies best utilize the parallel execution capacity of the segments.</p>

<p>Use the DISTRIBUTED clause of the CREATE TABLE statement to define the
distribution policy for a table. Ideally, each segment will store an equal volume of data and perform an equal share of work when processing queries. There are two kinds of distribution policies:</p>

<ul>
<li>DISTRIBUTED BY (column, ...) defines a distribution key from one or more columns. A hash function applied to the distribution key determines which segment stores the row. Rows that have the same distribution key are stored on the same segment. If the distribution keys are unique, the hash function ensures the data is distributed evenly. The default distribution policy is a hash on the primary key of the table, or the first column if no primary key is specified.</li>
<li>DISTRIBUTED RANDOMLY distributes rows in round-robin fashion among the
segments.</li>
</ul>

<p>When different tables are joined on the same columns that comprise the distribution key, the join can be accomplished at the segments, which is much faster than joining rows across segments. The random distribution policy makes this impossible, so it is best practice to define a distribution key that will optimize joins.</p>

<h3>
<a id="exercises-2" class="anchor" href="#exercises-2" aria-hidden="true"><span class="octicon octicon-link"></span></a>Exercises</h3>

<h4>
<a id="execute-the-create-table-script-in-psql" class="anchor" href="#execute-the-create-table-script-in-psql" aria-hidden="true"><span class="octicon octicon-link"></span></a>Execute the CREATE TABLE script in psql</h4>

<p>The CREATE TABLE statements for the faa database are in the faa create_dim_tables.sql script. </p>

<ol>
<li>
<p>Change to the directory containing the FAA data and scripts:</p>

<blockquote>
<p><code>$ cd ~/gpdb-sandbox-tutorials/faa</code></p>
</blockquote>
</li>
<li>
<p>Open the script in a text editor to see the text of the commands that will be executed when you run the script. </p>

<blockquote>
<pre><code>gpadmin@gpdb-sandbox faa]$ more create_dim_tables.sql
create table faa.d_airports (airport_code text, airport_desc text) distributed  by (airport_code);
create table faa.d_wac (wac smallint, area_desc text) distributed by (wac);
create table faa.d_airlines (airlineid integer, airline_desc text) distributed   by (airlineid);
create table faa.d_cancellation_codes (cancel_code text, cancel_desc text)   distributed by (cancel_code);
create table faa.d_delay_groups (delay_group_code text, delay_group_desc text)   distributed by (delay_group_code);
create table faa.d_distance_groups (distance_group_code text,   distance_group_desc text) distributed by (distance_group_code)
</code></pre>
</blockquote>
</li>
<li>
<p>Execute the create_dim_tables.sql script.  The psql \i command executes a script:    </p>

<blockquote>
<p><code>$ psql -U user1 tutorial</code></p>

<pre><code>tutorial=# \i create_dim_tables.sql
</code></pre>
</blockquote>
</li>
<li>
<p>List the tables that were created, using the psql \dt command.</p>

<blockquote>
<p><code>tutorial=# \dt</code></p>
</blockquote>
</li>
<li>
<p>Exit the psql shell:</p>

<blockquote>
<p><code>tutorial=# \q</code></p>
</blockquote>
</li>
</ol>