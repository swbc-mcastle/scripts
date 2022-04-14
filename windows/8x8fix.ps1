Stop-Process -Name "8x8 Work"
remove-item $env:APPDATA\"8x8 Work" -Force -Recurse
Start-Process "C:\Program Files\8x8 Inc\8x8 Work\8x8 Work.exe"
