<#
This is an example configuration file

By default, it is enough to have a single one of them,
however if you have enough configuration settings to justify having multiple copies of it,
feel totally free to split them into multiple files.
#>

<#
# Example Configuration
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Example.Setting' -Value 10 -Initialize -Validation 'integer' -Handler { } -Description "Example configuration setting. Your module can then use the setting using 'Get-PSFConfigValue'"
#>

Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Import.DoDotSource' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be dotsourced on import. By default, the files of this module are read as string value and invoked, which is faster but worse on debugging."
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Import.IndividualFiles' -Value $false -Initialize -Validation 'bool' -Description "Whether the module files should be imported individually. During the module build, all module code is compiled into few files, which are imported instead by default. Loading the compiled versions is faster, using the individual files is easier for debugging and testing out adjustments."

Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Default.Location' -Value 'eastus' -Initialize -Validation string -Description 'Default location to deploy resources to.'
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Default.StorageAccount.SKU' -Value 'Standard_LRS' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Default.StorageAccount.Kind' -Value 'Storage' -Initialize -Validation string -Description ''

Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.ResourceGroup.Pattern' -Value '' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.ResourceGroup.Default' -Value '{0}' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.FunctionApp.Pattern' -Value '' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.FunctionApp.Default' -Value '{0}' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.KeyVault.Pattern' -Value '' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.KeyVault.Default' -Value '{0}' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.StorageAccount.Pattern' -Value '' -Initialize -Validation string -Description ''
Set-PSFConfig -Module 'FunctionAppDeploymentTools' -Name 'Naming.StorageAccount.Default' -Value '{0}' -Initialize -Validation string -Description ''