#!/usr/bin/env bash

set -e

BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

if [ -z "$1" ]; then
  error "No command specified."
  echo "Usage: ./task.sh {build|run|format|test|clean}"
  exit 1
fi

VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}' | tr -d "''\"")
info "Detected pubspec version: $VERSION"

COMMAND=$1
shift

case "$COMMAND" in
  build)
    info "Compiling native executable..."
    mkdir -p build
    dart compile exe -DDOPO_VERSION="$VERSION" bin/dopo.dart -o build/dopo

    if command -v strip &> /dev/null; then
        info "Stripping debug symbols to reduce size..."
        strip build/dopo
    fi

    success "Build complete! Executable is at ./build/dopo"
    ;;

  run)
    info "Running in JIT mode (dart run)..."
    dart run --define=DOPO_VERSION="$VERSION" bin/dopo.dart "$@"
    ;;

  format)
    info "Formatting Dart code..."
    dart format .
    success "Formatting complete."
    ;;

  test)
    info "Running unit tests..."
    dart test
    ;;

  clean)
    info "Cleaning build directory..."
    rm -rf build/
    success "Clean complete."
    ;;

  *)
    error "Unknown command: $COMMAND"
    echo "Usage: ./task.sh {build|run|format|test|clean}"
    exit 1
    ;;
esac