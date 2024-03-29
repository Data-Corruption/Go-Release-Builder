#!/bin/bash

INSTALL_DIR="/usr/local/bin" # This dir should already be in the system PATH
BINARY_PATH="unknown"
# EXECUTABLE_NAME is dynamically set by the build script, if you wish to change it, do so there
EXECUTABLE_NAME="example_app"

declare -a binaries=("svlens-linux-amd64" "svlens-linux-arm64" "svlens-linux-riscv64")
declare -a foundBinaries

# Check each bin path to see if it exists in the current directory
for path in "${binaries[@]}"; do
  if [[ -e "$path" ]]; then
    foundBinaries+=("$path")
  fi
done

# Check how many valid bin paths were found
case ${#foundBinaries[@]} in
  0)  # No binaries were found
    echo "Error: No binaries were found in the current directory."
    exit 1
    ;;
  1)  # Exactly one binary was found
    BINARY_PATH=${foundBinaries[0]}
    ;;
  *)  # Multiple binaries found
    echo "Multiple binaries were found. Please choose one:"
    # List found binaries and prompt the user to choose
    select chosenPath in "${foundBinaries[@]}"; do
      if [[ " ${foundBinaries[*]} " =~ " ${chosenPath} " ]]; then
        echo "You selected: $chosenPath"
        BINARY_PATH=$chosenPath
        break
      else
        echo "Invalid selection. Please try again."
      fi
    done
    ;;
esac

# Check if the binary path is still unknown
if [[ "$BINARY_PATH" == "unknown" ]]; then
  echo "Error: Unable to determine which binary to use."
  exit 1
fi

# Make sure the install directory exists
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Error: Install directory does not exist. `$INSTALL_DIR`"
  exit 1
fi

# Copy the binary to the install directory (overwrite if it exists)
cp "$BINARY_PATH" "$INSTALL_DIR/$EXECUTABLE_NAME"
# Check if the copy was successful
if [ $? -ne 0 ]; then
  echo "Failed to copy the binary to the install directory. Please check your permissions."
  exit 1
fi

# Make the executable... executable
chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

# Allow the exe to use privileged ports
setcap 'cap_net_bind_service=+ep' "$INSTALL_DIR/$EXECUTABLE_NAME"

echo "Successfully installed $EXECUTABLE_NAME to $INSTALL_DIR/$EXECUTABLE_NAME"
echo "Please restart your terminal session to use $EXECUTABLE_NAME."