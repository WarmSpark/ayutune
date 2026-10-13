import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lyric_line.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import 'innertube_service.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_playlists_cache');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _playlists.clear();
        for (final item in list) {
          final tracksRaw = (item['tracks'] as List?) ?? [];
          final List<Track> tracks = [];
          for (final t in tracksRaw) {
            final lyricsRaw = (t['lyrics'] as List?) ?? [];
            final lyrics = lyricsRaw.map((l) {
              return LyricLine(
                timestamp: Duration(milliseconds: l['ms'] ?? 0),
                text: l['text'] ?? '',
              );
            }).toList();

            tracks.add(
              Track(
                id: t['id'] ?? '',
                title: t['title'] ?? '',
                artist: t['artist'] ?? '',
                duration: Duration(seconds: t['duration'] ?? 180),
                genreTag: t['genreTag'] ?? 'TAPE',
                audioUrl: t['audioUrl'],
                thumbnailUrl: t['thumbnailUrl'],
                isOffline: t['isOffline'] ?? false,
                lyrics: lyrics,
              ),
            );
          }

          _playlists.add(
            Playlist(
              id: item['id'] ?? '',
              name: item['name'] ?? 'UNTITLED TAPE',
              tracks: tracks,
              createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
            ),
          );
        }
      } catch (_) {}
    }
    _backgroundResolveThumbnails();
  }

  Future<void> _backgroundResolveThumbnails() async {
    bool hasUpdates = false;
    for (int pIdx = 0; pIdx < _playlists.length; pIdx++) {
      final playlist = _playlists[pIdx];
      final updatedTracks = <Track>[];
      bool playlistUpdated = false;
      for (final track in playlist.tracks) {
        if (track.thumbnailUrl == null || track.thumbnailUrl!.isEmpty) {
          final thumb = await InnerTubeService().resolveThumbnail(track.title, track.artist);
          if (thumb != null && thumb.isNotEmpty) {
            updatedTracks.add(track.copyWith(thumbnailUrl: thumb));
            playlistUpdated = true;
            continue;
          }
        }
        updatedTracks.add(track);
      }
      if (playlistUpdated) {
        _playlists[pIdx] = playlist.copyWith(tracks: updatedTracks);
        hasUpdates = true;
      }
    }
    if (hasUpdates) {
      await _persist();
    }
  }

  Future<Playlist> createPlaylist(String name) async {
    final trimmedName = name.trim().isEmpty ? 'NEW RETRO TAPE' : name.trim().toUpperCase();
    final newPlaylist = Playlist(
      id: 'tape_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      tracks: [],
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, newPlaylist);
    await _persist();
    return newPlaylist;
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final current = _playlists[index];
      if (!current.tracks.any((t) => t.id == track.id)) {
        final updatedTracks = List<Track>.from(current.tracks)..add(track);
        _playlists[index] = current.copyWith(tracks: updatedTracks);
        await _persist();
      }
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final current = _playlists[index];
      final updatedTracks = current.tracks.where((t) => t.id != trackId).toList();
      _playlists[index] = current.copyWith(tracks: updatedTracks);
      await _persist();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _persist();
  }

  Future<Playlist?> importSpotifyPlaylist(String url) async {
    try {
      final match = RegExp(r'playlist[/:]([a-zA-Z0-9]+)').firstMatch(url.trim());
      if (match == null) return null;

      final playlistId = match.group(1);
      final embedUri = Uri.parse('https://open.spotify.com/embed/playlist/$playlistId');
      final res = await http.get(
        embedUri,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final html = res.body;
      final dataMatch = RegExp(r'<script id="__NEXT_DATA__" type="application/json">({.*?})</script>').firstMatch(html);
      if (dataMatch == null) return null;

      final jsonStr = dataMatch.group(1)!;
      final data = jsonDecode(jsonStr);
      final entity = data['props']?['pageProps']?['state']?['data']?['entity'];
      if (entity == null) return null;

      final playlistName = (entity['name']?.toString() ?? 'SPOTIFY MIXTAPE').toUpperCase();
      final trackList = (entity['trackList'] as List?) ?? [];

      final List<Track> importedTracks = [];
      final futures = <Future<Track>>[];
      for (int i = 0; i < trackList.length; i++) {
        final t = trackList[i];
        final title = (t['title']?.toString() ?? 'UNTITLED').toUpperCase();
        final artist = (t['subtitle']?.toString() ?? 'UNKNOWN').toUpperCase();
        final durMs = t['duration'] as int? ?? 180000;
        final initialThumb = t['imageUrl']?.toString();

        futures.add(() async {
          String? resolvedThumb = initialThumb;
          if (resolvedThumb == null || resolvedThumb.isEmpty) {
            resolvedThumb = await InnerTubeService().resolveThumbnail(title, artist);
          }
          return Track(
            id: 'sp_${playlistId}_$i',
            title: title,
            artist: artist,
            duration: Duration(milliseconds: durMs),
            genreTag: 'SPOTIFY',
            thumbnailUrl: resolvedThumb,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: Duration.zero, text: 'PLAYING: $title'),
              LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $artist'),
              const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
            ],
          );
        }());
      }

      final resolvedList = await Future.wait(futures);
      importedTracks.addAll(resolvedList);

      final importedPlaylist = Playlist(
        id: 'tape_sp_${DateTime.now().millisecondsSinceEpoch}',
        name: playlistName,
        tracks: importedTracks,
        createdAt: DateTime.now(),
      );

      _playlists.insert(0, importedPlaylist);
      await _persist();
      return importedPlaylist;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _playlists.map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'createdAt': p.createdAt.toIso8601String(),
        'tracks': p.tracks.map((t) {
          return {
            'id': t.id,
            'title': t.title,
            'artist': t.artist,
            'duration': t.duration.inSeconds,
            'genreTag': t.genreTag,
            'audioUrl': t.audioUrl,
            'thumbnailUrl': t.thumbnailUrl,
            'isOffline': t.isOffline,
            'lyrics': t.lyrics.map((l) {
              return {
                'ms': l.timestamp.inMilliseconds,
                'text': l.text,
              };
            }).toList(),
          };
        }).toList(),
      };
    }).toList();

    await prefs.setString('saved_playlists_cache', jsonEncode(list));
  }
}
