Import-Module ActiveDirectory
[System.Collections.ArrayList]$array = @()
$script:ConfigFilePath = "$($env:APPDATA)\RoyalTSDynamicFolderCustomizer"
if ("$CustomProperty.ConfigFileName$" -ne '.ConfigFileName$' -and "$CustomProperty.ConfigFileName$" -ne "TODO")
{
	$script:configFileName = "$CustomProperty.ConfigFileName$"
}
else
{
	$script:configFileName = "settings.xml"
}
if (Test-Path "$($script:ConfigFilePath)\$($configFileName)")
{
	$data = Import-Clixml -Path "$($script:ConfigFilePath)\$($configFileName)"
	$filter = $data.filter
	$searchScope = $data.searchscope
	$server = $data.server
	$searchBase = $data.searchbase
	$credentialName = $data.credentialName
	$portNumber = $data.portNumber
	$connectionType = $data.connectionType
	$useCimChecked = $data.useCimChecked
	$useConsole = $data.adminConsole
	if ($useCimChecked -like "Checked")
	{
		$useCim = "true"
	}
	else
	{
		$useCim = "false"
	}
	if ($useConsole -like "Checked")
	{
		$useadminConsole = "true"
	}
	else
	{
		$useadminConsole = "false"
	}
	foreach ($computer in Get-ADComputer -SearchBase $searchBase -Filter $filter -SearchScope $searchScope -Server $server -Properties canonicalname)
	{
		if ($connectionType -like "RemoteDesktopConnection")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $connectionType;
						"Port"			     = $portNumber
						"Name"			     = $computer.name;
						"ComputerName"		     = $computer.name;
						"credentialName"	     = $credentialName;
						"Path" = $computer.canonicalname.replace("/$($computer.name)", "");
						"ConsoleSession" = $useadminConsole
					}
				)) | Out-Null
		}
		elseif ($connectionType -like "TerminalConnection*")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = "TerminalConnection";
						"TerminalConnectionType" = $connectionType.replace("TerminalConnection - ", "")
						"Port" = $portNumber
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $credentialName;
						"Path" = $computer.canonicalname.replace("/$($computer.name)", "");
					}
				)) | Out-Null
		}
		elseif ($connectionType -like "Windows*" -or $connectionType -like "TerminalServicesConnection")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type"			     = $connectionType;
						"UseCIM" = $useCim;
						"Name"			     = $computer.name;
						"ComputerName"		     = $computer.name;
						"credentialName"	     = $credentialName;
						"Path"			     = $computer.canonicalname.replace("/$($computer.name)", "");
					}
				)) | Out-Null
		}
		elseif ([string]::IsNullOrEmpty($portNumber))
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $connectionType;
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $credentialName;
						"Path" = $computer.canonicalname.replace("/$($computer.name)", "");
					}
				)) | Out-Null
		}
		else
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $connectionType;
						"Port" = $portNumber
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $credentialName;
						"Path" = $computer.canonicalname.replace("/$($computer.name)", "");
					}
				)) | Out-Null
		}
		
	}
	$array = $array | Sort-Object -Property path
	$hash = @{ }
	$hash.add("Objects", $array)
	$hash | ConvertTo-Json
}