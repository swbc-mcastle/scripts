$ExtensionID = Read-Host -Prompt "enter extension ID:"
reg add HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist /v 1 /t REG_SZ /d $ExtensionID /f