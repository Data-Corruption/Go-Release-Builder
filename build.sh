#!/bin/bash
DIST_DIR=dist
SRC_DIR=src

# clean dist dir
if [ -d "$DIST_DIR" ]; then
    rm -rf $DIST_DIR
fi
mkdir $DIST_DIR

# Function that takes in an OS and architecture then builds an executable
build() {
  GOOS=$1 GOARCH=$2 go build -o $DIST_DIR/bin-$1-$2 ./$SRC_DIR/...
  # check if build was successful
  if [ $? -eq 0 ]; then
    echo "Successfully built for $1 $2."
  else
    echo "Build failed."
    exit 1
  fi
}

build linux amd64
build linux arm64
build linux riscv64