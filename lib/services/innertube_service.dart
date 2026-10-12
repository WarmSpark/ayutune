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
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Vinyl beats rolling in...)'),
        LyricLine(timestamp: Duration(seconds: 10), text: 'Spray paint dripping on the concrete lane'),
        LyricLine(timestamp: Duration(seconds: 25), text: 'MURALS ON CITY WALLS'),
        LyricLine(timestamp: Duration(seconds: 40), text: 'THEN HE IS PULLING ME IN'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'Colors dancing in the morning light'),
        LyricLine(timestamp: Duration(seconds: 80), text: 'Walking past the shadows of the night'),
        LyricLine(timestamp: Duration(seconds: 105), text: 'Underneath an umbrella in black and white'),
        LyricLine(timestamp: Duration(seconds: 130), text: 'Step by step down the vintage stairs'),
        LyricLine(timestamp: Duration(seconds: 160), text: 'Electric echoes playing in the air'),
      ],
    ),
    const Track(
      id: 'default_2',
      title: 'WHEN HE IS PULLING ME IN',
      artist: 'LO-FI UMBRELLA DUO',
      duration: Duration(minutes: 3, seconds: 18),
      genreTag: 'LO-FI',
      isOffline: true,
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Chiptune acoustic strumming)'),
        LyricLine(timestamp: Duration(seconds: 15), text: 'Raindrops tapping on the pavement tiles'),
        LyricLine(timestamp: Duration(seconds: 35), text: 'Shared an umbrella, walked for miles'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'WHEN HE IS PULLING ME IN'),
        LyricLine(timestamp: Duration(seconds: 85), text: 'Never let the vintage record end'),
        LyricLine(timestamp: Duration(seconds: 120), text: 'Two silhouette dreams around the bend'),
      ],
    ),
    const Track(
      id: 'default_3',
      title: 'RAINY AFTERNOON STAIRS',
      artist: 'PIXEL CADENCE',
      duration: Duration(minutes: 4, seconds: 0),
      genreTag: 'LO-FI',
      isOffline: true,
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Sub-bass rumble and tape hiss)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'Sitting on the cold stone stair'),
        LyricLine(timestamp: Duration(seconds: 45), text: 'Purple schoolbag, damp chilly air'),
        LyricLine(timestamp: Duration(seconds: 75), text: 'Looking for an 8-bit silver lining'),
        LyricLine(timestamp: Duration(seconds: 110), text: 'While the clock keeps retro timing'),
      ],
    ),
    const Track(
      id: 'default_4',
      title: '8-BIT COFFEE SHOP',
      artist: 'CHIP-HOP RECORDS',
      duration: Duration(minutes: 2, seconds: 45),
      genreTag: '8-BIT',
      isOffline: true,
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Espresso machine and Game Boy arpeggios)'),
        LyricLine(timestamp: Duration(seconds: 15), text: 'Pixel art foam on a warm mug cup'),
        LyricLine(timestamp: Duration(seconds: 40), text: 'Rewind the tape, never giving up'),
        LyricLine(timestamp: Duration(seconds: 70), text: 'Dithered sunlight through the cafe glass'),
      ],
    ),
    const Track(
      id: 'default_5',
      title: 'MIDNIGHT HIGHWAY 1986',
      artist: 'NEON DRIFT',
      duration: Duration(minutes: 3, seconds: 52),
      genreTag: 'SYNTH',
      isOffline: false,
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Analog synth arpeggio pulse)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'Headlights slicing through the coastal fog'),
        LyricLine(timestamp: Duration(seconds: 50), text: 'Cassette deck playing in a midnight log'),
        LyricLine(timestamp: Duration(seconds: 90), text: 'Tachometer glowing neon gold'),
        LyricLine(timestamp: Duration(seconds: 130), text: 'Stories that the retro highway told'),
      ],
    ),
    const Track(
      id: 'default_6',
      title: 'KYOTO PAPER CRANES',
      artist: 'ORIGAMI SOUND',
      duration: Duration(minutes: 3, seconds: 10),
      genreTag: 'LO-FI',
      isOffline: true,
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Koto plucks and vinyl rain ambiance)'),
        LyricLine(timestamp: Duration(seconds: 25), text: 'Folded paper wings against the sky'),
        LyricLine(timestamp: Duration(seconds: 60), text: 'Watching ancient temple shadows fly'),
        LyricLine(timestamp: Duration(seconds: 100), text: 'Bamboo lanterns softly alight'),
        LyricLine(timestamp: Duration(seconds: 140), text: 'Whispers drifting into Kyoto night'),
      ],
    ),
    const Track(
      id: 'default_7',
      title: 'SUBWAY ECHOES',
      artist: 'UNDERGROUND TAPE CLUB',
      duration: Duration(minutes: 2, seconds: 58),
      genreTag: 'LO-FI',
      isOffline: false,
      audioUrl: 'https://cdn.freesound.org/previews/708/708892_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(Electric train rumble and click-clack track)'),
        LyricLine(timestamp: Duration(seconds: 18), text: 'Fluorescent buzz along platform four'),
        LyricLine(timestamp: Duration(seconds: 48), text: 'Sliding metal on the subway door'),
        LyricLine(timestamp: Duration(seconds: 88), text: 'Lost in transit with headphones on'),
        LyricLine(timestamp: Duration(seconds: 125), text: 'Waiting for the morning neon dawn'),
      ],
    ),
    const Track(
      id: 'default_8',
      title: 'CRT MIDNIGHT STATIC',
      artist: 'CATHODE GLITCH',
      duration: Duration(minutes: 3, seconds: 30),
      genreTag: '8-BIT',
      isOffline: true,
      audioUrl: 'https://cdn.freesound.org/previews/682/682631_11861866-lq.mp3',
      lyrics: [
        LyricLine(timestamp: Duration(seconds: 0), text: '(High frequency phosphor hum and lo-fi beat)'),
        LyricLine(timestamp: Duration(seconds: 20), text: 'Channel 3 flickering snow and noise'),
        LyricLine(timestamp: Duration(seconds: 55), text: 'Nostalgic memories of 90s joys'),
        LyricLine(timestamp: Duration(seconds: 95), text: 'Cathode ray dreams in violet light'),
        LyricLine(timestamp: Duration(seconds: 135), text: 'Static glow keeping watch tonight'),
      ],
    ),
  ];

  List<Track> getDefaultTracks() => List.unmodifiable(_defaultLibrary);

  Future<List<Track>> searchTracks(String query) async {
    if (query.trim().isEmpty) {
      return getDefaultTracks();
    }

    try {
      final searchList = await _yt.search.search(query);
      final List<Track> results = [];

      for (final video in searchList.take(15)) {
        results.add(
          Track(
            id: video.id.value,
            title: video.title.toUpperCase(),
            artist: video.author.toUpperCase(),
            duration: video.duration ?? const Duration(minutes: 3),
            genreTag: 'STREAM',
            youtubeVideoId: video.id.value,
            isOffline: false,
            lyrics: [
              LyricLine(timestamp: const Duration(seconds: 0), text: 'PLAYING: ${video.title}'),
              LyricLine(timestamp: const Duration(seconds: 10), text: 'ARTIST: ${video.author}'),
              const LyricLine(timestamp: Duration(seconds: 30), text: 'STREAMED VIA INNERTUBE ENGINE'),
            ],
          ),
        );
      }

      return results;
    } catch (_) {
      return _defaultLibrary.where((track) {
        return track.title.toLowerCase().contains(query.toLowerCase()) ||
            track.artist.toLowerCase().contains(query.toLowerCase()) ||
            track.genreTag.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<String?> resolveAudioStreamUrl(Track track) async {
    if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
      return track.audioUrl;
    }

    if (track.youtubeVideoId != null && track.youtubeVideoId!.isNotEmpty) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(track.youtubeVideoId!);
        final audioOnlyStreams = manifest.audioOnly.sortByBitrate();
        if (audioOnlyStreams.isNotEmpty) {
          return audioOnlyStreams.last.url.toString();
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  void dispose() {
    _yt.close();
  }
}
