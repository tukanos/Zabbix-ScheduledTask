# Zabbix-ScheduledTask

### Step 1:
Copy the file DiscoverScheduledTasks.ps1 for folder of Zabbix Agent
Normally is in "C:\Zabbix\"

### Passo 2:
Change if necessary the $path variable in file DiscoverScheduledTasks.ps1, default is "\\"

### Passo 3:
In the configuration file of Zabbix Agent add the following parameters:

    EnableRemoteCommands=1

    UnsafeUserParameters=1
    
    Timeout=30

    UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\DiscoverScheduledTasks.ps1" "$1" "$2"

### Passo 4:
Restart the Zabbix Agent

### Passo 5: 
bind the Template Windows Task Scheduled in host.
     
# Telegram: @iakim
