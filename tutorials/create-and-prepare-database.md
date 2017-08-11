---
layout: default
title:  "Create and Prepare Database"
permalink: /create-and-prepare-database
---

<h2 class='inline-header'>Create and Prepare Database</h2>

<p>Create a new database with the CREATE DATABASE SQL command in psql or the createdb utility command in a terminal. The new database is a copy of the template1 database, unless you specify a different template.
To use the CREATE DATABASE command, you must be connected to a database. With a newly installed Greenplum Database system, you can connect to the template1 database to create your first user database. The createdb utility, entered at a shell prompt, is a wrapper around the CREATE DATABASE command. In this exercise you will drop the tutorial database if it exists and then create it new with the createdb utility.  </p>

<h3>
<a id="exercises-1" class="anchor" href="#exercises-1" aria-hidden="true"><span class="octicon octicon-link"></span></a>Exercises</h3>

<h4>
<a id="create-database" class="anchor" href="#create-database" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create Database</h4>

<ol>
<li>
<p>Enter these commands to drop the tutorial database if it exists:  </p>

<blockquote>
<p><code>$ dropdb tutorial</code>  </p>
</blockquote>
</li>
<li>
<p>Enter the createdb command to create the tutorial database, with the defaults:  </p>

<blockquote>
<p><code>$ createdb tutorial</code></p>
</blockquote>
</li>
<li>
<p>Verify that the database was created using the <em>psql -l</em> command:  </p>

<blockquote>
<pre><code>[gpadmin@gpdb-sandbox ~]$ psql -l
                  List of databases
   Name    |  Owner  | Encoding |  Access privileges
-----------+---------+----------+---------------------
 gpadmin   | gpadmin | UTF8     |
 gpperfmon | gpadmin | UTF8     | gpadmin=CTc/gpadmin
                                : =c/gpadmin
 postgres  | gpadmin | UTF8     |
 template0 | gpadmin | UTF8     | =c/gpadmin
                                : gpadmin=CTc/gpadmin
 template1 | gpadmin | UTF8     | =c/gpadmin
                                : gpadmin=CTc/gpadmin
 tutorial  | gpadmin | UTF8     |
(6 rows)
</code></pre>
</blockquote>
</li>
<li>
<p>Connect to the tutorial database as user1, entering the password you created
for user1 when prompted:</p>

<blockquote>
<p><code>psql -U user1 tutorial</code>  </p>
</blockquote>
</li>
</ol>

<h4>
<a id="grant-database-privileges-to-users" class="anchor" href="#grant-database-privileges-to-users" aria-hidden="true"><span class="octicon octicon-link"></span></a>Grant database privileges to users</h4>

<p>In a production database, you should grant users the minimum permissions required to do their work. For example, a user may need SELECT permissions on a table to view data, but not UPDATE, INSERT, or DELETE to modify the data.  To complete the exercises in this guide, the database users will require permissions to create and manipulate objects in the tutorial database.  </p>

<ol>
<li>
<p>Connect to the tutorial database as gpadmin.  </p>

<blockquote>
<p><code>$ psql -U gpadmin tutorial</code></p>
</blockquote>
</li>
<li>
<p>Grant user1 and user2 all privileges on the tutorial database.    </p>

<blockquote>
<p><code>tutorial=# GRANT ALL PRIVILEGES ON DATABASE tutorial TO user1, user2;</code>  </p>
</blockquote>
</li>
<li>
<p>Log out of psql and perform the next steps as the user1 role.  </p>

<blockquote>
<p><code>tutorial=# \q</code></p>
</blockquote>
</li>
</ol>

<h4>
<a id="create-a-schema-and-set-a-search-path" class="anchor" href="#create-a-schema-and-set-a-search-path" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create a schema and set a search path</h4>

<p>A database schema is a named container for a set of database objects, including tables, data types, and functions. A database can have multiple schemas. Objects within the schema are referenced by prefixing the object name with the schema name, separated with a period. For example, the person table in the employee schema is written employee.person.</p>

<p>The schema provides a namespace for the objects it contains. If the database is used for multiple applications, each with its own schema, the same table name can be used in each schema employee.person is a different table than customer.person. Both tables could be accessed in the same query as long as they are qualified with the schema name.</p>

<p>The database contains a schema search path, which is a list of schemas to search for objects names that are not qualified with a schema name. The first schema in the search path is also the schema where new objects are created when no schema is specified. The default search path is user,public, so by default, each object you create belongs to a schema associated with your login name.  In this exercise, you create an faa schema and set the search path so that it is the default schema.</p>

<ol>
<li>
<p>Change to the directory containing the FAA data and scripts:</p>

<blockquote>
<p><code>$ cd ~/gpdb-sandbox-tutorials/faa</code></p>
</blockquote>
</li>
<li>
<p>Connect to the tutorial database with psql:</p>

<blockquote>
<p><code>$ psql -U user1 tutorial</code>  </p>
</blockquote>
</li>
<li>
<p>Create the faa schema:</p>

<blockquote>
<pre><code>tutorial=# DROP SCHEMA IF EXISTS faa CASCADE;
tutorial=# CREATE SCHEMA faa;
</code></pre>
</blockquote>
</li>
<li>
<p>Add the faa schema to the search path:</p>

<blockquote>
<p><code>tutorial=# SET SEARCH_PATH TO faa, public, pg_catalog, gp_toolkit;</code>  </p>
</blockquote>
</li>
<li>
<p>View the search path:</p>

<blockquote>
<pre><code>tutorial=# SHOW search_path;
             search_path
-------------------------------------
 faa, public, pg_catalog, gp_toolkit
(1 row)
</code></pre>
</blockquote>
</li>
<li>
<p>The search path you set above is not persistent; you have to set it each time you connect to the database. You can associate a search path with the user role by using the ALTER ROLE command, so that each time you connect to the database with that role, the search path is restored:  </p>

<blockquote>
<p><code>tutorial=# ALTER ROLE user1 SET search_path TO faa, public, pg_catalog, gp_toolkit;</code></p>
</blockquote>
</li>
<li>
<p>Exit out of the psql shell:</p>

<blockquote>
<p><code>tutorial=# \q</code></p>
</blockquote>
</li>
</ol>
