---
layout: default
title:  "Importing into VMware Fusion"
permalink: /importing-into-vmware-fusion
---


<h2 class='inline-header'>Importing into VMware Fusion</h2>

<p>These instructions will assist you in Importing this VM into VMware Fusion and then installing VMware Tools into the VM.</p>

<ol>
<li>Select File / Import then Choose the OVA File to import and hit Continue.</li>
<li>Choose a Location to store the new VM and hit Save.  This will begin the Import process.   If you have any issues (older versions of Fusion sometimes stop), click relax the settings and Import the VM again.</li>
<li><p>Click Customize Settings at the end of the Import process.<br>
<img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import1.jpg" width="400" alt="VMWare Fusion import VM">  </p></li>
<li>
<p>Click General Icon under System Settings</p>

<p><img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import2.jpg" width="400" alt="VMWare Fusion system settings">   </p>
</li>
<li>
<p>Then click the box next to OS, select Linux, and then Centos 64-bit. Then finally click Change. This will allow Fusion to select the proper Tools package to mount to the host. Close out the Settings Window and Start the VM.  </p>

<p><img src="https://raw.githubusercontent.com/greenplum-db/gpdb-sandbox-tutorials/gh-pages/images/import3.jpg" width="400" alt="VMWare Fusion VM settings"> </p>
</li>
<li><p>The VM startup might ask about a Virtual IDE device, if so, select No.  This will keep the VM from asking this question on EVERY boot.</p></li>
<li>Login to the VM as root</li>
<li>In the VMware Fusion menus, Select Virtual Machine / Install VMware Tools and then choose Install.</li>
<li>
<p>At the root prompt in the VM:  </p>

<blockquote>
<p><code>mkdir /mnt/dvd</code><br>
<code>mount /dev/dvd2 /mnt/dvd -t iso9660</code>
<code>tar xvfz /mnt/dvd/VMwareTools*.tar.gz -C /tmp</code>
<code>/tmp/vmware-tools-distrib/vmware-install.pl</code></p>
</blockquote>
</li>
<li><p>Follow the prompts and finish the install of VMware Tools.</p></li>
<li>In the VMware Fusion menus, Select Virtual Machine / Cancel VMware Tools Installation</li>
<li>Note:  X-Windows System is not installed.  To install:
&gt;<code>yum groupinstall 'X Window System'</code>
</li>
</ol>
