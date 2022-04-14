CLS
@echo off
::
::  Remove All Encompass Obsolete Remnants (aka RENCOR?)
::  Version BETA
::
ECHO Starting UnInstall...
ECHO.
ECHO Removing SmartClient Installation Manager...
wmic product where name="SmartClient Installation Manager" call uninstall /nointeractive >nul 2>&1
ECHO Removing Encompass Document Converter...
wmic product where name="Encompass Document Converter" call uninstall /nointeractive >nul 2>&1
ECHO Removing Encompass eFolder...
wmic product where name="Encompass eFolder" call uninstall /nointeractive >nul 2>&1
ECHO Removing Encompass SmartClient...
wmic product where name="Encompass SmartClient" call uninstall /nointeractive >nul 2>&1
ECHO Removing SmartClient Core...
wmic product where name="SmartClient Core" call uninstall /nointeractive >nul 2>&1
ECHO.
ECHO All Encompass products removed!
CLS
ECHO Moving on to removing printers...
ECHO Removing Printer - Encompass
wmic printer where "DeviceID LIKE 'Encompass'" delete >nul 2>&1
ECHO Removing Printer - Encompass eFolder
wmic printer where "DeviceID LIKE 'Encompass eFolder'" delete >nul 2>&1
ECHO Removing Printer - Encompass Document Converter
wmic printer where "DeviceID LIKE 'Encompass Document Converter'" delete >nul 2>&1
ECHO.
ECHO All Encompass Added printers removed!
ECHO.
CLS
ECHO Removing Encompass Directories (just in case)!
rd C:\SmartC~1 /s /q
rd C:\Progra~2\Encomp~1 /s /q
rd C:\Progra~2\Elliem~1 /s /q
rd C:\Encomp~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Local\Encomp~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Local\Temp\Encomp~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Local\Temp\Encomp~2 /s /q
rd D:\Users\%USERNAME%\Appdata\LocalLow\Apps\Elliem~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Roaming\Elliem~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Roaming\Encomp~1 /s /q
rd D:\Users\%USERNAME%\Appdata\Roaming\ePass /s /q
ECHO Directories Removed!
ECHO.
CLS
ECHO Removing Encompass Registry Keys
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\ELLIE MAE" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\ELLIE MAE" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Black Ice Software LLC\Encompass Document Converter" /f
REG DELETE "HKEY_CURRENT_USER\ELLIE MAE" /f
REG DELETE "HKEY_CURRENT_USER\SOFTWARE\ELLIE MAE" /f
REG DELETE "HKEY_CURRENT_USER\SOFTWARE\ENCOMPASS" /f
REG DELETE "HKEY_CURRENT_USER\Software\Black Ice Software LLC\Encompass Document Converter" /f
REG DELETE "HKEY_CURRENT_CONFIG\Software\Encompass" /f
ECHO Registry Keys Removed!
ECHO.
CLS
ECHO EnCompass has been removed!