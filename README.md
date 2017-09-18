# Zabbix-ScheduledTask

### Passo 1:

    Copie o arquivo DiscoverScheduledTasks.ps1 para a pasta do Zabbix Agent
    Normalmente a pasta padrão é "C:\Zabbix\"

### Passo 2: 

    Altere se necessário a variável $path no arquivo DiscoverScheduledTasks.ps1, está setado o padrão "\"

### Passo 3:

    No arquivo de configuração do Zabbix Agent adicione os seguintes parâmetros:

    EnableRemoteCommands=1

    UnsafeUserParameters=1
    
    Timeout=30

    UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Zabbix\DiscoverScheduledTasks.ps1" "$1" "$2"

### Passo 4:

    Reinicie o serviço do Zabbix Agent

### Passo 5: 
     
     Vincule o template Template Windows Task Scheduled ao host.
     
### Passo 6:
        
        Este passo se faz necessário pois não consegui uma forma de corrigir a conversão das horas de acordo com o timezone do host, por exemplo, meu timezone é de valor -3, logo, quando a informação vai para o Zabbix, ele coloca como -6, provavelmente tem uma dupla conversão do timezone, uma feita pelo host e outra pelo Zabbix, então a maneira que consegui de se corrigir temporariamente* esse problema é alterando o timezone para universal, de valor 0 e alterando a hora manualmente.
        * Estou pesquisando para corrigir o problema
     
# Telegram: @iakim
