@echo off

if [%1] == [] GOTO help
if [%2] == [] GOTO help

if not exist C:\Links mkdir C:\Links

C:\ProgramData\chocolatey\tools\shimgen -o=C:\Links\%~nx1 -p=%2 -i=%2

GOTO :eof

:help
echo.
echo Link creates shims of executables using the ShimGen command
echo and places the same in C:\Links folder so that it can be 
echo found in the PATH and invoked from anywhere
echo.
echo %~n0 {alias} {target}
echo Example: %~n0 np.exe "C:\Program Files\Notepad3\Notepad3.exe"
