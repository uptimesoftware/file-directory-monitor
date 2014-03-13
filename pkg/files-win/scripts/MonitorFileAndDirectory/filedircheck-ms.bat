@ECHO OFF
set PHPDIR=..\..\apache\php\
"%PHPDIR%\php.exe" ..\..\plugins\scripts\MonitorFileAndDirectory\filedircheck-ms.php %1
