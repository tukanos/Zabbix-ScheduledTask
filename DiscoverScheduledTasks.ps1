# Script: DiscoverSchelduledTasks
# Author: Romain Si
# Revision: Isaac de Moraes
# This script is intended for use with Zabbix > 3.x
#
#
# Add to Zabbix Agent
# UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\DiscoverScheduledTasks.ps1" "$1" "$2"
#
## Modifier la variable $path pour indiquer les sous dossiers de Tâches Planifiées à traiter sous la forme "\nomDossier\","\nomdossier2\sousdossier\" voir (Get-ScheduledTask -TaskPath )
## Change the $path variable to indicate the Scheduled Tasks subfolder to be processed as "\nameFolder\","\nameFolder2\subfolder\" see (Get-ScheduledTask -TaskPath )

$ErrorActionPreference = "Stop"

$paths = "\", "\AG\"

Function Convert-ToUnixDate($PSdate) {
	$epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
	if ($PSdate -eq $Null) {
		$PSdate = $epoch
	}
	(New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

function Get-ScheduledTaskByFullName($fullname) {
	$path = $fullname.Substring(0, $fullname.LastIndexOf('/') + 1).replace("/","\")
	$name = $fullname.Substring($fullname.LastIndexOf('/') + 1)

	return Get-ScheduledTask -TaskPath "$path" -TaskName "$name"
}

function Get-ScheduledTaskInfoByFullName($fullname) {
	$path = $fullname.Substring(0, $fullname.LastIndexOf('/') + 1).replace("/","\")
	$name = $fullname.Substring($fullname.LastIndexOf('/') + 1)

	return Get-ScheduledTaskInfo -TaskPath "$path" -TaskName "$name"
}

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
	"DiscoverTasks" {
		$data = @()
		foreach ($path in $paths) {
			$apptasks = Get-ScheduledTask -TaskPath $path | where { $_.state -ne "Disabled" }
			if ($NULL -eq $apptasks) { continue }

			foreach ($currentapptasks in $apptasks)	{
				# $apptasksok = $apptasksok1.replace('â','&acirc;').replace('à','&agrave;').replace('ç','&ccedil;').replace('é','&eacute;').replace('è','&egrave;').replace('ê','&ecirc;')
			
				$data += @{ "{#APPTASKS}" = $currentapptasks.TaskPath.replace("\","/") + $currentapptasks.TaskName }		
			}
		}

		$json = @{ "data" = $data }
		$json | ConvertTo-Json | Write-Host
	}

	"TaskLastResult" {
		$taskResult = Get-ScheduledTaskInfoByFullName $ID
		Write-Output ($taskResult.LastTaskResult)
	}

	"TaskLastRunTime" {
		$taskResult = Get-ScheduledTaskInfoByFullName $ID

		$taskResult1 = $taskResult.LastRunTime
		$date = get-date -date "01/01/1970"
		$taskResult2 = Convert-ToUnixDate($taskResult1)
		Write-Output ($taskResult2)
	}

	"TaskNextRunTime" {
		$taskResult = Get-ScheduledTaskInfoByFullName $ID

		$taskResult1 = $taskResult.NextRunTime
		$date = get-date -date "01/01/1970"
		$taskResult2 = Convert-ToUnixDate($taskResult1)
		Write-Output ($taskResult2)
	}

	"TaskState" {
		$pathtask = Get-ScheduledTaskByFullName $ID
		$pathtask1 = $pathtask.State
		Write-Output ($pathtask1)
	}
}
