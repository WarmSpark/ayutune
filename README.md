# Velvetune

A retro brutalist Android music player combining vintage cassette tape aesthetics with high-fidelity dual-engine audio streaming and synchronized lyrics.

## Features

- **Dual-Engine Streaming**: High-quality 320kbps audio streaming powered by encrypted media resolution and indie streaming pipelines.
- **Cassette Tape Deck UI**: Animated tape deck with spinning spools synchronized with play, pause, seek, and playback rate.
- **Synchronized Lyrics**: Millisecond-accurate line-synced lyrics with automated Devanagari Romanization transliteration.
- **Album & Song Search**: Segmented catalog exploration supporting song queries, hit albums, and full-album queue playback.
- **Spotify Playlist Importer**: One-click import for public Spotify playlists into custom retro mixtapes with background thumbnail resolution.
- **Offline Mode & Autoplay**: Instant offline detection that loads saved mixtapes with seamless continuous playlist autoplay.
- **Hardware Audio FX**: Integrated Android LoudnessEnhancer and multi-band Equalizer for rich low-end punch and clarity.
- **Foreground Media Service**: Background audio playback with notification controls, lock screen metadata, and seek actions.
- **Retro Computing Themes**: High-contrast brutalist color palettes inspired by vintage hardware.

## Available Themes

- Paper Blue: Technical blueprint contrast on rich parchment.
- Deep Navy: Midnight terminal contrast.
- Classic Parchment: Warm aged paper aesthetic.
- Game Boy DMG: Nostalgic monochrome pea-green LCD display.
- Macintosh 1-Bit: Stark monochrome pixel art finish.
- Amber CRT: Warm phosphorescent terminal glow.

## Streaming Architecture

Velvetune implements a resilient client-side streaming engine:

1. **Primary Catalog & Stream Decryption**:
   - Direct integration with catalog search, album metadata, and trending releases.
   - Encrypted stream URLs are decrypted on-device using DES (Data Encryption Standard) via `dart_des` to resolve direct high-bitrate 320kbps MP4/AAC streams.
2. **Indie & Underground Fallback**:
   - Integrated SoundCloud streaming engine with dynamic client-id extraction.
   - Resolves progressive and HLS audio feeds for underground tracks and indie covers.
3. **Synchronized Karaoke Lyrics Engine**:
   - Queries LRCLIB for timestamped LRC lyrics.
   - Built-in phonetics engine transliterates Hindi/Devanagari text into Latin script for legible singing on retro mono fonts.
4. **Playback Engine**:
   - Backed by Just Audio with native Android audio effects (LoudnessEnhancer, Equalizer).
   - AudioService integration for system-wide notifications and media controls.

## Building from Source

### Prerequisites

- Flutter SDK 3.12.2 or higher
- Android SDK 34 (Java 17+)
- A connected Android device or emulator running Android 8.0 (API 26) or newer

### Build Steps

```bash
git clone https://github.com/WarmSpark/velvetune.git
cd velvetune
flutter pub get
flutter build apk --split-per-abi
```

The split release APKs will be located under `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk` (Recommended for modern Android devices, ~19 MB)
- `app-armeabi-v7a-release.apk` (For older 32-bit ARM devices)
- `app-x86_64-release.apk` (For x86_64 emulators/devices)

## Permissions

Velvetune asks only for minimal necessary permissions:
- `INTERNET`: To stream audio and fetch synchronized lyrics.
- `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: To maintain uninterrupted playback in the background.
- `POST_NOTIFICATIONS`: To show playback controls on Android 13+.
- `WAKE_LOCK`: To prevent audio dropout when the screen is locked.

Velvetune contains no tracking SDKs, no advertisements, and no analytics.
