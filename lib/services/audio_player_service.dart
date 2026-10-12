import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import 'innertube_service.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final InnerTubeService _innerTube = InnerTubeService();

  List<Track> _queue = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isShuffle = false;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPlayerService() {
    _initQueue();
    _listenToPlayerStreams();
  }

  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isShuffle => _isShuffle;
  bool get isPlaying => _player.playing;

  Track get currentTrack {
    if (_queue.isEmpty || _currentIndex >= _queue.length) {
      return _innerTube.getDefaultTracks().first;
    }
    return _queue[_currentIndex];
  }

  Duration get currentPosition => _player.position;
  Duration get totalDuration => _player.duration ?? currentTrack.duration;
  double get volume => _player.volume;

  int getActiveLyricIndex() {
    final lyrics = currentTrack.lyrics;
    if (lyrics.isEmpty) return 0;
    final pos = currentPosition;
    for (int i = lyrics.length - 1; i >= 0; i--) {
      if (pos >= lyrics[i].timestamp) {
        return i;
      }
    }
    return 0;
  }

  void _initQueue() {
    _queue = List.from(_innerTube.getDefaultTracks());
  }

  void _listenToPlayerStreams() {
    _positionSubscription = _player.positionStream.listen((_) {
      notifyListeners();
    });

    _durationSubscription = _player.durationStream.listen((_) {
      notifyListeners();
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });
  }

  Future<void> playTrack(Track track) async {
    final existingIndex = _queue.indexWhere((t) => t.id == track.id);
    if (existingIndex != -1) {
      _currentIndex = existingIndex;
    } else {
      _queue.insert(_currentIndex + 1, track);
      _currentIndex++;
    }
    await _loadAndPlayCurrent();
  }

  Future<void> playIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await _loadAndPlayCurrent();
  }

  Future<void> _loadAndPlayCurrent() async {
    _isLoading = true;
    notifyListeners();

    try {
      final track = currentTrack;
      _fetchLyricsInBackground(track);

      final streamData = await _innerTube.resolveAudioStream(track);

      if (streamData != null) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(streamData.url)),
        );
        await _player.play();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fetchLyricsInBackground(Track track) async {
    try {
      final lyrics = await _innerTube.fetchLyrics(track.title, track.artist);
      if (lyrics.isNotEmpty &&
          _currentIndex < _queue.length &&
          _queue[_currentIndex].id == track.id) {
        _queue[_currentIndex] = track.copyWith(lyrics: lyrics);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.idle) {
        await _loadAndPlayCurrent();
      } else {
        await _player.play();
      }
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void obliterate() {
    _player.stop();
    _player.seek(Duration.zero);
    notifyListeners();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _queue.length - 1;
    }
    await _loadAndPlayCurrent();
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_isShuffle && _queue.length > 1) {
      int nextIdx;
      do {
        nextIdx = DateTime.now().millisecond % _queue.length;
      } while (nextIdx == _currentIndex);
      _currentIndex = nextIdx;
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    }
    await _loadAndPlayCurrent();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void setVolume(double value) {
    _player.setVolume(value.clamp(0.0, 1.0));
    notifyListeners();
  }

  Future<void> searchAndPlay(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _innerTube.searchTracks(query);
      if (results.isNotEmpty) {
        _queue = List.from(results);
        _currentIndex = 0;
        await _loadAndPlayCurrent();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTrackToQueue(Track track) {
    _queue.add(track);
    notifyListeners();
  }

  void removeTrackFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (_currentIndex >= _queue.length) {
        _currentIndex = _queue.length - 1;
      }
      notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
