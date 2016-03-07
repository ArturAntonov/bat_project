:: Обновление компоненты Java. Удаление старых версий, установка новой.
@echo off
title Install Java

cd %~dp0
setlocal enabledelayedexpansion

:: закрытие браузеров
rem  for %%X in ( iexplore.exe firefox.exe) do taskkill /f /im %%X 
:: 1. Поиск и удаление старых версий
	::Находит в реестре имя раздела в котором есть требуемое значение параметра displayname
	::Это для того, чтобы найти значение АйДи программы для послдующего удаления
	
		for /f "delims=" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "*" /k ^| find /i "hkey"') do (
			set "hivename=%%A" & set "hivename=!hivename:HKEY_LOCAL_MACHINE=HKLM!"
			for /f "delims=" %%B in ("!hivename!") do (
				for /f "delims=" %%C in ( 'reg query "%%B" /s /f "*java*" ^|find /i  "hkey" ') do (
					set "hiveprog=%%C" & set "hiveprog=!hiveprog!"
					for /f "delims={} tokens=1,2" %%D in ("!hiveprog!") do (
						echo %%E >>javaVersion.txt					
					)
				)							
			)
		)					
	)

:: показывает имена найденных файлов
	for /f  %%A in (javaVersion.txt) do (
		for /f "delims=" %%B in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{%%A}" /v displayname ^| find /i "java" ') do (
			set "progname=%%B" & set "progname=!progname:REG_SZ=-!" & set "progname=!progname:displayname=Old_Version!"
			for /f "delims=" %%C in ("!progname!") do echo %%C
		)
	)

:: удаляет найденное
for /f %%D in (javaVersion.txt) do (
    start /wait msiexec.exe /x {%%D} /passive /norestart
    IF ERRORLEVEL 1 ECHO error level is 1 or more
    ping 127.0.0.1 -n 5 >nul
)


:: 2. Установка новой версии
for /f  "delims=" %%A in ( 'dir javaUpdate /b ^| find /i "java"') do (
	start /w javaUpdate\%%A /s /norestart
)

exit
