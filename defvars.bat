@echo off

set distver=x86
if "%~1" == "x64" set distver=x64
for /f %%i in ('fileversion "%~dp0Files\%distver%\php.exe"') do set version=%%i
for /f %%i in ('depver "%~dp0Files\%distver%\php.exe" MSVCR 0.dll') do set vcver=%%i
for /f %%i in ('depver "%~dp0Files\%distver%\ext\php_intl.dll" icuuc .dll') do set icuver=%%i
set phpver=%version%
set phpver=%phpver:~0,3%
set phpver=%phpver:.=%

set suffix=
set extrants=
set extrasnaps=

set basename=php-%version%-%extrants%Win32-VC%vcver%-%distver%%extrasnaps%
set msiname=%basename%.msi