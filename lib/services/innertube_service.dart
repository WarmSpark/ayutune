import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/lyric_line.dart';
import '../models/track.dart';

class InnerTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  final List<Track> _defaultLibrary = [
    const Track(
      id: 'default_1',
      title: 'MURALS ON CITY WALLS',
      artist: 'THE WIGGLY BAND',
      duration: Duration(minutes: 3, seconds: 45),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
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
      duration: Duration(minutes: 3, seconds: 18),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
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
      duration: Duration(minutes: 4, seconds: 0),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
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
      duration: Duration(minutes: 2, seconds: 45),
      genreTag: '8-BIT',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
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
      duration: Duration(minutes: 3, seconds: 52),
      genreTag: 'SYNTH',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
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
      duration: Duration(minutes: 3, seconds: 10),
      genreTag: 'LO-FI',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
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
      duration: Duration(minutes: 2, seconds: 58),
      genreTag: 'LO-FI',
      isOffline: false,
      thumbnailUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
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
      duration: Duration(minutes: 3, seconds: 30),
      genreTag: '8-BIT',
      isOffline: true,
      thumbnailUrl: 'https://images.unsplash.com/photo-1520523839898-50712825e617?w=400',
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
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

  Duration _parseDurationString(String str) {
    if (str.isEmpty) return const Duration(minutes: 3);
    final parts = str.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: m, seconds: s);
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: h, minutes: m, seconds: s);
    }
    return const Duration(minutes: 3);
  }

  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) {
      return getDefaultTracks();
    }

    try {
      final searchList = await _yt.search.searchContent(query);
      final List<Track> results = [];

      for (final item in searchList.whereType<SearchVideo>().take(20)) {
        final thumbUrl = item.thumbnails.isNotEmpty
            ? item.thumbnails.last.url.toString()
            : 'https://img.youtube.com/vi/${item.id.value}/hqdefault.jpg';

        results.add(
          Track(
            id: item.id.value,
            title: item.title.toUpperCase(),
            artist: item.author.toUpperCase(),
            duration: _parseDurationString(item.duration),
            genreTag: 'STREAM',
            youtubeVideoId: item.id.value,
            thumbnailUrl: thumbUrl,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: Duration.zero, text: 'PLAYING: ${item.title.toUpperCase()}'),
              LyricLine(timestamp: const Duration(seconds: 5), text: 'ARTIST: ${item.author.toUpperCase()}'),
              const LyricLine(timestamp: Duration(seconds: 15), text: 'FETCHING SYNCHRONIZED LYRICS...'),
            ],
          ),
        );
      }

      if (results.isNotEmpty) {
        return results;
      }
      return _filterFallback(query);
    } catch (_) {
      return _filterFallback(query);
    }
  }

  List<Track> _filterFallback(String query) {
    return _defaultLibrary.where((track) {
      return track.title.toLowerCase().contains(query.toLowerCase()) ||
          track.artist.toLowerCase().contains(query.toLowerCase()) ||
          track.genreTag.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<String?> resolveAudioStreamUrl(Track track) async {
    if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
      return track.audioUrl;
    }

    if (track.youtubeVideoId != null && track.youtubeVideoId!.isNotEmpty) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(
          track.youtubeVideoId!,
          ytClients: [YoutubeApiClient.androidSdkless],
        );
        final audioStreams = manifest.audioOnly.sortByBitrate();
        if (audioStreams.isNotEmpty) {
          return audioStreams.last.url.toString();
        }
      } catch (_) {
        try {
          final manifest = await _yt.videos.streamsClient.getManifest(track.youtubeVideoId!);
          final audioStreams = manifest.audioOnly.sortByBitrate();
          if (audioStreams.isNotEmpty) {
            return audioStreams.last.url.toString();
          }
        } catch (_) {
          return null;
        }
      }
    }

    return null;
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

  void dispose() {
    _yt.close();
  }
}
