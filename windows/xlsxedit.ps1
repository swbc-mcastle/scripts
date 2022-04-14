import-module psexcel
$regex = '\s'
$SamAccountName = import-xlsx C:\Users\mike.castle\Downloads\upn.samaccountnames.xlsx | select SamAccountName
if ($SamAccountName -match "\s") {Write-Host "This string contains a space"
    
}