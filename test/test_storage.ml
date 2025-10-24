open Asdf_kvs.Storage

let test_multiple_stores () =
  print_endline "=== Testing Multiple Independent Stores ===\n";

  (* Create three independent storage instances *)
  let store1 = create () in
  let store2 = create () in
  let store3 = create () in

  (* Add data to store1 *)
  print_endline "Adding data to store1:";
  set store1 "name" (String "Alice");
  set store1 "age" (Int32 30l);
  set store1 "score" (Float64 95.5);

  (* Add data to store2 *)
  print_endline "Adding data to store2:";
  set store2 "name" (String "Bob");
  set store2 "age" (Int32 25l);

  (* Add data to store3 *)
  print_endline "Adding data to store3:";
  set store3 "price" (Float32 19.99);
  set store3 "quantity" (Int64 100L);

  (* Dump all stores to show they're independent *)
  print_endline "\nStore 1:";
  dump store1;

  print_endline "\nStore 2:";
  dump store2;

  print_endline "\nStore 3:";
  dump store3;

  (* Test that stores are truly independent *)
  print_endline "\nVerifying independence:";
  Printf.printf "Store1 size: %d\n" (size store1);
  Printf.printf "Store2 size: %d\n" (size store2);
  Printf.printf "Store3 size: %d\n" (size store3);

  (* Clear store2 and verify others are unaffected *)
  print_endline "\nClearing store2...";
  clear store2;
  Printf.printf "Store1 size: %d (should be 3)\n" (size store1);
  Printf.printf "Store2 size: %d (should be 0)\n" (size store2);
  Printf.printf "Store3 size: %d (should be 2)\n" (size store3)

let test_basic_operations () =
  print_endline "\n=== Testing Basic Operations ===\n";

  let store = create () in

  (* Test set and get *)
  print_endline "Testing set and get:";
  set store "user" (String "John");
  (match get store "user" with
  | Some data -> Printf.printf "Got: %s\n" (data_to_string data)
  | None -> print_endline "Key not found");

  (* Test exists *)
  Printf.printf "Key 'user' exists: %b\n" (exists store "user");
  Printf.printf "Key 'missing' exists: %b\n" (exists store "missing");

  (* Test update *)
  print_endline "\nUpdating 'user':";
  set store "user" (String "Jane");
  (match get store "user" with
  | Some data -> Printf.printf "Got: %s\n" (data_to_string data)
  | None -> print_endline "Key not found");

  (* Test delete *)
  print_endline "\nDeleting 'user':";
  Printf.printf "Delete result: %b\n" (delete store "user");
  Printf.printf "Key 'user' exists: %b\n" (exists store "user");
  Printf.printf "Store size: %d\n" (size store)

let test_data_types () =
  print_endline "\n=== Testing Different Data Types ===\n";

  let store = create () in

  set store "i32_val" (Int32 2147483647l);
  set store "i64_val" (Int64 9223372036854775807L);
  set store "f32_val" (Float32 3.14159);
  set store "f64_val" (Float64 2.718281828459045);
  set store "str_val" (String "Hello, World!");

  dump store

let () =
  test_multiple_stores ();
  test_basic_operations ();
  test_data_types ();
  print_endline "\n=== All tests completed ==="
