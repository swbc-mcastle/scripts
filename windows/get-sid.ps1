$user = New-Object System.Security.Principal.NTAccount($env:username) 
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
$sid.Value
$PSDrives = (get-psdrive).Name

if ($PSDrives -notcontains "HKU") 
   {
    New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
   }

#New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
#Test-Path -ErrorAction SilentlyContinue "HKU:\$sid\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
#Remove-PSDrive -name "HKU"
Remove-ItemProperty "HKU:\$sid\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name "C:\SmartClientCache\Apps\Ellie Mae\Encompass\Encompass.exe"