#$GPOreport = (Get-GPOReport -GUID A1EEA7D3-ACAA-48A6-BCCF-22DA3B635AFF -ReportType HTML -Path $HOME\Documents\AuditReports\corpwkstndefault.HTML)
#Set-PSDebug -Trace 1
$DTG = Get-Date -format "dd-MMM-yyyy HH:mm:ss"
$Hostname = Get-Content -path $HOME\Documents\hostnames.csv 
$FirewallRPT = get-netfirewallprofile -policystore activestore -cimsession $Hostname | Select PSComputername,Name,Enabled | Sort-Object -prop PSComputerName
$DTG | Out-File -FilePath "$HOME\Documents\AuditReports\FireWallPolicyRPT\firewallpolicy.txt"
$FirewallRPT | Out-File -FilePath "$HOME\Documents\AuditReports\FireWallPolicyRPT\firewallpolicy.txt" -Append