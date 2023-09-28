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

$Paths = $args[0]
$Item = [string]$args[1]
$Id = [string]$args[2]

switch ($Item) {
	"DiscoverTasks" {
		$data = @()
		foreach ($path in $Paths) {
			$apptasks = Get-ScheduledTask -TaskPath $path | where { $_.state -ne "Disabled" }
			if ($NULL -eq $apptasks) { continue }

			foreach ($currentapptasks in $apptasks)	{
				$data += @{ "{#APPTASKS}" = $currentapptasks.TaskPath.replace("\","/") + $currentapptasks.TaskName }
			}
		}

		$json = @{ "data" = $data }
		$json | ConvertTo-Json | Write-Host
	}

	"TaskLastResult" {
		$taskResult = Get-ScheduledTaskInfoByFullName $Id
		Write-Output ($taskResult.LastTaskResult)
	}

	"TaskLastRunTime" {
		$taskResult = Get-ScheduledTaskInfoByFullName $Id

		$taskResult1 = $taskResult.LastRunTime
		$date = get-date -date "01/01/1970"
		$taskResult2 = Convert-ToUnixDate($taskResult1)
		Write-Output ($taskResult2)
	}

	"TaskNextRunTime" {
		$taskResult = Get-ScheduledTaskInfoByFullName $Id

		$taskResult1 = $taskResult.NextRunTime
		$date = get-date -date "01/01/1970"
		$taskResult2 = Convert-ToUnixDate($taskResult1)
		Write-Output ($taskResult2)
	}

	"TaskState" {
		$pathtask = Get-ScheduledTaskByFullName $Id
		$pathtask1 = $pathtask.State
		Write-Output ($pathtask1)
	}
}
