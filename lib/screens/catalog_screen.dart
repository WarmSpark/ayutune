import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/innertube_service.dart';
import '../theme/retro_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_thumbnail.dart';

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

  List<Track> _catalogTracks = [];
  List<Track> _searchResults = [];
  String _selectedCategory = 'ALL';
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _catalogTracks = _innerTube.getDefaultTracks();
  }

  void _onSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _innerTube.searchTracks(trimmed);
    setState(() {
      _searchResults = results;
      _hasSearched = true;
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _isSearching = false;
    });
  }

  List<Track> _getFilteredCatalog() {
    if (_selectedCategory == 'ALL') return _catalogTracks;
    if (_selectedCategory == 'SAVED') {
      return _catalogTracks.where((t) => t.isOffline).toList();
    }
    return _catalogTracks.where((t) => t.genreTag == _selectedCategory).toList();
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

    return Column(
      children: [
        _buildTopControls(theme),
        Expanded(
          child: _isSearching
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.accentTeal,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'QUERYING INNERTUBE DATABASE...',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                )
              : _hasSearched
                  ? _buildSearchResultsView(theme, playerService, currentTrack)
                  : _buildSpotifyBrowseView(theme, playerService, currentTrack),
        ),
        _buildMiniPlayer(theme, playerService, currentTrack),
      ],
    );
  }

  Widget _buildTopControls(RetroThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border(
          bottom: BorderSide(color: theme.ink, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      hintText: 'SONGS, ARTISTS, YOUTUBE...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: theme.inkDim,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        'CLR',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: theme.inkDim,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () => _onSearch(_searchController.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      if (_hasSearched) {
                        _hasSearched = false;
                        _searchController.clear();
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
  }

  Widget _buildSearchResultsView(
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'NO TRACKS FOUND',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: theme.inkDim,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SEARCH RESULTS (${_searchResults.length})',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.accentTeal,
                  ),
                ),
                GestureDetector(
                  onTap: _clearSearch,
                  child: Text(
                    '[SHOW HOME]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.accentCoral,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final track = _searchResults[index - 1];
        return _buildTrackListItem(theme, playerService, track, currentTrack);
      },
    );
  }

  Widget _buildSpotifyBrowseView(
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    final filtered = _getFilteredCatalog();
    final recommendedTracks = filtered.take(5).toList();
    final popularTracks = filtered.skip(2).take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('RECOMMENDED FOR TODAY', theme),
          const SizedBox(height: 8),
          _buildHorizontalCarousel(recommendedTracks, theme, playerService, currentTrack),
          const SizedBox(height: 16),
          _buildSectionHeader('START LISTENING', theme),
          const SizedBox(height: 8),
          _buildStartListeningGrid(filtered.take(6).toList(), theme, playerService, currentTrack),
          const SizedBox(height: 16),
          _buildSectionHeader('POPULAR ALBUMS AND SINGLES', theme),
          const SizedBox(height: 8),
          _buildHorizontalCarousel(popularTracks, theme, playerService, currentTrack),
          const SizedBox(height: 16),
          _buildSectionHeader('CASSETTE ARCHIVE', theme),
          const SizedBox(height: 8),
          Column(
            children: filtered.map((track) {
              return _buildTrackListItem(theme, playerService, track, currentTrack);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, RetroThemeData theme) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 12,
          color: theme.accentTeal,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: theme.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCarousel(
    List<Track> tracks,
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final isPlayingThis = track.id == currentTrack.id && playerService.isPlaying;

          return GestureDetector(
            onTap: () => playerService.playTrack(track),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: theme.panel,
                border: Border.all(
                  color: isPlayingThis ? theme.accentTeal : theme.ink,
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
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RetroThumbnail(
                    url: track.thumbnailUrl,
                    width: 118,
                    height: 118,
                    theme: theme,
                    badgeText: track.genreTag,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPlayingThis ? theme.accentTeal : theme.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: theme.inkDim,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(track.duration),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8,
                          color: theme.inkDim,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isPlayingThis ? theme.accentTeal : theme.accentCoral,
                          border: Border.all(color: theme.ink, width: 1),
                        ),
                        child: Text(
                          isPlayingThis ? 'PLAYING' : 'PLAY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: isPlayingThis ? const Color(0xFF0C1626) : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartListeningGrid(
    List<Track> tracks,
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tracks.map((track) {
            final isCurrent = track.id == currentTrack.id;
            return GestureDetector(
              onTap: () => playerService.playTrack(track),
              child: Container(
                width: itemWidth,
                height: 52,
                decoration: BoxDecoration(
                  color: isCurrent ? theme.card : theme.panel,
                  border: Border.all(
                    color: isCurrent ? theme.accentTeal : theme.ink,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.ink,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    RetroThumbnail(
                      url: track.thumbnailUrl,
                      width: 42,
                      height: 42,
                      theme: theme,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? theme.accentTeal : theme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 7,
                              color: theme.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTrackListItem(
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track track,
    Track currentTrack,
  ) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          RetroThumbnail(
            url: track.thumbnailUrl,
            width: 44,
            height: 44,
            theme: theme,
          ),
          const SizedBox(width: 8),
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? theme.accentTeal : theme.ink,
                        ),
                      ),
                    ),
                    if (isCurrent && playerService.isPlaying) ...[
                      const SizedBox(width: 4),
                      Text(
                        '|||',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
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
                    fontSize: 8,
                    color: theme.inkDim,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.background,
                        border: Border.all(color: theme.ink, width: 1),
                      ),
                      child: Text(
                        track.isOffline ? 'SAVED' : 'STREAM',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 7,
                          color: track.isOffline ? theme.accentYellow : theme.inkDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(track.duration),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.inkDim,
                ),
              ),
              const SizedBox(height: 4),
              RetroButton(
                label: (isCurrent && playerService.isPlaying) ? 'PAUSE' : 'PLAY',
                theme: theme,
                fontSize: 8,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
  }

  Widget _buildMiniPlayer(
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border(
          top: BorderSide(color: theme.ink, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RetroThumbnail(
            url: currentTrack.thumbnailUrl,
            width: 36,
            height: 36,
            theme: theme,
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 6),
          Row(
            children: [
              RetroButton(
                label: playerService.isPlaying ? 'PAUSE' : 'PLAY',
                theme: theme,
                fontSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                onTap: () => playerService.togglePlayPause(),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: 'OPEN',
                theme: theme,
                fontSize: 9,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: theme.accentTeal,
                textColor: const Color(0xFF0C1626),
                onTap: widget.onOpenPlayer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
