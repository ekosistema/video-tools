# 🎬 Video Tools

A simple, interactive command-line tool to manipulate video files using `ffmpeg`.

## ✨ Features

- Split videos into 30s clips
- Merge multiple videos
- Remove audio (from file or folder)
- Extract audio to `.wav`
- Convert `.mov` (Apple ProRes) to `.mp4`
- Randomly shuffle short video fragments
- Interactive terminal prompts
- Supports WSL, Linux, and macOS

---

## 🛠 Requirements

### ✅ `ffmpeg` must be installed and accessible in your `$PATH`.

Install it using your system's package manager:

- **macOS (Homebrew):**
  ```bash
  brew install ffmpeg
  ```

- **Ubuntu/Debian:**
  ```bash
  sudo apt update
  sudo apt install ffmpeg
  ```

- **WSL (Windows Subsystem for Linux):**
  Install as you would on Ubuntu.

---

## ⚡️ Installation

### 🔒 Global install (system-wide):

```bash
sudo curl -sSL https://raw.githubusercontent.com/ekosistema/video-tools/main/video_tools.sh -o /usr/local/bin/video_tools && sudo chmod +x /usr/local/bin/video_tools
```

### 👤 Local install (user-only, no sudo):

```bash
mkdir -p "$HOME/.local/bin"
curl -sSL https://raw.githubusercontent.com/ekosistema/video-tools/main/video_tools.sh -o "$HOME/.local/bin/video_tools"
chmod +x "$HOME/.local/bin/video_tools"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

> 💡 **macOS users using zsh:** Replace `~/.bashrc` with `~/.zshrc`.

### 🍏 macOS Installation

#### 🧱 Dependencies

1. Install **FFmpeg** and **coreutils** (for `gshuf`):

```bash
brew install ffmpeg coreutils
```

#### 📦 Script Installation

To install the script globally:

```bash
sudo curl -sSL https://raw.githubusercontent.com/ekosistema/video-tools/main/video_tools.sh -o /usr/local/bin/video_tools && sudo chmod +x /usr/local/bin/video_tools
```

Or for local user install (no sudo):

```bash
mkdir -p "$HOME/.local/bin"
curl -sSL https://raw.githubusercontent.com/ekosistema/video-tools/main/video_tools.sh -o "$HOME/.local/bin/video_tools"
chmod +x "$HOME/.local/bin/video_tools"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

> 💡 If you're using Bash on macOS, replace `~/.zshrc` with `~/.bashrc`.


---

## 🚀 Usage

After installation, run the tool by typing:

```bash
video_tools
```

You’ll see an interactive menu like this:

```
What do you want to do?
1) Randomize video
2) Merge videos
3) Split video (30s)
4) Remove audio
5) Extract audio to WAV
6) Convert Apple ProRes (.mov) to .mp4
7) Exit
```

Just type a number and follow the prompts.

---

## 🧩 Feature Details

### 1) Randomize video

Splits a video into 1-second clips, shuffles them, and reassembles the final video.

### 2) Merge videos

Select a folder and merge all supported video files inside it (`.mp4`, `.mov`, `.avi`, `.mkv`).

### 3) Split video (30s)

Divides a single video into 30-second segments.

### 4) Remove audio

Remove audio from a single video or all videos inside a folder.

### 5) Extract audio to WAV

Extracts audio in `.wav` format from a video or from all videos in a folder.

### 6) Convert Apple ProRes (.mov) to .mp4

Converts `.mov` (ProRes) files to high-quality `.mp4` using H.264 encoding.

---

## 📂 Supported Formats

- `.mp4`, `.mov`, `.avi`, `.mkv` (case insensitive)

---

## 📄 License

MIT

---

## 🙌 Acknowledgments

Built with ❤️ using `ffmpeg`, `bash`, and a desire to simplify video tasks from the terminal.
