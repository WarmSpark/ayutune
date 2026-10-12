import 'track.dart';

class HitAlbum {
  final String id;
  final String title;
  final String artist;
  final String year;
  final String thumbnailUrl;
  final List<Track> tracks;

  const HitAlbum({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.thumbnailUrl,
    required this.tracks,
  });
}
