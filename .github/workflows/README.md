# GitHub Actions CI

This repository uses GitHub Actions for continuous integration.

## Workflow: CI

**File:** `ci.yml`

**Triggers:**

- Push to `main` or `master` branches
- Pull requests to `main` or `master` branches

**Jobs:**

- **build-and-test**: Runs on Ubuntu and macOS with OCaml 5.1.x and 5.2.x

**Steps:**

1. Checkout code
2. Set up OCaml environment
3. Install dependencies
4. Build the project
5. Run all tests (lexer, parser, interpreter)
6. Check code formatting (optional)

## Testing Locally

Before pushing, you can run the same checks locally:

```bash
# Build
dune build

# Run tests
dune test

# Check formatting (if you have ocamlformat installed)
dune build @fmt
```

## Badge

Add this to your README.md to show build status:

```markdown
![CI](https://github.com/prabhatsachdeva/asdf-kvs/workflows/CI/badge.svg)
```
