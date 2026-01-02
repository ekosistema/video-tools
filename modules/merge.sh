#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to merge multiple video files into one.
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

MODULE_NAME="Merge Videos"
MODULE_DESCRIPTION="Merge all videos in a selected folder into one file."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <folder>   Input folder containing video files."
    echo "  -o <output>   Output merged filename."
    echo "  -h            Show this help message."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -i /path/to/videos -o my_movie.mp4"
    echo "  $(basename "$0") (Interactive mode)"
}

function run_batch_process() {
    local input_path="$1"
    local output_path="$2"

    check_dependency "ffmpeg" "required"
    
    input_path=$(fix_path_for_wsl "$input_path")

    if [ ! -d "$input_path" ]; then
        die "Error: Input '$input_path' is not a directory."
    fi

    local list_file="list_merge_$(date +%s).txt"
    trap 'rm -f "$list_file"' EXIT

    local count=0
    shopt -s nullglob
    for f in "$input_path"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
        if [ -f "$f" ]; then
            echo "file '$f'" >> "$list_file"
            ((count++))
        fi
    done
    shopt -u nullglob

    if [ "$count" -eq 0 ]; then
        die "Error: No video files found in '$input_path'."
    fi

    if [ -z "$output_path" ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        output_path="merged_video_${timestamp}.mp4"
    fi

    log_info "Merging $count videos..."
    ffmpeg -f concat -safe 0 -i "$list_file" -c copy -dn "$output_path" -v error -y

    if [ $? -eq 0 ]; then
        log_success "Merged video created: $output_path"
    else
        die "Merge failed."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a folder containing videos to merge:"
  if [ $? -ne 0 ]; then return; fi
  
  run_batch_process "$SELECTED_PATH" ""
}

function module_run() {
    run_interactive_menu
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    INPUT=""
    OUTPUT=""

    while getopts ":i:o:h" opt; do
      case $opt in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        h) usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
      esac
    done

    if [ -n "$INPUT" ]; then
        run_batch_process "$INPUT" "$OUTPUT"
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
