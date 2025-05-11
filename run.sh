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

run_fairlosstest() {
  echo "Running FairLossTest..."
  dune exec test/FairLossTest.exe
}

# Dispatch based on argument
case "$TARGET" in
  main)
    run_main
    ;;
  fairlosstest)
    run_fairlosstest
    ;;
  all)
    run_main
    run_fairlosstest
    ;;
  *)
    echo "❌ Unknown target: $TARGET"
    echo "Usage: ./run.sh [main | fairlosstest | all]"
    exit 1
    ;;
esac
