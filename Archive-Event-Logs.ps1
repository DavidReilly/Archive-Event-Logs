<#
.SYNOPSIS
	Saves and zips Windows event logs
.DESCRIPTION
	Simple script that can be run to save frequently overwritten logs to a folder or network location.
    The logs will be zipped into a single file each day to save space and easier copying over network/web 
    for review and troubleshooting.
.PARAMETER text
	No params at this time, variables set in script
.EXAMPLE
	PS> ./Archive-Event-Logs

.LINK
	https://github.com/DavidReilly/Archive-Event-Logs
.NOTES
	Author: David Reilly | License: CC0
#>


try {
##### Set Variables #####
$sourcePath = "C:\Windows\System32\winevt\Logs"    #### Path to Event Log source folder
$tempFolder = "C:\EventLogs\temp"        #### Path to temp folder for full file copy (will be cleared after zip file creation)
$destinationPath = "\\FS01\LogArchive"   #### Path to archive location (file or share path)
$zipFileName = "$env:computername Logs Archived - $(get-date -f yyyy-MM-dd).zip"   #### Name of zip file containing this day's logs
$daysKept = 30  #### Number of days to retain zipped log files on archive share for review/troubleshooting


##### Copy to temp folder for zip operation (prevents file in use errors for active logs)
# Copy files to the destination folder
Copy-Item -Path $sourcePath\* -Destination $tempFolder -Force


##### Perform zip in temp folder
# Zip the event logs
Compress-Archive -Path $tempFolder\* -DestinationPath "$destinationPath\$zipFileName" -Force

# Move the zip file to the destination folder or share
Move-Item -Path "$destinationPath\$zipFileName" -Destination $destinationPath -Force


##### Clean up temp folder
Get-ChildItem -Path $tempFolder | Remove-Item -Force


##### Prune archive location (you can also run this separately on server hosting log share)
Get-ChildItem -Path $destinationPath -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$daysKept) } | Remove-Item -Force

} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}