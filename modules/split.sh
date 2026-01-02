#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to split videos into smaller segments.
# Author: CeleroLab
# License: MIT
# ==============================================================================

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
PROJECT_ROOT="$(dirname "$DIR")"

if [[ -z "$ENVIRONMENT" ]]; then
    if [ -f "$PROJECT_ROOT/lib/core.sh" ]; then
        source "$PROJECT_ROOT/lib/core.sh"
        source "$PROJECT_ROOT/lib/utils.sh"
        detect_environment
    elif [ -f "$DIR/../lib/core.sh" ]; then
        source "$DIR/../lib/core.sh"
        source "$DIR/../lib/utils.sh"
        detect_environment
    else
        echo "Error: Libraries not found."
        exit 1
    fi
fi

MODULE_NAME="Split Video"
MODULE_DESCRIPTION="Split a video into segments (approx. 30s by default)."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <input>    Input video file or folder."
    echo "  -t <seconds>  Segment duration (default: 30)."
    echo "  -h            Show this help message."
    echo ""
    echo "Note: Output clips are saved in a subdirectory named '<filename>_clips'."
}

function split_single_file() {
    local input_path="$1"
    local time_arg="${2:-30}"

    local basename=$(basename "$input_path")
    local name="${basename%.*}"
    local ext="${basename##*.}"
    local outdir="${input_path%.*}_clips" # Create clip folder next to original file
    
    mkdir -p "$outdir"
    
    log_info "Splitting '$basename' into ${time_arg}s fragments..."
    
    ffmpeg -i "$input_path" -c copy -dn -map 0 -f segment -segment_time "$time_arg" -reset_timestamps 1 "$outdir/${name}_clip_%03d.${ext}" -v error -y
    
    if [ $? -eq 0 ]; then
       log_success "Clips saved: $outdir"
    else
       log_error "Splitting failed for $basename."
    fi
}

function run_batch_process() {
    local input_path="$1"
    local time_arg="${2:-30}"

    check_dependency "ffmpeg" "required"
    
    input_path=$(fix_path_for_wsl "$input_path")

    if [ ! -e "$input_path" ]; then
        die "Error: Input '$input_path' does not exist."
    fi

    if [ -f "$input_path" ]; then
        split_single_file "$input_path" "$time_arg"
    elif [ -d "$input_path" ]; then
         shopt -s nullglob
         for f in "$input_path"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
            split_single_file "$f" "$time_arg"
         done
         shopt -u nullglob
    else
        die "Invalid input type."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a video file or folder to split:"
  if [ $? -ne 0 ]; then return; fi
  
  read -p "Enter segment duration in seconds (default 30): " duration
  duration=${duration:-30}

  run_batch_process "$SELECTED_PATH" "$duration"
}

function module_run() {
    run_interactive_menu
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    INPUT=""
    TIME=""

    while getopts ":i:t:h" opt; do
      case $opt in
        i) INPUT="$OPTARG" ;;
        t) TIME="$OPTARG" ;;
        h) usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
      esac
    done

    if [ -n "$INPUT" ]; then
        run_batch_process "$INPUT" "$TIME"
    else
        if check_tty; then
            run_interactive_menu
        else
            echo "Error: Non-interactive session detected and no arguments provided."
            usage
            exit 1
        fi
    fi
fi
