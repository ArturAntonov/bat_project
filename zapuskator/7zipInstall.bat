@echo off
title 7-zip install

cd %~dp0
setlocal Enabledelayedexpansion
::Удаление ВинРара и установка 7z

:: 1. удаление винрара 
    for /f "delims=" %%A in ( 'dir C:\ /b ^| find /i "program files"' ) do (
            for /f "delims=" %%B in ( 'dir "C:\%%A" /b ^| find /i "winrar"') do (
                cd "C:\%%A\%%B"
                if exist "C:\%%A\%%B\Uninstall.exe" (
                    start /w Uninstall.exe /s
                )
                cd %~dp0
            )
        )

:: 2. чистка реестра HKLM от винрара
:: по имеющимся у меня данным - не требуется. в HKLM не мусорит.
:: 3. удаление папок из Програм Файлс
	
for /f "delims=" %%A in ( 'dir C:\ /b ^| find /i "program files"' ) do (
		del /q /f "C:\%%A\winrar\*.*"
		rd /q /s "C:\%%A\winrar"	
)
:: ошибка доступа к файлу. Можно попробовать сделать задачу на автозапуск на 1 раз. О!
:: 4. удаление папок из %Appdata%
set "regPath=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
set param=ProfileImagePath
for /f "delims=\ tokens=3 eol=H" %%C in ('REG QUERY "%regPath%"  /f "c:\users" /s ^| find /i "%param%"') do (
	for %%N in ( winrar ) do (
		for /f "delims=" %%D in ('dir /b "C:\Users\%%C\AppData\Roaming\" ^| find /i "%%N"') do  rd /q /s "C:\Users\%%C\AppData\Roaming\%%D"				
		)
)

:: 4. установка 7zip
 7zip\7z920.exe /S /norestart

exit
