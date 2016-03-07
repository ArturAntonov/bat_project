:: Установка Flash Player актуальной версии 
@echo off
title Install Flash player


cd %~dp0

for %%X in ( iexplore.exe firefox.exe) do taskkill /f /im %%X

set progaPath=flashPlayer
for /f "delims=" %%A in ('dir %progaPath% /b ^| find /i "install"') do (
	%progaPath%\%%A -install
)

exit