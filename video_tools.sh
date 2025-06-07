#!/bin/bash

function detect_environment() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ENVIRONMENT="MACOS"
  elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    ENVIRONMENT="WSL"
  else
    ENVIRONMENT="UNIX"
  fi
}

detect_environment

function select_file_or_folder() {
  echo "Select a file or folder to process:"

  if [[ -t 0 && -t 1 ]]; then
    echo "Use TAB to autocomplete the path. Type the path and press ENTER:"
    read -e -p "Path: " PATH_INPUT
  else
    echo "⚠️ Not an interactive terminal. Autocomplete not available."
    read -rp "Path: " PATH_INPUT
  fi

if [ "$ENVIRONMENT" = "WSL" ]; then
  # Solo transforma si es una ruta estilo Windows
  if [[ "$PATH_INPUT" =~ ^[a-zA-Z]:\\|^[a-zA-Z]:/ ]]; then
    # Convierte barras invertidas a normales
    PATH_INPUT=$(echo "$PATH_INPUT" | sed 's|\\|/|g')
    DRIVE_LETTER=$(echo "$PATH_INPUT" | cut -c1 | tr 'A-Z' 'a-z')
    PATH_INPUT="/mnt/$DRIVE_LETTER${PATH_INPUT:2}"
  fi
fi


  if [ ! -e "$PATH_INPUT" ]; then
    echo "❌ The specified path does not exist."
    exit 1
  fi
}

function randomize_video() {
  select_file_or_folder
  if [ -f "$PATH_INPUT" ]; then
    ORIGINAL_VIDEO="$PATH_INPUT"

    mkdir -p clips
    rm -f clips/*.mp4 list.txt

    echo "🧩 Splitting video into 1-second fragments..."
    ffmpeg -i "$ORIGINAL_VIDEO" -an -c copy -map 0 -segment_time 1 -f segment -reset_timestamps 1 clips/out%03d.mp4

    echo "🔀 Shuffling clips randomly..."
    SHUFFLER="shuf"
    if [ "$ENVIRONMENT" = "MACOS" ]; then
      SHUFFLER="gshuf"
      if ! command -v gshuf &> /dev/null; then
        echo "❌ 'gshuf' is required on macOS. Install it with: brew install coreutils"
        return
      fi
    fi
    FULL_PATH="$(pwd)/clips"
    find "$FULL_PATH" -name '*.mp4' | sort | $SHUFFLER | while read file; do
      echo "file '$file'" >> list.txt
    done

    EXT="${ORIGINAL_VIDEO##*.}"
    BASENAME="${ORIGINAL_VIDEO%.*}"
    OUTPUT_VIDEO="${BASENAME}_randomized.${EXT}"

    echo "🎬 Concatenating shuffled clips into final video..."
    ffmpeg -f concat -safe 0 -i list.txt -c copy "$OUTPUT_VIDEO"

    if [ $? -eq 0 ]; then
      echo "🧹 Cleaning up temporary files..."
      rm -rf clips list.txt
      echo "✅ Done! Randomized video saved as '$OUTPUT_VIDEO'"
    else
      echo "❌ Error occurred while generating the final video. Temporary files were not deleted."
    fi
  else
    echo "❌ You must select a single video file."
  fi
}





function merge_videos() {
  select_file_or_folder
  if [ -d "$PATH_INPUT" ]; then
    rm -f list.txt merged_video.mp4
    for f in "$PATH_INPUT"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
      [ -f "$f" ] && echo "file '$f'" >> list.txt
    done
    echo "🎬 Merging videos..."
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT="merged_video_${TIMESTAMP}.mp4"
    ffmpeg -f concat -safe 0 -i list.txt -c copy "$OUTPUT"
    echo "✅ Merged video: $OUTPUT"
  else
    echo "❌ Must be a folder."
  fi
}

function split_video() {
  select_file_or_folder
  if [ -f "$PATH_INPUT" ]; then
    BASENAME=$(basename "$PATH_INPUT")
    NAME="${BASENAME%.*}"
    EXT="${BASENAME##*.}"
    OUTDIR="${NAME}_clips"
    mkdir -p "$OUTDIR"
    echo "✂️ Splitting into 50s fragments..."
    ffmpeg -i "$PATH_INPUT" -c copy -map 0 -f segment -segment_time 30 -reset_timestamps 1 "$OUTDIR/${NAME}_clip_%03d.${EXT}"
    echo "✅ Clips saved in: $OUTDIR"
  else
    echo "❌ Must be an individual file."
  fi
}

function remove_audio() {
  select_file_or_folder
  if [ -f "$PATH_INPUT" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT="${PATH_INPUT%.*}_no_audio_${TIMESTAMP}.${PATH_INPUT##*.}"
    echo "🔇 Removing audio from $PATH_INPUT..."
    ffmpeg -i "$PATH_INPUT" -an -c copy "$OUTPUT"
    echo "✅ Generated: $OUTPUT"
  elif [ -d "$PATH_INPUT" ]; then
    mkdir -p "no_audio"
    for f in "$PATH_INPUT"/*.{mp4,MP4,mov,MOV,avi,AVI,mkv,MKV}; do
      [ -f "$f" ] || continue
      name=$(basename "$f")
      echo "🔇 Processing $name..."
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      ffmpeg -i "$f" -an -c copy "no_audio/${name%.*}_no_audio_${TIMESTAMP}.mp4"
    done
    echo "✅ Audio-free videos saved in ./no_audio"
  fi
}

function extract_audio() {
  select_file_or_folder
  if [ -f "$PATH_INPUT" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT="${PATH_INPUT%.*}_${TIMESTAMP}.wav"
    echo "🎧 Extracting audio..."
    ffmpeg -i "$PATH_INPUT" -vn -acodec pcm_s16le -ar 44100 -ac 2 "$OUTPUT"
    echo "✅ Extracted audio: $OUTPUT"
  elif [ -d "$PATH_INPUT" ]; then
    mkdir -p "audios_wav"
    for f in "$PATH_INPUT"/*.mp4; do
      name=$(basename "$f")
      echo "🎧 Processing $name..."
      TIMESTAMP=$(date +%Y%m%d_%H%M%S)
      ffmpeg -i "$f" -vn -acodec pcm_s16le -ar 44100 -ac 2 "audios_wav/${name%.*}_${TIMESTAMP}.wav"
    done
    echo "✅ Audios extracted in ./audios_wav"
  fi
}


function convert_prores() {
  select_file_or_folder
  if [ -f "$PATH_INPUT" ]; then
    EXT="${PATH_INPUT##*.}"
    if [[ "$EXT" != "mov" && "$EXT" != "MOV" ]]; then
      echo "⚠️ This function is intended for .mov (ProRes) files only."
      return
    fi

    BASENAME="${PATH_INPUT%.*}"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT="${BASENAME}_converted_${TIMESTAMP}.mp4"

    echo "🎥 Converting ProRes .mov to H.264 .mp4 (high quality)..."
    ffmpeg -i "$PATH_INPUT" -c:v libx264 -preset slow -crf 18 -c:a aac -b:a 192k "$OUTPUT"

    if [ $? -eq 0 ]; then
      echo "✅ Conversion successful: $OUTPUT"
    else
      echo "❌ Conversion failed."
    fi
  else
    echo "❌ You must select a .mov video file."
  fi
}

while true; do
  echo -e "\nWhat do you want to do?"
  echo "1) Randomize video"
  echo "2) Merge videos"
  echo "3) Split video (30s)"
  echo "4) Remove audio"
  echo "5) Extract audio to WAV"
  echo "6) Convert Apple ProRes (.mov) to .mp4"
echo "7) Exit"
  read -rp "Option: " option
  case $option in
    1) randomize_video;;
    2) merge_videos;;
    3) split_video;;
    4) remove_audio;;
    5) extract_audio;;
    6) convert_prores;;
    7) echo "👋 Exiting..."; exit 0;;
    *) echo "❌ Invalid option";;
  esac
  echo "-------------------------------"
done
