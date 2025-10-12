#!/bin/bash

# Test script for the REPL with predefined commands

echo "Testing REPL with predefined commands..."
echo ""

# Create a sequence of commands
cat <<EOF | dune exec ./src/repl.exe
create "users"
select "users"
set "alice" "admin"
set "bob" "user"
get "alice"
get "bob"
dump "users"
create "products"
select "products"
set "item1" "laptop"
set "item2" "phone"
dump "products"
exit
EOF

echo ""
echo "REPL test completed!"

