---
layout: default
title:  "psql Command Line Client"
permalink: /psql-commandline-client
---

<h2 class='inline-header'>psql Command Line Client</h2>







<p>The <a href="./">previous tutorial</a> showed how you can download and run a virtual machine with Greenplum Database on it. In continuation, this tutorial will show how to use the command line client “psql”.</p>

<h4><a id="what-is-psql" class="anchor" href="#what-is-psql" aria-hidden="true"><span class="octicon octicon-link"></span></a>What is psql?</h4>

<p>First start the virtual machine, and login with the known credentials. By default, Greenplum Database comes with “psql” as command line client, and that is a very powerful tool to query the database or use it in scripts.</p>

<p>How to start psql</p>

<p>Start a terminal, and type in:</p>

<blockquote>
<p><code>psql</code></p>
</blockquote>
<br/>

<p>it tries to connect to the database using a number of default settings:</p>

<ul>
<li>TCP Port: 5432</li>
<li>Host: will use the Unix Domain Socket</li>
<li>Username: your Unix username</li>
<li>Database: same as your username</li>
</ul>

<p>Each setting can be changed on the commandline, or overridden using the configuration file or environment variables. The most common settings are:</p>

<ul>
<li>Hostname: -h or --host</li>
<li>Username: -U or --username (uppercase U)</li>
<li>TCP-Port: -p or --port</li>
<li>Database name: -d or --dbname</li>
</ul>

<p>Therefore in order to connect from your local workstation to a Greenplum Database server, you need the following command line:</p>

<blockquote>
<p><code>psql -U gpadmin -h gpdbserver -p 5432 postgres</code></p>
</blockquote>


<h4><a id="which-databases-are-available" class="anchor" href="#which-databases-are-available" aria-hidden="true"><span class="octicon octicon-link"></span></a>Which databases are available?</h4>

<p>In a newly created Greenplum Database system, a total of 3 databases are created by default:</p>
<ul>
<li>“template0”: empty, used as fallback if “template1” needs to be recreated</li>
<li>“template1”: used as template for every newly created database - everything which is installed or created in “template1” will also be available in the new database</li>
<li>“postgres”: can be used as default database to establish a connection, until a database for your project is created</li>
</ul>

<p>It comes handy to create a “gpadmin” database as well, in order to have a default database for the gpadmin user. It saves a few keystrokes every time you use psql:</p>

<blockquote>
<p><code>CREATE DATABASE gpadmin;</code></p>
</blockquote>
<br/>


<h4><a id="what-does-psql-offer" class="anchor" href="#what-does-psql-offer" aria-hidden="true"><span class="octicon octicon-link"></span></a>What does psql offer?</h4>

<p>Once connected to the database, psql offers a broad range of commands to explore the database:</p>
<ul>
<li>\l: lists all databases</li>
<li>\l+: lists all databases and shows extended information</li>
<li>\c <database>: connects to <database></li>
<li>\timing: switches client-side timing on or off</li>
<li>\dt: lists all tables</li>
<li>\dt+: lists all tables and extended information</li>
<li>\dt public.*: lists all tables in the public schema</li>
<li>\dn: lists all schemas</li>
<li>\df: lists all functions</li>
<li>\x: switches between row and column based output (handy for very wide tables)</li>
</ul>



<h4><a id="how-to-load-data-using-psql" class="anchor" href="#how-to-load-data-using-psql" aria-hidden="true"><span class="octicon octicon-link"></span></a>How to load data using psql</h4>

<p>The COPY command can be used to load data from files into tables. Psql is often used in scripts to execute the COPY command, however that can also happen interactively. Connect to your database and execute the following command:</p>


<blockquote>
<p><code>COPY tablename from ‘/path/to/filename.csv’;</code></p>
</blockquote>
<br/>

<p>Note: the file needs to be on the database server, and needs to be accessible for the user which runs the Greenplum Database. The server will directly open the file and read the data.</p>

<p>That is not very handy, if psql runs on another host. However psql offers a nice way to work around this problem:</p>


<blockquote>
<p><code>\copy tablename from ‘/path/to/filename.csv’</code></p>
</blockquote>
<br/>

<p>Using the backslash form, psql will transfer the file over the network to the database.</p>




<h4><a id="how-to-export-data-using-psql" class="anchor" href="#how-to-export-data-using-psql" aria-hidden="true"><span class="octicon octicon-link"></span></a>How to export data using psql</h4>

<p>The COPY command is not only used to transfer data to the database, but can also be used to export data:</p>


<blockquote>
<p><code>COPY tablename to ‘/path/to/export.csv’;</code></p>
</blockquote>
<br/>

<p>This will export the content of the table "tablename" to the file ‘export.csv’ on the master server. Again, psql can do the heavy lifting and transfer the data over the network:</p>


<blockquote>
<p><code>\copy tablename to ‘/path/to/export.csv’</code></p>
</blockquote>
<br/>

<p>More options how to load and unload data are described in the Data Loading tutorial.</p>




<h4><a id="execute-scripts" class="anchor" href="#execute-scripts" aria-hidden="true"><span class="octicon octicon-link"></span></a>Execute scripts</h4>

<p>One of the advanced use cases for psql is the usage in scripts and batch jobs. psql offers the option to execute single commands, using the -c option. And it allows to read an arbitrary number of commands from a text file and send them to the database, using the -f option.</p>

<p>Single command:</p>


<blockquote>
<p><code>psql -c “SELECT COUNT(*) FROM tablename”</code></p>
</blockquote>
<br/>

<p>It’s even more handy to (un)format the output to be used in scripts:</p>


<blockquote>
<p><code>psql -q -A -t -c “SELECT COUNT(*) FROM tablename”</code></p>
</blockquote>
<br/>

<p>Read commands from text file:</p>


<blockquote>
<p><code>psql -f textfile.txt</code></p>
</blockquote>
<br/>

<p>This option can also be used when already connected to a database:</p>


<blockquote>
<p><code>\i textfile.txt</code></p>
</blockquote>
<br/>



<h4><a id="row-and-column-based-output" class="anchor" href="#row-and-column-based-output" aria-hidden="true"><span class="octicon octicon-link"></span></a>Row- and column based output</h4>

<p>The normal output for any result is column-based. That is, psql will calculate the width for every cell based on the data returned from the query. If the output is larger than the terminal, or if a table has many columns, this will wrap around and produce non-readable output.</p>

<p>The command line option -x/--expanded and the inline option \x will switch to row-based output. In this format, every tuple will be printed on a separate line. This makes it easy to read very long or very wide datasets.</p>




<h4><a id="Measure runtime" class="anchor" href="#c" aria-hidden="true"><span class="octicon octicon-link"></span></a>Measure runtime</h4>

<p>The psql client has a built-in stopwatch:</p>

<blockquote>
<p><code>\timing</code></p>
</blockquote>
<br/>

<p>This will measure the time required to execute the query. Keep in mind that this also measures the time which is required to transfer the data to the client. If you have a small result set, this will be pretty accurate. However if you just do a SELECT * from a large table, you might spend more time in transferring the data than in selecting the data from the table.</p>





<h4><a id="stop-scripts-on-error" class="anchor" href="#stop-scripts-on-error" aria-hidden="true"><span class="octicon octicon-link"></span></a>Stop scripts on error</h4>

<p>If psql is used in scripts, or if a large script is executed in the database using the -f option, it might happen that something goes wrong. A syntax error, a missing table, anything which might cause an error, and later on produces more follow-up errors.</p>

<p>By default, psql will not stop when it encounters an error, but will read all commands from the file and tries to execute them. Most of the time that is not what you want, either because the other commands depend on the failing command and therefore the result is just one big mess. Or because everything was running in one transaction and the transaction fails on the first error.</p>

<p>For this kind of use cases psql offers a stop command when it encounters an error:</p>


<blockquote>
<p><code>\set ON_ERROR_STOP</code></p>
</blockquote>
<br/>

<p>This will stop the execution of a script when an error is encountered.</p>




<h4><a id="next-steps" class="anchor" href="#next-steps" aria-hidden="true"><span class="octicon octicon-link"></span></a>Next steps</h4>

<p>Now that you learned how to use psql, it’s time to create a database for your project. Alternatively you can look into GUI clients like pgAdmin3.</p>

