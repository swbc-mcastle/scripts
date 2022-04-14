Set objRootDSE = GetObject("LDAP://RootDSE")
strDNSDomain = objRootDSE.Get("DefaultNamingContext")
strDomain = "LDAP://" & strDNSDomainGetObject("LDAP://RootDSE")