function Get-AppLockerEvents {

<#

.Synopsis
Gets Applocker events from a machine

.Description
Gets Applocker events from a machine. Uses Get-WinEvent to grab the initial data. Uses .net XML extraction to parse. Translates user SIDs using .net security principle.

.Parameter Computername
Specify the computer to get the applocker events from (Make sure to specify the correct logname when querying EVL forward targets).

.Parameter Logname
Specify the log name the events are located in. Either "Microsoft-Windows-AppLocker/EXE and DLL" or "ForwardedEvents" for event log forwarded machines.

.Example
Get-Applocker-Events -computername targetmachine -logname "Microsoft-Windows-AppLocker/EXE and DLL"
Get-AppLockerEvents -Computername evlserver -Logname ForwardedEvents | export-csv -NoTypeInformation -Path $env:userprofile\desktop\applockerevents.csv

.Link
https://github.com/natesubra/POSH
References:
http://blogs.technet.com/b/ashleymcglone/archive/2013/08/28/powershell-get-winevent-xml-madness-getting-details-from-event-logs.aspx
https://social.technet.microsoft.com/Forums/windows/en-US/6b9476fa-66b8-4da9-bee2-6dcc0907c157/applocker-remote-reporting?forum=winserverpowershell
http://poshcode.org/5494
https://gallery.technet.microsoft.com/scriptcenter/Get-WinEventData-Extract-344ad840
http://pastebin.com/dRs27F16
http://ramblingcookiemonster.wordpress.com/2014/08/03/learning-and-exploring-powershell-a-practical-example/
https://technet.microsoft.com/en-us/library/ff730940.aspx

#>
        Param(
        [Parameter(mandatory=$true)][string]$Computername,
        [Parameter(mandatory=$true)][string][validateset("Microsoft-Windows-AppLocker/EXE and DLL","ForwardedEvents")]$Logname
        )
 
    Get-WinEvent -computername $ComputerName -logname $Logname | % {
       
        #Get the XML for this event.
        $XML = [xml]$_.ToXml()
 
        #Build the custom output for this event
        $_ | Select-Object -Property MachineName,
            TimeCreated,
            LevelDisplayName,
            ID,
            UserId,
            @{ Name = "User"; Expression = {[string][System.Security.Principal.SecurityIdentifier]::new($_.UserId).Translate([System.Security.Principal.NTAccount]).Value}},
            @{ Name = "RuleName"; Expression = {$XML.Event.UserData.RuleAndFileData.RuleName}},
            @{ Name = "FilePath"; Expression = {$XML.Event.UserData.RuleAndFileData.FilePath}},
            @{ Name = "FileHash"; Expression = {$XML.Event.UserData.RuleAndFileData.FileHash}},
            @{ Name = "Fqbn";     Expression = {$XML.Event.UserData.RuleAndFileData.Fqbn}},
            Message

    }
}
