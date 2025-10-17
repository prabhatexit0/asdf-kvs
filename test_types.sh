#!/bin/bash

echo "Testing all data types in asdf-kvs..."

dune exec ./src/repl.exe << 'EOF'
create "mydb"
use "mydb"
set "age" i32 "30"
set "timestamp" i64 "1234567890"
set "pi" f32 "3.14159"
set "e" f64 "2.71828"
set "name" string "Alice"
dump "mydb"
get "age"
get "pi"
get "name"
exit
EOF

echo -e "\nType test completed!"

