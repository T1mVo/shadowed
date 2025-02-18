#!/usr/bin/env just --justfile

# List all recipes
@default:
    just --list

# Run tests
@test:
    tt run

# Clean out and diff directories
@clean:
    find . -type d -name "diff" -exec rm -r {} +
    find . -type d -name "out" -exec rm -r {} +
