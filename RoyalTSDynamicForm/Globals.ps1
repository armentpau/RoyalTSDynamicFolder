#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
$hashPorts = @{
	"SecureGateway" = 22
	"RoyalServer" = 54899 
	"RemoteDesktopGateway" = $null
	"RemoteDesktopConnection" = 3389
	"TerminalConnection - SSH" = 22
	"TerminalConnection - Telnet" = 23
	"TerminalConnection - Serial" = $null
	"VNCConnection" = 5900
	"WindowsEventsConnection" = $null
	"WindowsServicesConnection" = $null
	"WindowsProcessesConnection" = $null
	"TerminalServicesConnection" = $null
	"PowerShellConnection"	     = $null
}

function Update-DCTextBoxes
{
	if (-not ([string]::IsNullOrEmpty($domainTextBox.Text)))
	{
		try
		{
			$selectedDomain = Get-ADDomain -Identity $($domainTextBox.text) -ErrorAction Stop
			$dcRootTextBox.text = $selectedDomain.distinguishedname
			$dcTextBox.Text = $selectedDomain.pdcemulator
		}
		catch
		{
			
		}
	}
	else
	{
		$dcRootTextBox.Text = ""
		$dcTextBox.Text = ""
	}
}

function Start-showOUDialogs
{
	if (-not [string]::IsNullOrEmpty($dcRootTextBox.Text))
	{
		$script:currentlySelectedOU = $searchBaseTextBox.text
		$script:selectedDomainRoot = $dcRootTextBox.text
		Show-OU_Selector_psf
		$searchBaseTextBox.Text = $script:selectedOU
	}
}
