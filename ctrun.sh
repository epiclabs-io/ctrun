#!/bin/bash

## ctrun.sh -- executes a container in a specific Docker network
## assigning a fixed IP address from DNS and mapping volumes to
## a specific local directory

## By Javier Peletier jm@epiclabs.io . Copyright (c) Epic Labs 
# https://github.com/epiclabs-io/ctrun
## Licensed under GNU

#container network
CTNET=ctnet

#DNS server to use:
DNS_SERVER_CTNET=192.168.5.1

#LOCAL DATA DIRECTORY
DATA_DIR=/data


function resolve() {

    local host="$1"
    dig +short $host @$DNS_SERVER_CTNET  | grep -v "\.$" | head -n 1

}

function ctrun() {

	local host="$1"
	local data="$DATA_DIR/$host"
	local ip="$(resolve $host)"
	local cmd="-d --net=ctnet --ip=\"$ip\" --name=\"$host\" --hostname=\"$host\" --dns=\"$DNS_SERVER_CTNET\""

	if [[ "$host" == "" ]]; then
		echo "Usage: "
		echo "ctrun hostname [-v volume_path1[:options]] [docker run switches/options] image_name [command]"
		exit 1
	fi
	
	if [[ "$ip" == "" ]]; then
		echo "Could not resolve '$host' to an IP address"
		exit 1
	fi
	
	shift

	while (( "$#" )); do
		if [ "$1" == "-v" ]; then
			VOLPATH="$2"
			PARMS=""
			
			if [[ "$VOLPATH" == "" ]]; then
				echo "Missing volume path"
				exit 1
			fi
			
			if [[ "${VOLPATH:0:1}" != "/" ]]; then
				VOLPATH="/$VOLPATH"
			fi
			
			if [[ "$VOLPATH" =~ .*:.* ]]; then
				V="${VOLPATH%:*}"
				PARMS="${VOLPATH##*:}"
				VOLPATH="$V"
			fi
			
			LOCALPATH="$data$VOLPATH"
			cmd="$cmd -v $LOCALPATH:$VOLPATH"
			mkdir -p "$LOCALPATH"
			
			if [[ "$PARMS" != "" ]]; then
				cmd="$cmd:$PARMS"
			fi
			
			shift
		else
			cmd="$cmd $1"
		fi
		
		shift
	done

	#echo docker run $cmd
	docker run $cmd
}


ctrun $@
