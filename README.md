<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/GPDB.jpg" width="750">
<h1 align="center">An Introduction and Greenplum DB Tutorial using the GPDB Sandbox VM</h1>

****

These tutorials showcase how GPDB can address day-to-day tasks performed in typical DW/BI environments. It is designed to be used with the Greenplum Database Sandbox VM that is available for download.

The scripts/data for this tutorial are in the gpdb-sandbox virtual machine at /home/gpadmin.   The repository is pre-cloned, but will update as the VM boots in order to provide the most recent version of these instructions.

 - Import the GPDB Sandbox Virtual Machine into VMware Fusion or Virutal Box.  If you import into VMware Fusion and would like to install the VMware Tools, see [Appendix 1](#appendix1) 
 for installation details. 
 - Start the GPDB Sandbox Virtual Machine.  Once the machine starts, you will see the following screen
![](https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/Boot%20Image.jpg)
This screen provides you all the information you need to interact with the VM.
	 - Username/Password combinations
	 - Managment URLs
	 - IP address for SSH Connection

Interacting with the Sandbox via a new terminal is preferable, as it makes many of the operations simpler.  

To introduce Greenplum Database, we use a public data set, the Airline On-Time Statistics and Delay Causes data set, published by the United States Department of Transportation at http://www.transstats.bts.gov/.  The On-Time Performance dataset records flights by date, airline, originating airport, destination airport, and many other flight details. Data is available for flights since 1987. The exercises in this guide use data for about a million flights in 2009 and 2010.  The FAA uses the data to calculate statistics such as the percent of flights that depart or arrive on time by origin, destination, and airline. 

You are encouraged to review the SQL scripts in the faa directory as you work
through this introduction. You can run most of the exercises by entering the
commands yourself or by executing a script in the faa directory.
 

<a name="tutorials"></a>Tutorials
------------

* [Introduction to the Greenplum Database Architecture](#lesson0)
* [Lesson 1: Create Users and Roles](#lesson1)  
* [Lesson 2: Create and Prepare Database](#lesson2)   
* [Lesson 3: Create Tables](#lesson3) 
* [Lesson X:  ](#lesson4) 
* [Lesson X:  ](#lesson5) 
* [Appendix 1: Importing into VMware Fusion](#appendix1) 



-----------------------------------
<a name="lesson0"></a>Introduction to the Greenplum Database  Architecture
------------

[Pivotal Greenplum Database](http://greenplum.org) is a massively parallel processing (MPP) database server with an architecture specially designed to manage large-scale analytic data warehouses and business intelligence workloads.

MPP (also known as a shared nothing architecture) refers to systems with two or more processors that cooperate to carry out an operation, each processor with its own memory, operating system and disks. Greenplum uses this high-performance system architecture to distribute the load of multi-terabyte data warehouses, and can use all of a system's resources in parallel to process a query.

Greenplum Database is based on PostgreSQL open-source technology. It is essentially several PostgreSQL database instances acting together as one cohesive database management system (DBMS). It is based on PostgreSQL 8.2.15, and in most cases is very similar to PostgreSQL with regard to SQL support, features, configuration options, and end-user functionality. Database users interact with Greenplum Database as they would a regular PostgreSQL DBMS.

The internals of PostgreSQL have been modified or supplemented to support the parallel structure of Greenplum Database. For example, the system catalog, optimizer, query executor, and transaction manager components have been modified and enhanced to be able to execute queries simultaneously across all of the parallel PostgreSQL database instances. The Greenplum interconnect (the networking layer) enables communication between the distinct PostgreSQL instances and allows the system to behave as one logical database.

Greenplum Database also includes features designed to optimize PostgreSQL for business intelligence (BI) workloads. For example, Greenplum has added parallel data loading (external tables), resource management, query optimizations, and storage enhancements, which are not found in standard PostgreSQL. Many features and optimizations developed by Greenplum make their way into the PostgreSQL community. For example, table partitioning is a feature first developed by Greenplum, and it is now in standard PostgreSQL.

Greenplum Database stores and processes large amounts of data by distributing the data and processing workload across several servers or hosts. Greenplum Database is an array of individual databases based upon PostgreSQL 8.2 working together to present a single database image. The master is the entry point to the Greenplum Database system. It is the database instance to which clients connect and submit SQL statements. The master coordinates its work with the other database instances in the system, called segments, which store and process the data.

Figure 1. High-Level Greenplum Database Architecture  
<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/highlevel_arch.jpg" width="400">  

The following topics describe the components that make up a Greenplum Database system and how they work together. 

**Greenplum Master**
The Greenplum Database master is the entry to the Greenplum Database system, accepting client connections and SQL queries, and distributing work to the segment instances.

Greenplum Database end-users interact with Greenplum Database (through the master) as they would with a typical PostgreSQL database. They connect to the database using client programs such as psql or application programming interfaces (APIs) such as JDBC or ODBC.

The master is where the global system catalog resides. The global system catalog is the set of system tables that contain metadata about the Greenplum Database system itself. The master does not contain any user data; data resides only on the segments. The master authenticates client connections, processes incoming SQL commands, distributes workloads among segments, coordinates the results returned by each segment, and presents the final results to the client program.

**Greenplum Segments**
Greenplum Database segment instances are independent PostgreSQL databases that each store a portion of the data and perform the majority of query processing.

When a user connects to the database via the Greenplum master and issues a query, processes are created in each segment database to handle the work of that query. For more information about query processes, see About Greenplum Query Processing.

User-defined tables and their indexes are distributed across the available segments in a Greenplum Database system; each segment contains a distinct portion of data. The database server processes that serve segment data run under the corresponding segment instances. Users interact with segments in a Greenplum Database system through the master.

Segments run on a servers called segment hosts. A segment host typically executes from two to eight Greenplum segments, depending on the CPU cores, RAM, storage, network interfaces, and workloads. Segment hosts are expected to be identically configured. The key to obtaining the best performance from Greenplum Database is to distribute data and workloads evenly across a large number of equally capable segments so that all segments begin working on a task simultaneously and complete their work at the same time.

**Greenplum Interconnect**
The interconect is the networking layer of the Greenplum Database architecture.

The interconnect refers to the inter-process communication between segments and the network infrastructure on which this communication relies. The Greenplum interconnect uses a standard 10-Gigabit Ethernet switching fabric.

By default, the interconnect uses User Datagram Protocol (UDP) to send messages over the network. The Greenplum software performs packet verification beyond what is provided by UDP. This means the reliability is equivalent to Transmission Control Protocol (TCP), and the performance and scalability exceeds TCP. If the interconnect used TCP, Greenplum Database would have a scalability limit of 1000 segment instances. With UDP as the current default protocol for the interconnect, this limit is not applicable.

**Pivotal Query Optimizer**
The Pivotal Query Optimizer brings a state of the art query optimization framework to Greenplum Database that is distinguished from other optimizers in several ways:

 - Modularity.  Pivotal Query Optimizer is not confined inside a single RDBMS. It is currently leveraged in both Greenplum Database and Pivotal HAWQ, but it can also be run as a standalone component to allow greater flexibility in adopting new backend systems and using the optimizer as a service. This also enables elaborate testing of the optimizer without going through the other components of the database stack.
 
 - Extensibility.  The Pivotal Query Optimizer has been designed as a collection of independent components that can be replaced, configured, or extended separately. This significantly reduces the development costs of adding new features, and also allows rapid adoption of emerging technologies. Within the Query Optimizer, the representation of the elements of a query has been separated from how the query is optimized. This lets the optimizer treat all elements equally and avoids the issues with the imposed order of optimizations steps of multi-phase optimizers.

 - Performance.  The Pivotal Query Optimizer leverages a multi-core scheduler that can distribute individual optimization tasks across multiple cores to speed up the optimization process. This allows the Query Optimizer to apply all possible optimizations as the same time, which results in many more plan alternatives and a wider range of queries that can be optimized. For instance, when the Pivotal Query Optimizer was used with TPC-H Query 21 it generated 1.2 Billion possible plans in 250 ms. This is especially important in Big Data Analytics where performance challenges are magnified by the volume of data that needs to be processed. A suboptimal optimization choice could very well lead to a query that just runs forever.

[Return to Tutorial List](#tutorials)  

***  

<a name="lesson1"></a>Lesson 1: Create Users and Roles
------------
Greenplum Database manages database access using roles. Initially, there is one superuser role—the role associated with the OS user who initialized the database instance, usually gpadmin. This user owns all of the Greenplum Database files and OS processes, so it is important to reserve the gpadmin role for system tasks only.  

A role can be a user or a group. A user role can log in to a database; that is, it has the LOGIN attribute. A user or group role can become a member of a group.

Permissions can be granted to users or groups. Initially, of course, only the gpadmin role is able to create roles. You can add roles with the createuser utility command, CREATE ROLE SQL command, or the CREATE USER SQL command. The CREATE USER command is the same as the CREATE ROLE command except that it automatically assigns the role the LOGIN attribute. 

**Create a user with the createuser utility command**

1. Login to the GPDB Sandbox as the gpadmin user.  
2. Enter the *createuser* command and reply to the prompts:  
>`$ createuser -P user11`  

	```
	[gpadmin@gpdb-sandbox ~]$ createuser -P user1  
Enter password for new role:  
Enter it again:  
Shall the new role be a superuser? (y/n) n  
Shall the new role be allowed to create databases? (y/n) y  
Shall the new role be allowed to create more new roles? (y/n) n  
NOTICE:  resource queue required -- using default resource queue "pg_default"  
	```
	
**Create a user with the CREATE USER command**  

1. Connect to the template1 database as gpadmin:  
>`$ psql template1`

2. Create a user with the name user2:  
>`template1=#  CREATE USER user2 WITH PASSWORD 'pivotal' NOSUPERUSER;`  

3. Display a list of roles:  
>
```
template1=# \du
                       List of roles
 Role name |            Attributes             | Member of
-----------+-----------------------------------+-----------
 gpadmin   | Superuser, Create role, Create DB |
 gpmon     | Superuser, Create DB              |
 user1     | Create DB                         |
 user2     |                                   |
 ``` 

**Create a users group and add the users to it**

1. While connected to the template1 database as gpadmin enter the following SQL commands:
>
```  
	template1=# CREATE ROLE users;  
	template1=# GRANT users TO user1, user2;  
```

2. Display the list of roles again:
>
```
template1=# \du
                       List of roles
 Role name |            Attributes             | Member of
-----------+-----------------------------------+-----------
 gpadmin   | Superuser, Create role, Create DB |
 gpmon     | Superuser, Create DB              |
 user1     | Create DB                         | {users}
 user2     |                                   | {users}
 users     | Cannot login                      |
 ```


<a name="lesson2"></a>Lesson 2: Create and Prepare Database
------------
Create a new database with the CREATE DATABASE SQL command in psql or the createdb utility command in a terminal. The new database is a copy of the template1 database, unless you specify a different template.
To use the CREATE DATABASE command, you must be connected to a database. With a newly installed Greenplum Database system, you can connect to the template1 database to create your first user database. The createdb utility, entered at a shell prompt, is a wrapper around the CREATE DATABASE command. In this exercise you will drop the tutorial database if it exists and then create it new with the createdb utility.  

**Create Database**   

1. Enter these commands to drop the tutorial database if it exists:  
>`$ dropdb tutorial`  

2. Enter the createdb command to create the tutorial database, with the defaults:  
>`$ createdb tutorial`

3. Verify that the database was created using the *psql -l* command:  
>
```
[gpadmin@gpdb-sandbox ~]$ psql -l
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
```  
4. Connect to the tutorial database as user1, entering the password you created
for user1 when prompted:  
>`psql -U user1 tutorial` 

**Grant database privileges to users**  

In a production database, you should grant users the minimum permissions required to do their work. For example, a user may need SELECT permissions on a table to view data, but not UPDATE, INSERT, or DELETE to modify the data.  To complete the exercises in this guide, the database users will require permissions to create and manipulate objects in the tutorial database.  

1. Connect to the tutorial database as gpadmin.  
>`$ psql -U gpadmin tutorial`

2. Grant user1 and user2 all privileges on the tutorial database.    
>`tutorial=# GRANT ALL PRIVILEGES ON DATABASE tutorial TO user1, user2;`  

3. Log out of psql and perform the next steps as the user1 role.  
>`tutorial=# \q`

**Create a schema and set a search path**  

A database schema is a named container for a set of database objects, including tables, data types, and functions. A database can have multiple schemas. Objects within the schema are referenced by prefixing the object name with the schema name, separated with a period. For example, the person table in the employee schema is written employee.person.

The schema provides a namespace for the objects it contains. If the database is used for multiple applications, each with its own schema, the same table name can be used in each schema employee.person is a different table than customer.person. Both tables could be accessed in the same query as long as they are qualified with the schema name.

The database contains a schema search path, which is a list of schemas to search for objects names that are not qualified with a schema name. The first schema in the search path is also the schema where new objects are created when no schema is specified. The default search path is user,public, so by default, each object you create belongs to a schema associated with your login name.  In this exercise, you create an faa schema and set the search path so that it is the default schema.

1. Change to the directory containing the FAA data and scripts:
>`$ cd ~/gpdb-sandbox-tutorials/faa`

2. Connect to the tutorial database with psql:
>`$ psql -U user1 tutorial`  

3. Create the faa schema:
>
```
tutorial=# DROP SCHEMA IF EXISTS faa CASCADE;  
tutorial=# CREATE SCHEMA faa;  
```

4. Add the faa schema to the search path:
>`tutorial=# SET SEARCH_PATH TO faa, public, pg_catalog, gp_toolkit;`  

5. View the search path:
>`tutorial=# SHOW search_path;`

6. The search path you set above is not persistent; you have to set it each time you
connect to the database. You can associate a search path with the user role by using the
ALTER ROLE command, so that each time you connect to the database with that role, the search path is restored:  
>`tutorial=# ALTER ROLE user1 SET search_path TO faa, public, pg_catalog, gp_toolkit;`

<a name="lesson3"></a>Lesson 3: Create Tables
------------












<a name="lesson2"></a>Lesson 2: Parallel Data Loading
------------

In a large scale, multi-terabyte data warehouse, large amounts of data must be loaded within a relatively small maintenance window. Greenplum supports fast, parallel data loading with its external tables feature. Administrators can also load external tables in single row error isolation mode to filter bad rows into a separate error table while continuing to load properly formatted rows. Administrators can specify an error threshold for a load operation to control how many improperly formatted rows cause Greenplum to abort the load operation.

By using external tables in conjunction with Greenplum Database's parallel file server (gpfdist), administrators can achieve maximum parallelism and load bandwidth from their Greenplum Database system.

Figure 1. External Tables Using Greenplum Parallel File Server (gpfdist) 

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/ext_tables.jpg" width="500">

Another Greenplum utility, gpload, runs a load task that you specify in a YAML-formatted control file. You describe the source data locations, format, transformations required, participating hosts, database destinations, and other particulars in the control file and gpload executes the load. This allows you to describe a complex task and execute it in a controlled, repeatable fashion.

**Exercises**  
For the FAA fact table, we will use an ETL (Extract, Transform, Load) process to load data from the source gzip files into a loading table, and then insert the data into a query and reporting table. For the best load speed, use the gpfdist Greenplum utility to distribute the rows to the segments. In a production system, gpfdist runs on the servers where the data is located. With a single-node Greenplum Database instance, there is only one host, and you run gpdist on it. Starting gpfdist is like starting a file server; there is no data movement until a request is made on the process.

*Note: This exercise loads data using the Greenplum Database external table feature
to move data from external data files into the database. Moving data between the
database and external tables is a security consideration, so only superusers are
permitted to use the feature. Therefore, you will run this exercise as the gpadmin
database user.*

 1. From a terminal, ssh to the Sandbox VM as gpadmin using the IP Address found in the boot-up screen (as seen below)  
 
	>`ssh gpadmin@X.X.X.X`  In the example shown, this would be ssh gpadmin@192.168.9.132 
 
 <img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/Boot_Image_HLjpg.jpg" width="800">
 	
 2. If you haven't already started the Greenplum Database.  
	>`./start_all.sh`  
 
 3. Change to the tutorials directory.
	> `cd gpdb-sandbox-tutorials`  
 
 4. The first step is to create the database and the associated tables for these tutorials.  The CREATE TABLE statements for the faa database are in the faa/create_dim_tables.sql script. Open the script in a text editor to see the text  of the commands that will be executed when you run the script.
	 <img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/create.jpg" width="500">  
	 Execute the DDL file and create the tables.  
>`psql -f faa/create_dim_tables.sql` 

 5. Now, we need to setup **gpfdist** to serve the external data file.
	
	First, start the **gpfdist** utility.  
>`gpfdist -d /home/gpadmin/gpdb-sandbox-tutorials/data -p 8081 -l /home/gpadmin/gpdb-sandbox-tutorials/gpfdist.log &`
		
	This will start the gpfdist server with the data directory as its source, so that any external tables built will be able to poin to any files there firectly or via a wildcard.  In this example, we will point to the file directly.
		
	Now, we can create an Greenplum External Table to point directly to the data file.  There is a pre-created shell-script to do this.  The script removes the tables if it already exists and the creates an external table in the image of the playbyplay table create in an earlier step.  
	
	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/exttable.jpg" width="800">
Execute the DDL script to create the external table.
>`psql -f ext_table.sql`   
 6. We can now load a native Greenplum table (playbyplay) by querying the external table directly and inserting the data. But first we will run a couple of quick tests to show a before and after look at the tables.  
	Start psql:
>`psql` 
 
	Now, let's generate a count of the rows in the playbyplay table that was created earlier.  
	At the psql prompt type:  
>`select count(*) from playbyplay;`  

	This should return a count of 0 rows.  If we run the same command against the external table we will get a count of the rows in our data file.  From the psql prompt type:
>`select count(*) from ext_playbyplay;`  

	This returns 47990 rows.  
 7. Now the data can be loaded into Greenplum using a psql command.  
>`insert into playbyplay (select * from ext_playbyplay);`   

	Since we are querying a file that is being accessed via gpfdist, the load happens in parallel across all segments of the Greenplum Database.  Further scalability can be achieved by running multiple gpfdist instances and having multiple datafile.   Once, the load is complete, we can check the count of rows in the playbyplay table again.  From the psql prompt type:  
>`select count(*) from playbyplay;`    
	
	Now, it should report 47990 rows, or the same number from our data file.  
 Log out of psql by typing: `\q` then press enter.
 
 8. External Tables can also point at sources other than local files.  Web External tables allow Greenplum Database to treat dynamic data sources like regular database tables. The sources can be either a linux command or a URL.  In this example, we will read the weather information for 2013 directly from the GitHub site that this tutorial is stored.  Look inside the provided DDL script to see how the web external table is created.
>`more ext_web_tables.sql`

 To create the web external table, execute the following DDL script.
>`psql -f ext_web_tables.sql`

 9. Start the psql client, type: `psql`
	 
	 You can test the Web External Table by just querying some rows. Run the following query to test.  
>`select * from ext_weather limit 10;`
	
	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/webtest.jpg" width="800">  
 10. Now, we can load the data from the External Web Table into the Greenplum Database.  From the psql prompt type:
>`insert into weather (select * from ext_weather);`  

	This should report that 22384 rows were inserted.
	You can also query the newly loaded table to verify the table load.  
>`select * from weather limit 10;`

	This should return a data set that resembles the one shown above for ext_weather.
	
This concludes the lesson on Loading Data into the Greenplum Database.  The next lesson will cover querying the database.   

[Return to Tutorial List](#tutorials)  

****

<a name="lesson2"></a>Lesson 2: Querying the Database
--------	

This lesson provides an overview of how Greenplum Database processes queries. Understanding this process can be useful when writing and tuning queries.
 
Users issue queries to Greenplum Database as they would to any database management system. They connect to the database instance on the Greenplum master host using a client application such as psql and submit SQL statements.  In this lesson, you will use [Apache Zeppelin (incubating)](https://zeppelin.incubator.apache.org/) to submit SQL statements to the Greenplum Database.  Apache Zeppelin is a web-based notebook that enables interactive data analytics.  A [PostgeSQL interpreter](https://issues.apache.org/jira/browse/ZEPPELIN-250) has been added to Zeppelin, so that it can now work directly with products such as Pivotal Greenplum Database and Pivotal HDB. 

**Understanding Query Planning and Dispatch**  
The master receives, parses, and optimizes the query. The resulting query plan is either parallel or targeted. The master dispatches parallel query plans to all segments, as shown in Figure 1. Each segment is responsible for executing local database operations on its own set of data.query plans.

Most database operations—such as table scans, joins, aggregations, and sorts—execute across all segments in parallel. Each operation is performed on a segment database independent of the data stored in the other segment databases.

Figure 1. Dispatching the Parallel Query Plan  
<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/dispatch.jpg" width="400">
 	  
**Understanding Greenplum Query Plans**    
A query plan is the set of operations Greenplum Database will perform to produce the answer to a query. Each node or step in the plan represents a database operation such as a table scan, join, aggregation, or sort. Plans are read and executed from bottom to top.

In addition to common database operations such as tables scans, joins, and so on, Greenplum Database has an additional operation type called motion. A motion operation involves moving tuples between the segments during query processing.

To achieve maximum parallelism during query execution, Greenplum divides the work of the query plan into slices. A slice is a portion of the plan that segments can work on independently. A query plan is sliced wherever a motion operation occurs in the plan, with one slice on each side of the motion.

**Understanding Parallel Query Execution** 
Greenplum creates a number of database processes to handle the work of a query. On the master, the query worker process is called the query dispatcher (QD). The QD is responsible for creating and dispatching the query plan. It also accumulates and presents the final results. On the segments, a query worker process is called a query executor (QE). A QE is responsible for completing its portion of work and communicating its intermediate results to the other worker processes.

There is at least one worker process assigned to each slice of the query plan. A worker process works on its assigned portion of the query plan independently. During query execution, each segment will have a number of processes working on the query in parallel.

Related processes that are working on the same slice of the query plan but on different segments are called gangs. As a portion of work is completed, tuples flow up the query plan from one gang of processes to the next. This inter-process communication between the segments is referred to as the interconnect component of Greenplum Database.  

**Exercises**  
Now, that query execution has been explained, let's run some queries.

 1. From a terminal, ssh to the Sandbox VM as gpadmin using the IP Address found in the boot-up screen (as seen below)  
>`ssh gpadmin@X.X.X.X`  

	In the example shown, this would be ssh gpadmin@192.168.9.132

 	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/Boot_Image_HLjpg.jpg" width="800">  

 2. Start the Greenplum Database if you haven't already started it.
>`./start_all.sh`  
 3. Open a browser on your desktop and browse to `http://X.X.X.X:8080` using the same IP address that you used for the ssh step. You will see the Apache Zepplin Welcome page.
 	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/zepp.jpg" width="500">  
  
 4. Click on Create new note underneath the Notebook heading and type: `tutorial`
 	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/zep-create.jpg" width="500">  

 5. Click "tutorial" to open the newly created notebook.  Or, if you prefer, there is already a notebook created called football that has the queries and paragraphs pre-created.  If you choose this option, the Interpretor Binding options will display at the top, scroll down and hit save to close this portion of the screen.
 6. You should now see the the open notebook with a "paragraph" ready for input.  Click in the the empty white rectangle (called paragraph) and type: 
>`%psql.sql select count(*) from playbyplay;`  

 The result should look like the graphic below.
 
 7. Next, let's try a more compex query and try out some of the visualization features of Zepplin. In a new paragraph type:
   
	>    ```
	%psql.sql  SELECT p.offense,w.temperature,count(*) FROM weather w,
	playbyplay p WHERE w.date=p.gamedate AND (upper(w.hometeam) = p.offense
	OR upper(w.hometeam) = p.defense) AND p.isinterception = true
	AND p.offense SIMILAR TO '[ABCD]%' GROUP BY p.offense,w.temperature  
	ORDER BY p.offense;
	
	This should return a data set showing team abbreviation, game temperature, and number of interceptions.   This query scans all the offensive plays in 2013 and returns any that were interceptions and the temperature of that game for teams that begin with A,B,C, or D.  

8. There is a row of icons underneath the query.  The one on the far right is a scatter-plot, click that.  You will then be able to drag the fields of the query into the axis of the plot.  Drag offense to the xAxis, temperature to the yAxis, and count to size.  You should now see a scatter plot with the vertical axis showing the number of interceptions per team at a given temperature.  The size of the "dot" represents the relative number of interceptions.  
  	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/scatter.jpg" width="800">  
9. The final query leverages subquerys to determine how many interceptions each team threw at home versus on the road for the season.  Once again, for display purposes, the teams have been limited to those beginning with A-D.
  
>```
%psql.sql select home.team,home.homeint,road.roadint from (select p.offense
as team,count(*) as roadint from weather w,playbyplay p 
where w.date=p.gamedate and (upper(w.hometeam) =  p.defense) and 
p.isinterception = true group by p.offense) road,
(select p.offense as team ,count(*) as homeint from weather w,
playbyplay p where w.date=p.gamedate and (upper(w.hometeam) =  p.offense)
and p.isinterception = true group by p.offense) home 
where home.team = road.team and home.team similar to '[ABCD]%'  
order by homeint;  
```  
   
[Return to Tutorial List](#tutorials)  


****
<a name="lesson3"></a>Lesson 3: Creating Partitioned Tables
------

Table partitioning enables supporting very large tables, such as fact tables, by logically dividing them into smaller, more manageable pieces. Partitioned tables can improve query performance by allowing the Greenplum Database query optimizer to scan only the data needed to satisfy a given query instead of scanning all the contents of a large table.

Partitioning does not change the physical distribution of table data across the segments. Table distribution is physical: Greenplum Database physically divides partitioned tables and non-partitioned tables across segments to enable parallel query processing. Table partitioning is logical: Greenplum Database logically divides big tables to improve query performance and facilitate data warehouse maintenance tasks, such as rolling old data out of the data warehouse.

Greenplum Database supports:

* Range partitioning: division of data based on a numerical range, such as date or price.  
* List partitioning: division of data based on a list of values, such as sales territory or product line.  
* A combination of both types.  

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/part.jpg" width="400">  

**Exercises**  

This exercise will demonstrate how to create a range partitioned table and loading it via external table.

The DDL to create the partitioned table is in the file create_part.sql. This snapshot shows the relevant portion of the file.  

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/createpart.jpg" width="600">  

This statement defines a RANGE partition using the date the player was drafted as the partition key.   The START/END represent the high and low of the values in that column.  EVERY defines the partition granularity or how many of the values from the range will be within a single partition.   The DEFAULT PARTITION is the partition that values that don't match any of the defined partitions are inserted into.  

First, create the partitioned table and the External Table use to query the data file:
> `psql -f create_part.sql`  

This is the output from that ddl.  You can see the partitions were created.  

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/part-output.jpg" width="600">  

Now, query the external data and insert data into the partitioned table.    
Launch psql:  
> `psql`  

Then, type:  
> `insert into players (select * from ext_players);`
  
[Return to Tutorial List](#tutorials)  

****
<a name="lesson4"></a>Lesson 4: Advanced Analytics with the Greenplum Database
------	
***COMING SOON!***  
[PivotalR](https://cran.r-project.org/web/packages/PivotalR/vignettes/pivotalr.pdf)
T

****
<a name="lesson5"></a>Lesson 5: Backup and Recovery Operations
----------	
The Greenplum Database parallel dump utility gpcrondump backs up the Greenplum master instance and each active segment instance at the same time.

By default, gpcrondump creates dump files in the gp_dump subdirectory.

Several dump files are created for the master, containing database information such as DDL statements, the Greenplum system catalog tables, and metadata files. gpcrondump creates one dump file for each segment, which contains commands to recreate the data on that segment.

You can perform full or incremental backups. To restore a database to its state when an incremental backup was made, you will need to restore the previous full backup and all subsequent incremental backups.

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/backup.jpg" width="400"> 

Each file created for a backup begins with a 14-digit timestamp key that identifies the backup set the file belongs to.

gpchrondump can be run directly in a terminal on the master host, or you can add it to crontab on the master host to schedule regular backups.

**Exercises**

These exercises will walk through how to create a full backup of your database and then restore a table.
 
1) To run a full backup, use "gpcrondump -x database -u /path/for/backup -a".   This will backup the entire database to the directory given without prompting the user.
> `gpcrondump -x gpadmin -u /tmp -a`

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/gpcrondump.jpg" width="600"> 

This runs a full backup of the database created during the previous exercises.  To view the backups:
> `ls -al /tmp/db_dumps`  


The Greenplum Database parallel restore utility gpdbrestore takes the timestamp key generated by gpcrondump, validates the backup set, and restores the database objects and data into a distributed database in parallel. Parallel restore operations require a complete backup set created by gpcrondump, a full backup and any required incremental backups. 

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/restore.jpg" width="400"> 

The Greenplum Database gpdbrestore utility provides flexibility and verification options for use with the automated backup files produced by gpcrondump or with backup files moved from the Greenplum array to an alternate location. 

Now, that we have a full backup let's remove data from a table to simulate a failure.  Type `psql` to bring up a psql prompt:
>`select count(*) from weather;`

This should return 22384 rows in the table.  Let's truncate the table and then check the row count:
>```
truncate table weather;
select count(*) from weather;

The report should now show 0 rows in the table. So, let's restore the data. First, exit from the psql shell by typing `\q` then issue the gpdbrestore command:
>`gpdbrestore -T public.weather -s gpadmin -u /tmp -a`

<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/gpdbrestore.jpg" width="600"> 


Once this is complete, launch the psql shell again: `psql` and then check the status of the weather table:
>`select count(*) from weather;`

The table should show 22384 rows again as it was prior to the truncate call.

[Return to Tutorial List](#tutorials)  

****
<a name="appendix1"></a>Appendix 1: Importing into VMware Fusion
------	

These instructions will assist you in Importing this VM into VMware Fusion and then installing VMware Tools into the VM.

1. Select File / Import then Choose the OVA File to import and hit Continue.
2. Choose a Location to store the new VM and hit Save.  This will begin the Import process.   If you have any issues (older versions of Fusion sometimes stop), click relax the settings and Import the VM again.
3. Click Customize Settings at the end of the Import process.  
	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import1.jpg" width="400">  

4. Click General Icon under System Settings
  
	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import2.jpg" width="400">   

5. Then click the box next to OS, select Linux, and then Centos 64-bit. Then finally click Change. This will allow Fusion to select the proper Tools package to mount to the host. Close out the Settings Window and Start the VM.  

	<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import3.jpg" width="400"> 

6. The VM startup might ask about a Virtual IDE device, if so, select No.  This will keep the VM from asking this question on EVERY boot.
7. Login to the VM as root
8. In the VMware Fusion menus, Select Virtual Machine / Install VMware Tools and then choose Install.
9. At the root prompt in the VM:  

	>`mkdir /mnt/dvd`  
	>`mount /dev/dvd2 /mnt/dvd -t iso9660`
	>`tar xvfz /mnt/dvd/VMwareTools*.tar.gz -C /tmp`
	>`/tmp/vmware-tools-distrib/vmware-install.pl`
	
10. Follow the prompts and finish the install of VMware Tools.
11. In the VMware Fusion menus, Select Virtual Machine / Cancel VMware Tools Installation
* Note:  X-Windows System is not installed.  To install:
>`yum groupinstall 'X Window System'`


	

 


[Return to Tutorial List](#tutorials)  
