$samlist = Import-Csv C:\temp\userlist.csv | Select SamAccountName
$upnlist = Import-Csv C:\temp\userlist.csv | Select UserPrincipalName
$upn = $upnlist.trim("@swbc.com")