import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/innertube_service.dart';
import '../services/offline_service.dart';
import '../services/playlist_service.dart';
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
  Playlist? _expandedPlaylist;

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
      return OfflineService().offlineTracks;
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
                        'QUERYING 320KBPS RETRO DATABASE...',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                )
              : _hasSearched
                  ? _buildSearchResultsList(theme, playerService)
                  : _selectedCategory == 'TAPES'
                      ? _buildTapesList(theme, playerService)
                      : _buildDefaultCatalogList(theme, playerService),
        ),
        _buildBottomPlayer(theme, playerService, currentTrack),
      ],
    );
  }

  Widget _buildTopControls(RetroThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2),
      ),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.ink, width: 2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.ink,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 6),
                        child: Text(
                          'SEARCH',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.inkDim,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: 'SONG / ARTIST...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.inkDim.withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: _clearSearch,
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  'CLR',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.inkDim,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: _onSearch,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: 'GO',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                backgroundColor: theme.accentTeal,
                textColor: const Color(0xFF0C1626),
                onTap: () => _onSearch(_searchController.text),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: '+ SPOTIFY',
                theme: theme,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                onTap: () => _showSpotifyImportDialog(theme),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryChip('ALL', theme),
                const SizedBox(width: 6),
                _categoryChip('SAVED', theme),
                const SizedBox(width: 6),
                _categoryChip('TAPES', theme),
                const SizedBox(width: 6),
                _categoryChip('LO-FI', theme),
                const SizedBox(width: 6),
                _categoryChip('8-BIT', theme),
                const SizedBox(width: 6),
                _categoryChip('SYNTH', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, RetroThemeData theme) {
    final isSelected = _selectedCategory == label && !_hasSearched;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _hasSearched = false;
          _searchResults = [];
          _expandedPlaylist = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentTeal : theme.background,
          border: Border.all(
            color: isSelected ? theme.ink : theme.inkDim,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF0C1626) : theme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(RetroThemeData theme, AudioPlayerService playerService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SEARCH RESULTS (${_searchResults.length})',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.accentCoral,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Text(
                    'NO RESULTS FOUND FOR "${_searchController.text.toUpperCase()}"',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.inkDim,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final track = _searchResults[index];
                    final isPlayingThis = playerService.currentTrack.id == track.id;
                    return _buildTrackCard(track, isPlayingThis, theme, playerService);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTapesList(RetroThemeData theme, AudioPlayerService playerService) {
    final playlists = PlaylistService().playlists;

    if (_expandedPlaylist != null) {
      final p = _expandedPlaylist!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _expandedPlaylist = null),
                      child: Text(
                        '< ALL TAPES',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.accentTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '| ${p.name}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.ink,
                      ),
                    ),
                  ],
                ),
                RetroButton(
                  label: 'PLAY ALL',
                  theme: theme,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: theme.accentCoral,
                  textColor: Colors.white,
                  onTap: () {
                    if (p.tracks.isNotEmpty) {
                      playerService.playQueue(p.tracks, startIndex: 0);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: p.tracks.isEmpty
                ? Center(
                    child: Text(
                      'THIS TAPE IS EMPTY',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: theme.inkDim,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: p.tracks.length,
                    itemBuilder: (context, idx) {
                      final track = p.tracks[idx];
                      final isPlayingThis = playerService.currentTrack.id == track.id;
                      return _buildTrackCard(track, isPlayingThis, theme, playerService);
                    },
                  ),
          ),
        ],
      );
    }

    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NO RETRO TAPES CREATED YET',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.inkDim,
              ),
            ),
            const SizedBox(height: 12),
            RetroButton(
              label: '+ IMPORT SPOTIFY PLAYLIST',
              theme: theme,
              fontSize: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              backgroundColor: theme.accentCoral,
              textColor: Colors.white,
              onTap: () => _showSpotifyImportDialog(theme),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final p = playlists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.card,
            border: Border.all(color: theme.ink, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.background,
                  border: Border.all(color: theme.accentTeal, width: 2),
                ),
                child: Icon(Icons.album, size: 26, color: theme.accentTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.tracks.length} TRACKS | RETRO MIXTAPE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: theme.inkDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: 'VIEW',
                theme: theme,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () => setState(() => _expandedPlaylist = p),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: 'PLAY',
                theme: theme,
                fontSize: 10,
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () {
                  if (p.tracks.isNotEmpty) {
                    playerService.playQueue(p.tracks, startIndex: 0);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultCatalogList(RetroThemeData theme, AudioPlayerService playerService) {
    final filtered = _getFilteredCatalog();

    if (_selectedCategory == 'SAVED' && filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NO OFFLINE TAPES SAVED YET',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.inkDim,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TAP "SAVE TAPE" ON ANY TRACK TO DOWNLOAD',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: theme.inkDim.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final track = filtered[index];
        final isPlayingThis = playerService.currentTrack.id == track.id;
        return _buildTrackCard(track, isPlayingThis, theme, playerService);
      },
    );
  }

  Widget _buildTrackCard(
    Track track,
    bool isPlayingThis,
    RetroThemeData theme,
    AudioPlayerService playerService,
  ) {
    final isOffline = track.isOffline || OfflineService().isDownloaded(track.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPlayingThis ? theme.panel : theme.card,
        border: Border.all(
          color: isPlayingThis ? theme.accentTeal : theme.ink,
          width: isPlayingThis ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          RetroThumbnail(
            url: track.thumbnailUrl,
            theme: theme,
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPlayingThis ? theme.accentTeal : theme.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.inkDim,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.background,
                        border: Border.all(color: theme.inkDim, width: 1),
                      ),
                      child: Text(
                        track.genreTag,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: theme.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isOffline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentTeal,
                          border: Border.all(color: theme.ink, width: 1),
                        ),
                        child: const Text(
                          'OFFLINE TAPE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C1626),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.background,
                          border: Border.all(color: theme.inkDim, width: 1),
                        ),
                        child: Text(
                          '320KBPS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: theme.accentTeal,
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
              if (isPlayingThis && playerService.isPlaying)
                Text(
                  '|||',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.accentTeal,
                  ),
                )
              else
                Text(
                  _formatDuration(track.duration),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.inkDim,
                  ),
                ),
              const SizedBox(height: 6),
              RetroButton(
                label: (isPlayingThis && playerService.isPlaying) ? 'PAUSE' : 'PLAY',
                theme: theme,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                backgroundColor: isPlayingThis ? theme.accentCoral : theme.background,
                textColor: isPlayingThis ? Colors.white : theme.ink,
                onTap: () {
                  if (isPlayingThis) {
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

  Widget _buildBottomPlayer(
    RetroThemeData theme,
    AudioPlayerService playerService,
    Track currentTrack,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border(
          top: BorderSide(color: theme.ink, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          RetroThumbnail(
            url: currentTrack.thumbnailUrl,
            theme: theme,
            width: 44,
            height: 44,
          ),
          const SizedBox(width: 10),
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
                    fontSize: 11,
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
                    fontSize: 9,
                    color: theme.inkDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              RetroButton(
                label: playerService.isPlaying ? 'PAUSE' : 'PLAY',
                theme: theme,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                onTap: () => playerService.togglePlayPause(),
              ),
              const SizedBox(width: 6),
              RetroButton(
                label: 'OPEN',
                theme: theme,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  void _showSpotifyImportDialog(RetroThemeData theme) {
    final textController = TextEditingController();
    bool isImporting = false;

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
                'IMPORT SPOTIFY PLAYLIST',
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
                    Text(
                      'PASTE ANY PUBLIC SPOTIFY PLAYLIST LINK. AYUTUNE WILL PARSE ALL TRACKS AND MAP THEM TO 320KBPS RETRO AUDIO.',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: theme.inkDim,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://open.spotify.com/playlist/...',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: theme.inkDim.withValues(alpha: 0.6),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.ink, width: 1.5),
                        ),
                      ),
                    ),
                    if (isImporting) ...[
                      const SizedBox(height: 14),
                      CircularProgressIndicator(color: theme.accentTeal, strokeWidth: 2.5),
                      const SizedBox(height: 8),
                      Text(
                        'PARSING SPOTIFY EMBED & MAPPING TRACKS...',
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
              ),
              actions: [
                TextButton(
                  onPressed: isImporting ? null : () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: theme.inkDim,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isImporting
                      ? null
                      : () async {
                          final url = textController.text.trim();
                          if (url.isEmpty) return;
                          setDialogState(() => isImporting = true);
                          final playlist = await PlaylistService().importSpotifyPlaylist(url);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (playlist != null) {
                              setState(() {
                                _selectedCategory = 'TAPES';
                                _hasSearched = false;
                                _expandedPlaylist = playlist;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: theme.panel,
                                  content: Text(
                                    'IMPORTED TAPE: ${playlist.name} (${playlist.tracks.length} TRACKS)',
                                    style: TextStyle(fontFamily: 'monospace', color: theme.accentTeal),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: theme.panel,
                                  content: Text(
                                    'FAILED TO PARSE SPOTIFY PLAYLIST. CHECK URL.',
                                    style: TextStyle(fontFamily: 'monospace', color: theme.accentCoral),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: Text(
                    'IMPORT TAPE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: theme.accentTeal,
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
