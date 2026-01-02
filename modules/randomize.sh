#!/bin/bash
# ==============================================================================
# Video Tools 2.0
# Copyright (C) 2025 CeleroLab
#
# Description: Module to randomize video clips for glitch effects.
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

MODULE_NAME="Randomize Video"
MODULE_DESCRIPTION="Split a video into 1s clips, shuffle them, and merge back."

function usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i <input>    Input video file or folder."
    echo "  -o <output>   Output randomized video file (single file mode only)."
    echo "  -h            Show this help message."
}

function randomize_single_file() {
    local input_path="$1"
    local output_path="$2"

    local shuffler="shuf"
    if [ "$ENVIRONMENT" = "MACOS" ]; then
      shuffler="gshuf"
      if ! check_dependency "gshuf"; then
        die "Error: 'gshuf' is required on macOS. Install it with: brew install coreutils"
      fi
    elif ! command -v shuf &> /dev/null; then
       die "Error: 'shuf' command not found."
    fi

    # Create distinct temp dir per process to allow running in parallel if needed
    local timestamp=$(date +%s%N)
    local temp_dir="clips_${timestamp}"
    mkdir -p "$temp_dir"
    local list_file="list_${timestamp}.txt"
    
    # Ensure cleanup on this function return/exit
    # (Since we are in a loop, we clean explicitly at end, but trap is safety net)
    trap 'rm -rf "$temp_dir" "$list_file"' RETURN

    log_info "Splitting $(basename "$input_path") into 1-second fragments..."
    ffmpeg -i "$input_path" -an -c copy -dn -map 0 -segment_time 1 -f segment -reset_timestamps 1 "$temp_dir/out%03d.mp4" -v error -y

    log_info "Shuffling clips..."
    find "$temp_dir" -name '*.mp4' | sort | $shuffler | while read file; do
      echo "file '$file'" >> "$list_file"
    done

    if [ -z "$output_path" ]; then
        local ext="${input_path##*.}"
        local basename="${input_path%.*}"
        output_path="${basename}_randomized.${ext}"
    fi

    log_info "Concatenating..."
    ffmpeg -f concat -safe 0 -i "$list_file" -c copy "$output_path" -v error -y

    if [ $? -eq 0 ]; then
      log_success "Created: $output_path"
    else
      log_error "Failed to randomize $input_path"
    fi

    # Explicit cleanup
    rm -rf "$temp_dir" "$list_file"
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
        randomize_single_file "$input_path" "$output_path"
    elif [ -d "$input_path" ]; then
         if [ -n "$output_path" ]; then
            log_warning "Output argument ignored in batch mode. Files will be saved alongside originals."
         fi
         
         shopt -s nullglob
         for f in "$input_path"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
            randomize_single_file "$f" ""
         done
         shopt -u nullglob
    else
        die "Invalid input type."
    fi
}

function run_interactive_menu() {
  select_file_or_folder "Select a video file or folder to randomize:"
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
