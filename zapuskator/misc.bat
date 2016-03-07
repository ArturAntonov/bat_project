:: Копирование пользователям программы FreeVimager на рабочий стол
:: Копирование папки с ярлыками на рабчий стол
:: помещение объектов будет выполняться при помощи 7zip
:: будет использоваться список пользователей, который создавался при установке Либры
@echo off 
cd %~dp0

:: 1. копирование программы для сканирования FreeVimager
	for /f "delims=" %%U in (userName.txt) do (
		Echo copy FreeVimager to %%U directory
        for /f %%N in ( 'dir misc /b ^| find /i "freevimager"') do (
            7z x misc\%%N -y -oC:\Users\%%U\Desktop
        )
		Echo Copy FreeVimager to %%U ... OK
	)

:: 2. копирование пользователям папки с ссылками на сайты. Для офисов отдельные скрипты, т.к. архивы разные
    for /f "delims=" %%U in (userName.txt) do (
		Echo copy Links to %%U Desktop
        for /f %%N in ( 'dir misc /b ^| find /i "_AP"') do (
            7z x misc\%%N -y -oC:\Users\%%U\Desktop
        )
		Echo Copy Links to %%U Desktop ... OK
	)


:: 3. Установка сервиса DameWare 
    cd dameWareSrvc
    IF %PROCESSOR_ARCHITECTURE%==x86 (set BIT=x86) ELSE (set BIT=x64)
    for /f "delims=" %%A in ( 'dir /b ^| find /i "%BIT%" ') do (
        start /wait msiexec.exe /i "%%A" /passive /norestart
    )
    cd ..
    

exit