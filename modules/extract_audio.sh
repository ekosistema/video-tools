#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to extract audio tracks to WAV format.
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

MODULE_NAME="Extract Audio"
MODULE_DESCRIPTION="Extract audio (WAV) from a video file or all videos in a folder."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <input>    Input file or folder."
    echo "  -o <output>   Output file (single file mode only)."
    echo "  -h            Show this help message."
}

function run_batch_process() {
    local input_path="$1"
    local output_path="$2"

    check_dependency "ffmpeg" "required"
    
    input_path=$(fix_path_for_wsl "$input_path")

    if [ ! -e "$input_path" ]; then
        die "Error: Input '$input_path' does not exist."
    fi

    if [ -f "$input_path" ]; then
        if [ -z "$output_path" ]; then
             local timestamp=$(date +%Y%m%d_%H%M%S)
             output_path="${input_path%.*}_${timestamp}.wav"
        fi
        
        log_info "Extracting audio..."
        ffmpeg -i "$input_path" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$output_path" -v error -y
        
        if [ $? -eq 0 ]; then
          log_success "Extracted audio: $output_path"
        else
          die "Extraction failed."
        fi

    elif [ -d "$input_path" ]; then
        local outdir="$input_path/audios_wav"
        mkdir -p "$outdir"
        
        shopt -s nullglob
        for f in "$input_path"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
          if [ -f "$f" ]; then
             local name=$(basename "$f")
             log_info "Processing $name..."
             local timestamp=$(date +%Y%m%d_%H%M%S)
             ffmpeg -i "$f" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$outdir/${name%.*}_${timestamp}.wav" -v error -y
          fi
        done
        shopt -u nullglob
        
        log_success "Audios extracted in $outdir"
    else
        die "Invalid input type."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a file or folder to extract audio from:"
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
