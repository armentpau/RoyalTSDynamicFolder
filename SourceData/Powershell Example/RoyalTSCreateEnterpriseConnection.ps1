Import-Module ActiveDirectory
[System.Collections.ArrayList]$array = @()
foreach ($computer in Get-ADComputer -SearchBase "ou=Enterprise Servers,dc=ahc,dc=root,dc=loc" -Filter * -SearchScope subtree -Properties canonicalname)
{
	$array.add((
			New-Object -TypeName System.Management.Automation.PSObject -Property @{
				"Type" = "RemoteDesktopConnection";
				"Name" = $computer.name;
				"credentialName" = "949237a";
				"Path" = $computer.canonicalname.replace("/$($computer.name)", "")
			}
		)) | Out-Null
}
#$array = $array | Sort-Object -Property name
$hash = @{ }
$hash.add("Objects", $array)

$hash | ConvertTo-Json