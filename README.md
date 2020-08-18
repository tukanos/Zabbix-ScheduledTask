# Zabbix-ScheduledTask

## Step 1:
#### Copy the file DiscoverScheduledTasks.ps1 for folder of Zabbix Agent
#### Normally is in "C:\Zabbix\"

## Step 2:
#### Change if necessary the $path variable in file DiscoverScheduledTasks.ps1, default is "\"

## Step 3:
#### In the configuration file of Zabbix Agent add the following parameters:

    EnableRemoteCommands=1

    UnsafeUserParameters=1
    
    Timeout=30

    UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\DiscoverScheduledTasks.ps1" "$1" "$2"

## Step 4:
#### Verify if your Windows Hosts is enable for execute scripts, if no, run in powershell:

    Set-ExecutionPolicy RemoteSigned
    
## Step 5:
#### Restart the Zabbix Agent

## Step 6: 
#### Bind the Template Windows Task Scheduled in host.
