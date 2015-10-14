<img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VOU5MUmh3MzMydlk" width="750">
<h1 align="center">An Introduction and Greenplum DB Tutorial</h1>
<h1 align="center">using the</h1>
<h1 align="center">Greenplum DB Sandbox VM</h1>



-----------------------------------

About the Greenplum Architecture
--------------------------------

Pivotal Greenplum Database is a massively parallel processing (MPP) database server with an architecture specially designed to manage large-scale analytic data warehouses and business intelligence workloads.

MPP (also known as a shared nothing architecture) refers to systems with two or more processors that cooperate to carry out an operation, each processor with its own memory, operating system and disks. Greenplum uses this high-performance system architecture to distribute the load of multi-terabyte data warehouses, and can use all of a system's resources in parallel to process a query.

Greenplum Database is based on PostgreSQL open-source technology. It is essentially several PostgreSQL database instances acting together as one cohesive database management system (DBMS). It is based on PostgreSQL 8.2.15, and in most cases is very similar to PostgreSQL with regard to SQL support, features, configuration options, and end-user functionality. Database users interact with Greenplum Database as they would a regular PostgreSQL DBMS.

The internals of PostgreSQL have been modified or supplemented to support the parallel structure of Greenplum Database. For example, the system catalog, optimizer, query executor, and transaction manager components have been modified and enhanced to be able to execute queries simultaneously across all of the parallel PostgreSQL database instances. The Greenplum interconnect (the networking layer) enables communication between the distinct PostgreSQL instances and allows the system to behave as one logical database.

Greenplum Database also includes features designed to optimize PostgreSQL for business intelligence (BI) workloads. For example, Greenplum has added parallel data loading (external tables), resource management, query optimizations, and storage enhancements, which are not found in standard PostgreSQL. Many features and optimizations developed by Greenplum make their way into the PostgreSQL community. For example, table partitioning is a feature first developed by Greenplum, and it is now in standard PostgreSQL.

Greenplum Database stores and processes large amounts of data by distributing the data and processing workload across several servers or hosts. Greenplum Database is an array of individual databases based upon PostgreSQL 8.2 working together to present a single database image. The master is the entry point to the Greenplum Database system. It is the database instance to which clients connect and submit SQL statements. The master coordinates its work with the other database instances in the system, called segments, which store and process the data.

Figure 1. High-Level Greenplum Database Architecture  
<img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VM2Y2bjh1VUx1c3M" width="400">  

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



Greenplum Database Tutorial
-----------------

This tutorial showcases how GPDB can address day-to-day tasks performed in typical DW/BI environments. It is designed to be used with the Greenplum Database Sandbox VM that is available for download.

The scripts/data for this tutorial are in the gpdb-sandbox virtual machine at /home/gpadmin.   The repository is pre-cloned, but will update as the VM boots in order to provide the most recent version of these instructions.

 - Import the GPDB Sandbox Virtual Machine into VMware Fusion or Virutal Box
 - Start the GPDB Sandbox Virtual Machine.  Once the machine starts, you will see the following screen
![](https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VUUtkUERxbFNZd00)
This screen provides you all the information you need to interact with the VM.
	 - Username/Password combinations
	 - Managment URLs
	 - IP address for SSH Connection

Interacting with the Sandbox via a new terminal is preferable, as it makes many of the operations simpler.  

This tutorial is based on a freely-available datasets with statistics from the 2013 NFL Football Season.   


****
Lesson 1: Parallel Data Loading
----------

In a large scale, multi-terabyte data warehouse, large amounts of data must be loaded within a relatively small maintenance window. Greenplum supports fast, parallel data loading with its external tables feature. Administrators can also load external tables in single row error isolation mode to filter bad rows into a separate error table while continuing to load properly formatted rows. Administrators can specify an error threshold for a load operation to control how many improperly formatted rows cause Greenplum to abort the load operation.

By using external tables in conjunction with Greenplum Database's parallel file server (gpfdist), administrators can achieve maximum parallelism and load bandwidth from their Greenplum Database system.

Figure 1. External Tables Using Greenplum Parallel File Server (gpfdist) 

<img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VME5JMDZCNmE2cGs" width="500">

Another Greenplum utility, gpload, runs a load task that you specify in a YAML-formatted control file. You describe the source data locations, format, transformations required, participating hosts, database destinations, and other particulars in the control file and gpload executes the load. This allows you to describe a complex task and execute it in a controlled, repeatable fashion.

This tutorial will demonstrate how to load an external csv delimited file into the Greenplum Database using the **gpfdist** parallel data load utility.

 1. Open a terminal and ssh into the sandbox machine. 
 Type: `ssh gpadmin@X.X.X.X`

 2. Start the Greeplum Database. 
Type: `./start_all.sh`

 3. Type: `cd gpdb-sandbox-tutorials`
 
 4. The first step is to create the database and the associated tables for these demos.  To make the process easier, a script has been provided that contains all the needed ddl statements.  Here is a look inside the file:  
	 <img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VNDlIeUsxdTVjM00" width="500">

 5. Now, we need to setup **gpfdist** to serve the external data file.
	
	First, start the **gpfdist** utility  
	Type: `gpfdist -d /home/gpadmin/gpdb-sandbox-tutorials/data -p 8081 -l /home/gpadmin/gpdb-sandbox-tutorials/gpfdist.log &`
		
	This will start the gpfdist server with the data directory as its source, so that any external tables built will be able to poin to any files there firectly or via a wildcard.  In this example, we will point to the file directly.
		
	Now, we can create an Greenplum External Table to point directly to the data file.  There is a pre-created shell-script to do this.  The script removes the tables if it already exists and the creates an external table in the image of the playbyplay table create in an earlier step.  
	
	<img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VLXVIbkJwcnJJdjQ" width="800">
	
	Type: `psql -f ext_table.sql` to run the shell-script.
 6. We can now load a native Greenplum table (playbyplay) by querying the external table directly and inserting the data. But first we will run a couple of quick tests to show a before and after look at the tables.  
	Start psql by typing:  `psql`  
	Now, let's generate a count of the rows in the playbyplay table that was created earlier.  
	At the psql prompt type:  `select count(*) from playbyplay;`  
	This should return a count of 0 rows.  If we run the same command against the external table we will get a count of the rows in our data file,   
	Type:  `select count(*) from ext_playbyplay;`  
	This returns 47990 rows.  
 7. Load the data into Greenplum using a psql command,   
    Type: `insert into playbyplay (select * from ext_ playbyplay);`  
	Since we are querying a file that is being accessed via gpfdist, the load happens in parallel across all segments of the Greenplum Database.  Further scalability can be achieved by running multiple gpfdist instances and having multiple datafile.   Once, the load is complete, we can check the count of rows in the playbyplay table again,     
	Type: `select count(*) from playbyplay;`    
	Now, it should report 47990 rows, or the same number from our data file.  
 Log out of psql by typing: `\q` then press enter.
 
 8. External Tables can also point at sources other than local files.  Web External tables allow Greenplum Database to treat dynamic data sources like regular database tables. The sources can be either a linux command or a URL.  In this example, we will read the weather information for 2013 directly from the GitHub site that this tutorial is stored.  
	Type: `psql -f ext_web_tables.sql`

 9. Start the psql client, type: `psql`
	 
	 You can test the Web External Table by just querying some rows. Run the following query to test.  
	 Type: `select * from ext_weather limit 10;`
	
	<img src="https://drive.google.com/uc?export=&id=0B5ncp8FqIy8VT0VuRGNEU2N5RkE" width="800">
		
 10. Now, we can load the data from the External Web Table into the Greenplum Database.  
	Type: `insert into weather (select * from ext_weather)`  
	This should report that 22384 rows were inserted.
	
This concludes the lesson on Loading Data into the Greenplum Database.  The next lesson will cover querying the database.
	
****
Lesson 2: Querying the Database
----------	
 
****
Lesson 3: Partitioning Tables
----------	

****
Lesson 4: Advanced Analytics with the Greenplum Database
----------	



