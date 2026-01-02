#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Utility functions for path handling and selection.
# Author: CeleroLab
# License: MIT
# ==============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

function fix_path_for_wsl() {
  local path="$1"
  if [ "$ENVIRONMENT" = "WSL" ]; then
    if [[ "$path" =~ ^[a-zA-Z]:\\ || "$path" =~ ^[a-zA-Z]:/ ]]; then
      path=$(echo "$path" | sed 's|\\|/|g')
      local drive_letter=$(echo "$path" | cut -c1 | tr 'A-Z' 'a-z')
      path="/mnt/$drive_letter${path:2}"
    fi
  fi
  echo "$path"
}

function select_file_or_folder() {
  local prompt_msg="${1:-Select a file or folder to process:}"
  
  echo -e "${BLUE}$prompt_msg${NC}"

  local path_input=""
  
  if [[ -t 0 && -t 1 ]]; then
    echo "Use TAB to autocomplete the path. Type the path and press ENTER (default: current directory):"
    read -e -p "Path: " path_input
  else
    log_warning "Not an interactive terminal. Autocomplete not available."
    read -rp "Path: " path_input
  fi

  if [ -z "$path_input" ]; then
    path_input="."
  fi

  path_input=$(fix_path_for_wsl "$path_input")
  
  path_input="${path_input%\"}"
  path_input="${path_input#\"}"
  path_input="${path_input%\'}"
  path_input="${path_input#\'}"

  if [ ! -e "$path_input" ]; then
    log_error "The specified path does not exist: $path_input"
    return 1
  fi

  SELECTED_PATH="$path_input"
  return 0
}
