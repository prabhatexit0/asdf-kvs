(lang dune 3.12)

(name asdf-kvs)

(generate_opam_files true)

(source
 (github prabhatsachdeva/asdf-kvs))

(authors "Prabhat Sachdeva")

(maintainers "Prabhat Sachdeva")

(license MIT)

(package
 (name asdf-kvs)
 (synopsis "A key-value store with a custom language")
 (description
  "An in-memory key-value store with lexer, parser, and interpreter")
 (depends
  (ocaml
   (>= 5.0))
  (dune
   (>= 3.12))))
