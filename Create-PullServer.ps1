configuration CreatePullServer
{
    param
    (
        [string[]]$computername = 'localhost'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node $computername
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name = "DSC-Service"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure = "Present"
            EndpointName = "PSDSCPullServer"
            Port = 8080
            PhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbprint = "AllUncencryptedTraffic"
            ModulePath = "$env:ProgramFiles\WindowsPowershell\DscService\Modules"
            ConfigurationPath = "$env:ProgramFiles\Windowspowershell\DscService\Configuration"
            State = "started"
            DependsOn = "[WindowsFeature]DSCServiceFeature"
        }
        
        xDscWebService PSDSCComplicanceServer
        {
            Ensure = "Present"
            EndpointName = "PSDSCComplianceServer"
            Port = 9080
            PhysicalPath = "$env:SystemDrive\inetpub\wwwroot\PSDSCCompliancServer"
            CertificateThumbprint = "AllUncencryptedTraffic"
            State = "Started"
            IsComplianceServer = $true
            DependsOn = ("[WindowsFeature]DSCServiceFeature"."[xDSCWebService]PSDSCPullServer")
        }
    }
}


#Generate MOV
CreatePullServer -computername dev-dc.dev.local

#Push the MOF
Start-DscConfiguration .\CreatePullServer -wait

            