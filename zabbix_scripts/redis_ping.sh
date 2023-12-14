#!/bin/bash

redis_cli_uri=${1:-redis://127.0.0.1:6379}

ping_output=$(redis-cli -u "${redis_cli_uri}" PING 2>/dev/null)

if [[ "${ping_output}" != "PONG" ]]
then
        output=0
else
	output=1
fi

echo "${output}"
