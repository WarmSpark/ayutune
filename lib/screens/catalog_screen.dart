import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/innertube_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/retro_button.dart';

class CatalogScreen extends StatefulWidget {
  final VoidCallback onOpenPlayer;

  const CatalogScreen({
    super.key,
    required this.onOpenPlayer,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final InnerTubeService _innerTube = InnerTubeService();
  final TextEditingController _searchController = TextEditingController();

  List<Track> _displayedTracks = [];
  String _selectedCategory = 'ALL';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _displayedTracks = _innerTube.getDefaultTracks();
  }

  void _onSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await _innerTube.searchTracks(query);
    setState(() {
      _displayedTracks = results;
      _isSearching = false;
    });
  }

  List<Track> _getFilteredTracks() {
    if (_selectedCategory == 'ALL') return _displayedTracks;
    if (_selectedCategory == 'SAVED') {
      return _displayedTracks.where((t) => t.isOffline).toList();
    }
    return _displayedTracks.where((t) => t.genreTag == _selectedCategory).toList();
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _innerTube.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final playerService = Provider.of<AudioPlayerService>(context);
    final currentTrack = playerService.currentTrack;
    final filtered = _getFilteredTracks();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.ink, width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        'SEARCH',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.inkDim,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _onSearch,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.ink,
                          ),
                          decoration: InputDecoration(
                            hintText: 'TRACKS, ARTISTS, YOUTUBE...',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: theme.inkDim,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_isSearching)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.accentTeal,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => _onSearch(_searchController.text),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.accentCoral,
                              border: Border.all(color: theme.ink, width: 1),
                            ),
                            child: const Text(
                              'GO',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'SAVED', 'LO-FI', '8-BIT', 'SYNTH'].map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.accentTeal : theme.background,
                            border: Border.all(color: theme.ink, width: 1.5),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? const Color(0xFF0C1626) : theme.ink,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final track = filtered[index];
                final isCurrent = track.id == currentTrack.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? theme.card : theme.panel,
                    border: Border.all(
                      color: isCurrent ? theme.accentTeal : theme.ink,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.ink,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.background,
                          border: Border.all(color: theme.ink, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            track.genreTag.length > 3
                                ? track.genreTag.substring(0, 3)
                                : track.genreTag,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.accentTeal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.ink,
                                    ),
                                  ),
                                ),
                                if (isCurrent && playerService.isPlaying) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '|||',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.accentTeal,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                color: theme.inkDim,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.background,
                                    border: Border.all(color: theme.ink, width: 1),
                                  ),
                                  child: Text(
                                    track.genreTag,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 7,
                                      color: theme.accentTeal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: theme.background,
                                    border: Border.all(color: theme.ink, width: 1),
                                  ),
                                  child: Text(
                                    track.isOffline ? 'SAVED' : 'STREAM',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 7,
                                      color: track.isOffline
                                          ? theme.accentYellow
                                          : theme.inkDim,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDuration(track.duration),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.inkDim,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RetroButton(
                            label: (isCurrent && playerService.isPlaying) ? 'PAUSE' : 'PLAY',
                            theme: theme,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            backgroundColor: theme.accentCoral,
                            textColor: Colors.white,
                            onTap: () {
                              if (isCurrent) {
                                playerService.togglePlayPause();
                              } else {
                                playerService.playTrack(track);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentTrack.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.ink,
                        ),
                      ),
                      Text(
                        currentTrack.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8,
                          color: theme.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    RetroButton(
                      label: playerService.isPlaying ? 'PAUSE' : 'PLAY',
                      theme: theme,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      backgroundColor: theme.accentCoral,
                      textColor: Colors.white,
                      onTap: () => playerService.togglePlayPause(),
                    ),
                    const SizedBox(width: 6),
                    RetroButton(
                      label: 'OPEN',
                      theme: theme,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      backgroundColor: theme.accentTeal,
                      textColor: const Color(0xFF0C1626),
                      onTap: widget.onOpenPlayer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
