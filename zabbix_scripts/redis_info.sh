#!/bin/bash

redis_cli_uri=${1:-redis://127.0.0.1:6379}

ping_output=$(redis-cli -u "${redis_cli_uri}" PING 2>/dev/null)

if [[ "${ping_output}" != "PONG" ]]
then
        exit 1
fi

info_output=$(redis-cli -u "${redis_cli_uri}" info)

output='{}'

for data_block_name in $(echo "${info_output}"| grep -E '^# ' | sed 's/^# //')
do
	output_block_name=$(echo "${data_block_name}" | sed 's/\r//')
	data_block_content=$(echo "${info_output}" | awk '/^# '"${data_block_name}"'/,/^\r$/' | sed 's/^# '"${data_block_name}"'$//' | grep -vE '^\s*$')

	output_block_content='{}'

	if [[ "${data_block_content}" != '' ]]
	then
		if [[ "${output_block_name}" == "Keyspace" ]]
		then
			while read redis_db_info
			do
				redis_db_info_name=$(echo "${redis_db_info}" | cut -d':' -f1)
				redis_db_info_content=$(echo "${redis_db_info}" | tr -d '\r\n' |  cut -d':' -f2)

				unset output_block_content_sub

				output_block_content_sub=$(echo "${redis_db_info_content}" | tr -d '\n' | jq -Rs 'split(",") | map(select(length > 0)) | map(split("=") | {(.[0]): .[1]}) | add')
				output_block_content=$(echo "${output_block_content}" | jq -c '. += {"'"${redis_db_info_name}"'": '"${output_block_content_sub}"'}')
			done <<< ${data_block_content}
		else
			output_block_content=$(echo "${data_block_content}" | jq -Rsc 'split("\r\n") | map(select(length > 0)) | map(split(":") | {(.[0]): .[1]}) | add')
		fi
	fi

	output=$(echo "${output}" | jq -c '. += {"'"${output_block_name}"'": '"${output_block_content}"'}')
done

echo "${output}"
