#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to split videos into smaller segments.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Split Video"
MODULE_DESCRIPTION="Split a video into segments (approx. 30s by default)."

function module_run() {
  select_file_or_folder "Select a video file to split:"
  if [ $? -ne 0 ]; then return; fi

  if [ -f "$SELECTED_PATH" ]; then
    check_dependency "ffmpeg" "required"

    local basename=$(basename "$SELECTED_PATH")
    local name="${basename%.*}"
    local ext="${basename##*.}"
    local outdir="${name}_clips"
    
    mkdir -p "$outdir"
    
    local segment_time=30
    
    log_info "Splitting '$basename' into ${segment_time}s fragments..."
    
    ffmpeg -i "$SELECTED_PATH" -c copy -dn -map 0 -f segment -segment_time "$segment_time" -reset_timestamps 1 "$outdir/${name}_clip_%03d.${ext}" -v error
    
    if [ $? -eq 0 ]; then
       log_success "Clips saved in directory: $outdir"
    else
       log_error "Splitting failed."
    fi
  else
    log_error "Must be an individual file."
  fi
}
