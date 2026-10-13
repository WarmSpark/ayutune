import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyric_line.dart';
import '../models/track.dart';

class SoundCloudService {
  static final SoundCloudService _instance = SoundCloudService._internal();
  factory SoundCloudService() => _instance;
  SoundCloudService._internal();

  String? _cachedClientId;
  DateTime? _clientIdLastFetched;
  static const String _fallbackClientId = 'O4KAW11rMMnH5modEfDHOdzmnuvsck9X';

  Future<String> getClientId() async {
    if (_cachedClientId != null &&
        _clientIdLastFetched != null &&
        DateTime.now().difference(_clientIdLastFetched!).inHours < 12) {
      return _cachedClientId!;
    }

    try {
      final res = await http.get(
        Uri.parse('https://soundcloud.com'),
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final matches = RegExp(r'src="(https://a-v2\.sndcdn\.com/assets/[^"]+\.js)"')
            .allMatches(res.body)
            .map((m) => m.group(1)!)
            .toList();

        for (final scriptUrl in matches.reversed.take(4)) {
          try {
            final scriptRes = await http.get(
              Uri.parse(scriptUrl),
              headers: {'User-Agent': 'Mozilla/5.0'},
            ).timeout(const Duration(seconds: 3));

            if (scriptRes.statusCode == 200) {
              final idMatch = RegExp(r'client_id[:=]"?([a-zA-Z0-9]{32})"?')
                  .firstMatch(scriptRes.body);
              if (idMatch != null) {
                _cachedClientId = idMatch.group(1);
                _clientIdLastFetched = DateTime.now();
                return _cachedClientId!;
              }
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    _cachedClientId = _fallbackClientId;
    _clientIdLastFetched = DateTime.now();
    return _cachedClientId!;
  }

  Future<List<Track>> searchTracks(String query, {int limit = 10}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final clientId = await getClientId();
      final uri = Uri.parse(
          'https://api-v2.soundcloud.com/search/tracks?q=${Uri.encodeComponent(cleanQuery)}&client_id=$clientId&limit=$limit');

      final res = await http.get(
        uri,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final collection = (data['collection'] as List?) ?? [];
      final List<Track> tracks = [];

      for (final item in collection) {
        final id = item['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final rawTitle = item['title']?.toString() ?? 'UNTITLED';
        final user = item['user'] as Map<String, dynamic>?;
        final rawArtist = user?['username']?.toString() ?? 'SOUNDCLOUD ARTIST';

        final media = item['media'] as Map<String, dynamic>?;
        final transcodings = (media?['transcodings'] as List?) ?? [];
        if (transcodings.isEmpty) continue;

        String? chosenUrl;
        for (final t in transcodings) {
          final format = t['format'] as Map<String, dynamic>?;
          final protocol = format?['protocol']?.toString();
          if (protocol == 'progressive') {
            chosenUrl = t['url']?.toString();
            break;
          }
        }
        chosenUrl ??= transcodings.first['url']?.toString();
        if (chosenUrl == null || chosenUrl.isEmpty) continue;

        var artwork = item['artwork_url']?.toString();
        if (artwork != null && artwork.isNotEmpty) {
          artwork = artwork.replaceAll('-large.', '-t500x500.');
        } else {
          final avatar = user?['avatar_url']?.toString();
          artwork = avatar?.replaceAll('-large.', '-t500x500.');
        }

        final durationMs = int.tryParse(item['duration']?.toString() ?? '180000') ?? 180000;
        final durationSecs = (durationMs / 1000).round();

        final cleanTitle = _cleanTrackTitle(rawTitle).toUpperCase();
        final cleanArtist = _cleanArtistName(rawArtist).toUpperCase();

        tracks.add(
          Track(
            id: 'sc_$id',
            title: cleanTitle,
            artist: cleanArtist,
            duration: Duration(seconds: durationSecs > 0 ? durationSecs : 180),
            genreTag: 'INDIE',
            audioUrl: 'sc:$chosenUrl',
            thumbnailUrl: artwork,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: Duration.zero, text: 'PLAYING: $cleanTitle'),
              LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $cleanArtist'),
              const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
            ],
          ),
        );
      }
      return tracks;
    } catch (_) {
      return [];
    }
  }

  Future<String?> resolveStreamUrl(String scAudioUrl) async {
    final cleanUrl = scAudioUrl.startsWith('sc:')
        ? scAudioUrl.substring(3)
        : scAudioUrl;

    if (!cleanUrl.startsWith('http')) return null;

    try {
      final clientId = await getClientId();
      final streamEndpoint = Uri.parse('$cleanUrl?client_id=$clientId');
      final res = await http.get(
        streamEndpoint,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final streamUrl = data['url']?.toString();
        if (streamUrl != null && streamUrl.startsWith('http')) {
          return streamUrl;
        }
      }
    } catch (_) {}
    return null;
  }

  String _cleanTrackTitle(String title) {
    return title
        .replaceAll(RegExp(r'\(.*?official.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[.*?official.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(.*?video.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[.*?video.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(.*?audio.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[.*?audio.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(.*?lyrics.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[.*?lyrics.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _cleanArtistName(String artist) {
    return artist.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
