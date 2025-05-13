# Run the VDS pipeline

#!/bin/bash

set -e  # Exit immediately on error

echo "Building project..."
dune build

# Get the target from the first argument
TARGET=$1

# Define what to run
run_main() {
  echo "Running main..."
  dune exec bin/main.exe
}

run_perfectLinkTest() {
  echo "Running PerfectLink..."
  dune exec test/PerfectLinkTest.exe
}

# Dispatch based on argument
case "$TARGET" in
  main)
    run_main
    ;;
  test_perfectLink)
    run_perfectLinkTest
    ;;
  all)
    run_main
    run_perfectLinkTest
    ;;
  *)
    echo "❌ Unknown target: $TARGET"
    echo "Usage: ./run.sh [main | fairlosstest | all]"
    exit 1
    ;;
esac
