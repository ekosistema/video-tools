#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Utility functions for path handling and selection.
# Author: CeleroLab
# License: MIT
# ==============================================================================

# Utils Library: Input and Path Handling

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# --- Path Handling ---

function fix_path_for_wsl() {
  local path="$1"
  if [ "$ENVIRONMENT" = "WSL" ]; then
    # Only transform if it looks like a Windows path (C:\...)
    if [[ "$path" =~ ^[a-zA-Z]:\\ || "$path" =~ ^[a-zA-Z]:/ ]]; then
      # Convert backslashes to forward slashes
      path=$(echo "$path" | sed 's|\\|/|g')
      # Extract drive letter
      local drive_letter=$(echo "$path" | cut -c1 | tr 'A-Z' 'a-z')
      # Construct /mnt/c/... path
      path="/mnt/$drive_letter${path:2}"
    fi
  fi
  echo "$path"
}

# --- Interaction ---

function select_file_or_folder() {
  local prompt_msg="${1:-Select a file or folder to process:}"
  
  echo -e "${BLUE}$prompt_msg${NC}"

  local path_input=""
  
  if [[ -t 0 && -t 1 ]]; then
    # Interactive mode
    echo "Use TAB to autocomplete the path. Type the path and press ENTER:"
    read -e -p "Path: " path_input
  else
    # Non-interactive
    log_warning "Not an interactive terminal. Autocomplete not available."
    read -rp "Path: " path_input
  fi

  # Fix WSL path if necessary
  path_input=$(fix_path_for_wsl "$path_input")
  
  # Remove quotes if user added them (common when copying paths)
  path_input="${path_input%\"}"
  path_input="${path_input#\"}"
  path_input="${path_input%\'}"
  path_input="${path_input#\'}"

  # Validate existence
  if [ ! -e "$path_input" ]; then
    log_error "The specified path does not exist: $path_input"
    return 1
  fi

  # Return the result via a global variable or echo (using global for simplicity in bash scripts often easier)
  SELECTED_PATH="$path_input"
  return 0
}
