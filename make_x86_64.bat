REM 65001     utf-8
REM 936       gbk
REM 437       American English
chcp 65001
@echo off

rem -------------------------------------
if not "%~1"=="p" start /min cmd.exe /c %0 p&exit
rem -------------------------------------
cd /d "%~dp0"
set "TOPDIR=%cd%"
title "%~n0"

if "x12" == "x1" (
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
)

rem -------------------------------------
if "x%WBK_ROOTDIR%" == "x"      set "WBK_ROOTDIR=D:/wbk"
if "x%PGM_ROOTDIR%" == "x"      set "PGM_ROOTDIR=D:/pgm"
if "x%PGMBAK_ROOTDIR%" == "x"   set "PGMBAK_ROOTDIR=E:/pgm"
if "x%PGMBAK2_ROOTDIR%" == "x"  set "PGMBAK2_ROOTDIR=F:/pgm"
rem -------------------------------------

rem -------------------------------------
: setlocal enabledelayedexpansion
rem -------------------------------------
setlocal enabledelayedexpansion
rem -------------------------------------

:----------------------------------------
set "ORIGIN_PATH=%PATH%"
set "MINI_PATH=C:/WINDOWS/system32;C:/WINDOWS;C:/WINDOWS/System32/Wbem"
set "PATH=%MINI_PATH%"
:----------------------------------------

rem -------------------------------------
if "x12" == "x1" (
rem set "MSYSTEM=MINGW64"
set "MSYSTEM_MSYS=true"
set "MSYSTEM_MINGW=false"
call "!WBK_ROOTDIR!/etc/skel/tpl.tools.env.msys2.bat"
)
rem -------------------------------------

rem -------------------------------------
if "x1" == "x1" call "!WBK_ROOTDIR!/etc/skel/tpl.tools.env.CMake.bat"
rem -------------------------------------

if "x!PROXY_PORT!" == "x" set "PROXY_PORT=51273"
if "x12" == "x1" call "!WBK_ROOTDIR!/etc/skel/tpl.tools.env.proxy.lantern.bat"

if "x1" == "x1" set "HOME="

DEL %TOPDIR:/=\%\%~n0.cmake.log 2>&1
SET /a TRYCOUNTS=0
:try_again

if exist "msys64\var\lib\pacman\db.lck" DEL "msys64\var\lib\pacman\db.lck"
if exist "msys32\var\lib\pacman\db.lck" DEL "msys32\var\lib\pacman\db.lck"

cmake -Dx86_64=ON -P KiCad-Winbuilder.cmake >>%TOPDIR%/%~n0.cmake.log 2>&1

if not %errorlevel% == 0 set /a TRYCOUNTS=!TRYCOUNTS!+1 && goto :try_again

goto :_my_eof_

:eof_with_error
echo %error%
goto :_my_eof_

:eof_no_error
pause
goto :_my_eof_

:_my_eof_
echo TRYCOUNTS=!TRYCOUNTS! >%TOPDIR%/%~n0.TRYCOUNTS.log
:EOF
