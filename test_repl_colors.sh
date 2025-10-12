#!/bin/bash

# Test script for the colorful REPL

echo "Testing beautiful REPL with syntax highlighting and emojis..."
echo ""

cat <<EOF | dune exec ./src/repl.exe
create "users"
select "users"
set "alice" "admin"
get "alice"
dump "users"
get "nonexistent"
exit
EOF

echo ""
echo "REPL test completed!"

