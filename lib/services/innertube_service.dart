import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_des/dart_des.dart';
import '../models/lyric_line.dart';
import '../models/track.dart';

class ResolvedStream {
  final String url;
  final int totalBytes;
  final String contentType;

  const ResolvedStream({
    required this.url,
    required this.totalBytes,
    required this.contentType,
  });
}

class InnerTubeService {
  final List<Track> _defaultLibrary = [
    const Track(
      id: 'default_1',
      title: 'MURALS ON CITY WALLS',
      artist: 'THE WIGGLY BAND',
      duration: Duration(minutes: 6, seconds: 12),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(VINYL BEATS ROLLING IN...)'),
        LyricLine(timestamp: Duration(seconds: 10), text: 'SPRAY PAINT DRIPPING ON THE CONCRETE LANE'),
        LyricLine(timestamp: Duration(seconds: 25), text: 'MURALS ON CITY WALLS'),
        LyricLine(timestamp: Duration(seconds: 40), text: 'THEN HE IS PULLING ME IN'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'COLORS DANCING IN THE MORNING LIGHT'),
        LyricLine(timestamp: Duration(seconds: 80), text: 'WALKING PAST THE SHADOWS OF THE NIGHT'),
        LyricLine(timestamp: Duration(seconds: 105), text: 'UNDERNEATH AN UMBRELLA IN BLACK AND WHITE'),
        LyricLine(timestamp: Duration(seconds: 130), text: 'STEP BY STEP DOWN THE VINTAGE STAIRS'),
        LyricLine(timestamp: Duration(seconds: 160), text: 'ELECTRIC ECHOES PLAYING IN THE AIR'),
      ],
    ),
    const Track(
      id: 'default_2',
      title: 'WHEN HE IS PULLING ME IN',
      artist: 'LO-FI UMBRELLA DUO',
      duration: Duration(minutes: 7, seconds: 5),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(CHIPTUNE ACOUSTIC STRUMMING)'),
        LyricLine(timestamp: Duration(seconds: 15), text: 'RAINDROPS TAPPING ON THE PAVEMENT TILES'),
        LyricLine(timestamp: Duration(seconds: 35), text: 'SHARED AN UMBRELLA, WALKED FOR MILES'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'WHEN HE IS PULLING ME IN'),
        LyricLine(timestamp: Duration(seconds: 85), text: 'NEVER LET THE VINTAGE RECORD END'),
        LyricLine(timestamp: Duration(seconds: 120), text: 'TWO SILHOUETTE DREAMS AROUND THE BEND'),
      ],
    ),
    const Track(
      id: 'default_3',
      title: 'RAINY AFTERNOON STAIRS',
      artist: 'PIXEL CADENCE',
      duration: Duration(minutes: 5, seconds: 43),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(SUB-BASS RUMBLE AND TAPE HISS)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'SITTING ON THE COLD STONE STAIR'),
        LyricLine(timestamp: Duration(seconds: 45), text: 'PURPLE SCHOOLBAG, DAMP CHILLY AIR'),
        LyricLine(timestamp: Duration(seconds: 75), text: 'LOOKING FOR AN 8-BIT SILVER LINING'),
        LyricLine(timestamp: Duration(seconds: 110), text: 'WHILE THE CLOCK KEEPS RETRO TIMING'),
      ],
    ),
    const Track(
      id: 'default_4',
      title: '8-BIT COFFEE SHOP',
      artist: 'CHIP-HOP RECORDS',
      duration: Duration(minutes: 5, seconds: 2),
      genreTag: '8-BIT',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(ESPRESSO MACHINE AND GAME BOY ARPEGGIOS)'),
        LyricLine(timestamp: Duration(seconds: 15), text: 'PIXEL ART FOAM ON A WARM MUG CUP'),
        LyricLine(timestamp: Duration(seconds: 40), text: 'REWIND THE TAPE, NEVER GIVING UP'),
        LyricLine(timestamp: Duration(seconds: 70), text: 'DITHERED SUNLIGHT THROUGH THE CAFE GLASS'),
      ],
    ),
    const Track(
      id: 'default_5',
      title: 'MIDNIGHT HIGHWAY 1986',
      artist: 'NEON DRIFT',
      duration: Duration(minutes: 5, seconds: 53),
      genreTag: 'SYNTH',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(ANALOG SYNTH ARPEGGIO PULSE)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'HEADLIGHTS SLICING THROUGH THE COASTAL FOG'),
        LyricLine(timestamp: Duration(seconds: 50), text: 'CASSETTE DECK PLAYING IN A MIDNIGHT LOG'),
        LyricLine(timestamp: Duration(seconds: 90), text: 'TACHOMETER GLOWING NEON GOLD'),
        LyricLine(timestamp: Duration(seconds: 130), text: 'STORIES THAT THE RETRO HIGHWAY TOLD'),
      ],
    ),
    const Track(
      id: 'default_6',
      title: 'KYOTO PAPER CRANES',
      artist: 'ORIGAMI SOUND',
      duration: Duration(minutes: 6, seconds: 12),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(KOTO PLUCKS AND VINYL RAIN AMBIANCE)'),
        LyricLine(timestamp: Duration(seconds: 25), text: 'FOLDED PAPER WINGS AGAINST THE SKY'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'WATCHING ANCIENT TEMPLE SHADOWS FLY'),
        LyricLine(timestamp: Duration(seconds: 100), text: 'BAMBOO LANTERNS SOFTLY ALIGHT'),
        LyricLine(timestamp: Duration(seconds: 140), text: 'WHISPERS DRIFTING INTO KYOTO NIGHT'),
      ],
    ),
    const Track(
      id: 'default_7',
      title: 'SUBWAY ECHOES',
      artist: 'UNDERGROUND TAPE CLUB',
      duration: Duration(minutes: 7, seconds: 5),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(ELECTRIC TRAIN RUMBLE AND TRACK CLICK)'),
        LyricLine(timestamp: Duration(seconds: 18), text: 'FLUORESCENT BUZZ ALONG PLATFORM FOUR'),
        LyricLine(timestamp: Duration(seconds: 48), text: 'SLIDING METAL ON THE SUBWAY DOOR'),
        LyricLine(timestamp: Duration(seconds: 88), text: 'LOST IN TRANSIT WITH HEADPHONES ON'),
        LyricLine(timestamp: Duration(seconds: 125), text: 'WAITING FOR THE MORNING NEON DAWN'),
      ],
    ),
    const Track(
      id: 'default_8',
      title: 'CRT MIDNIGHT STATIC',
      artist: 'CATHODE GLITCH',
      duration: Duration(minutes: 5, seconds: 43),
      genreTag: '8-BIT',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1520523839898-50712825e617?w=400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(HIGH FREQUENCY HUM AND LO-FI BEAT)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'CHANNEL 3 FLICKERING SNOW AND NOISE'),
        LyricLine(timestamp: Duration(seconds: 55), text: 'NOSTALGIC MEMORIES OF RETRO JOYS'),
        LyricLine(timestamp: Duration(seconds: 95), text: 'CATHODE RAY DREAMS IN VIOLET LIGHT'),
        LyricLine(timestamp: Duration(seconds: 135), text: 'STATIC GLOW KEEPING WATCH TONIGHT'),
      ],
    ),
  ];

  List<Track> getDefaultTracks() => List.unmodifiable(_defaultLibrary);

  String _cleanHtml(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String? _decryptSaavnUrl(String? encryptedUrl) {
    if (encryptedUrl == null || encryptedUrl.isEmpty) return null;
    try {
      final key = utf8.encode('38346591');
      final encryptedBytes = base64.decode(encryptedUrl);
      final des = DES(key: key, mode: DESMode.ECB, paddingType: DESPaddingType.PKCS7);
      final decryptedBytes = des.decrypt(encryptedBytes);
      final raw = utf8.decode(decryptedBytes).trim();
      if (raw.endsWith('_96.mp4')) {
        return raw.replaceAll('_96.mp4', '_320.mp4');
      }
      return raw;
    } catch (_) {
      return null;
    }
  }

  Future<List<Track>> searchTracks(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getDefaultTracks();
    }

    try {
      final uri = Uri.parse(
          'https://www.jiosaavn.com/api.php?__call=search.getResults&q=${Uri.encodeComponent(cleanQuery)}&_format=json&_marker=0&ctx=android&p=1&n=25');
      final response = await http
          .get(uri, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'})
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List?) ?? [];
        final List<Track> tracks = [];

        for (final item in results) {
          final id = item['id']?.toString() ?? '';
          if (id.isEmpty) continue;

          final title = _cleanHtml(item['song']?.toString() ?? item['title']?.toString() ?? 'UNTITLED').toUpperCase();
          final artist = _cleanHtml(item['primary_artists']?.toString() ?? item['singers']?.toString() ?? 'UNKNOWN').toUpperCase();

          final enc = item['encrypted_media_url']?.toString();
          final preview = item['media_preview_url']?.toString();
          final streamUrl = _decryptSaavnUrl(enc) ?? preview;
          if (streamUrl == null || streamUrl.isEmpty) continue;

          int durSecs = 180;
          final rawDuration = item['duration'];
          if (rawDuration != null) {
            durSecs = int.tryParse(rawDuration.toString()) ?? 180;
          }

          var image = item['image']?.toString() ?? '';
          if (image.contains('150x150')) {
            image = image.replaceAll('150x150', '500x500');
          }

          tracks.add(
            Track(
              id: id,
              title: title,
              artist: artist,
              duration: Duration(seconds: durSecs),
              genreTag: (item['language']?.toString() ?? 'RETRO').toUpperCase(),
              audioUrl: streamUrl,
              thumbnailUrl: image.isNotEmpty ? image : null,
              isOffline: false,
              lyrics: [
                LyricLine(timestamp: Duration.zero, text: 'PLAYING: $title'),
                LyricLine(timestamp: const Duration(seconds: 4), text: 'ARTIST: $artist'),
                const LyricLine(timestamp: Duration(seconds: 8), text: 'SYNCHRONIZING RETRO LYRICS...'),
              ],
            ),
          );
        }

        if (tracks.isNotEmpty) {
          return tracks;
        }
      }

      return _filterFallback(cleanQuery);
    } catch (_) {
      return _filterFallback(cleanQuery);
    }
  }

  List<Track> _filterFallback(String query) {
    return _defaultLibrary.where((track) {
      return track.title.toLowerCase().contains(query.toLowerCase()) ||
          track.artist.toLowerCase().contains(query.toLowerCase()) ||
          track.genreTag.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<ResolvedStream?> resolveAudioStream(Track track) async {
    if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
      return ResolvedStream(
        url: track.audioUrl!,
        totalBytes: 0,
        contentType: 'audio/mp4',
      );
    }
    return null;
  }

  Future<String?> resolveAudioStreamUrl(Track track) async {
    final stream = await resolveAudioStream(track);
    return stream?.url;
  }

  Future<List<LyricLine>> fetchLyrics(String title, String artist) async {
    try {
      final cleanTitle = title
          .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
      final cleanArtist = artist
          .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();

      final getUri = Uri.parse(
          'https://lrclib.net/api/get?track_name=${Uri.encodeComponent(cleanTitle)}&artist_name=${Uri.encodeComponent(cleanArtist)}');
      final res1 = await http
          .get(getUri, headers: {'User-Agent': 'Ayutune/1.0'})
          .timeout(const Duration(seconds: 4));

      if (res1.statusCode == 200) {
        final data = jsonDecode(res1.body);
        final synced = data['syncedLyrics'] as String?;
        if (synced != null && synced.trim().isNotEmpty) {
          return _parseLrc(synced);
        }
        final plain = data['plainLyrics'] as String?;
        if (plain != null && plain.trim().isNotEmpty) {
          return _parsePlain(plain);
        }
      }

      final searchUri = Uri.parse(
          'https://lrclib.net/api/search?q=${Uri.encodeComponent('$cleanTitle $cleanArtist')}');
      final res2 = await http
          .get(searchUri, headers: {'User-Agent': 'Ayutune/1.0'})
          .timeout(const Duration(seconds: 4));

      if (res2.statusCode == 200) {
        final list = jsonDecode(res2.body) as List;
        if (list.isNotEmpty) {
          final first = list.first;
          final synced = first['syncedLyrics'] as String?;
          if (synced != null && synced.trim().isNotEmpty) {
            return _parseLrc(synced);
          }
          final plain = first['plainLyrics'] as String?;
          if (plain != null && plain.trim().isNotEmpty) {
            return _parsePlain(plain);
          }
        }
      }
    } catch (_) {}

    return [];
  }

  List<LyricLine> _parseLrc(String lrc) {
    final List<LyricLine> lines = [];
    final regex = RegExp(r'^\[(\d{2}):(\d{2}(?:\.\d+)?)\](.*)$');
    for (final raw in lrc.split('\n')) {
      final trimmed = raw.trim();
      final match = regex.firstMatch(trimmed);
      if (match != null) {
        final mins = int.tryParse(match.group(1) ?? '0') ?? 0;
        final secs = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        final ms = (mins * 60 * 1000 + secs * 1000).round();
        final text = match.group(3)?.trim() ?? '';
        if (text.isNotEmpty) {
          lines.add(LyricLine(
            timestamp: Duration(milliseconds: ms),
            text: text.toUpperCase(),
          ));
        }
      }
    }
    return lines;
  }

  List<LyricLine> _parsePlain(String plain) {
    final List<LyricLine> lines = [];
    final rawLines = plain
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    for (int i = 0; i < rawLines.length; i++) {
      lines.add(LyricLine(
        timestamp: Duration(seconds: i * 5),
        text: rawLines[i].toUpperCase(),
      ));
    }
    return lines;
  }

  void dispose() {}
}
