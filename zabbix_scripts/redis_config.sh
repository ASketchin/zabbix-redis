#!/bin/bash

redis_cli_uri=${1:-redis://127.0.0.1:6379}

ping_output=$(redis-cli -u "${redis_cli_uri}" PING 2>/dev/null)

if [[ "${ping_output}" != "PONG" ]]
then
        exit 1
fi

config_output=$(redis-cli -u "${redis_cli_uri}" --raw config get '*' | sed 'N;s/\n/ /g')

output='{}'

while read redis_config
do
	redis_config_name=$(echo "${redis_config}" | cut -d' ' -f1)
	redis_config_content=$(echo "${redis_config}" | tr -d '\r\n' | cut -d' ' -f2-)

	output=$(echo "${output}" | jq -c '. += {"'"${redis_config_name}"'": "'"${redis_config_content}"'"}')
done <<< ${config_output}

echo "${output}"
