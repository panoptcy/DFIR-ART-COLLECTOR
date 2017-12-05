::DFIR Art Collector 
::Version: win-v1.0.0

@echo off

::Variables
set memtool=winpmem_1.6.2.exe
set filemov=rawcopy.exe

::Checking all arguments are set
set /A iargs=0
for %%i in (%*) do set /A iargs+=1
if %iargs% gtr 3 (
	echo  ERROR: too many arguments.
	exit /B 1
)
if %iargs% leq 2 (
	echo  ERROR: too few arguments.
	exit /B 1
)

::Checking for admin rights
fsutil dirty query %SystemDrive% > NUL 2>&1
if not %errorLevel% equ 0 (
	echo.&echo  ERROR: %~nx0 is running without administrator rights.
	exit /B 1
)

::Setup
mkdir %2\%computername%\
mkdir %2\%computername%\memory
mkdir %2\%computername%\process
mkdir %2\%computername%\network
mkdir %2\%computername%\session
mkdir %2\%computername%\other
mkdir %2\%computername%\raw_disk

::Memory Collection
echo Beginning Memory Collection
echo.
echo ####-Memory Collection-#### >> %2\%computername%\%computername%-collection_log.txt
call :memorydump %1 %2
echo.

::Volatile Artifact Collection
echo Beginning Volatile Artifact Collection
echo.
echo ####-Volatile Artifact Collection-#### >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : Volatile Artifact Collection Start Time >> %2\%computername%\%computername%-collection_log.txt
call :proc %1 %2
call :network %1 %2
call :session %1 %2
echo %date% - %time% : Volatile Artifact Collection End Time >> %2\%computername%\%computername%-collection_log.txt
echo. >> %2\%computername%\%computername%-collection_log.txt
echo.

::Non-Volatile Artifact Collection
echo Beginning Non-Volatile Artifact Collection
echo.
echo ####-Non-Volatile Artifact Collection-#### >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : Non-Volatile Artifact Collection Start Time >> %2\%computername%\%computername%-collection_log.txt
call :other %1 %2
echo %date% - %time% : Non-Volatile Artifact Collection End Time >> %2\%computername%\%computername%-collection_log.txt
echo. >> %2\%computername%\%computername%-collection_log.txt
echo.

::Hashing Evidence 
echo Hashing Evidence 
echo.
echo ####-Hashing Evidence-#### >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : Hashing Evidence Start Time >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : %2\%computername%\%computername%-evidence-hashing.txt >> %2\%computername%\%computername%-collection_log.txt
%1\tools\win\jessek\md5deep.exe -r %2\%computername%\* >> %2\%computername%\%computername%-evidence-hashing.txt
echo %date% - %time% : Hashing Evidence End Time >> %2\%computername%\%computername%-collection_log.txt
echo. >> %2\%computername%\%computername%-collection_log.txt
echo.

::Disk Image
echo Beginning Disk Image Collection
echo.
echo ####-Beginning Disk Image Collection-#### >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : Disk Image Collection Start Time >> %2\%computername%\%computername%-collection_log.txt
echo %date% - %time% : %2\%computername%\raw_disk\%computername%-drive%3 >> %2\%computername%\%computername%-collection_log.txt
%1\tools\win\access_data\ftkimager.exe \\.\PHYSICALDRIVE%3 %2\%computername%\raw_disk\%computername%-drive%3 --e01 --frag 2G --compress 6 --case-number TBD --evidence-number %computername%-drive%3 --description %computername%-drive%3 --examiner TBD --notes none
echo %date% - %time% : Disk Image Collection End Time >> %2\%computername%\%computername%-collection_log.txt
goto :eof

::Function to grab memory with winpmem and log activity in log file
:memorydump
	echo %date% - %time% : Memory Collection Start Time >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\%memtool% %2\%computername%\memory\%computername%-memdump.mem
	echo %date% - %time% : Memory Collection End Time >> %2\%computername%\%computername%-collection_log.txt
	echo. >> %2\%computername%\%computername%-collection_log.txt
	goto :eof

::Function to grab process related artifacts
:proc
	echo %date% - %time% : %2\%computername%\process\%computername%-pslist.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\pslist.exe -accepteula >> %2\%computername%\process\%computername%-pslist.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-pslist-tree.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\pslist.exe -accepteula -t >> %2\%computername%\process\%computername%-pslist-tree.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-listdlls.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\Listdlls.exe -accepteula >> %2\%computername%\process\%computername%-listdlls.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-listdlls-u.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\Listdlls.exe -accepteula -u >> %2\%computername%\process\%computername%-listdlls-u.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-psservice.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psservice.exe -accepteula >> %2\%computername%\process\%computername%-psservice.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-psservice-config.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psservice.exe -accepteula config >> %2\%computername%\process\%computername%-psservice-config.txt
	goto :eof

::Function to grab network related artifacts
:network
	echo %date% - %time% : %2\%computername%\network\%computername%-tcpvcon.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\Tcpvcon.exe -accepteula >> %2\%computername%\network\%computername%-tcpvcon.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-tcpvcon-acn.csv >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\Tcpvcon.exe -accepteula -acn >> %2\%computername%\network\%computername%-tcpvcon-acn.csv
	echo %date% - %time% : %2\%computername%\network\%computername%-ipconfig-all.txt >> %2\%computername%\%computername%-collection_log.txt
	ipconfig /all >> %2\%computername%\network\%computername%-ipconfig-all.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-ipconfig-displaydns.txt >> %2\%computername%\%computername%-collection_log.txt
	ipconfig /displaydns >> %2\%computername%\network\%computername%-ipconfig-displaydns.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-arp-a.txt >> %2\%computername%\%computername%-collection_log.txt
	arp -a >> %2\%computername%\network\%computername%-arp-a.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-route-print.txt >> %2\%computername%\%computername%-collection_log.txt
	route print >> %2\%computername%\network\%computername%-route-print.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-net-use.txt >> %2\%computername%\%computername%-collection_log.txt
	net use >> %2\%computername%\network\%computername%-net-use.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-net-session.txt >> %2\%computername%\%computername%-collection_log.txt
	net session >> %2\%computername%\network\%computername%-net-session.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-net-view.txt >> %2\%computername%\%computername%-collection_log.txt
	net view \127.0.0.1 >> %2\%computername%\network\%computername%-net-view.txt
	goto :eof

::Function to grab session related artifacts
:session
	echo %date% - %time% : %2\%computername%\session\%computername%-psloggedon.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psloggedon.exe -accepteula >> %2\%computername%\session\%computername%-psloggedon.txt
	echo %date% - %time% : %2\%computername%\session\%computername%-logonsessions.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\logonsessions.exe -accepteula >> %2\%computername%\session\%computername%-logonsessions.txt
	echo %date% - %time% : %2\%computername%\session\%computername%-logonsessions-p.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\logonsessions.exe -p -accepteula >> %2\%computername%\session\%computername%-logonsessions-p.txt
	echo %date% - %time% : %2\%computername%\session\%computername%-logonsessions-pc.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\logonsessions.exe -pc -accepteula >> %2\%computername%\session\%computername%-logonsessions-pc.txt
	goto :eof

::Function to grab other artifacts
:other
	echo %date% - %time% : %2\%computername%\other\%computername%-psinfo.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psinfo.exe -accepteula >> %2\%computername%\other\%computername%-psinfo.txt
	echo %date% - %time% : %2\%computername%\other\%computername%-psloglist.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psloglist.exe -accepteula >> %2\%computername%\other\%computername%-psloglist.txt
	echo %date% - %time% : %2\%computername%\other\%computername%-psloglist-s.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\psloglist.exe -s -accepteula >> %2\%computername%\other\%computername%-psloglist-s.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-autorunsc-hs.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\autorunsc.exe -hs -accepteula config >> %2\%computername%\process\%computername%-autorunsc-hs.txt
	echo %date% - %time% : %2\%computername%\process\%computername%-autorunsc-hsc.csv >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\SysinternalsSuite\autorunsc.exe -hs -accepteula config >> %2\%computername%\process\%computername%-autorunsc-hsc.csv
	echo %date% - %time% : %2\%computername%\process\%computername%-schtasks.txt >> %2\%computername%\%computername%-collection_log.txt
	schtasks >> %2\%computername%\process\%computername%-schtasks.txt
	echo %date% - %time% : %2\%computername%\network\%computername%-hosts.txt >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\jschicht\%filemov% /FileNamePath:%SystemRoot%\System32\drivers\etc\hosts /OutputPath:%2\%computername%\network\ /OutputName:%computername%-hosts.txt
	if exist %SystemRoot%\hiberfil.sys (
		echo %date% - %time% : %2\%computername%\memory\%computername%-hiberfil.sys >> %2\%computername%\%computername%-collection_log.txt
		%1\tools\win\jschicht\%filemov% /FileNamePath:%SystemRoot%\hiberfil.sys /OutputPath:%2\%computername%\memory\ /OutputName:%computername%-hiberfil.sys
	)
	echo %date% - %time% : %2\%computername%\other\%computername%-winaudit.csv >> %2\%computername%\%computername%-collection_log.txt
	%1\tools\win\parmavex_services\WinAudit.exe /r=gsoxuTUeERNtmidSAr /o=csv  /f=%2\%computername%\other\%computername%-winaudit.csv
	goto :eof