#!/usr/bin/env bash

if command -v btop &>/dev/null; then
	trap "pkill -P $$; exit 1" int
	while :; do
		clear
		btop
		{
			for i in $(seq 5 -1 1); do
				echo "restarting btop in ${i}..."
				sleep 1
			done
		} &
		wait
	done
fi
