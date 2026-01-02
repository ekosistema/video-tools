#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to remove audio tracks from videos.
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
    else
         if [ -f "$DIR/../lib/core.sh" ]; then
            source "$DIR/../lib/core.sh"
            source "$DIR/../lib/utils.sh"
            detect_environment
         else
            echo "Error: Libraries not found."
            exit 1
         fi
    fi
fi

MODULE_NAME="Remove Audio"
MODULE_DESCRIPTION="Remove audio track from a video file or all videos in a folder."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <input>    Input file or directory."
    echo "  -o <output>   Output file (only for single file input)."
    echo "  -h            Show this help message."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") -i input.mp4 -o input_no_audio.mp4"
    echo "  $(basename "$0") -i /path/to/folder"
    echo "  $(basename "$0") (Interactive mode)"
}

function run_batch_process() {
    local input_path="$1"
    local output_path="$2"

    check_dependency "ffmpeg" "required"

    input_path=$(fix_path_for_wsl "$input_path")

    if [ ! -e "$input_path" ]; then
        die "Error: Input path '$input_path' does not exist."
    fi

    if [ -f "$input_path" ]; then
        if [ -z "$output_path" ]; then
            local timestamp=$(date +%Y%m%d_%H%M%S)
            output_path="${input_path%.*}_no_audio_${timestamp}.${input_path##*.}"
        fi
        
        log_info "Removing audio from $input_path..."
        ffmpeg -i "$input_path" -an -c copy -dn "$output_path" -v error -y
        
        if [ $? -eq 0 ]; then
             echo "$output_path"
        else
            die "Failed to remove audio."
        fi

    elif [ -d "$input_path" ]; then
         local outdir="$input_path/no_audio"
         mkdir -p "$outdir"
         
         shopt -s nullglob
         for f in "$input_path"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
            local name=$(basename "$f")
            log_info "Processing $name..."
            local timestamp=$(date +%Y%m%d_%H%M%S)
            
            ffmpeg -i "$f" -an -c copy -dn "$outdir/${name%.*}_no_audio_${timestamp}.mp4" -v error -y
         done
         shopt -u nullglob
         
         log_success "Audio-free videos saved in $outdir"
    else
        die "Invalid input type."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a file or folder to remove audio from:"
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
        i) INPUT="$OPTARG"
        ;;
        o) OUTPUT="$OPTARG"
        ;;
        h) usage; exit 0
        ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1
        ;;
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
