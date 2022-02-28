function Get-FDKeyVaultCertificate
{
	<#
	.SYNOPSIS
		Retrieve the certificate from an Azure KeyVault
	
	.DESCRIPTION
		Retrieve the certificate from an Azure KeyVault
		Returns the certificate object as consumed by PowerShell.
		Supports retrieving either only the public key or both public and private.

		In opposite to the native KeyVault commands, it does not return any KV metadata.
	
	.PARAMETER VaultName
		Name of the KeyyVault to access.
	
	.PARAMETER Name
		Name of the certificate to access.
	
	.PARAMETER PrivateKey
		Include the private key in the certificate retrieved.

	.PARAMETER WhatIf
		if this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Get-FDKeyVault -VaultName 'myVault' -Name 'myCert'

		Retrieve the public version of the 'myCert' certificate from vault 'myVault'
	
	.EXAMPLE
		PS C:\> Get-FDKeyVault -VaultName 'myVault' -Name 'myCert' -PrivateKey

		Retrieve both the public & private key of the 'myCert' certificate from vault 'myVault'
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
	[OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
	[CmdletBinding(SupportsShouldProcess = $true)]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$VaultName,

		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		[switch]
		$PrivateKey
	)
	
	process
	{
		if ($PrivateKey) {
			Invoke-PSFProtectedCommand -ActionString 'Get-FDKeyVaultCertificate.Retrieving.Secret' -ActionStringValues $VaultName, $Name -Target $Name -ScriptBlock {
				$secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $Name -ErrorAction Stop
			} -EnableException $true -PSCmdlet $PSCmdlet
			$certString = [PSCredential]::New("irrelevant", $secret.SecretValue).GetNetworkCredential().Password
			$bytes = [convert]::FromBase64String($certString)
			[System.Security.Cryptography.X509Certificates.X509Certificate2]::new($bytes, "", "Exportable,PersistKeySet")
		}
		else {
			Invoke-PSFProtectedCommand -ActionString 'Get-FDKeyVaultCertificate.Retrieving.Public' -ActionStringValues $VaultName, $Name -Target $Name -ScriptBlock {
				$cert = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -ErrorAction Stop
			} -EnableException $true -PSCmdlet $PSCmdlett
			$cert.Certificate
		}
	}
}
