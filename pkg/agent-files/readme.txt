Agent Installation
-------------------------

POSIX:
a. Place the filedircheck-nix-agent.pl file in the directory /opt/uptime-agent/scripts/
   (create the directory if needed)
b. Create/edit the following password file:
   /opt/uptime-agent/bin/.uptmpasswd
   and add the following line to it:
   filedircheck   /opt/uptime-agent/scripts/filedircheck-nix-agent.pl

WINDOWS:
a. Place the filedircheck-win-agent.vbs file in the uptime agent directory in a subdirectory called "scripts" (C:\program files\uptime software\up.time agent\scripts)
   (create the scripts directory if needed)
b. Open the uptime Agent Console (Start > up.time agent) and click on Advanced > Custom Scripts
c. Enter the following:
Command Name: filedircheck
Path to Script: cscript //nologo "C:\Program Files\uptime software\up.time agent\scripts\filedircheck-win-agent.vbs"
