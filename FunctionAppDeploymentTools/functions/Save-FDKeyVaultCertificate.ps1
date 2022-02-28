function Save-FDKeyVaultCertificate
{
	<#
	.SYNOPSIS
		Exports a certificate from Azure KeyVault and stores it in file.
	
	.DESCRIPTION
		Exports a certificate from Azure KeyVault and stores it in file.

		Supports retrieving the secret information in different format:
		- Public key information only (.cer)
		- Encrypted private key information (.pfx)
		- Unencrypted private key information (.pem)
		The format is chosen based on the file extension selected for the output file.

		To save as pfx certificate, specifying a passsword is required.
	
	.PARAMETER VaultName
		Name of the Key Vault to access.
	
	.PARAMETER Name
		Name of the Certificate to save to file.
	
	.PARAMETER Path
		The path to write the certificate to.
		Include the filename and extension, the extension will determine thee data format retrieved.
		Supported extensions: .cer, .pfx, .pem
	
	.PARAMETER Password
		The password to protect the certificate with.
		Only applies to pfx certificates
	
	.PARAMETER WhatIf
		if this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

	.EXAMPLE
		PS C:\> Save-FDKeyVaultCertificate -VaultName myVault -Name myCert -Path .\cert.cer

		Saves the public key information of the "myCert" certificate in vault "myVault" to the file "cert.cer" in the current folder.
	
	.EXAMPLE
		PS C:\> Save-FDKeyVaultCertificate -VaultName myVault -Name myCert -Path .\cert.pfx -Password (Read-Host -AsSecureString)

		Saves the "myCert" certificate in vault "myVault" to the file "cert.pfx" in the current folder, protected by the specified password.
	
	.EXAMPLE
		PS C:\> Save-FDKeyVaultCertificate -VaultName myVault -Name myCert -Path .\cert.pem

		Saves the unencrypted private key information of the "myCert" certificate in vault "myVault" to the file "cert.pem" in the current folder.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$VaultName,

		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.FileOrParent', ErrorString = 'PSFramework.Validate.FSPath.FileOrParent')]
		[string]
		$Path,

		[securestring]
		$Password
	)
	
	begin
	{
		$outPath = Resolve-PSFPath -Path $Path -Provider FileSystem -NewChild -SingleItem
		$type = ($outPath -split "\.")[-1]
	}
	process
	{
		switch ($type) {
			#region PFX
			'pfx' {
				if (-not $Password) {
					Stop-PSFFunction -String 'Save-FDKeyVaultCertificate.Error.NoPassword' -Cmdlet $PSCmdlet -EnableException $true
				}

				Invoke-PSFProtectedCommand -ActionString 'Save-FDKeyVaultCertificate.Retrieving.Secret' -ActionStringValues $VaultName, $Name -Target $Name -ScriptBlock {
					$secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -ErrorAction Stop
				} -EnableException $true -PSCmdlet $PSCmdlet
				$certString = [PSCredential]::New("irrelevant", $secret.SecretValue).GetNetworkCredential().Password
				$bytes = [convert]::FromBase64String($certString)
				$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes, "", "Exportable,PersistKeySet")
				$newBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $Password)
				[System.IO.File]::WriteAllBytes($outPath, $newBytes)
			}
			#endregion PFX

			#region PEM
			'pem' {
				Invoke-PSFProtectedCommand -ActionString 'Save-FDKeyVaultCertificate.Retrieving.Secret' -ActionStringValues $VaultName, $Name -Target $Name -ScriptBlock {
					$secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -ErrorAction Stop
				} -EnableException $true -PSCmdlet $PSCmdlet
				$certString = [PSCredential]::New("irrelevant", $secret.SecretValue).GetNetworkCredential().Password
				$bytes = [convert]::FromBase64String($certString)
				$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes, "", "Exportable,PersistKeySet")

				$certificatePem = [System.Security.Cryptography.PemEncoding]::Write("CERTIFICATE", $cert.RawData) -join ""
				$key = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
				$pubKeyPem = [System.Security.Cryptography.PemEncoding]::Write("PUBLIC KEY", $key.ExportSubjectPublicKeyInfo()) -join ""
				$privKeyPem = [System.Security.Cryptography.PemEncoding]::Write("PRIVATE KEY", $key.ExportPkcs8PrivateKey()) -join ""

				$certString = $certificatePem, $pubKeyPem, $privKeyPem -join "`n`n"
				$encoding = [System.Text.UTF8Encoding]::new($false)
				[System.IO.File]::WriteAllText($outPath, $certString, $encoding)
			}
			#endregion PEM

			#region CER
			'cer' {
				Invoke-PSFProtectedCommand -ActionString 'Save-FDKeyVaultCertificate.Retrieving.Public' -ActionStringValues $VaultName, $Name -Target $Name -ScriptBlock {
					$cert = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -ErrorAction Stop
				} -EnableException $true -PSCmdlet $PSCmdlet
				$bytes = $cert.Certificate.GetRawCertData()
				[System.IO.File]::WriteAllBytes($outPath, $bytes)
			}
			#endregion CER

			default {
				Stop-PSFFunction -String 'Save-FDKeyVaultCertificate.Error.UnknownExtension' -StringValues $type, $outPath -Cmdlet $PSCmdlet -EnableException $true
			}
		}
	}
}