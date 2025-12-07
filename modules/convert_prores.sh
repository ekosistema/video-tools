#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to convert ProRes files to MP4.
# Author: CeleroLab
# License: MIT
# ==============================================================================

MODULE_NAME="Convert ProRes to MP4"
MODULE_DESCRIPTION="Convert Apple ProRes (.mov) to high-quality H.264 .mp4."

function module_run() {
  select_file_or_folder "Select a .mov (ProRes) file:"
  if [ $? -ne 0 ]; then return; fi

  if [ -f "$SELECTED_PATH" ]; then
    local ext="${SELECTED_PATH##*.}"
    if [[ "${ext,,}" != "mov" ]]; then
      log_warning "This function is intended for .mov (ProRes) files only."
      return
    fi
     
    check_dependency "ffmpeg" "required"

    local basename="${SELECTED_PATH%.*}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output="${basename}_converted_${timestamp}.mp4"

    log_info "Converting ProRes .mov to H.264 .mp4 (high quality)..."
    ffmpeg -i "$SELECTED_PATH" -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 192k "$output" -v error

    if [ $? -eq 0 ]; then
      log_success "Conversion successful: $output"
    else
      log_error "Conversion failed."
    fi
  else
    log_error "You must select a .mov video file."
  fi
}
