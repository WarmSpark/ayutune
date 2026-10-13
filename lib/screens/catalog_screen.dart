import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hit_album.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/innertube_service.dart';
import '../services/offline_service.dart';
import '../services/playlist_service.dart';
import '../theme/retro_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/audio_listener_dialog.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_theme_dialog.dart';
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

  List<Track> _top10Tracks = [];
  List<HitAlbum> _hitAlbums = [];
  List<Track> _globalHits = [];
  List<Track> _hindiHits = [];

  List<Track> _searchResults = [];
  String _selectedCategory = 'ALL';
  bool _isSearching = false;
  bool _hasSearched = false;
  Playlist? _expandedPlaylist;

  @override
  void initState() {
    super.initState();
    _top10Tracks = _innerTube.getTop10WeeklyTracks();
    _hitAlbums = _innerTube.getHitAlbums();
    _globalHits = _innerTube.getGlobalTopHits();
    _hindiHits = _innerTube.getTrendingHindiHits();
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
    if (!mounted) return;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;
    final playerService = Provider.of<AudioPlayerService>(context);
    final currentTrack = playerService.currentTrack;

    return Column(
      children: [
        _buildTopControls(theme, themeProvider),
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
                  ? _buildSearchResultsGrid(theme, playerService)
                  : _selectedCategory == 'SAVED'
                      ? _buildSavedList(theme, playerService)
                      : _selectedCategory == 'TAPES'
                          ? _buildTapesList(theme, playerService)
                          : _selectedCategory == 'ALBUMS'
                              ? _buildAlbumsGrid(theme, playerService)
                              : _buildNetflixCatalogView(theme, playerService),
        ),
        _buildBottomPlayer(theme, playerService, currentTrack),
      ],
    );
  }

  Widget _buildTopControls(RetroThemeData theme, ThemeProvider themeProvider) {
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
          _buildPaletteStrip(theme, themeProvider),
          const SizedBox(height: 6),
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
                      hintText: 'SONG / ARTIST / ALBUM...',
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
              const SizedBox(width: 4),
              RetroButton(
                label: 'GO',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                backgroundColor: theme.accentTeal,
                textColor: const Color(0xFF0C1626),
                onTap: () => _onSearch(_searchController.text),
              ),
              const SizedBox(width: 4),
              RetroButton(
                label: 'LISTEN',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                backgroundColor: theme.accentYellow,
                textColor: const Color(0xFF0C1626),
                onTap: () => _openAudioListener(theme),
              ),
              const SizedBox(width: 4),
              RetroButton(
                label: '+ SPOTIFY',
                theme: theme,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                backgroundColor: theme.accentCoral,
                textColor: Colors.white,
                onTap: () => _showSpotifyImportDialog(theme),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _categoryChip('ALL', theme),
              _categoryChip('SAVED', theme),
              _categoryChip('TAPES', theme),
              _categoryChip('ALBUMS', theme),
            ],
          ),
        ],
      ),
    );
  }

  void _openAudioListener(RetroThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AudioListenerDialog(theme: theme),
    );
  }

  Widget _buildPaletteStrip(RetroThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: theme.background,
        border: Border.all(color: theme.ink, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'PALETTE:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: RetroThemeData.allThemes.map((item) {
                  final isCurrent = item.type == theme.type;
                  return GestureDetector(
                    onTap: () => themeProvider.setTheme(item),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.background,
                        border: Border.all(
                          color: isCurrent ? item.accentTeal : theme.ink,
                          width: isCurrent ? 2.5 : 1.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          RetroButton(
            label: '+ CUSTOM',
            theme: theme,
            fontSize: 9,
            backgroundColor: theme.accentCoral,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            onTap: () => _showThemeCustomDialog(theme, themeProvider),
          ),
        ],
      ),
    );
  }

  void _showThemeCustomDialog(RetroThemeData theme, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => RetroThemeDialog(
        theme: theme,
        themeProvider: themeProvider,
      ),
    );
  }

  Widget _categoryChip(String label, RetroThemeData theme) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _hasSearched = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentCoral : theme.background,
          border: Border.all(color: theme.ink, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : theme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildNetflixCatalogView(RetroThemeData theme, AudioPlayerService playerService) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildHeroBanner(theme, playerService),
        const SizedBox(height: 14),
        _buildShelfHeader('TOP 10 SONGS OF THE WEEK', 'GLOBAL CHART', theme, null),
        const SizedBox(height: 8),
        _buildTop10Shelf(theme, playerService),
        const SizedBox(height: 16),
        _buildShelfHeader('HIT ALBUMS OF ALL TIME', 'FAMOUS DISCOGRAPHY', theme, () {
          setState(() => _selectedCategory = 'ALBUMS');
        }),
        const SizedBox(height: 8),
        _buildAlbumsShelf(theme, playerService),
        const SizedBox(height: 16),
        _buildShelfHeader('GLOBAL BILLBOARD HITS', 'HOT 100 TRENDING', theme, null),
        const SizedBox(height: 8),
        _buildTrackShelf(_globalHits, theme, playerService),
        const SizedBox(height: 16),
        _buildShelfHeader('TRENDING HINDI & BOLLYWOOD HITS', 'DESI TOP CHARTS', theme, null),
        const SizedBox(height: 8),
        _buildTrackShelf(_hindiHits, theme, playerService),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHeroBanner(RetroThemeData theme, AudioPlayerService playerService) {
    if (_top10Tracks.isEmpty) return const SizedBox.shrink();
    final featured = _top10Tracks.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: theme.panel,
        border: Border.all(color: theme.ink, width: 2.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              border: Border.all(color: theme.ink, width: 2),
            ),
            child: RetroThumbnail(
              url: featured.thumbnailUrl,
              width: 110,
              height: 110,
              theme: theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.accentCoral,
                  ),
                  child: const Text(
                    'CHART TOPPER #1',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  featured.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  featured.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.inkDim,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    RetroButton(
                      label: 'PLAY 320K',
                      theme: theme,
                      fontSize: 10,
                      backgroundColor: theme.accentTeal,
                      textColor: const Color(0xFF0C1626),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      onTap: () {
                        playerService.playTrack(featured);
                        widget.onOpenPlayer();
                      },
                    ),
                    const SizedBox(width: 8),
                    RetroButton(
                      label: '+ TAPE',
                      theme: theme,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      onTap: () => _showAddToPlaylistDialog(featured, theme),
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

  Widget _buildShelfHeader(
    String title,
    String tag,
    RetroThemeData theme,
    VoidCallback? onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.panel,
                  border: Border.all(color: theme.accentTeal, width: 1),
                ),
                child: Text(
                  tag,
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
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                '[MORE]',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.accentCoral,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTop10Shelf(RetroThemeData theme, AudioPlayerService playerService) {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _top10Tracks.length,
        itemBuilder: (context, index) {
          final track = _top10Tracks[index];
          final rank = index + 1;

          return Container(
            width: 135,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            child: InkWell(
              onTap: () => playerService.playTrack(track),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 135,
                        height: 125,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.ink, width: 1.5),
                          ),
                        ),
                        child: RetroThumbnail(
                          url: track.thumbnailUrl,
                          width: 135,
                          height: 125,
                          theme: theme,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accentCoral,
                            border: Border.all(color: theme.ink, width: 1.2),
                          ),
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: const Color(0xFF0C1626),
                          child: const Text(
                            '320K',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00F0FF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
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
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(track.duration),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                color: theme.inkDim,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.background,
                                border: Border.all(color: theme.ink, width: 1),
                              ),
                              child: Text(
                                'PLAY',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumsShelf(RetroThemeData theme, AudioPlayerService playerService) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _hitAlbums.length,
        itemBuilder: (context, index) {
          final album = _hitAlbums[index];

          return Container(
            width: 145,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            child: InkWell(
              onTap: () => _showAlbumModal(album, theme, playerService),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 145,
                        height: 135,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.ink, width: 1.5),
                          ),
                        ),
                        child: RetroThumbnail(
                          url: album.thumbnailUrl,
                          width: 145,
                          height: 135,
                          theme: theme,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.background,
                            border: Border.all(color: theme.ink, width: 1),
                          ),
                          child: Text(
                            album.year,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.accentYellow,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: const Color(0xFF0C1626),
                          child: Text(
                            '${album.tracks.length} TRACKS',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00F0FF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          album.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: theme.inkDim,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accentCoral,
                            border: Border.all(color: theme.ink, width: 1),
                          ),
                          child: const Text(
                            'VIEW ALBUM',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackShelf(
    List<Track> tracks,
    RetroThemeData theme,
    AudioPlayerService playerService,
  ) {
    return SizedBox(
      height: 195,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];

          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            child: InkWell(
              onTap: () => playerService.playTrack(track),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 115,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.ink, width: 1.5),
                      ),
                    ),
                    child: RetroThumbnail(
                      url: track.thumbnailUrl,
                      width: 130,
                      height: 115,
                      theme: theme,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.ink,
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
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              track.genreTag,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: theme.accentTeal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.background,
                                border: Border.all(color: theme.ink, width: 1),
                              ),
                              child: Text(
                                'PLAY',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: theme.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumsGrid(RetroThemeData theme, AudioPlayerService playerService) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.74,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _hitAlbums.length,
      itemBuilder: (context, index) {
        final album = _hitAlbums[index];

        return Container(
          decoration: BoxDecoration(
            color: theme.panel,
            border: Border.all(color: theme.ink, width: 2),
          ),
          child: InkWell(
            onTap: () => _showAlbumModal(album, theme, playerService),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 125,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: theme.ink, width: 1.5),
                        ),
                      ),
                      child: RetroThumbnail(
                        url: album.thumbnailUrl,
                        width: double.infinity,
                        height: 125,
                        theme: theme,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.background,
                          border: Border.all(color: theme.ink, width: 1),
                        ),
                        child: Text(
                          album.year,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.accentYellow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          color: theme.inkDim,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RetroButton(
                        label: 'VIEW TRACKS',
                        theme: theme,
                        fontSize: 9,
                        backgroundColor: theme.accentTeal,
                        textColor: const Color(0xFF0C1626),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        onTap: () => _showAlbumModal(album, theme, playerService),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsGrid(RetroThemeData theme, AudioPlayerService playerService) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'NO TRACKS FOUND IN DATABASE',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.inkDim,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: theme.panel,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESULTS (${_searchResults.length})',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.accentCoral,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.76,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final track = _searchResults[index];

              return Container(
                decoration: BoxDecoration(
                  color: theme.panel,
                  border: Border.all(color: theme.ink, width: 2),
                ),
                child: InkWell(
                  onTap: () => playerService.playTrack(track),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.ink, width: 1.5),
                          ),
                        ),
                        child: RetroThumbnail(
                          url: track.thumbnailUrl,
                          width: double.infinity,
                          height: 120,
                          theme: theme,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(track.duration),
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    color: theme.inkDim,
                                  ),
                                ),
                                RetroButton(
                                  label: 'PLAY',
                                  theme: theme,
                                  fontSize: 9,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  onTap: () => playerService.playTrack(track),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavedList(RetroThemeData theme, AudioPlayerService playerService) {
    final savedTracks = OfflineService().offlineTracks;

    if (savedTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NO SAVED TAPES IN STORAGE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.inkDim,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TAP "SAVE TAPE" ON ANY TRACK TO STORE IT',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: theme.inkDim,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: savedTracks.length,
      itemBuilder: (context, index) {
        final track = savedTracks[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.panel,
            border: Border.all(color: theme.ink, width: 2),
          ),
          child: Row(
            children: [
              RetroThumbnail(
                url: track.thumbnailUrl,
                width: 48,
                height: 48,
                theme: theme,
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
                        color: theme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  ],
                ),
              ),
              RetroButton(
                label: 'PLAY',
                theme: theme,
                fontSize: 10,
                backgroundColor: theme.accentTeal,
                textColor: const Color(0xFF0C1626),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onTap: () => playerService.playTrack(track),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTapesList(RetroThemeData theme, AudioPlayerService playerService) {
    final playlists = PlaylistService().playlists;

    if (_expandedPlaylist != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: theme.panel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _expandedPlaylist = null),
                  child: Text(
                    '[<- ALL TAPES]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.accentTeal,
                    ),
                  ),
                ),
                Text(
                  _expandedPlaylist!.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.ink,
                  ),
                ),
                RetroButton(
                  label: 'PLAY ALL',
                  theme: theme,
                  fontSize: 10,
                  backgroundColor: theme.accentTeal,
                  textColor: const Color(0xFF0C1626),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  onTap: () => playerService.playQueue(_expandedPlaylist!.tracks),
                ),
              ],
            ),
          ),
          Expanded(
            child: _expandedPlaylist!.tracks.isEmpty
                ? Center(
                    child: Text(
                      'EMPTY TAPE - ADD SONGS FROM CATALOG',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.inkDim,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _expandedPlaylist!.tracks.length,
                    itemBuilder: (context, index) {
                      final track = _expandedPlaylist!.tracks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.panel,
                          border: Border.all(color: theme.ink, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${(index + 1).toString().padLeft(2, '0')}.',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.inkDim,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.ink,
                                    ),
                                  ),
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
                                ],
                              ),
                            ),
                            RetroButton(
                              label: 'PLAY',
                              theme: theme,
                              fontSize: 9,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              onTap: () => playerService.playQueue(
                                _expandedPlaylist!.tracks,
                                startIndex: index,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SAVED MIXTAPES (${playlists.length})',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.ink,
              ),
            ),
            RetroButton(
              label: '+ CREATE TAPE',
              theme: theme,
              fontSize: 10,
              backgroundColor: theme.accentTeal,
              textColor: const Color(0xFF0C1626),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onTap: () => _showCreateTapeDialog(theme),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...playlists.map((pl) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.panel,
              border: Border.all(color: theme.ink, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.ink, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'TAPE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: theme.accentCoral,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pl.name,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.ink,
                        ),
                      ),
                      Text(
                        '${pl.tracks.length} TRACKS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          color: theme.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
                RetroButton(
                  label: 'OPEN',
                  theme: theme,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onTap: () => setState(() => _expandedPlaylist = pl),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showAlbumModal(HitAlbum album, RetroThemeData theme, AudioPlayerService playerService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.panel,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.ink, width: 2.5),
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.ink, width: 2),
                    ),
                    child: RetroThumbnail(
                      url: album.thumbnailUrl,
                      width: 72,
                      height: 72,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.ink,
                          ),
                        ),
                        Text(
                          album.artist,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: theme.inkDim,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RELEASED: ${album.year}  |  ${album.tracks.length} TRACKS',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      '[X]',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.accentCoral,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RetroButton(
                label: 'PLAY ALL SONGS IN ALBUM',
                theme: theme,
                fontSize: 11,
                backgroundColor: theme.accentTeal,
                textColor: const Color(0xFF0C1626),
                padding: const EdgeInsets.symmetric(vertical: 8),
                onTap: () {
                  Navigator.of(context).pop();
                  playerService.playQueue(album.tracks);
                  widget.onOpenPlayer();
                },
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 1.5,
                color: theme.ink,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: album.tracks.length,
                  itemBuilder: (context, idx) {
                    final track = album.tracks[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.background,
                        border: Border.all(color: theme.ink, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${(idx + 1).toString().padLeft(2, '0')}.',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.accentCoral,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.ink,
                                  ),
                                ),
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
                              ],
                            ),
                          ),
                          RetroButton(
                            label: 'PLAY',
                            theme: theme,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            onTap: () {
                              Navigator.of(context).pop();
                              playerService.playQueue(album.tracks, startIndex: idx);
                              widget.onOpenPlayer();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTapeDialog(RetroThemeData theme) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: theme.ink, width: 2.5),
          ),
          title: Text(
            'NEW MIXTAPE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.ink,
            ),
          ),
          content: TextField(
            controller: textController,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: theme.ink,
            ),
            decoration: InputDecoration(
              hintText: 'MIXTAPE NAME...',
              hintStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: theme.inkDim,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.ink, width: 1.5),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.accentTeal, width: 2),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          actions: [
            RetroButton(
              label: 'CANCEL',
              theme: theme,
              fontSize: 10,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onTap: () => Navigator.of(context).pop(),
            ),
            RetroButton(
              label: 'CREATE',
              theme: theme,
              fontSize: 10,
              backgroundColor: theme.accentTeal,
              textColor: const Color(0xFF0C1626),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onTap: () {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  PlaylistService().createPlaylist(name);
                  setState(() {});
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddToPlaylistDialog(Track track, RetroThemeData theme) {
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
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: theme.ink, width: 2.5),
              ),
              title: Text(
                'ADD TO MIXTAPE',
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
                        hintText: 'NEW TAPE NAME...',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.inkDim,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add, color: theme.accentTeal),
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isNotEmpty) {
                              PlaylistService().createPlaylist(name);
                              textController.clear();
                              setDialogState(() {});
                            }
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.ink, width: 1.5),
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.accentTeal, width: 2),
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlists.length,
                        itemBuilder: (context, idx) {
                          final pl = playlists[idx];
                          final hasTrack = pl.tracks.any((t) => t.id == track.id);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              pl.name,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.ink,
                              ),
                            ),
                            subtitle: Text(
                              '${pl.tracks.length} tracks',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: theme.inkDim,
                              ),
                            ),
                            trailing: RetroButton(
                              label: hasTrack ? 'REMOVE' : 'ADD',
                              theme: theme,
                              fontSize: 9,
                              backgroundColor: hasTrack ? theme.accentCoral : theme.accentTeal,
                              textColor: hasTrack ? Colors.white : const Color(0xFF0C1626),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              onTap: () {
                                if (hasTrack) {
                                  PlaylistService().removeTrackFromPlaylist(pl.id, track.id);
                                } else {
                                  PlaylistService().addTrackToPlaylist(pl.id, track);
                                }
                                setDialogState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                RetroButton(
                  label: 'DONE',
                  theme: theme,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
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
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: theme.ink, width: 2.5),
              ),
              title: Text(
                'SPOTIFY PLAYLIST IMPORT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.ink,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASTE ANY PUBLIC SPOTIFY PLAYLIST LINK',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: theme.inkDim,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.ink, width: 1.5),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.accentTeal, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                  if (isImporting) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.accentTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PARSING SPOTIFY METADATA...',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: theme.accentTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                RetroButton(
                  label: 'CANCEL',
                  theme: theme,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onTap: () => Navigator.of(context).pop(),
                ),
                RetroButton(
                  label: 'IMPORT TAPE',
                  theme: theme,
                  fontSize: 10,
                  backgroundColor: theme.accentTeal,
                  textColor: const Color(0xFF0C1626),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onTap: () {
                    if (isImporting) return;
                    final url = textController.text.trim();
                    if (url.isEmpty) return;

                    setDialogState(() => isImporting = true);
                    PlaylistService().importSpotifyPlaylist(url).then((playlist) {
                      if (context.mounted) {
                        setDialogState(() => isImporting = false);
                        Navigator.of(context).pop();
                        if (playlist != null) {
                              setState(() {
                                _selectedCategory = 'TAPES';
                                _expandedPlaylist = playlist;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: theme.panel,
                                  content: Text(
                                    'IMPORTED ${playlist.tracks.length} TRACKS INTO "${playlist.name}"',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      color: theme.accentTeal,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        });
                      },
                    ),
              ],
            );
          },
        );
      },
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
            width: 44,
            height: 44,
            theme: theme,
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentTrack.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.inkDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }
}
