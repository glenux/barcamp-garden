#!/bin/sh

set -e

usage() {
    echo "Usage: $(basename "$0") NAME HOST PORT"
}

NAME=${1:-}
HOST=${2:-}
PORT=${3:-}

if [ -z "$NAME" ]; then
	usage
	echo "ERROR: missing NAME"
	exit 1
fi

if [ -z "$HOST" ]; then
	usage
	echo "ERROR: missing HOST"
	exit 1
fi

if [ -z "$PORT" ]; then
	usage
	echo "ERROR: missing PORT"
	exit 1
fi

if ! hash nc > /dev/null 2>&1 ; then
	echo "WARNING: missing nc binary"
	# TODO: move to Dockerfile once tested & functional
	apt-get update 
	apt-get -y install netcat-traditional
fi

echo "$(basename "$0") - block until specified TCP port becomes available"

echo "Waiting for $NAME on $HOST:$PORT to become available..."
while ! nc -z "$HOST" "$PORT" 2>/dev/null ; do
    elapsed=$(( elapsed+1 ))
    if [ "$elapsed" -gt 120 ]; then
        echo "ERROR: connection timed out for $NAME on $HOST:$PORT!"
        exit 1
    fi
    sleep 1
done

sleep 5
echo "Service is ready for $NAME!"
