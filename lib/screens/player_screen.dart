import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../services/offline_service.dart';
import '../services/playlist_service.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 600;
        final deckHeight = isCompact ? 190.0 : 255.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight - 12.0,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.panel,
                      border: Border.all(color: theme.ink, width: 2.5),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _tabButton('TAPE DECK', 0, theme),
                                const SizedBox(width: 8),
                                _tabButton('JIGGLY LYRICS', 1, theme),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.background,
                                border: Border.all(color: theme.accentTeal, width: 1.5),
                              ),
                              child: Text(
                                playerService.isAutoplay ? 'AUTOPLAY: ON' : 'AUTOPLAY: OFF',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.accentTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_centerViewMode == 0)
                          CassetteDeck(
                            theme: theme,
                            title: track.title,
                            artist: track.artist,
                            isPlaying: playerService.isPlaying,
                            thumbnailUrl: track.thumbnailUrl,
                          )
                        else
                          JigglyLyricsView(
                            theme: theme,
                            lyrics: track.lyrics,
                            activeIndex: activeLyricIndex,
                            height: deckHeight,
                            onSeekLyric: (pos) => playerService.seek(pos),
                          ),
                        const SizedBox(height: 10),
                        WigglyWaveform(
                          theme: theme,
                          isPlaying: playerService.isPlaying,
                        ),
                        const SizedBox(height: 10),
                        RetroScrubber(
                          theme: theme,
                          currentPosition: playerService.currentPosition,
                          totalDuration: playerService.totalDuration,
                          onSeek: (pos) => playerService.seek(pos),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildPaletteStrip(theme, themeProvider),
                  const SizedBox(height: 6),
                  _buildControlsBar(theme, playerService, track),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(String label, int mode, RetroThemeData theme) {
    final isSelected = _centerViewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _centerViewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.ink : theme.background,
          border: Border.all(color: theme.ink, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'THEME COLOR',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
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
                  margin: const EdgeInsets.only(left: 8),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: item.background,
                    border: Border.all(
                      color: isCurrent ? item.accentTeal : item.ink,
                      width: isCurrent ? 3.0 : 1.5,
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

  Widget _buildControlsBar(
    RetroThemeData theme,
    AudioPlayerService playerService,
    dynamic track,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RetroButton(
                label: 'SHUFFLE',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                backgroundColor: playerService.isShuffle ? theme.accentTeal : theme.background,
                textColor: playerService.isShuffle ? const Color(0xFF0C1626) : theme.ink,
                onTap: () => playerService.toggleShuffle(),
              ),
              RetroButton(
                label: 'PREV',
                theme: theme,
                backgroundColor: theme.ink,
                textColor: theme.background,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () => playerService.previous(),
              ),
              RetroButton(
                label: playerService.isPlaying ? 'PAUSE' : 'PLAY',
                theme: theme,
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onTap: () => playerService.togglePlayPause(),
              ),
              RetroButton(
                label: 'NEXT',
                theme: theme,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () => playerService.next(),
              ),
              RetroButton(
                label: 'AUTO',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                backgroundColor: playerService.isAutoplay ? theme.accentTeal : theme.background,
                textColor: playerService.isAutoplay ? const Color(0xFF0C1626) : theme.ink,
                onTap: () => playerService.toggleAutoplay(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RetroButton(
                    label: 'SAVE TAPE',
                    theme: theme,
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: theme.accentTeal,
                    textColor: const Color(0xFF0C1626),
                    onTap: () => _handleSaveTrack(track, theme),
                  ),
                  const SizedBox(width: 8),
                  RetroButton(
                    label: '+ TAPE',
                    theme: theme,
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onTap: () => _showAddToPlaylistDialog(track, theme),
                  ),
                ],
              ),
              VolumeStepper(
                theme: theme,
                volume: playerService.volume,
                onVolumeChanged: (val) => playerService.setVolume(val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSaveTrack(dynamic track, RetroThemeData theme) async {
    final offline = OfflineService();
    if (offline.isDownloaded(track.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.panel,
          content: Text(
            'TRACK ALREADY IN OFFLINE STORAGE: ${track.title}',
            style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: theme.panel,
        duration: const Duration(seconds: 2),
        content: Text(
          'DOWNLOADING 320KBPS AUDIO FOR OFFLINE STORAGE...',
          style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
        ),
      ),
    );

    final saved = await offline.downloadTrack(track);
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: theme.panel,
          content: Text(
            'SAVED TO OFFLINE TAPES: ${track.title}',
            style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
          ),
        ),
      );
    }
  }

  void _showAddToPlaylistDialog(dynamic track, RetroThemeData theme) {
    final playlists = PlaylistService().playlists;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.panel,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.ink, width: 2.5),
              ),
              title: Text(
                'ADD TO RETRO TAPE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: theme.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'CREATE NEW TAPE NAME',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.inkDim,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add, color: theme.accentTeal),
                          onPressed: () async {
                            final name = textController.text.trim();
                            if (name.isNotEmpty) {
                              final created = await PlaylistService().createPlaylist(name);
                              await PlaylistService().addTrackToPlaylist(created.id, track);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: theme.panel,
                                    content: Text(
                                      'ADDED TO NEW TAPE: ${created.name}',
                                      style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (playlists.isEmpty)
                      Text(
                        'NO RETRO TAPES CREATED YET',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.inkDim,
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: playlists.length,
                          itemBuilder: (context, idx) {
                            final p = playlists[idx];
                            return ListTile(
                              title: Text(
                                p.name,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.ink,
                                ),
                              ),
                              subtitle: Text(
                                '${p.tracks.length} TRACKS',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: theme.inkDim,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 12, color: theme.accentTeal),
                              onTap: () async {
                                await PlaylistService().addTrackToPlaylist(p.id, track);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: theme.panel,
                                      content: Text(
                                        'ADDED TO TAPE: ${p.name}',
                                        style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: theme.ink,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
