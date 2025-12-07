#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to extract audio tracks to WAV format.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Extract Audio"
MODULE_DESCRIPTION="Extract audio (WAV) from a video file or all videos in a folder."

function module_run() {
  select_file_or_folder "Select a file or folder to extract audio from:"
  if [ $? -ne 0 ]; then return; fi

  check_dependency "ffmpeg" "required"

  if [ -f "$SELECTED_PATH" ]; then
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output="${SELECTED_PATH%.*}_${timestamp}.wav"
    
    log_info "Extracting audio..."
    ffmpeg -i "$SELECTED_PATH" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$output" -v error
    
    if [ $? -eq 0 ]; then
      log_success "Extracted audio: $output"
    else
      log_error "Extraction failed."
    fi

  elif [ -d "$SELECTED_PATH" ]; then
    local outdir="audios_wav"
    mkdir -p "$outdir"
    
    shopt -s nullglob
    for f in "$SELECTED_PATH"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
      if [ -f "$f" ]; then
         local name=$(basename "$f")
         log_info "Processing $name..."
         local timestamp=$(date +%Y%m%d_%H%M%S)
         ffmpeg -i "$f" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$outdir/${name%.*}_${timestamp}.wav" -v error
      fi
    done
    shopt -u nullglob
    
    log_success "Audios extracted in ./$outdir"
  fi
}
