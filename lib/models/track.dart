import 'lyric_line.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final String genreTag;
  final String? audioUrl;
  final String? youtubeVideoId;
  final bool isOffline;
  final List<LyricLine> lyrics;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.genreTag,
    this.audioUrl,
    this.youtubeVideoId,
    this.isOffline = false,
    this.lyrics = const [],
  });

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    Duration? duration,
    String? genreTag,
    String? audioUrl,
    String? youtubeVideoId,
    bool? isOffline,
    List<LyricLine>? lyrics,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      genreTag: genreTag ?? this.genreTag,
      audioUrl: audioUrl ?? this.audioUrl,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      isOffline: isOffline ?? this.isOffline,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}
