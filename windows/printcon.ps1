import-module PrintManagement
$printer = $args[0]
#$client = $args[1]
$client = Read-Host -Prompt "Enter hostname of computer"
Add-Printer -CimSession $client -ConnectionName \\p-appprt1\$printer
