#Encompass reg key and printer fix V4
#Mike Castle 20211130

#import dependancies
import-module PrintManagement
import-module Microsoft.PowerShell.Management
Add-Type -AssemblyName PresentationCore,PresentationFramework

#get SID of currently logged in user
$user = New-Object System.Security.Principal.NTAccount($env:username) 
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 

#list current PSDrives
$PSDrives = (get-psdrive).Name

#create a new PSDrive mapping "HKEY_USERS to "HKU:\" if not already created
if ($PSDrives -notcontains "HKU") 
   {
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
   }

#variables for registry keys, paths, and printers. values will either be "True" or "False"
$regpathcheck1 = Test-Path -ErrorAction SilentlyContinue "HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass"
$regpathcheck2 = Test-Path -ErrorAction SilentlyContinue "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"
$regcheck1 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass').PSObject.Properties.Name -contains "WordBackgroundPrint" 
$regcheck1_2 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass' -Name WordBackgroundPrint).PSObject.Properties.Value -contains "0"
$regcheck2 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass').PSObject.Properties.Name -contains "UseWordSaveAsPDFAddIn"
$regcheck2_2 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass' -Name UseWordSaveAsPDFAddIn).PSObject.Properties.Value -contains "1"
$regcheck3 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown').PSObject.Properties.Name -contains "bProtectedMode"
$regcheck3_2 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown' -Name bProtectedMode).PSObject.Properties.Value -contains "00000000"
$regcheck3_3 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown').PSObject.Properties.Name -contains "bEnhancedSecurityInBrowser"
$regcheck3_4 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown' -Name bEnhancedSecurityInBrowser).PSObject.Properties.Value -contains "00000000"
$regcheck3_5 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown').PSObject.Properties.Name -contains "bEnhancedSecurityStandalone"
$regcheck3_6 = (Get-Itemproperty -ErrorAction SilentlyContinue 'HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown' -Name bEnhancedSecurityStandalone).PSObject.Properties.Value -contains "00000000"
$regcheck4 = (Get-Itemproperty -ErrorAction SilentlyContinue "HKU:\$sid\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\SmartClientCache\Apps\Ellie Mae\Encompass\Encompass.exe").PSObject.Properties.Value -contains "$ IgnoreFreeLibrary<AcroRd32.dll>"
$regcheck4_2 = (Get-Itemproperty -ErrorAction SilentlyContinue "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\SmartClientCache\Apps\Ellie Mae\Encompass\Encompass.exe").PSObject.Properties.Value -contains "$ IgnoreFreeLibrary<AcroRd32.dll>"
$printercheck1 = (Get-Printer -ErrorAction SilentlyContinue).Name -contains "Encompass Document Converter"
$printercheck1_2 = (get-printer -ErrorAction SilentlyContinue -name "Encompass Document Converter").DriverName -contains "Encompass Document Converter Driver"
$printercheck2 = (Get-Printer -ErrorAction SilentlyContinue).Name -contains "Encompass eFolder"
$printercheck2_2 = (get-printer -ErrorAction SilentlyContinue -name "Encompass eFolder").DriverName
$printercheck3 = (Get-Printer -ErrorAction SilentlyContinue).Name -contains "Encompass"
$printercheck3_2 = (get-printer -ErrorAction SilentlyContinue -name "Encompass").DriverName

#variables for log file and Date-Time-Group
$logfile = "C:\Windows\Temp\encompass-regcheck.log.txt"
$DTG = Get-Date -Format FileDateTime

#create log file and write DTG into header, appends to existing text.
"`n$DTG" | Out-File -FilePath $logfile -Append

#Stop running processes
stop-process -name WINWORD -ErrorAction SilentlyContinue
stop-process -name Acrord32 -ErrorAction SilentlyContinue

#run repair on Adobe Reader DC
$AdobeProductCode = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq 'Adobe Acrobat Reader DC'}).PSchildName
msiexec.exe /fum $AdobeProductCode | Wait-Process

#run repair on MS Office
#"'C:\Program Files\Microsoft Office 15\ClientX64\OfficeClickToRun.exe' scenario=Repair DisplayLevel=false RepairType=quickRepair forceappshutdown=true"

#re-enable Microsoft Print to PDF feature
Disable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart 
Enable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart
restart-service spooler -ErrorAction SilentlyContinue

#register dll's
regsvr32 secman.dll /s
regsvr32 secman64.dll /s
regsvr32 ntdll.dll /s

#checks below will automatically make needed changes and output to logfile 
Write-Output "Testing path: HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass..." | Out-File -FilePath $logfile -Append
if ($regpathcheck1 -contains "True")
    {
    Write-Output "Path found, no action taken" | Out-File -FilePath $logfile -Append
    }
else
    {
    Write-Output "Path not found, creating: HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass" | Out-File -FilePath $logfile -Append
    New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Ellie Mae"
    New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Ellie Mae\Encompass"
    }
    Write-Output "Testing path: HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown..." | Out-File -FilePath $logfile -Append
if ($regpathcheck2 -contains "True")
    {
    Write-Output "Path found, no action taken" | Out-File -FilePath $logfile -Append
    }
else 
    {
    Write-Output "Path not found, creating path: HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" | Out-File -FilePath $logfile -Append
    New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"
    }
    Write-Output "Checking RegKey: WordBackgroundPrint..." | Out-File -FilePath $logfile -Append
if ($regcheck1 -contains "True" -and $regcheck1_2 -contains "True")
    {
    Write-Output "RegKey: WordBackgroundPrint is correctly installed, no action taken" | Out-File -FilePath $logfile -Append
    }
else 
    {
    Write-Output "Key not found, writing RegKey: WordBackgroundPrint" | Out-File -FilePath $logfile -Append
    New-Itemproperty -Path "HKLM:\SOFTWARE\Wow6432Node\Ellie Mae\Encompass" -Name "WordBackgroundPrint" -Value "0" -PropertyType String -Force | Out-Null
    }
    Write-Output "Checking RegKey: UseWordSaveAsPDFAddIn..." | Out-File -FilePath $logfile -Append
if ($regcheck2 -contains "True" -and $regcheck2_2 -contains "True")
    {
    Write-Output "RegKey: UseWordSaveAsPDFAddIn is correctly installed, no action taken" | Out-File -FilePath $logfile -Append
    }
else 
    {
    Write-Output "Key not found, writing RegKey: UseWordSaveAsPDFAddIn" | Out-File -FilePath $logfile -Append
    New-Itemproperty -Path "HKLM:\SOFTWARE\Wow6432Node\Ellie Mae\Encompass" -Name "UseWordSaveAsPDFAddIn" -Value "1" -PropertyType String -Force | Out-Null
    }
    Write-Output "Checking RegKey: bProtectedMode..." | Out-File -FilePath $logfile -Append
if ($regcheck3 -contains "True" -and $regcheck3_2 -contains "True")
    {
    Write-Output "RegKey: bProtectedMode is correctly installed, no action taken" | Out-File -FilePath $logfile -Append
    }
else
    {
    Write-Output "Key not found, writing RegKey: bProtectedMode" | Out-File -FilePath $logfile -Append
    New-Itemproperty  -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name "bProtectedMode" -Value "00000000" -PropertyType DWORD -Force | Out-Null
    }
    Write-Output "Checking Regkey: bEnhancedSecurityInBrowser..." | Out-File -FilePath $logfile -Append
if ($regcheck3_3 -contains "True" -and $regcheck3_4 -contains "True")
    {
    Write-Output "RegKey: bEnhancedSecurityInBrowser is correctly installed, no action taken" | Out-File -FilePath $logfile -Append
    }
else
    {
    Write-Output "Key not found, writing RegKey: bEnhancedSecurityInBrowser" | Out-File -FilePath $logfile -Append
    New-Itemproperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name "bEnhancedSecurityInBrowser" -Value "00000000" -PropertyType DWORD -Force | Out-Null
    }
    Write-Output "Checking RegKey: bEnhancedSecurityStandalone..." | Out-File -FilePath $logfile -Append
if ($regcheck3_5 -contains "True" -and $regcheck3_6 -contains "True")
    {
    Write-Output "RegKey: bEnhancedSecurityStandalone is correctly installed, no action taken" | Out-File -FilePath $logfile -Append
    }
else
    {
    Write-Output "Key not found, writing RegKey: bEnhancedSecurityStandalone" | Out-File -FilePath $logfile -Append
    New-Itemproperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name "bEnhancedSecurityStandalone" -Value "00000000" -PropertyType DWORD -Force | Out-Null
    }
if ($regcheck4 -contains "True")
    {
    Write-Output "Bad key found in HKCU\...\AppCompatFlags\Layers, removing key" | Out-File -FilePath $logfile -Append
    Remove-Itemproperty "HKU:\$sid\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\SmartClientCache\Apps\Ellie Mae\Encompass\Encompass.exe"
    }
if ($regcheck4_2 -contains "True")
    {
    Write-Output "Bad key found in HKLM\...\AppCompatFlags\Layers, removing key" | Out-File -FilePath $logfile -Append
    Remove-Itemproperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\SmartClientCache\Apps\Ellie Mae\Encompass\Encompass.exe"
    }
if ($printercheck1 -contains "True")
    {
    Write-Output "Printer: Encompass Document Converter is installed" | out-file -FilePath $logfile -Append
    }
else
    {
    Write-Output "Printer: Encompass Document Converter is not installed, installing now..." | out-file -FilePath $logfile -Append
    Add-Printer  -Name "Encompass Document Converter" -DriverName "Encompass Document Converter Driver" -PortName "EDCPort:"
    }
if ($printercheck2 -contains "True")
    {
    Write-Output "Printer: Encompass eFolder is installed" | out-file -FilePath $logfile -Append
    }
else
    {
    Write-Output "Printer: Encompass eFolder is not installed, installing now..." | out-file -FilePath $logfile -Append
    Add-Printer  -Name "Encompass eFolder" -DriverName "Encompass eFolder 2.0" -PortName "eFolderPort"
    }
if ($printercheck3 -contains "True")
    {
    Write-Output "Printer: Encompass is installed" | out-file -FilePath $logfile -Append
    }
else 
    {
    Write-Output "Printer: Encompass is not installed, installing now..." | out-file -FilePath $logfile -Append
    Add-Printer  -Name "Encompass" -DriverName "Amyuni Document Converter 2.51" -PortName "PDF"
    }

#remove previously mapped PSDrive
Remove-PSDrive -Name "HKU"

#user prompt with path to log file
[System.Windows.MessageBox]::Show("Repair complete`noutput located in C:\Windows\Temp\encompass-regcheck.log.txt`nClick OK to close this window.")