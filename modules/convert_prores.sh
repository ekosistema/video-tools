#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to convert ProRes files to MP4.
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

MODULE_NAME="Convert ProRes to MP4"
MODULE_DESCRIPTION="Convert Apple ProRes (.mov) to high-quality H.264 .mp4."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <input>    Input ProRes file or folder."
    echo "  -o <output>   Output MP4 file (single file mode only)."
    echo "  -h            Show this help message."
}

function convert_single_file() {
    local input_path="$1"
    local output_path="$2"

    local ext="${input_path##*.}"
    if [[ "${ext,,}" != "mov" ]]; then
      log_warning "Skipping $input_path: Not a .mov file."
      return
    fi

    if [ -z "$output_path" ]; then
        local basename="${input_path%.*}"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        output_path="${basename}_converted_${timestamp}.mp4"
    fi

    log_info "Converting $(basename "$input_path")..."
    ffmpeg -i "$input_path" -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 192k "$output_path" -v error -y

    if [ $? -eq 0 ]; then
      log_success "Created: $output_path"
    else
      log_error "Conversion failed for $input_path"
    fi
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
        convert_single_file "$input_path" "$output_path"
    elif [ -d "$input_path" ]; then
        if [ -n "$output_path" ]; then
           log_warning "Output argument ignored in batch mode."
        fi
        
        shopt -s nullglob
        for f in "$input_path"/*.{mov,MOV}; do
           convert_single_file "$f" ""
        done
        shopt -u nullglob
    else
        die "Invalid input type."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a .mov (ProRes) file or folder:"
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
