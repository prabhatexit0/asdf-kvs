#!/bin/bash

echo "=== Testing asdf-kvs TCP Server/Client ==="
echo ""

# Start server in background
echo "1. Starting server..."
dune exec ./src/server.exe &
SERVER_PID=$!
echo "   Server PID: $SERVER_PID"
sleep 2  # Give server time to start

echo ""
echo "2. Testing client connections..."
echo ""

# Test with client 1
echo "--- Client 1 ---"
(
  sleep 0.5
  echo 'create "users"'
  sleep 0.2
  echo 'use "users"'
  sleep 0.2
  echo 'set "alice" string "admin"'
  sleep 0.2
  echo 'set "bob" string "user"'
  sleep 0.2
  echo 'dump "users"'
  sleep 0.2
  echo 'exit'
) | dune exec ./src/client.exe &
CLIENT1_PID=$!

# Wait for client 1 to finish
wait $CLIENT1_PID

echo ""
echo "--- Client 2 (connecting to same server) ---"

# Test with client 2 - should see data from client 1
(
  sleep 0.5
  echo 'use "users"'
  sleep 0.2
  echo 'get "alice"'
  sleep 0.2
  echo 'set "charlie" i32 "30"'
  sleep 0.2
  echo 'dump "users"'
  sleep 0.2
  echo 'exit'
) | dune exec ./src/client.exe &
CLIENT2_PID=$!

# Wait for client 2 to finish
wait $CLIENT2_PID

echo ""
echo "3. Shutting down server..."
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

echo ""
echo "=== Test completed! ==="

