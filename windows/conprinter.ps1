$String = 
$PrinterList = get-wmiobject win32_printer -computername p-appprt1 | select name
$Printer = 