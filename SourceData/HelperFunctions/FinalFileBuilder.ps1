$FormFile = "$((Get-Item $($PSScriptRoot)).parent.fullname)\Exported"
$footer = "$((Get-Item $($PSScriptRoot)).parent.fullname)\RoyalTS"
$destination = "$((Get-Item $($PSScriptRoot)).parent.fullname)\FinalizedFile"

$tempData = get-content "$($formfile)\RoyalTSDynamicForm.Export.ps1"
$tempData += "`r`n"
$tempData += get-content "$($footer)\RoyalTSDynamicConnectionFooter.ps1"
$tempData | out-file "$($destination)\ExportedCompleteFile.ps1" -encoding ascii

Write-Host $FormFile
write-host $footer
