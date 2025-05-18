# Run the VDS pipeline

#!/bin/bash

set -e  # Exit immediately on error

echo "Building project..."
dune build

# Get the target from the first argument
TARGET=$1

# Define what to run
run_main() {
  echo "Running Main (Receiver)..."
  dune exec bin/main.exe
}

run_sender() {
  echo "Running Sender..."
  dune exec bin/sender.exe
}

# Dispatch based on argument
case "$TARGET" in
  main)
    run_main
    ;;
  send)
    run_sender
    ;;
  all)
    run_main
    run_sender
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Usage: ./run.sh [main | send | all]"
    exit 1
    ;;
esac
