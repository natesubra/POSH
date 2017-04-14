Import-Module ActiveDirectory

$userpath = '<UNC-Path-to-User-Folder>'
$mappedpath = '<Drive Letter>'
$OU = '<OU DN>'

$adusers = get-aduser -Filter * -SearchBase $OU  -SearchScope OneLevel
foreach ($user in $adusers) {
$sam = "$($user.SamAccountName.ToString())"

New-Item -Path $userpath$sam -ItemType Directory -Force
$acl = get-acl $userpath$sam

set-aduser -identity $sam -HomeDirectory $userpath$sam -HomeDrive $mappedpath

$aclset = New-Object System.Security.AccessControl.FileSystemAccessRule("$sam", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($aclset)
Set-Acl $userpath$sam $acl
}
