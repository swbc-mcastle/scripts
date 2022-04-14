Add-Type -assemblyName System.Windows.Forms;$a=@(1..100);while(1){[System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(($a|get-random),($a|get-random));start-sleep -seconds 5}
