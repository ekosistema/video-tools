# 🎬 Video Tools ![v2.1.0](https://img.shields.io/badge/version-2.0.0-blue)

**A modular and extensible command-line toolkit for video manipulation.**

Video Tools 2.1.0 is a Bash helper that simplifies complex `ffmpeg` operations into an easy-to-use interactive menu. Whether you need to split, merge, simple randomize, or process batches of videos, this tool handles it with grace. 

Now re-engineered with a **modular architecture**, making it faster, safer, and easily extensible.

---

## ✨ Features

- **🌗 Hybrid CLI/TUI Interface**: Use it manually with a visual menu OR automate it with command-line arguments.
- **📂 Batch Processing**: All modules now accept folders to process multiple videos at once.
- **✂️ Smart Splitting**: Automatically split videos into 30-second clips.
- **🔗 Seamless Merging**: Combine multiple video files from a directory into one.
- **🔇 Audio Removal**: Strip audio tracks from single files or batch process entire folders.
- **🎧 Audio Extraction**: Extract high-quality WAV audio from your video files.
- **🍏 ProRes Conversion**: Convert heavy Apple ProRes (`.mov`) files to high-quality H.264 `.mp4`.
- **🔀 Video Randomizer**: Create glitch-art style videos by shuffling 1-second fragments.
- **🧩 Modular Design**: Easily add your own custom scripts to the `modules/` folder.
- **🖥️ Cross-Platform**: Optimized for **Linux**, **WSL** (Windows Subsystem for Linux), and **macOS**.

---

## 🚀 Installation

### Prerequisites

Ensure you have **ffmpeg** installed on your system.
- **macOS**: `brew install ffmpeg coreutils`
- **Ubuntu/Debian/WSL**: `sudo apt install ffmpeg`

### ⚡ One-Line Install

Copy and paste this command into your terminal to download and install:

```bash
git clone https://github.com/ekosistema/video-tools.git && cd video-tools && ./install.sh
```

### 🛠️ Manual Installation

If you prefer to install it manually:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/ekosistema/video-tools.git
    cd video-tools
    ```

2.  **Make scripts executable**:
    ```bash
    chmod +x bin/video-tools install.sh
    chmod +x modules/*.sh
    ```

3.  **Run the setup script** (creates a symlink):
    ```bash
    ./install.sh
    ```
    *Alternatively, add the `bin/` folder to your `$PATH` manually.*

---

## ▶️ Usage

Video Tools 2.0 now supports a **Hybrid UX**, allowing you to use it either visually (Interactive Menu) or programmatically (Headless CLI).

### 1. 🖥️ Interactive Mode (TUI)

Simply run the tool without arguments to launch the visual menu. This is perfect for when you don't want to remember complex flags.

```bash
video-tools
# OR run a specific module interactively:
./modules/remove_audio.sh
```

You will see:
```text
=== Video Tools (MACOS/LINUX/WSL) ===
1) Randomize Video - Split a video into 1s clips, shuffle them, and merge back.
2) Merge Videos - Merge all videos in a selected folder into one file.
3) Split Video - Split a video into segments (approx. 30s).
4) Remove Audio - Remove audio track from a video file or all videos in a folder.
5) Extract Audio - Extract audio (WAV) from a video file or all videos in a folder.
6) Convert ProRes to MP4 - Convert Apple ProRes (.mov) to high-quality H.264 .mp4.
7) Exit
```

### 2. 🤖 Headless Mode (CLI / Batch)

For power users, pipelines, and cron jobs, you can pass arguments directly to the modules. In this mode, the tool runs **silently** (no questions asked) and exits with a standard status code.

**Common Syntax:**
```bash
./modules/<script_name>.sh -i <input> [-o <output>] [other_flags]
```

**Examples:**

*   **Remove Audio:**
    ```bash
    ./modules/remove_audio.sh -i input.mp4 -o output_silent.mp4
    ```

*   **Split Video (Batch Folder):**
    ```bash
    ./modules/split.sh -i /path/to/my_videos_folder/ -t 15
    ```

*   **Randomize (Glitch Effect):**
    ```bash
    ./modules/randomize.sh -i input.mp4
    # OR process an entire folder:
    ./modules/randomize.sh -i /path/to/folder/
    ```

*   **Merge Videos:**
    ```bash
    ./modules/merge.sh -i /path/to/video_folder -o final_movie.mp4
    ```

*   **Get Help:**
    ```bash
    ./modules/split.sh --help
    ```

---

## ❓ Common Problems

**1. "Command not found: video-tools"**
- Ensure you ran `./install.sh`.
- Check if the installation directory (e.g., `~/bin`) is in your system `$PATH`. You may need to add `export PATH="$HOME/bin:$PATH"` to your `.bashrc` or `.zshrc`.

**2. "gshuf: command not found" (macOS)**
- The randomizer feature requires `gshuf`. Install it via Homebrew: `brew install coreutils`.

**3. "Permission denied"**
- If the script doesn't run, try making it executable: `chmod +x bin/video-tools`.

---

## 📝 Credits

**Version**: 2.1.0  
**License**: MIT

Developed with ❤️ and ☕ by [CeleroLab.Com](https://celerolab.com).  
*Keeping video editing simple, one script at a time.*
