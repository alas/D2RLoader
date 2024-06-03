REM get handle64.exe from: https://download.sysinternals.com/files/Handle.zip and place it in the same folder as this script or use the one already included here


@echo off
setlocal EnableDelayedExpansion

:: RAN AS ADMINISTRATOR? CHECK/FIX IF NOT ::
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo. &echo. &echo. &echo.
    echo    Run as admin to close handle.
    echo      Requesting privilages.... &echo.
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------



FOR /F %%I in ('handle64 -p D2R.exe -a "DiabloII Check For Other Instances" -nobanner') do set STOP_FLAG=%%I


:: PRIMARY SCRIPT ::
:while

    if %STOP_FLAG% == No (
	mode con cols=51 lines=9 >nul
	echo. & echo. & echo. 
	echo       #######################################
        echo                 ~ NO OPEN HANDLES ~          
	echo       #######################################
	echo. &echo.
        goto :DONE
    )

:: SET CONSOLE WINDOW SIZE ::
mode con cols=51 lines=16 >nul

:: SET PID/HEX VALUES FOR PROCESS HANDLE ::
    FOR /F "tokens=2,3 delims=:" %%A in ('handle64 -p D2R.exe -a ^"DiabloII Check For Other Instances^"') do (
        set pid=%%A
        set hex=%%B
    )


:: DEBUGGING OUTPUT ::
    echo      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    echo                [ DEBUG INFO ] 
    echo      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ & echo.


    FOR /F "tokens=1" %%X in ("%pid%") do (
        set pid=%%X
    )

    FOR /F "tokens=2" %%X in ("%hex%") do (
        set hex=%%X
    )

    echo         *.... STOP_FLAG: [ %STOP_FLAG% ]
    echo         *.......... PID: [ %pid%   ]
    echo         *.......... HEX: [ %hex%     ] &echo.

:: CLOSE HANDLE (suppressed output) ::
    handle64 -p %pid% -c %hex% -y -nobanner >nul &echo.


    FOR /F %%I in ('handle64 -p D2R.exe -a "DiabloII Check For Other Instances" -nobanner') do set STOP_FLAG=%%I & echo.

    if %STOP_FLAG% == No (
	echo     #######################################
        echo                 ~ Handle Closed ~
	echo     #######################################
	echo. &echo.
        goto :DONE

    ) else (

:: Theoretically this error should never be trigged, since admin privilages are taken care of at beginning of script. ::
        echo!!!!.... ERROR: RE-RUN PROGRAM AS ADMINISTRATOR 
    )
)


:DONE
    timeout /t 2 >nul
