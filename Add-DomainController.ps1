Configuration Add-DomainController
{
    Param
    (
        [Parameter(Mandatory)]
        [String] $domainFQDN,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $adminCredential
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'
    Import-DscResource -ModuleName 'PSDscResources'

    node localhost
    {
        WindowsFeature 'InstallADDomainServicesFeature'
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }

        WindowsFeature 'RSATADPowerShell'
        {
            Ensure = 'Present'
            Name = 'RSAT-AD-PowerShell'
            DependsOn = '[WindowsFeature]InstallADDomainServicesFeature'
        }

        WaitForADDomain 'WaitForestAvailability'
        {
            DomainName = $domainFQDN
            Credential = $adminCredential
            DependsOn = '[WindowsFeature]RSATADPowerShell'
        }

        ADDomainController 'DomainControllerMinimal'
        {
            DomainName = $domainFQDN
            Credential = $adminCredential

            DependsOn = '[WaitForADDomain]WaitForestAvailability'
        }
    }
}