function Check-WebContent {

#Requires -Version 3.0

<#

.Synopsis
Using the the WUG Service account, initiate an HTTP(s) connection and evaluate retrieved content against certain parameters

.Description
Using the invoke-webrequest cmdlet (requires POSH 3+), grabs the page response and checks for the content and or the statuscode response

.Parameter URL
The URL of the Redirect to check

.Parameter ExpectedResponseCode
Expected http response code (e.g. 200)

.Parameter ExpectedContentString
The string to match on. Regex can be used.

.Parameter NotFromWUG
Use this parameter to bypass using WUG specific variables, allows the function to work outside of the WUG context

.Example

Perform a content check against google.com from a non WUG context

Check-WebContent -URL www.google.com -ExpectedResponseCode 200 -ExpectedContentString "<title>Google</title>" -NotFromWUG

.Link
Code repository for this cmdlet
https://github.com/natesubra/POSH/WhatsUpGold

#>

        Param(
        [Parameter(Mandatory=$true)][string]$URL,
        [Parameter(Mandatory=$true)][string]$ExpectedContentString,
        [Parameter(Mandatory=$false)][int]$ExpectedResponseCode,
        [Parameter(Mandatory=$false)][switch]$NotFromWUG
        )

$Web_Response = (Invoke-WebRequest -UseDefaultCredentials -UseBasicParsing -Uri $URL -ErrorAction SilentlyContinue -UserAgent "Whats Up Gold" -WebSession $ContentCheckSession)

$Actual_Response_StatusCode = $Web_Response.StatusCode
$Actual_WebContent = $Web_Response.RawContent

$ContextCode = 0
$ContextMessage = "Check Succeeded, Response Code:$Actual_Response_StatusCode, Content match: `"$ExpectedContentString`""

if (!($ExpectedResponseCode -or $ExpectedContentString)) {
$ContextCode = 1
$ContextMessage = "Check failed, At least one expected parameter must be provided"
}

elseif (!($Actual_Response_StatusCode -eq $ExpectedResponseCode -or !$ExpectedResponseCode)) {
    $ContextCode = 1
    $ContextMessage = "Check failed, Response Code:$Actual_Response_StatusCode, Expected response code: $ExpectedResponseCode"
}
elseif (!($Actual_WebContent -match $ExpectedContentString -or !$ExpectedContentString)) {
    $ContextCode = 1
    $ContextMessage = "Check failed, Response Code:$Actual_Response_StatusCode, Expected content not found: `"$ExpectedContentString`""
}

$ContextCode.ToString() + ", " + $ContextMessage

if ($NotFromWUG -eq $false) {
    $Context.SetResult($ContextCode,$ContextMessage)
    $Logger.WriteLine($ContextCode.ToString() + ", " + $ContextMessage)
    }
}
