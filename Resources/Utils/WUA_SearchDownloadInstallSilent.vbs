'-------------------------------------------
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Version 2.0
' WUA_SearchDownloadInstall.vbs - Script will query the Windows Update
'   servers, display the applicable updates, download and install updates.
'
'-------------------------------------------
on error resume next

const L_Msg01_Text = 	"Searching for recommended updates..."

const L_Msg02_Text = 	"List of applicable items on the machine:"
const L_Msg03_Text = 	"There are no applicable updates."
const L_Msg04_Text = 	"Press return to continue..."
const L_Msg05_Text = 	"Select an option:"
const L_Msg06_Text = 	"Downloading updates..."
const L_Msg07_Text = 	"Installing updates..."
const L_Msg08_Text = 	"Listing of updates installed and individual installation results:"
const L_Msg09_Text = 	"Installation Result: "
const L_Msg10_Text = 	"Restart Required:  "
const L_Msg11_Text = 	"A restart is required to complete Windows Updates. Restart now?"
const L_Msg12_Text = 	"Press return to continue..."
const L_Msg13_Text = 	"Not Started"
const L_Msg14_Text = 	"In Progress"
const L_Msg15_Text = 	"Succeeded"
const L_Msg16_Text = 	"Succeeded with errors"
const L_Msg17_Text = 	"Failed"
const L_Msg18_Text = 	"Process stopped before completing"
const L_Msg19_Text = 	"Restart Required"
const L_Msg20_Text = 	"N"   'No
const L_Msg21_Text = 	"Y"   'Yes
const L_Msg22_Text = 	"Searching for all applicable updates..."
const L_Msg23_Text = 	"Search for for (A)ll updates or (R)ecommended updates only? "
const L_Msg24_Text = 	"A"  ' All
const L_Msg25_Text = 	"R"  ' Recommended only
const L_Msg26_Text = 	"S"  ' Single update only
const L_Msg27_Text = 	"Enter the number of the update to download and install:"
const L_Msg28_Text = 	"(A)ll updates, (N)o updates or (S)elect a single update? "

Set updateSession = CreateObject("Microsoft.Update.Session")
Set updateSearcher = updateSession.CreateupdateSearcher()
Set oShell = WScript.CreateObject ("WScript.shell")

WScript.Echo L_Msg22_Text & vbCRLF
Set searchResult = updateSearcher.Search("IsInstalled=0 and Type='Software'")

WScript.Echo L_Msg02_Text
WScript.Echo

For I = 0 To searchResult.Updates.Count-1
    Set update = searchResult.Updates.Item(I)
    WScript.Echo I + 1 & "> " & update.Title
Next

If searchResult.Updates.Count = 0 Then
	WScript.Echo
	WScript.Echo L_Msg03_Text
	WScript.Echo
	Wscript.StdOut.Write L_Msg12_Text
	Wscript.StdIn.ReadLine
	WScript.Quit
End If

Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl")

For I = 0 to searchResult.Updates.Count-1
	Set update = searchResult.Updates.Item(I)
	updatesToDownload.Add(update)
Next

WScript.Echo vbCRLF & L_Msg06_Text
WScript.Echo

Set downloader = updateSession.CreateUpdateDownloader() 
downloader.Updates = updatesToDownload
downloader.Download()

Set updatesToInstall = CreateObject("Microsoft.Update.UpdateColl")

'Creating collection of downloaded updates to install 

For I = 0 To searchResult.Updates.Count-1
    set update = searchResult.Updates.Item(I)
    If update.IsDownloaded = true Then
        updatesToInstall.Add(update)	
    End If
Next

WScript.Echo
WScript.Echo L_Msg07_Text & vbCRLF
Set installer = updateSession.CreateUpdateInstaller()
installer.Updates = updatesToInstall
Set installationResult = installer.Install()

WScript.Echo L_Msg08_Text & vbCRLF
	
For I = 0 to updatesToInstall.Count - 1
	WScript.Echo I + 1 & "> " & _
	updatesToInstall.Item(i).Title & _
	": " & ResultCodeText(installationResult.GetUpdateResult(i).ResultCode)		
Next
	
'Output results of install
WScript.Echo
WScript.Echo L_Msg09_Text & ResultCodeText(installationResult.ResultCode)
WScript.Echo L_Msg10_Text & installationResult.RebootRequired & vbCRLF 

WScript.Echo
Wscript.StdOut.Write L_Msg12_Text
Wscript.StdIn.ReadLine

If installationResult.RebootRequired then
	oShell.Run "shutdown /r /t 0",1	
end if

WScript.Echo
WScript.Quit	

Function ResultCodeText(resultcode)
	if resultcode=0 then ResultCodeText=L_Msg13_Text
	if resultcode=1 then ResultCodeText=L_Msg14_Text
	if resultcode=2 then ResultCodeText=L_Msg15_Text
	if resultcode=3 then ResultCodeText=L_Msg16_Text
	if resultcode=4 then ResultCodeText=L_Msg17_Text
	if resultcode=5 then ResultCodeText=L_Msg18_Text
end Function	