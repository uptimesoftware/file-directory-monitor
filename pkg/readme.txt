Agent Files Installation
-------------------------

POSIX:
a. Place the filedircheck-nix-agent.pl file in the directory /opt/uptime-agent/scripts/
   (create the directory if needed)
b. Create/edit the following password file:
   /opt/uptime-agent/bin/.uptmpasswd
   and add the following line to it:
   filedircheck   /opt/uptime-agent/scripts/filedircheck-nix-agent.pl
c. run the following commands to change ownership and permission on /opt/uptime-agent/scripts/filedircheck-nix-agent.pl
	chown uptimeagent:uptimeagent /opt/uptime-agent/scripts/filedircheck-nix-agent.pl
	chmod 770 /opt/uptime-agent/scripts/filedircheck-nix-agent.pl

WINDOWS:
a. Place the filedircheck-win-agent.vbs file in the uptime agent directory in a subdirectory called "scripts" (C:\Program Files\uptime software\Uptime agent\scripts)
   (create the scripts directory if needed)
b. Run as administrator, the Uptime Agent Console (Start > Uptime Agent Console) and click on Advanced > Custom Scripts
c. Enter the following:
Command Name: filedircheck
Path to Script: cscript //nologo "C:\Program Files\uptime software\Uptime agent\scripts\filedircheck-win-agent.vbs"
d. click add/edit to add the new command to the list above and click close.
e. If you have no set up a password for the agent, set one now the click save. It will restart the agent, then you can exit the agent console.
