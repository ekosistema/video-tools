#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Core library functions for logging and environment detection.
# Author: CeleroLab
# License: MIT
# ==============================================================================



# --- Constants & Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Environment Detection ---
function detect_environment() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ENVIRONMENT="MACOS"
  elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    ENVIRONMENT="WSL"
  else
    ENVIRONMENT="UNIX"
  fi
  export ENVIRONMENT
}

# --- Logging Functions ---
function log_info() {
  echo -e "${BLUE}[INFO] $1${NC}"
}

function log_success() {
  echo -e "${GREEN}[OK] $1${NC}"
}

function log_warning() {
  echo -e "${YELLOW}[WARN] $1${NC}"
}

function log_error() {
  echo -e "${RED}[ERROR] $1${NC}" >&2
}

function die() {
  log_error "$1"
  exit 1
}

# --- Dependency Check ---
function check_dependency() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
     if [ "$2" == "required" ]; then
        die "Error: Required command '$cmd' is not installed."
     else
        log_warning "Command '$cmd' not found. Some features may not work."
        return 1
     fi
  fi
  return 0
}
