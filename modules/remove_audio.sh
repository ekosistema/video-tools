#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to remove audio tracks from videos.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Remove Audio"
MODULE_DESCRIPTION="Remove audio track from a video file or all videos in a folder."

function module_run() {
  select_file_or_folder "Select a file or folder to remove audio from:"
  if [ $? -ne 0 ]; then return; fi

  check_dependency "ffmpeg" "required"

  if [ -f "$SELECTED_PATH" ]; then
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output="${SELECTED_PATH%.*}_no_audio_${timestamp}.${SELECTED_PATH##*.}"
    
    log_info "Removing audio from $SELECTED_PATH..."
    ffmpeg -i "$SELECTED_PATH" -an -c copy -dn "$output" -v error
    
    if [ $? -eq 0 ]; then
      log_success "Generated: $output"
    else
      log_error "Failed to remove audio."
    fi

  elif [ -d "$SELECTED_PATH" ]; then
    local outdir="no_audio"
    mkdir -p "$outdir"
    
    shopt -s nullglob
    for f in "$SELECTED_PATH"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
      local name=$(basename "$f")
      log_info "Processing $name..."
      local timestamp=$(date +%Y%m%d_%H%M%S)
      
      ffmpeg -i "$f" -an -c copy -dn "$outdir/${name%.*}_no_audio_${timestamp}.mp4" -v error
    done
    shopt -u nullglob
    
    log_success "Audio-free videos saved in ./$outdir"
  fi
}
