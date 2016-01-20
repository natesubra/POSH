function Verify-WebRedirectLocation {

#Requires -Version 3.0

<#

.Synopsis
Initiate an HTTP(s) connection and evaluate it against certain parameters

.Description
Using the invoke-webrequest (requires PS 3+), grabs the page response and checks for the $_.StatusCode and/or the Header location

.Parameter URL
The URL of the Redirect to check

.Parameter ExpectedResponseCode
The expected HTTP(s) response code (ex. 200/301/302 etc)

.Parameter ExpectedLocation
The expected HTTP(s) redirect target

.Parameter NotFromWUG
Use this parameter to bypass using WUG specific variables, allows the function to work outside of the WUG context

.Example
Verify-WebRedirectLocation -URL "HTTP://redirectmetohttps/" -ExpectedLocation "https://redirectmetohttps/" -ExpectedResponseCode 301

.Link
Code repository for this cmdlet
https://github.com/natesubra/POSH

#>

        Param(
        [Parameter(Mandatory=$true)][string]$URL,
        [Parameter(Mandatory=$false)][int]$ExpectedResponseCode,
        [Parameter(Mandatory=$false)][string]$ExpectedLocation,
        [Parameter(Mandatory=$false)][switch]$NotFromWUG
        )

$ContextCode = 0
$ContextMessage = "Web redirect verified"

$Web_Response = (Invoke-WebRequest -UseDefaultCredentials -UseBasicParsing $URL -MaximumRedirection 0 -ErrorAction SilentlyContinue)

$Actual_Location = ($Web_Response.Headers["Location"])
$Actual_Response_StatusCode = $Web_Response.StatusCode

if (!($ExpectedResponseCode -or $ExpectedLocation)) {
$ContextCode = 1
$ContextMessage = "Web redirect failed, at least one expected parameter must be provided"
}

elseif (!($Actual_Response_StatusCode -eq $ExpectedResponseCode -or !$ExpectedResponseCode)) {
    $ContextCode = 1
    $ContextMessage = "Web redirect failed, expected response code: $ExpectedResponseCode actual: $Actual_Response_StatusCode"
}
elseif (!($Actual_Location -eq $ExpectedLocation -or !$ExpectedLocation)) {
    $ContextCode = 1
    $ContextMessage = "Web redirect failed, expected location: $ExpectedLocation actual: $Actual_Location"
}

$ContextCode.ToString() + ", " + $ContextMessage

if ($NotFromWUG -eq $false) {
    $Context.SetResult($ContextCode,$ContextMessage)
    $Logger.WriteLine($ContextCode.ToString() + ", " + $ContextMessage)
    }
}
