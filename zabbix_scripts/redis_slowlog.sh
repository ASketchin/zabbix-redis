#!/bin/bash

redis_cli_uri=${1:-redis://127.0.0.1:6379}

ping_output=$(redis-cli -u "${redis_cli_uri}" PING 2>/dev/null)

if [[ "${ping_output}" != "PONG" ]]
then
        exit 1
fi

output=$(redis-cli -u "${redis_cli_uri}" --raw slowlog $2)

echo "${output}"
