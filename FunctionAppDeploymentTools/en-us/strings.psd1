# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Get-FDKeyVaultCertificate.Retrieving.Public'       = 'Retrieving the public certificate {1} from vault {0}' # $VaultName, $Name
	'Get-FDKeyVaultCertificate.Retrieving.Secret'       = 'Retrieving the private key certificate {1} from vault {0}' # $VaultName, $Name

	'Save-FDKeyVaultCertificate.Error.NoPassword'       = 'Password must be specified when exporting as PFX!' # 
	'Save-FDKeyVaultCertificate.Error.UnknownExtension' = 'Unrecognized file extension: {0} - specify either a .cer, .pfx or .pem ({1})' # $type, $outPath
	'Save-FDKeyVaultCertificate.Retrieving.Public'      = 'Retrieving the public certificate {1} from vault {0}' # $VaultName, $Name
	'Save-FDKeyVaultCertificate.Retrieving.Secret'      = 'Retrieving the private key certificate {1} from vault {0}' # $VaultName, $Name
}