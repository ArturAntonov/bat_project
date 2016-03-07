@echo off
cd %~dp0
setlocal enabledelayedexpansion
echo :::::::::::::::::::::::::::::::
echo :: STAGE 1 : Scaning system  ::
echo :::::::::::::::::::::::::::::::

	::Находит в реестре имя раздела в котором есть требуемое значение параметра displayname
	::Это для того, чтобы найти значение АйДи программы для послдующего удаления
	for %%X in (openoffice libreoffice) do (

		for /f "delims=" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "*" /k ^| find /i "hkey"') do (
			set "hivename=%%A" & set "hivename=!hivename:HKEY_LOCAL_MACHINE=HKLM!"
			for /f "delims=" %%B in ("!hivename!") do (
				for /f "delims=" %%C in ( 'reg query "%%B" /s /f "*%%X*" ^| find /i "hkey" ') do (
					set "hiveprog=%%C" & set "hiveprog=!hiveprog!"
					for /f "delims={} tokens=1,2" %%D in ("!hiveprog!") do (
						echo %%E>>libreOpen.txt						
					)
				)							
			)
		)					
	)
	::
	:: показывает имена найденных файлов
	for /f  %%A in (libreOpen.txt) do (
		for /f "delims=" %%B in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{%%A}" /v displayname ^| find /i "office" ') do (
			set "progname=%%B" & set "progname=!progname:REG_SZ=-!" & set "progname=!progname:displayname=Old_Version!"
			for /f "delims=" %%C in ("!progname!") do echo %%C
		)
	)
	::
	::
Echo .	
echo ::::::::::::::::::::::::::::::::::::::
echo :: STAGE 2 : UNINSTALL OLD VERSIONS ::
echo ::::::::::::::::::::::::::::::::::::::
Echo .
::удаление программ
	taskkill /f /im soffice.bin
	::
	for /f  %%A in (libreOpen.txt) do (
		START /wait msiexec.exe /x {%%A} /passive /norestart
		Echo Uninstall old versions of %%A ... OK
	)
	::
Echo .
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :: STAGE 3 : cleaning up old files in appdata, Program Files, Reg ::
echo ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Echo .
::чистка файлов и удаление записей реестра
	::
	::Удаление папок из Program Files
		::	
		if  exist "C:\Program Files (x86)\" (
			set  "fileFolder=C:\Program Files (x86)" 
		) else (
			set "fileFolder=C:\Program Files"
		)
		for %%A in (openoffice libreoffice) do (
			for /f "delims=" %%B in ('dir "%fileFolder%" /b ^|find /i "%%A"') do rd /s /q "%fileFolder%\%%B"
		)
		Echo Program Files Cleaning...DONE
		::
	::Удаление файлов из %appdata% у каждого пользователя на этом компьютере
		::
		:: составление списка пользователей
        :: данный список также используется другими скриптами ( misc.bat)
		::

		set "regPath=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
		set param=ProfileImagePath
		for /f "delims=\ tokens=3 eol=H" %%C in ('REG QUERY "%regPath%"  /f "c:\users" /s ^| find /i "%param%"') do (
			for %%N in (openoffice libreoffice) do (
				for /f "delims=" %%D in ('dir /b "C:\Users\%%C\AppData\Roaming\" ^| find /i "%%N"') do  rd /q /s "C:\Users\%%C\AppData\Roaming\%%D"				
			)
			Echo %%C>>userName.txt
		)
		Echo Remove files from AppData ... OK
		::
	::удаление записей в реестре
		::
		::поиск корней реестра по маске. основа - reg query "HKLM" /s /f "*" /k | findstr /i "libreoffice"
		::
		for %%N in (openoffice libreoffice) do (
			for /f "delims=" %%A in ('reg query "HKLM" /s /f "*" /k ^| find /i "%%N"') do (
				set "hivename=%%A" & set "hivename=!hivename:HKEY_LOCAL_MACHINE=HKLM!"
				for /f "delims=" %%B in ("!hivename!") do (
					echo Y|reg delete "%%B"  >nul
					echo Y|reg delete "%%B\"  >nul
				)
			)
			for /f "delims=" %%B in ( 'reg query "HKLM" /s /v "*%%N*" ^| find /i "hkey"') do (
				set "hivename=%%B" & set "hivename=!hivename:HKEY_LOCAL_MACHINE=HKLM!"
				for /f "delims=" %%C in ("!hivename!") do (
					for /f "delims=R tokens=1" %%D in ( 'reg query "%%C" /s /f "*"   ^| find /i "%%N"') do (  
						set "paramname=%%D" & set "paramname=!paramname:    =!" 
						for /f "delims=" %%E in ("!paramname!") do (
							echo Y|reg delete "%%C" /v "%%E"  >nul
							echo Y|reg delete "%%C" /v "%%E\"  >nul
						)	
					)	
				)
			)
			echo cleaning %%N ... OK	
		)
		::
		
Echo Reg Cleaning... OK
Echo .
ECHO ----------------------------------------------
ECHO ininstall old versions files ... DONE
ECHO ----------------------------------------------
Echo .
echo ::::::::::::::::::::::::::::::::::::::::::::::
echo :: STAGE 4 : Install new version of program ::
echo ::::::::::::::::::::::::::::::::::::::::::::::
Echo
	::
	:: Установка либры и затем распределение файлов конфига по юзерам
	:: установка либры из папки, в которой всегда хранится либра
	Echo INSTALL libreoffice
	for /f "delims=" %%F in ('dir /b "LibreOfficeDistr\" ^| find /i "libreoffice"') do (
		Echo Installing %%F ...
		start /wait msiexec.exe /i "LibreOfficeDistr\%%F" /passive /norestart
		Echo Install %%F... OK
	)
Echo .
echo ::::::::::::::::::::::::::::::::::::::::::::::
echo :: STAGE 5 : copy config diles to all users ::
echo ::::::::::::::::::::::::::::::::::::::::::::::
Echo .
	:: Копирование файлов по юзерским аппдата
	for /f "delims=" %%U in (userName.txt) do (
		Echo copy settings file to %%U directory
		7z x libreOfficeConfig.zip -y -oC:\Users\%%U\AppData\Roaming
		Echo Copy config files to %%U ... OK
	)
	Echo Install LibreOffice ... OK
	::
Echo .
echo :::::::::::::::::::::::::::::::::
echo ::  STAGE 5 :Cleaning garbage  ::
echo :::::::::::::::::::::::::::::::::
Echo .
	::
	del /q /f libreOpen.txt
rem	del /q /f userName.txt
	::
Echo .
echo :::::::::::::::::::::::::::::::::
echo ::          COMPLETE           ::
echo :::::::::::::::::::::::::::::::::
Echo .


exit

	
	
		

