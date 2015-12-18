#TODO CMDLET
 
#TODO optional domain
$dns_servers = (Get-ADDomain).ReplicaDirectoryServers
 
# Create empty array
$dns_array = @()
 
foreach ($dns_server in $dns_servers) {
$dns_server_output = Get-DnsServerForwarder -ComputerName $dns_server
 
    foreach ($dns_forwarder_ip in $dns_server_output.ReorderedIPAddress.IPAddressToString) {
    $Forwarder_Hostname = ([System.Net.Dns]::GetHostEntry("$dns_forwarder_ip")).HostName
    $dns_obj_props = @{'DNS_Server' = $dns_server ; 'Forwarder_IP' = $dns_forwarder_ip ; 'Forwarder_Resolved' = $Forwarder_Hostname}
    $dns_obj = New-Object -TypeName PSObject -Property $dns_obj_props
    $dns_obj | ft -AutoSize
    $dns_array += $dns_obj
    }
 
}
$dns_array | ft -autosize
