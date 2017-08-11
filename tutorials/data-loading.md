---
layout: default
title:  "Data Loading"
permalink: /data-loading
---

<h2 class='inline-header'>Data Loading</h2>

<p>Loading external data into Greenplum Database tables can be accomplished in different ways. We will use three methods to load the FAA data:  </p>

<ul>
<li>The simplest data loading method is the SQL INSERT statement. You can execute INSERT statements directly with psql or another interactive client, run a script containing INSERT statements, or run a client application with a database connection. This is the least efficient method for loading large volumes of data and should be used only for small amounts of data.</li>
<li>You can use the COPY command to load the data into a table when the data is in external text files. The COPY command syntax allows you to define the format of the text file so the data can be parsed into rows and columns. This is faster than INSERT statements but, like INSERT statements, it is not a parallel process.<br>
The SQL COPY command requires that external files be accessible to the host where the master process is running. On a multi-node Greenplum Database system, the data files may be on a file system that is not accessible to the master process. In this case, you can use the psql \copy meta-command, which streams the data to the server over the psql connection. The scripts in this tutorial use the \copy meta-command.<br>
</li>
<li> You can use a pair of Greenplum utilities, gpfdist and gpload, to load external data into tables at high data transfer rates. In a large scale, multi-terabyte data warehouse, large amounts of data must be loaded within a relatively small maintenance window. Greenplum supports fast, parallel data loading with its external tables feature. Administrators can also load external tables in single row error isolation mode to filter bad rows into a separate error table while continuing to load properly formatted rows. Administrators can specify an error threshold for a load operation to control how many improperly formatted rows cause Greenplum to abort the load operation.</li>
</ul>

<p>By using external tables in conjunction with Greenplum Database's parallel file server (gpfdist), administrators can achieve maximum parallelism and load bandwidth from their Greenplum Database system.</p>

<p>Figure 1. External Tables Using Greenplum Parallel File Server (gpfdist) </p>

<p><img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/ext_tables.jpg" width="500" alt="External Tables Using Greenplum Parallel File Server"></p>

<p>Another Greenplum utility, gpload, runs a load task that you specify in a YAML-formatted control file. You describe the source data locations, format, transformations required, participating hosts, database destinations, and other particulars in the control file and gpload executes the load. This allows you to describe a complex task and execute it in a controlled, repeatable fashion.</p>

<p>In the following exercises, you load data into the tutorial database using each of these methods.  </p>

<h3>
<a id="exercises-3" class="anchor" href="#exercises-3" aria-hidden="true"><span class="octicon octicon-link"></span></a>Exercises</h3>

<h4>
<a id="load-data-with-the-insert-statement" class="anchor" href="#load-data-with-the-insert-statement" aria-hidden="true"><span class="octicon octicon-link"></span></a>Load data with the INSERT statement</h4>

<p>The faa.d_cancellation_codes table is a simple two-column look-up table, easily loaded with an INSERT statement.  </p>

<ol>
<li>
<p>Change to the directory containing the FAA data and scripts:</p>

<blockquote>
<p><code>$ cd ~/gpdb-sandbox-tutorials/faa</code></p>
</blockquote>
</li>
<li>
<p>Use the \d psql meta-command to describe the faa.d_cancellation_codes table:  </p>

<blockquote>
<pre><code>tutorial=# \d d_cancellation_codes
Table "faa.d_cancellation_codes"
   Column    | Type | Modifiers
-------------+------+-----------
 cancel_code | text |
 cancel_desc | text |
Distributed by: (cancel_code)
</code></pre>
</blockquote>
</li>
<li>
<p>Load the data into the table with a multirow INSERT statement (alternatively issue \i insert_into_cancellation_codes.sql):  </p>

<blockquote>
<pre><code>tutorial=# INSERT INTO faa.d_cancellation_codes
tutorial-# VALUES ('A', 'Carrier'),
tutorial-# ('B', 'Weather'),
tutorial-# ('C', 'NAS'),
tutorial-# ('D', 'Security'),
tutorial-# ('', 'none');
INSERT 0 5
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="load-data-with-the-copy-statement" class="anchor" href="#load-data-with-the-copy-statement" aria-hidden="true"><span class="octicon octicon-link"></span></a>Load data with the COPY statement</h4>

<p>The COPY statement moves data between the file system and database tables. Data for five of the FAA tables is in the following CSV-formatted text files:</p>

<ol>
<li>
<p>In a text editor, review the .csv data files. </p>

<ul>
<li>L_AIRLINE_ID.csv</li>
<li>L_AIRPORTS.csv</li>
<li>L_DISTANCE_GROUP_250.csv</li>
<li>L_ONTIME_DELAY_GROUPS.csv</li>
<li>L_WORLD_AREA_CODES.csv<br>
Notice that the first line of each file contains the column names and that the last line of the file contains the characters “.”, which signals the end of the input data.<br>
</li>
</ul>
</li>
<li>
<p>In a text editor, review the following scripts:</p>

<ul>
<li>copy_into_airlines.sql</li>
<li>copy_into_airports.sql</li>
<li>copy_into_delay_groups.sql</li>
<li>copy_into_distance_groups.sql</li>
<li>copy_into_wac.sql<br>
The HEADER keyword prevents the \copy command from interpreting the column
names as data. </li>
</ul>
</li>
<li>
<p>Run the following scripts to load the data:  </p>

<blockquote>
<pre><code>tutorial-# =# \i copy_into_airlines.sql
tutorial-# =# \i copy_into_airports.sql
tutorial-# =# \i copy_into_delay_groups.sql
tutorial-# =# \i copy_into_distance_groups.sql
tutorial-# =# \i copy_into_wac.sql
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="load-data-with-gpfdist" class="anchor" href="#load-data-with-gpdist" aria-hidden="true"><span class="octicon octicon-link"></span></a>Load data with gpdist</h4>

<p>For the FAA fact table, we will use an ETL (Extract, Transform, Load) process to load data from the source gzip files into a loading table, and then insert the data into a query and reporting table. For the best load speed, use the gpfdist Greenplum utility to distribute the rows to the segments. In a production system, gpfdist runs on the servers where the data is located. With a single-node Greenplum Database instance, there is only one host, and you run gpdist on it. Starting gpfdist is like starting a file server; there is no data movement until a request is made on the process.</p>

<p><em>Note: This exercise loads data using the Greenplum Database external table feature to move data from external data files into the database. Moving data between the database and external tables is a security consideration, so only superusers are permitted to use the feature. Therefore, you will run this exercise as the gpadmin database user.</em>  </p>

<ol>
<li>
<p>Execute <em>gpfdist</em>. Use the –d switch to set the “home” directory used to search for files in the faa directory. Use the –p switch to set the port and background the process.  </p>

<blockquote>
<p><code>$ gpfdist -d ~/gpdb-sandbox-tutorials/faa -p 8081 &gt; /tmp/gpfdist.log 2&gt;&amp;1 &amp;</code>  </p>
</blockquote>
</li>
<li>
<p>Check that <em>gpfdist</em> is running with the ps command:</p>

<blockquote>
<p><code>$ ps -A | grep gpfdist</code>  </p>
</blockquote>
</li>
<li>
<p>View the contents of the gpfdist log.</p>

<blockquote>
<p><code>more /tmp/gpfdist.log</code>  </p>
</blockquote>
</li>
<li>
<p>Start a psql session as gpadmin and execute the create_load_tables.sql script.  This script creates two tables: the faa_otp_load table, into which gpdist will load the data, and the faa_load_errors table, where load errors will be logged. (The faa_load_errors table may already exist. Ignore the error message.) The faa_otp_load table is structured to match the format of the input data from the FAA Web site.  </p>

<blockquote>
<p><code>$ psql -U gpadmin tutorial</code> </p>

<pre><code>tutorial=# \i create_load_tables.sql
CREATE TABLE
CREATE TABLE
</code></pre>
</blockquote>
</li>
<li>
<p>Create an external table definition with the same structure as the faa_otp_load table.   </p>

<blockquote>
<pre><code>tutorial=# \i create_ext_table.sql
psql:create_ext_table.sql:5: NOTICE:  HEADER means that each one
of the data files has a header row.
CREATE EXTERNAL TABLE
</code></pre>
</blockquote>

<p>This is a pure metadata operation. No data has moved from the data files on the host to the database yet. The external table definition references files in the faa directory that match the pattern otp*.gz. There are two matching files, one containing data for December 2009, the other for January 2010. </p>
</li>
<li>
<p>Move data from the external table to the faa_otp_load table.  </p>

<blockquote>
<pre><code>tutorial=#  INSERT INTO faa.faa_otp_load SELECT * FROM faa.ext_load_otp;
NOTICE:  Found 26526 data formatting errors (26526 or more input rows).
Rejected related input data.
INSERT 0 1024552
</code></pre>
</blockquote>

<p>Greenplum moves data from the gzip files into the load table in the database. In a production environment, you could have many gpfdist processes running, one on each host or several on one host, each on a separate port number. </p>
</li>
<li>
<p>Examine the errors briefly. (The \x on psql meta-command changes the display of the results to one line per column, which is easier to read for some result sets.)</p>

<blockquote>
<pre><code>tutorial=# \x
Expanded display is on.
tutorial=# SELECT DISTINCT relname, errmsg, count(*)
           FROM faa.faa_load_errors GROUP BY 1,2;
-[ RECORD 1 ]-------------------------------------------------
relname | ext_load_otp
errmsg  | invalid input syntax for integer: "", column deptime
count   | 26526
</code></pre>
</blockquote>
</li>
<li>
<p>Exit the psql shell:</p>

<blockquote>
<p><code>tutorial=# \q</code></p>
</blockquote>
</li>
</ol>

<h4>
<a id="load-data-with-gpload" class="anchor" href="#load-data-with-gpload" aria-hidden="true"><span class="octicon octicon-link"></span></a>Load data with gpload</h4>

<p>Greenplum provides a wrapper program for gpfdist called gpload that does much
of the work of setting up the external table and the data movement.  In this exercise, you reload the faa_otp_load table using the gpload utility.  </p>

<ol>
<li>
<p>Since gpload executes gpfdist, you must first kill the gpfdist process you
started in the previous exercise. </p>

<blockquote>
<pre><code>[gpadmin@gpdb-sandbox faa]$ ps -A | grep gpfdist
4035 pts/0    00:00:02 gpfdist
</code></pre>
</blockquote>

<p>Your process id will not be the same, so kill the appropriate one with the kill command, or just use the simpler killall command:</p>

<pre><code>  gpadmin@gpdb-sandbox faa]$ killall gpfdist
  [1]+  Exit 1    gpfdist -d $HOME/gpdb-sandbox-tutorials/faa -p   8081 &gt; /tmp/  gpfdist.log 2&gt;&amp;1
</code></pre>
</li>
<li>
<p>Edit and customize the gpload.yaml input file. Be sure to set the correct path to the faa directory. Notice the TRUNCATE: true preload instruction ensures that the data loaded in the previous exercise will be removed before the load in this exercise starts. </p>

<blockquote>
<p><code>vi gpload.yaml</code>  </p>

<pre><code>---
VERSION: 1.0.0.1
# describe the Greenplum database parameters
DATABASE: tutorial
USER: gpadmin
HOST: localhost
PORT: 5432
# describe the location of the source files
# in this example, the database master lives on the same host as the source files
GPLOAD:
   INPUT:
    - SOURCE:
         LOCAL_HOSTNAME:
           - gpdb-sandbox
         PORT: 8081
         FILE:
           - /Users/gpadmin/gpdb-sandbox-tutorials/faa/otp*.gz
    - FORMAT: csv
    - QUOTE: '"'
    - ERROR_LIMIT: 50000
    - ERROR_TABLE: faa.faa_load_errors
   OUTPUT:
    - TABLE: faa.faa_otp_load
    - MODE: INSERT
   PRELOAD:
    - TRUNCATE: true
</code></pre>
</blockquote>
</li>
<li>
<p>Execute gpload with the gpload.yaml input file. (Include the -v flag if you
want to see details of the loading process.)</p>

<blockquote>
<p><code>$ gpload -f gpload.yaml -l gpload.log</code>  </p>

<pre><code>2015-10-21 15:05:39|INFO|gpload session started 2015-10-21 15:05:39
2015-10-21 15:05:39|INFO|started gpfdist -p 8081 -P 8082 -f "/home/gpadmin/gpdb-sandbox-tutorials/faa/otp*.gz" -t 30
2015-10-21 15:05:58|WARN|26528 bad rows
2015-10-21 15:05:58|INFO|running time: 18.64 seconds
2015-10-21 15:05:58|INFO|rows Inserted          = 1024552
2015-10-21 15:05:58|INFO|rows Updated           = 0
2015-10-21 15:05:58|INFO|data formatting errors = 0
2015-10-21 15:05:58|INFO|gpload succeeded with warnings
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="create-and-load-fact-tables" class="anchor" href="#create-and-load-fact-tables" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create and Load fact tables</h4>

<p>The final step of the ELT process is to move data from the load table to the fact table.  For the FAA example, you create two fact tables. The faa.otp_r table is a row-oriented table, which will be loaded with data from the faa.faa_otp_load table. The faa.otp_c table has the same structure as the faa.otp_r table, but is column-oriented and partitioned. You will load it with data from the faa.otp_r table.  The two tables will contain identical data and allow you to experiment with a column-oriented and partitioned table in addition to a traditional row-oriented table. </p>

<ol>
<li>
<p>Create the faa.otp_r and faa.otp_c tables by executing the create_fact_tables.sql script.</p>

<blockquote>
<p><code>$ psql -U gpadmin tutorial</code><br>
<code>tutorial=#  \i create_fact_tables.sql</code>
Review the create_fact_tables.sql script and note that some columns are excluded from the fact table and the data types of some columns are cast to a different datatype. The MADlib routines usually require float8 values, so the numeric columns are cast to float8 as part of the transform step.</p>
</blockquote>
</li>
<li>
<p>Load the data from the faa_otp_load table into the faa.otp_r table using the SQL INSERT FROM statement. Load the faa.otp_c table from the faa.otp_r table. Both of these loads can be accomplished by running the load_into_fact_table.sql script.</p>

<blockquote>
<p><code>tutorial=#  \i load_into_fact_table.sql</code></p>
</blockquote>
</li>
</ol>

<h3>
<a id="data-loading-summary" class="anchor" href="#data-loading-summary" aria-hidden="true"><span class="octicon octicon-link"></span></a>Data loading summary</h3>

<p>The ability to load billions of rows quickly into the Greenplum database is one of its key features. Using “Extract, Load and Transform” (ELT) allows load processes to make use of the massive parallelism of the Greenplum system by staging the data (perhaps just the use of external tables) and then applying data transformations within Greenplum Database. Set-based operations can be done in parallel, maximizing performance.</p>

<p>With other loading mechanisms such as COPY, data is loaded through the master in a single process. This does not take advantage of the parallel processing power of the Greenplum segments. External tables provide a means of leveraging the parallel processing power of the segments for data loading. Also, unlike other loading mechanisms, you can access multiple data sources with one SELECT of an external table.</p>

<p>External tables make static data available inside the database. External tables can be defined with file:// or gpfdist:// protocols. gpfdist is a file server program that loads files in parallel. Since the data is static, external tables can be rescanned during a query execution.</p>

<p>External Web tables allow http:// protocol or an EXECUTE clause to execute an operating system command or script. That data is assumed to be dynamic—query plans involving Web tables do not allow rescanning because the data could change during query execution. Execution plans may be slower, as data must be materialized (I/O) if it cannot fit in memory.</p>

<p>The script or process to populate a table with external Web tables may be executed on every segment host. It is possible, therefore, to have duplication of data. This is something to be aware of and check for when using Web tables, particularly with SQL extract calls to another database.</p>