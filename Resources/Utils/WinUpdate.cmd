@echo off

if [%1] == [/s] goto silent
if [%1] == [-s] goto silent
 
cscript "C:\Windows\System32\en-US\WUA_SearchDownloadInstall.vbs"
goto :eof

:silent
cscript %~dp0"WUA_SearchDownloadInstallSilent.vbs"
