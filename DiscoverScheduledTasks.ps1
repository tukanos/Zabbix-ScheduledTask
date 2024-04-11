# Script: DiscoverSchelduledTasks
# Author: Romain Si
# Revision: Isaac de Moraes
# Revision: Patrik Svestka
#
# This script is intended for use with Zabbix > 3.x
# Note: This script uses front slash in the path instead of Task Schedule's backslash path (XML) as the backslash are considered unsafe character in Zabbix
#
# Add to Zabbix Agent
# UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\DiscoverScheduledTasks.ps1" "$1" "$2" "$3"
#
# Note: should there be a need to use wild char star (*) in the task path - it is considered to be an unsafe character in Zabbix- it needs to be enabled
#       in zabbix_agent2.conf using UnsafeUserParameters=1
#
# Examples when running directly from PowerShell:
#
# 1) List all tasks at the path /Accounting/ including the subfolders and list the /backup/ only
#   `.\DiscoverSchelduledTasks.ps1 '/Accounting/*,/Backup/' 'DiscoverTasks'`
# 2) Show the last task result for the AccoungDailyBackup task
#    `'.\DiscoverSchelduledTasks.ps1 '/Accounting/' 'TaskLastResult' 'AccountingDailyBackup'`

$ErrorActionPreference = "Stop"

function Convert-ToUnixDate($taskTime) {
    $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970')
    if ($taskTime -eq $Null) { $taskTime = $epoch }
    return (New-TimeSpan -Start $epoch -End $taskTime).TotalSeconds
}

# Note: Not using Get-ScheduledTaskInfo directly as it can not deal correctly with accented or wild characters
function Get-ScheduledTaskInfoByFullName($path, $name) {
    return (Get-ScheduledTask -TaskPath "$path" -TaskName "$name" | Get-ScheduledTaskInfo)
}

function Get-ScheduledTaskByFullName($path, $name) {
    return Get-ScheduledTask -TaskPath "$path" -TaskName "$name"
}

# Zabbix template is using the forward slash (/) instead of the Task schedule XML's backslash (\) - changing to the proper XML's style
$taskPath = ([string]$args[0]).replace('/','\')
$taskAction = [string]$args[1]
# getting only portion task name from the task path and name
$taskName = ([string]$args[2]).Substring(([string]$args[2]).LastIndexOf('/') + 1)

switch ($taskAction) {
    'DiscoverTasks' {
        $data = @()
        $taskPath = $taskPath -split ',' | % { $_.Trim() }
        foreach ($path in $taskPath) {
            $appTasks = Get-ScheduledTask -TaskPath $path | where { $_.state -ne "Disabled" }
            if ($appTasks -eq $null) { continue }
            foreach ($currentAppTasks in $appTasks) {
                $data += @{ '{#APPTASKS}' = $currentAppTasks.TaskPath.replace('\','/') + $currentAppTasks.TaskName }
            }
        }
        $json = @{ 'data' = $data }
        $json | ConvertTo-Json | Write-Host
    }

    'TaskLastResult' {
        $lastTaskResult = (Get-ScheduledTaskInfoByFullName $taskPath $taskName).LastTaskResult
        Write-Output $lastTaskResult
    }

    'TaskLastRunTime' {
        $lastRunTime = (Get-ScheduledTaskInfoByFullName $taskPath $taskName).LastRunTime
        $unixTime = Convert-ToUnixDate($lastRunTime)
        Write-Output $unixTime
    }

    'TaskNextRunTime' {
        $nextRunTime = (Get-ScheduledTaskInfoByFullName $taskPath $taskName).NextRunTime
        $unixTime = Convert-ToUnixDate($nextRunTime)
        Write-Output $unixTime
    }

    'TaskState' {
        $taskState = (Get-ScheduledTaskByFullName $taskPath $taskName).State
        Write-Output $taskState
    }

    Default {
        throw "Error trying getting  task action: $taskAction"
    }
}
