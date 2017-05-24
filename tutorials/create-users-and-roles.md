---
layout: default
title:  "Create Users and Roles"
permalink: /create-users-and-roles
---


<h2 class='inline-header'>Create Users and Roles</h2>

<p>Greenplum Database manages database access using roles. Initially, there is one superuser role—the role associated with the OS user who initialized the database instance, usually gpadmin. This user owns all of the Greenplum Database files and OS processes, so it is important to reserve the gpadmin role for system tasks only.  </p>

<p>A role can be a user or a group. A user role can log in to a database; that is, it has the LOGIN attribute. A user or group role can become a member of a group.</p>

<p>Permissions can be granted to users or groups. Initially, of course, only the gpadmin role is able to create roles. You can add roles with the createuser utility command, CREATE ROLE SQL command, or the CREATE USER SQL command. The CREATE USER command is the same as the CREATE ROLE command except that it automatically assigns the role the LOGIN attribute. </p>

<h3>
<a id="exercises" class="anchor" href="#exercises" aria-hidden="true"><span class="octicon octicon-link"></span></a>Exercises</h3>

<h4>
<a id="create-a-user-with-the-createuser-utility-command" class="anchor" href="#create-a-user-with-the-createuser-utility-command" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create a user with the createuser utility command</h4>

<ol>
<li>Login to the GPDB Sandbox as the gpadmin user.<br>
</li>
<li>
<p>Enter the <em>createuser</em> command and reply to the prompts:  </p>

<blockquote>
<p><code>$ createuser -P user1</code></p>

<pre><code>Enter password for new role:
Enter it again:
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) y
Shall the new role be allowed to create more new roles? (y/n) n
NOTICE:  resource queue required -- using default resource queue
"pg_default"
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="create-a-user-with-the-create-user-command" class="anchor" href="#create-a-user-with-the-create-user-command" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create a user with the CREATE USER command</h4>

<ol>
<li>
<p>Connect to the template1 database as gpadmin:  </p>

<blockquote>
<p><code>$ psql template1</code></p>
</blockquote>
</li>
<li>
<p>Create a user with the name user2:  </p>

<blockquote>
<p><code>template1=#  CREATE USER user2 WITH PASSWORD 'pivotal' NOSUPERUSER;</code>  </p>
</blockquote>
</li>
<li>
<p>Display a list of roles:  </p>

<blockquote>
<pre><code>template1=# \du
                       List of roles
 Role name |            Attributes             | Member of
-----------+-----------------------------------+-----------
 gpadmin   | Superuser, Create role, Create DB |
 gpmon     | Superuser, Create DB              |
 user1     | Create DB                         |
 user2     |                                   |
</code></pre>
</blockquote>
</li>
</ol>

<h4>
<a id="create-a-users-group-and-add-the-users-to-it" class="anchor" href="#create-a-users-group-and-add-the-users-to-it" aria-hidden="true"><span class="octicon octicon-link"></span></a>Create a users group and add the users to it</h4>

<ol>
<li>
<p>While connected to the template1 database as gpadmin enter the following SQL commands:</p>

<blockquote>
<pre><code>    template1=# CREATE ROLE users;
    template1=# GRANT users TO user1, user2;
</code></pre>
</blockquote>
</li>
<li>
<p>Display the list of roles again:</p>

<blockquote>
<pre><code>template1=# \du
                       List of roles
 Role name |            Attributes             | Member of
-----------+-----------------------------------+-----------
 gpadmin   | Superuser, Create role, Create DB |
 gpmon     | Superuser, Create DB              |
 user1     | Create DB                         | {users}
 user2     |                                   | {users}
 users     | Cannot login                      |
</code></pre>
</blockquote>
</li>
<li>
<p>Exit out of the psql shell:  </p>

<blockquote>
<p><code>template1=# \q</code></p>
</blockquote>
</li>
</ol>