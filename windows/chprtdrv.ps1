$EndPoint = Read-Host -Prompt "Enter Computer Hostname:"
$driver = Read-Host -Prompt "Enter driver name:"
$pattern1 = Read-Host -Prompt "Enter search string for printer:"

$printers = get-printer | select Name


foreach($printer in ($printers|Where{$_.Name -like $pattern1})){
        $name = $printer.name
        & rundll32 printui.dll PrintUIEntry /Xs /n $name DriverName $driver
}