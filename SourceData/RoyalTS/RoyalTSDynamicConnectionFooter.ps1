Import-Module ActiveDirectory
[System.Collections.ArrayList]$array = @()
[System.Collections.ArrayList]$pathArray = @()
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
	if ($($data.useCimChecked) -like "Checked")
	{
		$useCim = "true"
	}
	else
	{
		$useCim = "false"
	}
	if ($($data.adminConsole) -like "Checked")
	{
		$useadminConsole = "true"
	}
	else
	{
		$useadminConsole = "false"
	}
	foreach ($computer in Get-ADComputer -SearchBase $searchBase -Filter $filter -SearchScope $searchScope -Server $server -Properties canonicalname)
	{
		if ($data.useParentCred -eq $true)
		{
			$subPath = $computer.canonicalname.replace("/$($computer.name)", "")
			$initialCounter = 0
			foreach ($pathItem in $subPath.split("/"))
			{
				if ($initialCounter -eq 0)
				{
					$builderPath = "/"
					$initialCounter++
					$previousPath = $pathItem
					
					
				}
				else
				{
					$builderPath = "$($builderPath)/$previousPath".replace('//', '/')
					$previousPath = $pathItem
					
				}
				if ($pathArray.Contains("$($builderPath)/$pathItem"))
				{
					
				}
				else
				{
					$array.add((
							New-Object -TypeName System.Management.Automation.PSObject -Property @{
								"Type"			    = "Folder";
								"CredentialsFromParent" = "true";
								"Path"			    = $builderPath;
								"Name"			    = $pathItem;
							}
						)) | Out-Null
					$pathArray.add("$($builderPath)/$pathItem") | Out-Null
				}
			}
		}
		if ($($data.connectionType) -like "RemoteDesktopConnection")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $data.connectionType;
						"Port" = $data.portNumber
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $data.credentialName;
						"Path" = "/" +$computer.canonicalname.replace("/$($computer.name)", "");
						"ConsoleSession" = $useadminConsole;
						"CredentialsFromParent" = $data.useParentCred;
					}
				)) | Out-Null
		}
		elseif ($($data.connectionType) -like "TerminalConnection*")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type"			     = "TerminalConnection";
						"TerminalConnectionType" = $($data.connectionType).replace("TerminalConnection - ", "")
						"Port"			     = $data.portNumber
						"Name"			     = $computer.name;
						"ComputerName"		     = $computer.name;
						"credentialName"	     = $data.credentialName;
						"Path"			     = "/" +$computer.canonicalname.replace("/$($computer.name)", "");
						"CredentialsFromParent"  = $data.useParentCred;
					}
				)) | Out-Null
		}
		elseif ($($data.connectionType) -like "Windows*" -or $($data.connectionType) -like "TerminalServicesConnection")
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $data.connectionType;
						"UseCIM" = $useCim;
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $data.credentialName;
						"Path" = "/" +$computer.canonicalname.replace("/$($computer.name)", "");
						"CredentialsFromParent" = $data.useParentCred;
					}
				)) | Out-Null
		}
		elseif ([string]::IsNullOrEmpty($data.portNumber))
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $data.connectionType;
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $data.credentialName;
						"Path" = "/"+$computer.canonicalname.replace("/$($computer.name)", "");
						"CredentialsFromParent" = $data.useParentCred;
					}
				)) | Out-Null
		}
		else
		{
			$array.add((
					New-Object -TypeName System.Management.Automation.PSObject -Property @{
						"Type" = $data.connectionType;
						"Port" = $data.portNumber
						"Name" = $computer.name;
						"ComputerName" = $computer.name;
						"credentialName" = $data.credentialName;
						"Path" = "/" +$computer.canonicalname.replace("/$($computer.name)", "");
						"CredentialsFromParent" = $data.useParentCred;
					}
				)) | Out-Null
		}
		
	}
	$newarray = $array | Sort-Object -Property path
	$hash = @{ }
	$hash.add("Objects", $newarray)
	$hash | ConvertTo-Json
}