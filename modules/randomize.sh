#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to randomize video clips for glitch effects.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Randomize Video"
MODULE_DESCRIPTION="Split a video into 1s clips, shuffle them, and merge back."

function module_run() {
  select_file_or_folder "Select a video file to randomize:"
  if [ $? -ne 0 ]; then return; fi

  if [ -f "$SELECTED_PATH" ]; then
    local original_video="$SELECTED_PATH"
    
    # Check dependencies
    check_dependency "ffmpeg" "required"
    
    local shuffler="shuf"
    if [ "$ENVIRONMENT" = "MACOS" ]; then
      shuffler="gshuf"
      if ! check_dependency "gshuf"; then
        log_error "'gshuf' is required on macOS. Install it with: brew install coreutils"
        return
      fi
    # On WSL/Linux shuf is usually present
    elif ! command -v shuf &> /dev/null; then
       log_error "'shuf' command not found."
       return
    fi

    # Create temp directory
    local temp_dir="clips_$(date +%s)"
    mkdir -p "$temp_dir"
    local list_file="list_$(date +%s).txt"

    # Set trap to clean up on exit or interrupt
    trap 'rm -rf "$temp_dir" "$list_file"' EXIT

    log_info "Splitting video into 1-second fragments..."
    ffmpeg -i "$original_video" -an -c copy -dn -map 0 -segment_time 1 -f segment -reset_timestamps 1 "$temp_dir/out%03d.mp4" -v error

    log_info "Shuffling clips randomly..."
    find "$temp_dir" -name '*.mp4' | sort | $shuffler | while read file; do
      echo "file '$file'" >> "$list_file"
    done

    local ext="${original_video##*.}"
    local basename="${original_video%.*}"
    local output_video="${basename}_randomized.${ext}"

    log_info "Concatenating shuffled clips into final video..."
    ffmpeg -f concat -safe 0 -i "$list_file" -c copy "$output_video" -v error

    if [ $? -eq 0 ]; then
      log_success "Done! Randomized video saved as '$output_video'"
    else
      log_error "Error occurred while generating the final video."
    fi

    # Trap will handle cleanup
  else
    log_error "You must select a single video file."
  fi
}
