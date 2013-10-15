<?php
require('rcs_function.php');

// get all the variables from the environmental variable
$element_type   = getenv('UPTIME_SYSTEM_TYPE');
$agent_hostname = getenv('UPTIME_HOSTNAME');
$agent_port     = intval(getenv('UPTIME_AGENT_PORT'));
$agent_password = getenv('UPTIME_PASSWORD');

$dir            = getenv('UPTIME_DIRECTORY');
$recursive      = getenv('UPTIME_SEARCHSUBDIRS');
$filetocheck    = getenv('UPTIME_FILE');

$agent_keyname = "filedircheck";
$exitcode   = 0;


// backwards compatibility (uptime 5.x)
if ($element_type == "" || $element_type == "N/A") {
	$element_type = "AGENT";	// if there's no system_type, assume it's an agent
}
// make sure port is valid (known issue in 6.0; fixed in 6.0.1+)
if ($agent_port == "") {
	$agent_port = 9998;
}

// "contains()" function
// http://www.jonasjohn.de/snippets/php/contains.htm
function contains($str, $content, $ignorecase = true){
	$str = ' ' . $str;
    if ($ignorecase){
        $str = strtolower($str);
        $content = strtolower($content);
    }  
    return strpos($str,$content) ? true : false;
}


// determine if the agent is a Windows or other (posix) agent since the Windows agent requires special handling
function is_agent($veroutput, $agenttype, $ignorecase = true) {
	$rv = 0;
	// check if the agent is on Windows or anything else (Posix)
	if (contains($veroutput, $agenttype, $ignorecase)) {
		$rv = 1;
	}
	if (strlen($veroutput) == 0) {
		$rv = 0;
		print "Error: no lines returned from 'ver'. Is the agent running?";
		exit(1);
	}
	return $rv;
}

if (contains($element_type, "AGENT", true)) {

	// replace spaces with "@"
	$dir = str_replace(' ', '@', $dir);
	// replace spaces with "\s" (regex)
	$filetocheck = str_replace(' ', '\s', $filetocheck);
	// add the recursive (true/false) to the beginning of the string and split by "|"
	$cmdargs = $recursive . '#' . $dir . '#' . $filetocheck;

	// depending on the platform (Windows/Others) the command for the remote agent script will be different
	$veroutput = agentcmd($agent_hostname, $agent_port, "ver");
	if (is_agent($veroutput, "windows")) {
		$cmd = "rexec {$agent_password} {$agent_keyname} {$cmdargs}";
	}
	elseif (is_agent($veroutput, "linux")) {
		// Linux agents are a bit special; the full path is not necessary
		$cmd = "rexec {$agent_keyname} /opt/uptime-agent/scripts/filedircheck-nix-agent.pl {$cmdargs}";
	}
	else {
		// treat it as a Unix/Linux agent
		//$cmd = "/opt/uptime-agent/scripts/filedircheck-nix-agent.sh";
		$cmd = "rexec {$agent_keyname} /opt/uptime-agent/scripts/filedircheck-nix-agent.pl {$cmdargs}";
	}
	/*
	print "Host: $agent_hostname\n";
	print "Port: $agent_port\n";
	print "Pass: $agent_password\n";
	print "CMD:  $cmd\n";
	print "VAR:  $cmdargs\n";
	*/
	//$agent_output = uptime_remote_custom_monitor($agent_hostname, $agent_port, $agent_password, $cmd, $cmdargs);
	$timeout = 45;
	$agent_output = agentcmd($agent_hostname, $agent_port, $cmd, $timeout);
	if (strlen($agent_output) == 0) {
		print "Error: No lines returned from agent.";
		exit(1);
	}
	if ($agent_output == "ERR") {
		print "Error: Output received: 'ERR'. The agent may not be configured correctly. Check the password?";
		exit(1);
	}


	//print $agent_output;

	// zero files, let's display zero for all
	if (contains($agent_output, "CRIT - ", false)) {
		$exitcode = 2;	// set monitor to CRIT (2)
	}
	elseif (contains($agent_output, "ZEROFILES")) {
		# no files in directory, so output blank, but valid, data
		print "Directory {$dir}\n";
		print "Expression {$filetocheck}\n";
		print "NumFile 0\n";
		print "TotalSizeB 0\n";
		print "TotalSizeKB 0\n";
		print "TotalSizeMB 0\n";
		print "TotalSizeGB 0\n";
		print "TotalSizeTB 0\n";
		print "OldInMinutes 0\n";
		print "RecentDate <none>\n";
		print "RecentTime <none>\n";
		print "RecentModifiedName <none>\n";
		exit($exitcode);
	}

	print "{$agent_output}";
}
else {
	print "Error: Element {$agent_hostname} is an unsupported element type: '{$element_type}'\n";
}
exit($exitcode);

?>