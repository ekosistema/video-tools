#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to merge multiple video files into one.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Merge Videos"
MODULE_DESCRIPTION="Merge all videos in a selected folder into one file."

function module_run() {
  select_file_or_folder "Select a folder containing videos to merge:"
  if [ $? -ne 0 ]; then return; fi

  if [ -d "$SELECTED_PATH" ]; then
    check_dependency "ffmpeg" "required"
    
    local list_file="list_merge_$(date +%s).txt"
    trap 'rm -f "$list_file"' EXIT
    
    local count=0
    shopt -s nullglob
    for f in "$SELECTED_PATH"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
      if [ -f "$f" ]; then
         echo "file '$f'" >> "$list_file"
         ((count++))
      fi
    done
    shopt -u nullglob

    if [ "$count" -eq 0 ]; then
       log_warning "No video files found in the selected directory."
       return
    fi

    log_info "Merging $count videos..."
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output="merged_video_${timestamp}.mp4"
    
    ffmpeg -f concat -safe 0 -i "$list_file" -c copy -dn "$output" -v error

    if [ $? -eq 0 ]; then
       log_success "Merged video created: $output"
    else
       log_error "Merge failed."
    fi

  else
    log_error "Must be a folder."
  fi
}
