# Monitoring redis by zabbix-agent.

1. use template redis for zabbix-agent2;

2. add macros for zabbix host: {$REDIS.CONN.URI} = redis://127.0.0.1:6379

3. required jq (for debian systems: apt-get install jq)
