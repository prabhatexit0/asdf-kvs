# asdf kvs

An asdf key value store.

Supports the following operations:

```
create <store_name>;
select <store_name>;
unselect <store_name>;
drop <store_name>;
set "key" "value";
get "key";
save <store_name>;
load <file_name>;
dump <store_name>;

set (get "key")

```

# Features

1. Create stores.
2. Select stores.
2. Unselect stores.
2. Drop stores.
4. Set value for a key.
5. Get value for a key. 
6. Save store to disk.
7. Load store from disk.
8. Use it via CLI.
9. Use it via a TCP Connection.
10. Print all keys (CLI Only).

# Layers

1. Storage.
2. Query Execution.
4. Connection.
5. CLI.

# Grammer Spec

expressions: create, select, unselect, drop, set, get, save, load, dump

values: string literal


# Something Nested?
```
set (get "asdf") "value";

```