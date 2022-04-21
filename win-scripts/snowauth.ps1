$params = @{
    Url = 'instance.service-now.com'
    Credential = $userCred
    ClientCredential = $clientCred
}
New-ServiceNowSession @params