# File and Directory Monitor

See http://uptimesoftware.github.io for more information.

### Tags 
 plugin   logs  

### Category

plugin

### Version Compatibility


  
* File and Directory Monitor 4.1 - 7.3
* File and Directory Monitor 3.3 - 7.2, 7.1, 7.0, 6.0, 5.5, 5.4, 5.3, 5.2
  


### Description
This monitor can report the following Directory information: - Number of files matching a certain regular expression; - Largest file size that match that expression; - Age (in minutes) of the most recent file; - Most recent date of the latest file; - Most recent time of the latest file; - File name that was most recently modified


### Supported Monitoring Stations

7.3, 7.2, 7.1, 7.0, 6.0, 5.5, 5.4, 5.3, 5.2

### Supported Agents
Windows, Solaris, Linux, AIX

### Installation Notes
<p><a href="https://github.com/uptimesoftware/uptime-plugin-manager">Install using the up.time Plugin Manager</a></p>

<p>For the agent files, follow the instructions below:</p>

<p>Agent Installation</p>

<p>POSIX:
- Place the filedircheck-nix-agent.pl file in the directory /opt/uptime-agent/scripts/
(create the directory if needed)
- Create/edit the following password file:
/opt/uptime-agent/bin/.uptmpasswd
- and add the following line to it:
filedircheck /opt/uptime-agent/scripts/filedircheck-nix-agent.pl</p>

<p>WINDOWS:
- Place the filedircheck-win-agent.vbs file in the uptime agent directory in a subdirectory called "scripts" (C:\program files\uptime software\up.time agent\scripts)
(create the scripts directory if needed)
- Open the uptime Agent Console (Start > up.time agent) and click on Advanced > Custom Scripts
- Enter the following:
Command Name: filedircheck
Path to Script: cscript //nologo "C:\Program Files\uptime software\up.time agent\scripts\filedircheck-win-agent.vbs"</p>


### Dependencies
<p>n/a</p>


### Input Variables

* Directory

* Search Sub Directories

* File(s) (RegExp)


### Output Variables


* Size of File (Bytes)

* Size of File (KB)

* Size of File (MB)

* Size of File (GB)

* Size of File (TB)

* Number of Matched Files in Directory

* Minutes Old

* Hours Old

* Days Old

* Response time


### Languages Used

* Shell/Batch

* PHP

* Perl

