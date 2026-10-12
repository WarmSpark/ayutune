import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../theme/retro_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/cassette_deck.dart';
import '../widgets/jiggly_lyrics.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_scrubber.dart';
import '../widgets/wiggly_waveform.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  int _centerViewMode = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final playerService = Provider.of<AudioPlayerService>(context);
    final track = playerService.currentTrack;
    final activeLyricIndex = playerService.getActiveLyricIndex();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2.5),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _tabButton('TAPE DECK', 0, theme),
                        const SizedBox(width: 6),
                        _tabButton('JIGGLY LYRICS', 1, theme),
                      ],
                    ),
                    Text(
                      'SQUIGGLE VIBE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: theme.accentTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_centerViewMode == 0)
                  CassetteDeck(
                    theme: theme,
                    title: track.title,
                    artist: track.artist,
                    isPlaying: playerService.isPlaying,
                  )
                else
                  JigglyLyricsView(
                    theme: theme,
                    lyrics: track.lyrics,
                    activeIndex: activeLyricIndex,
                    onSeekLyric: (pos) => playerService.seek(pos),
                  ),
                const SizedBox(height: 8),
                WigglyWaveform(
                  theme: theme,
                  isPlaying: playerService.isPlaying,
                ),
                const SizedBox(height: 8),
                RetroScrubber(
                  theme: theme,
                  currentPosition: playerService.currentPosition,
                  totalDuration: playerService.totalDuration,
                  onSeek: (pos) => playerService.seek(pos),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildPaletteStrip(theme, themeProvider),
          const SizedBox(height: 8),
          _buildControlsBar(theme, playerService),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int mode, RetroThemeData theme) {
    final isSelected = _centerViewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _centerViewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.ink : theme.background,
          border: Border.all(color: theme.ink, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.background : theme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteStrip(RetroThemeData theme, ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'THEMES',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: theme.ink,
            ),
          ),
          Row(
            children: RetroThemeData.allThemes.map((item) {
              final isCurrent = item.type == theme.type;
              return GestureDetector(
                onTap: () => themeProvider.setTheme(item),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.background,
                    border: Border.all(
                      color: isCurrent ? item.accentTeal : item.ink,
                      width: isCurrent ? 2.5 : 1.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar(RetroThemeData theme, AudioPlayerService playerService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RetroButton(
          label: 'EXPORT',
          theme: theme,
          fontSize: 9,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: theme.panel,
                content: Text(
                  'EXPORT TRACK TO STORAGE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: theme.ink,
                  ),
                ),
              ),
            );
          },
        ),
        RetroButton(
          label: 'ALTER',
          theme: theme,
          fontSize: 9,
          onTap: () => playerService.toggleShuffle(),
        ),
        RetroButton(
          label: 'OOPS!',
          theme: theme,
          backgroundColor: theme.ink,
          textColor: theme.background,
          fontSize: 10,
          onTap: () => playerService.previous(),
        ),
        RetroButton(
          label: playerService.isPlaying ? 'PAUSE' : 'PLAY',
          theme: theme,
          backgroundColor: theme.accentCoral,
          textColor: Colors.white,
          fontSize: 11,
          onTap: () => playerService.togglePlayPause(),
        ),
        RetroButton(
          label: 'SKIP',
          theme: theme,
          fontSize: 9,
          onTap: () => playerService.next(),
        ),
        VolumeStepper(
          theme: theme,
          volume: playerService.volume,
          onVolumeChanged: (val) => playerService.setVolume(val),
        ),
        RetroButton(
          label: 'STOP',
          theme: theme,
          backgroundColor: theme.panel,
          textColor: theme.ink,
          fontSize: 9,
          onTap: () => playerService.obliterate(),
        ),
      ],
    );
  }
}
