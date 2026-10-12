import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lyric_line.dart';
import '../models/track.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final List<Track> _offlineTracks = [];

  List<Track> get offlineTracks => List.unmodifiable(_offlineTracks);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('offline_tracks_cache');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _offlineTracks.clear();
        for (final item in list) {
          final lyricsRaw = (item['lyrics'] as List?) ?? [];
          final lyrics = lyricsRaw.map((l) {
            return LyricLine(
              timestamp: Duration(milliseconds: l['ms'] ?? 0),
              text: l['text'] ?? '',
            );
          }).toList();

          _offlineTracks.add(
            Track(
              id: item['id'] ?? '',
              title: item['title'] ?? '',
              artist: item['artist'] ?? '',
              duration: Duration(seconds: item['duration'] ?? 180),
              genreTag: item['genreTag'] ?? 'OFFLINE',
              audioUrl: item['audioUrl'],
              thumbnailUrl: item['thumbnailUrl'],
              isOffline: true,
              lyrics: lyrics,
            ),
          );
        }
      } catch (_) {}
    }
  }

  bool isDownloaded(String trackId) {
    return _offlineTracks.any((t) => t.id == trackId);
  }

  Future<Track?> downloadTrack(Track track) async {
    if (track.audioUrl == null || track.audioUrl!.isEmpty) {
      return null;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${docDir.path}/offline_tracks');
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final safeId = track.id.replaceAll(RegExp(r'[^\w\-]'), '_');
    final filePath = '${targetDir.path}/$safeId.mp4';
    final file = File(filePath);

    final res = await http.get(
      Uri.parse(track.audioUrl!),
      headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
    );

    if (res.statusCode == 200) {
      await file.writeAsBytes(res.bodyBytes);

      final offlineTrack = track.copyWith(
        audioUrl: filePath,
        isOffline: true,
      );

      _offlineTracks.removeWhere((t) => t.id == track.id);
      _offlineTracks.insert(0, offlineTrack);

      await _persist();
      return offlineTrack;
    }

    return null;
  }

  Future<void> deleteTrack(String trackId) async {
    final track = _offlineTracks.where((t) => t.id == trackId).firstOrNull;
    if (track != null && track.audioUrl != null) {
      final file = File(track.audioUrl!);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }
    _offlineTracks.removeWhere((t) => t.id == trackId);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _offlineTracks.map((t) {
      return {
        'id': t.id,
        'title': t.title,
        'artist': t.artist,
        'duration': t.duration.inSeconds,
        'genreTag': t.genreTag,
        'audioUrl': t.audioUrl,
        'thumbnailUrl': t.thumbnailUrl,
        'lyrics': t.lyrics.map((l) {
          return {
            'ms': l.timestamp.inMilliseconds,
            'text': l.text,
          };
        }).toList(),
      };
    }).toList();

    await prefs.setString('offline_tracks_cache', jsonEncode(list));
  }
}
