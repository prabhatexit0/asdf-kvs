# asdf-kvs

A typed in-memory key-value store with a custom language, lexer, parser, and interpreter written in OCaml. Features a custom linked-list storage engine with support for multiple data types.

## Demo

https://github.com/user-attachments/assets/2071cf01-d062-4313-995e-be1448ebbaee

## Quick Start

Build the project:

```bash
dune build
```

Run the interactive REPL:

```bash
dune exec repl
```

Run the demo program:

```bash
dune exec main
```

Start the TCP server:

```bash
./start_server.sh
# or directly
dune exec server
```

Connect a TCP client:

```bash
./start_client.sh
# or directly
dune exec client
```

Run tests:

```bash
dune runtest
```

Test TCP server/client:

```bash
./test_tcp.sh
```

## Supported Operations

```
create "store_name";              # Create a new store
use "store_name";                 # Select a store for operations
unselect "store_name";            # Unselect the current store
drop "store_name";                # Delete a store
set "key" <type> "value";         # Set a typed key-value pair (requires selected store)
get "key";                        # Get a value by key (requires selected store)
dump "store_name";                # Display all keys in a store
save "filename";                  # Save store to file (stub - not yet implemented)
load "filename";                  # Load store from file (stub - not yet implemented)
```

## Supported Data Types

- `i32` - 32-bit signed integers
- `i64` - 64-bit signed integers
- `f32` - 32-bit floating point
- `f64` - 64-bit floating point
- `string` - text values

## Features

1. **Type System** - Strongly typed values with support for integers, floats, and strings
2. **Custom Storage Engine** - Linked-list based storage implementation
3. **TCP Server/Client** - Multi-client TCP server with networked access
4. **Multiple stores** - Create and manage multiple independent key-value stores
5. **Store selection** - Select a store to operate on using `use` command
6. **Nested expressions** - Commands can be nested, e.g., `set get "x" string "y"`
7. **Multiple statements** - Separate commands with semicolons
8. **Interactive REPL** - Beautiful colored REPL with helpful prompts

## Architecture

The project consists of several layers:

1. **Lexer** (`src/lexer.ml`) - Tokenizes input text into tokens
2. **Parser** (`src/parser.ml`) - Parses tokens into an abstract syntax tree (AST)
3. **Interpreter** (`src/interpreter.ml`) - Evaluates the AST and executes commands
4. **Storage** (`src/storage.ml`) - Custom linked-list storage engine with typed data support
5. **Server** (`src/server.ml`) - Multi-threaded TCP server for networked access
6. **Client** (`src/client.ml`) - TCP client for connecting to remote server
7. **REPL** (`src/repl.ml`) - Interactive command-line interface
8. **Main** (`src/main.ml`) - Demo program

## Grammar Specification

**Expressions:**

- `create <expr>` - Create a store
- `use <expr>` - Select a store (internally mapped to SELECT)
- `unselect <expr>` - Unselect a store
- `drop <expr>` - Drop a store
- `set <expr> <type> <expr>` - Set a typed key-value pair
- `get <expr>` - Get a value
- `dump <expr>` - Dump store contents
- `save <expr>` - Save to file (stub)
- `load <expr>` - Load from file (stub)

**Types:**

- `i32` - 32-bit signed integer
- `i64` - 64-bit signed integer
- `f32` - 32-bit floating point
- `f64` - 64-bit floating point
- `string` - text value

**Values:**

- String literals: `"text"`
- Names: unquoted identifiers

**Statements:**

- Multiple expressions separated by `;`

## TCP Server/Client

asdf-kvs includes a multi-threaded TCP server that allows multiple clients to connect and share the same key-value store.

### Starting the Server

```bash
./start_server.sh
# Server starts on 127.0.0.1:9090
```

The server:

- Accepts multiple concurrent client connections
- Maintains shared state across all clients
- Uses threads to handle each client independently
- Supports all commands available in the REPL

### Connecting Clients

```bash
# Terminal 1
./start_client.sh

# Terminal 2
./start_client.sh

# Terminal 3 (custom host/port)
./start_client.sh 127.0.0.1 9090
```

### Multi-Client Example

```
# Client 1
create "shared_db"
use "shared_db"
set "key1" string "value1"

# Client 2 (connects to same server)
use "shared_db"
get "key1"          # Returns "value1"
set "key2" i32 "42"

# Client 1
dump "shared_db"    # Shows both key1 and key2
```

## Examples

### Basic Usage

```
create "users";
use "users";
set "alice" string "admin";
set "bob" string "user";
get "alice";
dump "users";
```

### Using Different Types

```
create "mydb";
use "mydb";
set "age" i32 "30";
set "timestamp" i64 "1234567890";
set "pi" f32 "3.14159";
set "e" f64 "2.71828";
set "name" string "Alice";
dump "mydb";
```

### Nested Expressions

```
create "store";
use "store";
set "key1" string "value1";
set get "key1" string "value2";
```

This sets the value of the key returned by `get "key1"` to `"value2"`.

### Multiple Stores

```
create "users";
create "products";
use "users";
set "alice" string "admin";
use "products";
set "laptop" f64 "999.99";
dump "users";
dump "products";
```

## Storage Engine

The storage engine uses a custom linked-list implementation with the following characteristics:

- **Type-safe storage**: Each value is stored with its specific type (i32, i64, f32, f64, or string)
- **O(n) operations**: Linear time complexity for get, set, and delete operations
- **Modular design**: Easy to swap with other implementations (hash table, B-tree, etc.)
- **Independent instances**: Each store is a separate linked list instance

### Storage Module API

```ocaml
val create : unit -> t
val set : t -> string -> data -> unit
val get : t -> string -> data option
val delete : t -> string -> bool
val exists : t -> string -> bool
val size : t -> int
val clear : t -> unit
val dump : t -> unit
```

## Implementation Status

- ✅ In-memory storage with multiple stores
- ✅ Custom linked-list storage engine
- ✅ Type system with 5 data types (i32, i64, f32, f64, string)
- ✅ Lexer and parser for custom language
- ✅ Interpreter for command execution
- ✅ Interactive REPL with colors and nice UI
- ✅ Nested expressions
- ✅ Multi-threaded TCP server
- ✅ TCP client for remote connections
- ✅ Shared state across multiple clients
- ⏳ File persistence (save/load commands are stubs)
- ⏳ Write Ahead Log
- ⏳ Concurrency control (currently no locking)
- ⏳ Benchmarking
- ⏳ Authentication and security
- ⏳ B-tree or other advanced storage structures
- ⏳ Indexing and query optimization
- ⏳ So many things...
