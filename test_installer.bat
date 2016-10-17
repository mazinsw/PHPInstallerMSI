@echo off

call defvars %~1

msiexec /i "%~dp0%msiname%" /l*v "%~dp0%basename%.log"
