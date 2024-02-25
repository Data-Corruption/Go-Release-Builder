#!/bin/bash

# Variables ===================================================================

APP_NAME="example_app" # Replace this with your app name!

MOD_NAME=""
DEBUG=false

# Path variables
PROJECT_ROOT=""
BIN_DIR=""
APP_BIN_DIR=""

# Functions ===================================================================

# Function to print debug information
debug_print() {
  if [ "$DEBUG" = true ]; then
    echo "Debug: $1"
  fi
}

# Function that sets up error handling and verifies dependencies before running
setup() {
  # Exit on any error, fail on any errors in pipeline commands
  set -e
  set -o pipefail

  # Error if the version is not set
  if [ -z "$VERSION" ]; then
    echo "Error: VERSION environment variable is not set."
    echo "To set it manually, run \`export VERSION=\"vX.X.X\"\` before running this script."
    exit 1
  fi

  # List of required commands
  required_commands=("go" "sed" "awk")

  # Loop through the required commands and check if they are installed
  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "$cmd is not installed. Please install $cmd and try again."
      exit 1
    fi
  done
}

# Function that runs before building begins
preBuild() {
  # Set path variables
  PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  BIN_DIR="$PROJECT_ROOT/bin"
  APP_BIN_DIR="$BIN_DIR/$APP_NAME"

  debug_print "PROJECT_ROOT set to $PROJECT_ROOT"
  debug_print "BIN_DIR set to $BIN_DIR"
  debug_print "APP_BIN_DIR set to $APP_BIN_DIR"

  # Get the module name from go.mod
  MOD_NAME=$(awk -F' ' '/module/ {print $2}' "$PROJECT_ROOT/go.mod")

  debug_print "MOD_NAME set to $MOD_NAME"

  # Clean the app's old binaries
  if [ -d "$APP_BIN_DIR" ]; then
    rm -rf "$APP_BIN_DIR"
  fi
  mkdir -p "$APP_BIN_DIR"

  # Update the install scripts with the app name
  sed -i "s/^EXECUTABLE_NAME=.*$/EXECUTABLE_NAME=\"$APP_NAME\"/g" "$PROJECT_ROOT/scripts/install-linux.bash"
  sed -i "s/^\$appName = .*$/\$appName = \"$APP_NAME\"/g" "$PROJECT_ROOT/scripts/install-win.ps1"

  # Place any other pre-build steps here
  # For example:
  # - linting
  # - formatting
  # - tailwind css
  # - tests
  # - etc.

}

# Function that takes in the GOOS, GOARCH, and binary name to build
# VERSION is an environment variable that is set by the workflow before this script is run.
# To set it manually, run `export VERSION="vX.X.X"` before running this script.
build() {
  build_command="GOOS=$1 GOARCH=$2 go build -ldflags=\"-X '$MOD_NAME/internal/app/commands.version=$VERSION'\" -o \"$APP_BIN_DIR/$APP_NAME-$1-$2\" \"$PROJECT_ROOT/cmd/$APP_NAME\""
  debug_print "Executing build command: $build_command"
  eval "$build_command"
  echo "Successfully built $APP_NAME for $1 $2."
}

# Main script =================================================================

# Run the setup function
setup

# Run pre-build steps
preBuild

# Build the binaries
# If you edit the targets, you'll need to edit the .github/workflows/build.yml file as well.
# Particularly the "Zip Release Files" step and the "Create Release Draft"(files part) step.
build linux amd64
build linux arm64
build linux riscv64
