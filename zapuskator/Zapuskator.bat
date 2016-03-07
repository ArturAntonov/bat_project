@echo off
CD %~dp0
title Zapuskator by Artur Antonov	
:: тут будут запускать по порядку все нужные скрипты
:: на каждую программу будет свой скрипт
:: этот запускатор будет запускаться сам под правами админа, то есть в цепочке будет первым.
:: Для всех установщиков я стараюсь использовать цикл для поиска по ключевому слову для того, 
:: чтобы в дальнейшем можно было бы просто заменять файл в папке установщика на нужный без переписывания кода,
:: лишь чуть поменяв название файла на похожее( это там где х86 или х64 ). а так просто заменить файлы и они буду установлены

if not exist "C:\Windows\System32\msvcr100.dll" ( copy /y msvcr100.dll "C:\Windows\System32\" )

Echo .
ECHO =======================
ECHO = Install LibreOffice =
ECHO =======================
Echo .
elevate.exe -wait  libreOfficeInstall.bat
:: хотелось бы, чтобы каждый скрипт вконце себя создавал некий индикатор того, что он завершился
:: некий файл в некоей папке
:: проверка существования этого файла покажет  - завершился ли скрипт.

rem Echo .
rem ECHO ===============================
rem IF exist folderName\libreDetect.txt ( 
rem	ECHO = Install LibreOffice - OK =
rem ) ELSE (
rem	ECHO = Install LibreOffice - ERROR =
rem )
rem ECHO ===============================
rem Echo .

:: Следующий скрипт
Echo .
ECHO ========================
ECHO = Install Flash Player =
ECHO ========================
Echo .
elevate.exe -wait  flashPlayerInstall.bat

:: Следующий скрипт
Echo .
ECHO =================
ECHO = Install Java  =
ECHO =================
Echo .
elevate.exe -wait  javaUpdate.bat

:: Следующий скрипт
Echo .
ECHO ================
ECHO = Install 7zip =
ECHO ================
Echo .
elevate.exe -wait  7zipInstall.bat

:: Следующий скрипт
Echo .
ECHO ========================
ECHO = Install Miscellanous =
ECHO ========================
Echo .
elevate.exe -wait  misc.bat

:: Следующий скрипт
::Echo .
::ECHO ========================
::ECHO = Install Miscellanous =
::ECHO ========================
::Echo .
::elevate.exe -wait  settingsIE.bat


:: В конце идет удаление файлов проверки
:: RD /q /s folderName


del /q /f userName.txt

:: пауза для пользователя ( если таковой будет) и затем перезагрузка
Echo .
ECHO =============================================================
ECHO =Install COMPLETE. Now computer will reboot after 60 second.=
ECHO =============================================================
Echo .


shutdown /r
PING 127.0.0.1 -n 10 >nul

:: удаление файлов установки
taskkill /f /im close_runasspc.exe
start cmd.exe /c " ping 127.0.0.1 -n 2 >nul & cd %temp%  & rd /q /s zapuskat0r "
exit