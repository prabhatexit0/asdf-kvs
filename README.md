# asdf-kvs

An in-memory key-value store with a custom language, lexer, parser, and interpreter written in OCaml.

## Demo



https://github.com/user-attachments/assets/ba9753de-8417-4354-a77f-19f94a415e00



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

Run tests:

```bash
dune runtest
```

## Supported Operations

```
create "store_name";        # Create a new store
use "store_name";           # Select a store for operations
unselect "store_name";      # Unselect the current store
drop "store_name";          # Delete a store
set "key" "value";          # Set a key-value pair (requires selected store)
get "key";                  # Get a value by key (requires selected store)
dump "store_name";          # Display all keys in a store
save "filename";            # Save store to file (stub - not yet implemented)
load "filename";            # Load store from file (stub - not yet implemented)
```

## Features

1. **Multiple stores** - Create and manage multiple independent key-value stores
2. **Store selection** - Select a store to operate on using `use` command
3. **Nested expressions** - Commands can be nested, e.g., `set get "x" "y"`
4. **Multiple statements** - Separate commands with semicolons
5. **Interactive REPL** - Beautiful colored REPL with helpful prompts
6. **Demo mode** - Run a demo program to see the store in action

## Architecture

The project consists of several layers:

1. **Lexer** (`src/lexer.ml`) - Tokenizes input text into tokens
2. **Parser** (`src/parser.ml`) - Parses tokens into an abstract syntax tree (AST)
3. **Interpreter** (`src/interpreter.ml`) - Evaluates the AST and executes commands
4. **REPL** (`src/repl.ml`) - Interactive command-line interface
5. **Main** (`src/main.ml`) - Demo program

## Grammar Specification

**Expressions:**

- `create <expr>` - Create a store
- `use <expr>` - Select a store (internally mapped to SELECT)
- `unselect <expr>` - Unselect a store
- `drop <expr>` - Drop a store
- `set <expr> <expr>` - Set a key-value pair
- `get <expr>` - Get a value
- `dump <expr>` - Dump store contents
- `save <expr>` - Save to file (stub)
- `load <expr>` - Load from file (stub)

**Values:**

- String literals: `"text"`
- Names: unquoted identifiers

**Statements:**

- Multiple expressions separated by `;`

## Examples

### Basic Usage

```
create "users";
use "users";
set "alice" "admin";
set "bob" "user";
get "alice";
dump "users";
```

### Nested Expressions

```
create "store";
use "store";
set get "key1" "value2";
```

This sets the value of the key returned by `get "key1"` to `"value2"`.

### Multiple Stores

```
create "users";
create "products";
use "users";
set "alice" "admin";
use "products";
set "laptop" "999.99";
dump "users";
dump "products";
```

## Implementation Status

- ✅ In-memory storage with multiple stores
- ✅ Lexer and parser for custom language
- ✅ Interpreter for command execution
- ✅ Interactive REPL with colors and nice UI
- ✅ Nested expressions
- ⏳ File persistence (save/load commands are stubs)
- ⏳ TCP/network interface
- ⏳ Actual storage implementation (rn just using `HashMap`)
- ⏳ Concurrency control...
- ⏳ So many things...
