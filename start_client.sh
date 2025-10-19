#!/bin/bash

HOST=${1:-127.0.0.1}
PORT=${2:-9090}

echo "Connecting to asdf-kvs server at $HOST:$PORT..."
echo ""
dune exec ./src/client.exe -- $HOST $PORT

