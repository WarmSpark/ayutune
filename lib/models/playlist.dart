import 'track.dart';

class Playlist {
  final String id;
  final String name;
  final List<Track> tracks;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.tracks,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<Track>? tracks,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
