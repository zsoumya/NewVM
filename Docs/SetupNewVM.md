## Setup a new Windows VM as template using audit mode and SysPrep

1. Create new VM
1. Customize hardware (1 or 2 processors w/ 2-4 cores, 100 GB HDD, 4GB RAM, NAT typically with no printer, sound or USB support)
1. Update VM Settings:
	+ **Mount E:\VMWare\HostShare as read-only shared folder mapped as Windows drive**
	+ Ask for snapshots at every shutdown
1. Install OS (Windows 10 or Windows Server 2016)
1. Boot to Audit mode:
	+ **For GUI OS**: **`Ctrl+Shift+F3`** at OOBE screen
	+ **For Server Core OS**: Run sysprep with Audit, Generalize and Reboot options from command prompt
1. Install VMWare tools
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\SetupVMTemplate.ps1`**. This will ask for user inputs and perform the following tasks:
	+ Rename VM
	+ Add VM to workgroup
	+ Configure VM to respond to Ping
	+ Enable Server Manager remote management
	+ Set Windows Update to Automatic
	+ Turn on updates for other Microsoft products
	+ Restart Windows Update service
	+ Enable Remote Desktop with Network Level Authentication
	+ Set Telemetry settings to Security
	+ Set preferred date and time formats
	+ Remove unneeded scheduled tasks
	+ Change power plan to High Performance (for Windows 10)
	+ Create C:\Links folder
	+ Copy C:\Utils folder with contents
	+ Add C:\Links and C:\Utils folders to PATH
	+ Create PowerShell profile
	+ Display Date/Time settings Control Panel applet for date/time/timezone adjustment
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\InstallApps.ps1`** to:
	+ Install **Chocolatey**
	+ Install Chocolatey apps like **7zip**, **Notepad3**, **CCleaner**, **ConEmu**, etc.
	+ Install O&O Registry Editor
	+ Create **`C:\Links`** & **`C:\Utils`** folder with contents
	+ Add these two folders to the PATH
	+ Refresh PATH to reflect changes
	+ Create shims of installed apps and add them to the PATH
1. Run **`C:\ProgramData\chocolatey\bin\RefreshEnv`** to refresh PATH changes 
1. Customize 7zip file manager (associate file types, GUI settings like alternate row colors, etc.)
1. Activate Windows (this activation will not persist after generalization but is necessary to customize Windows UI items like Wallpaper)
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\CustomizeGUI.ps1`** to:
	+ Disable Internet Explorer ESC
	+ Hide Recycle Bin from desktop
	+ Remove Volume Control icon from System Tray
	+ Customize task bar (small icons, lock, combine always, etc.)
	+ Customize explorer (unhide extensions, open in "This PC" mode, expand to open folder in Navigation pane)
	+ Set small icons of desktop
	+ Set black extra large cursor
	+ Set color and transparency on task bar, title bar and action center
	+ Set small icons view for Control Panel
	+ Remove Task View button from task bar
	+ Remove Cortana from task bar (Windows 10 Pro only)
	+ Remove People button from task bar (Windows 10 Pro only)
	+ Turn on quiet hours
	+ Set a preferred set of folders on the start menu
	+ Change wallpaper
	> Not applicable for Server Core OS
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\RemoveApps.ps1`** to uninstall unneeded Windows modern apps. It might be necessary to repeat the command more than once to completely get rid of the undesired apps.
	> Only applicable for Windows 10
1. Install **IOBit Uninstaller**  
	Run IOBit Uninstaller and uninstall the following apps:
	+ OneDrive
	> Does not work in Server Core OS
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\ImportLayout.ps1`** to customize the start menu and task bar layouts.
	> Not applicable for Server Core OS  
	> **I am not yet able to make this work**
1. Customize Start Menu: Pin/Unpin necessary apps  
	**Windows 10 Preferred Start Menu Layout**  
	![alt text][StartLayoutWin10]  
	**Windows Server 2016 Preferred Start Menu Layout**  
	![alt text][StartLayoutWin2016]
	> Not applicable for Server Core OS
1. Perform more pesonalizations (**`Settings`** &rarr; **`Personalization`**):
	+ **`Color`**: Choose accent color based on wallpaper
	+ **`Start`**:  Turn on **`Show more tiles`**
	> Not applicable for Server Core OS
1. Customize CCleaner (disable monitoring) and run
1. Customize ConEmu (Monokai font, no title bars, no number on tab titles, etc.)
	> Not applicable for Server Core OS
1. Customize Everything (Hide results when no query, GUI settings like alternate row colors, etc.)
1. Customize NotePad++:
	+ Enable Monokai theme
	+ Enable Global Font: Consolas 11pt 
	+ Uncheck **`Settings`** &rarr; **`Preferences`** &rarr; **`Backup`** &rarr; **`Remember current session for next launch`**
1. Customize Opera:
	+ Black Theme
	+ Disable Ads
	+ Turn on VPN
	+ Disable password saving
	+ Install HTTPS Everywhere extension
	+ Customize sidebar icons
1. Customize Process Hacker (hide when minimized/closed, replace task manager, etc.)
1. Customize Explorer++: Switch to "List" view
	> Not applicable for GUI OS
1. Run RapidEE:
	+ Fix the **`PSModulePath`** environment variable (System/machine level not user level). Ensure the configured paths are in the following order:
		1. **`C:\Windows\system32\WindowsPowerShell\v1.0\Modules`**
		1. **`C:\Program Files\WindowsPowerShell\Modules`**
		1. **`C:\ProgramData\Boxstarter`**
	> This is needed to install Docker in future without issues.
	+ Fix any configured but non-existent paths
1. Run AutoRuns and remove any unwanted startup entries
	+ Remove the startup entry for OneDrive
1. Clear Action Center messages
	> Not applicable for Server Core OS
1. Perform **Windows Update** (run **`C:\Utils\WinUpdate.cmd -s`**)
1. Repeat performing updates until there are no more
1. Run **`cup all`** and CCleaner one last time before shutting down
1. Shutdown in Audit mode and create a snapshot (so that we can revert to it and create more customizations)
1. Start the VM
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\SysPrep.ps1`** to generalize the OS and copy current profile setting to the default profile. This will shut down the VM.
1. Create a new snapshot (of the Generalized OS) after the VM has shut down

## Clone and customize generalized VM after SysPrep

1. Clone the generalized snapshot (preferably full clone)
1. Customize the snapshot (memory, processors)
1. Change network adapter type from **NAT** to **Bridged** if required
1. Run **Compact** (first) and **Defragment** (next) on the hard disk from the VMWare console
1. Start the cloned VM (The OS will not be activated)
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\ImportLayout.ps1`** to customize the start menu and task bar layouts.
	> Not applicable for Server Core OS  
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\InitVMInstance.ps1`**. This will ask for user inputs and perform the following tasks:
    + Activate Windows
    + Rename VM host
    + Add VM to workgroup
    + Create new user and add the user to Administrators group
    + Set static IP address and DNS servers 
1. Perform **Windows Update** (run **`C:\Utils\WinUpdate.cmd -s`**)
1. Run **`cup all`** (Chocolatey update)
1. Run CCleaner
1. Follow the "**Customization Steps For Each User Login**" section for the logged in user and for the newly created admin user

## Customization Steps For Each User Login

1. Make Opera default browser
1. Perform UI pesonalizations (**`Settings`** &rarr; **`Personalization`**):
	+ **`Color`**: Choose accent color based on wallpaper
	+ **`Start`**:  Turn on **`Show more tiles`**
	+ Customize Lock Screen wallpaper if necessary
	> This action is necessary because for some reason the lock screen wallpaper cannot be changed in the audit mode.
	> Not applicable for Server Core OS  
1. Customize Start Menu: Pin/Unpin necessary apps  
	**Windows 10 Preferred Start Menu Layout**  
	![alt text][StartLayoutWin10]  
	**Windows Server 2016 Preferred Start Menu Layout**  
	![alt text][StartLayoutWin2016]
	> **This step is only necessary for the first login of a VM (typically Administrator for Windows Server and the installer-created user for Windows 10). Since we are going to import a preferred start and taskbar layout from this login, all subsequently created logins will inherit the preferred layout automatically without needing to be created manually**  
	> 
	> This action is necessary even after SysPrep because for some reason the start menu layout changes in the default user profile are not persisted from the SysPrep stage  
	> 
	> Not applicable for Server Core OS
1. Customize task bar icons:
	+ Unpin Search, Explorer and Internet Explorer from task bar
	+ Pin Opera, ConEmu and Iobit Uninstaller to task bar  
	**Preferred Start Menu Layout**  
	![alt text][TaskBarLayout]
	> **This step is only necessary for the first login of a VM (typically Administrator for Windows Server). We are going to import a prferred start and taskbar layout from this login and all subsequently created logins will inherit the preferred layout automatically without needing to be created**  
	> 
	> This action is necessary even after SysPrep because for some reason the start menu layout changes in the default user profile are not persisted from the SysPrep stage  
	> 
	> Not applicable for Server Core OS
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\InitLogin.ps1`** to:
	+ Set black extra large cursor (Not applicable for Server Core OS)
	+ Turn off auto-launch of Server Manager during logon (Not applicable for Server Core OS)
	+ Set preferred date and time formats
	> This step is necessary because for some reason the cursor changes and the date/time format changes in the default user profile are not persisted from the SysPrep stage

## Create a Domain and promote VM to Domain Controller

1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\CreateDomain.ps1`**. This will ask for user inputs and perform the following tasks:
    + Create a domain (Set ***`DSRM53cr3t`*** as safe mode admin password)
    + Promote the VM as a Domain Controller
    + Restart the VM

1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\InitDomain.ps1`**. This will ask for user inputs and perform the following tasks:
    + Promote specified users as Domain Admins
    + Relax the domain password policy (for testing purposes; not for Production environments)

## Add a VM to domain

1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\AddToDomain.ps1`**. This will ask for user inputs and perform the following tasks:
    + Update the DNS server IP of the VM
    + Install the Active Directory Module For Windows PowerShell (RSAT-AD-PowerShell)
    + Add the VM to the domain (optionally with a new host name)
    + Restart the VM
1. After VM restarts login as a domain administrator
1. Perform customizations as per section **"Customization Steps For Each User Login"**
1. Run **`powershell -ExecutionPolicy Bypass -File Z:\HostShare\NewVM\Scripts\CreateADLocalAdmin.ps1`**. This will ask for user inputs and perform the following tasks:
	+ Create a domain user
	+ Make the user a member of local Administrators group
	> If the domain user is already created just add the user to the local administrator group manually  
	> Will not work in Windows 10 because the ServerManager PowerShell is not installed in Windows 10
1. Logon as the newly created admin user from previous step and follow the "**Customization Steps For Each User Login**" section.




[StartLayoutWin10]: StartMenuLayoutWin10.png "Start menu layout for Windows 10"
[StartLayoutWin2016]: StartMenuLayoutWin2016.png "Start menu layout for Windows Server 2016"
[TaskBarLayout]: TaskBarLayoutAllOS.png "Task bar layout for all Windows"