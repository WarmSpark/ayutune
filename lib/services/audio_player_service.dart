import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track.dart';
import 'innertube_service.dart';

class AudioPlayerService extends ChangeNotifier {
  late final AudioPlayer _player;
  final InnerTubeService _innerTube = InnerTubeService();
  AndroidLoudnessEnhancer? _loudnessEnhancer;
  AndroidEqualizer? _equalizer;
  bool _isAudioFx = true;

  List<Track> _queue = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isShuffle = false;
  bool _isAutoplay = true;
  bool _isCrossfade = true;
  bool _isFadingOut = false;
  double _userTargetVolume = 1.0;

  bool _isBeatHaptic = false;
  Timer? _beatHapticTimer;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPlayerService() {
    if (!kIsWeb && Platform.isAndroid) {
      _loudnessEnhancer = AndroidLoudnessEnhancer();
      _equalizer = AndroidEqualizer();
      _player = AudioPlayer(
        audioPipeline: AudioPipeline(
          androidAudioEffects: [_loudnessEnhancer!, _equalizer!],
        ),
      );
    } else {
      _player = AudioPlayer();
    }
    _initQueue();
    _listenToPlayerStreams();
    _applyAudioFx();
  }

  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isShuffle => _isShuffle;
  bool get isAutoplay => _isAutoplay;
  bool get isPlaying => _player.playing;
  bool get isAudioFx => _isAudioFx;
  bool get isCrossfade => _isCrossfade;
  bool get isBeatHaptic => _isBeatHaptic;

  Track get currentTrack {
    if (_queue.isEmpty || _currentIndex >= _queue.length) {
      return _innerTube.getDefaultTracks().first;
    }
    return _queue[_currentIndex];
  }

  Track? get nextTrack {
    if (_queue.isEmpty) return null;
    if (_currentIndex + 1 < _queue.length) {
      return _queue[_currentIndex + 1];
    }
    return null;
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
    _positionSubscription = _player.positionStream.listen((pos) {
      _checkCrossfade(pos);
      notifyListeners();
    });

    _durationSubscription = _player.durationStream.listen((_) {
      notifyListeners();
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.playing && _isBeatHaptic) {
        _startBeatHaptics();
      } else if (!state.playing) {
        _stopBeatHaptics();
      }

      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
      notifyListeners();
    });
  }

  void _checkCrossfade(Duration pos) {
    if (!_isCrossfade || _isFadingOut) return;
    final dur = _player.duration;
    if (dur == null || dur.inSeconds <= 10) return;
    final remaining = (dur - pos).inMilliseconds;
    if (remaining <= 4000 && remaining >= 400) {
      _isFadingOut = true;
      _fadeOutVolume();
    }
  }

  Future<void> _fadeOutVolume() async {
    final currentVol = _player.volume;
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (!_player.playing || !_isFadingOut) break;
      final v = currentVol * (1.0 - (i / 10));
      await _player.setVolume(v.clamp(0.05, 1.0));
    }
  }

  Future<void> _fadeInVolume() async {
    if (!_isCrossfade) {
      await _player.setVolume(_userTargetVolume);
      return;
    }
    await _player.setVolume(0.1);
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!_player.playing) break;
      final v = 0.1 + (_userTargetVolume - 0.1) * (i / 10);
      await _player.setVolume(v.clamp(0.0, 1.0));
    }
  }

  void _startBeatHaptics() {
    _stopBeatHaptics();
    if (!_isBeatHaptic) return;
    _beatHapticTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
      if (_player.playing) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _stopBeatHaptics() {
    _beatHapticTimer?.cancel();
    _beatHapticTimer = null;
  }

  void toggleBeatHaptic() {
    _isBeatHaptic = !_isBeatHaptic;
    if (_isBeatHaptic && _player.playing) {
      _startBeatHaptics();
    } else {
      _stopBeatHaptics();
    }
    notifyListeners();
  }

  void toggleCrossfade() {
    _isCrossfade = !_isCrossfade;
    notifyListeners();
  }

  Future<void> _applyAudioFx() async {
    if (_loudnessEnhancer == null) return;
    try {
      await _loudnessEnhancer!.setEnabled(_isAudioFx);
      if (_isAudioFx) {
        await _loudnessEnhancer!.setTargetGain(2.5);
      }
      if (_equalizer != null) {
        await _equalizer!.setEnabled(_isAudioFx);
      }
    } catch (_) {}
  }

  Future<void> toggleAudioFx() async {
    _isAudioFx = !_isAudioFx;
    await _applyAudioFx();
    notifyListeners();
  }

  Future<void> _handleTrackCompleted() async {
    if (_currentIndex < _queue.length - 1) {
      await next();
    } else if (_isAutoplay) {
      await _autoplaySimilar();
    } else {
      _currentIndex = 0;
      await _loadAndPlayCurrent();
    }
  }

  Future<void> _autoplaySimilar() async {
    try {
      final similarTracks = await _innerTube.getSimilarTracks(currentTrack);
      if (similarTracks.isNotEmpty) {
        final nextTrack = similarTracks.first;
        _queue.add(nextTrack);
        _currentIndex = _queue.length - 1;
        await _loadAndPlayCurrent();
        return;
      }
    } catch (_) {}

    await next();
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

  Future<void> playQueue(List<Track> newTracks, {int startIndex = 0}) async {
    if (newTracks.isEmpty) return;
    _queue = List.from(newTracks);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    await _loadAndPlayCurrent();
  }

  Future<void> _loadAndPlayCurrent() async {
    _isLoading = true;
    _isFadingOut = false;
    notifyListeners();

    try {
      final track = currentTrack;
      _fetchLyricsInBackground(track);

      if (track.isOffline && track.audioUrl != null && File(track.audioUrl!).existsSync()) {
        await _player.setAudioSource(AudioSource.file(track.audioUrl!));
        await _player.play();
        _fadeInVolume();
      } else {
        final streamData = await _innerTube.resolveAudioStream(track);
        if (streamData != null) {
          if (track.audioUrl == null || track.audioUrl!.isEmpty) {
            _queue[_currentIndex] = track.copyWith(audioUrl: streamData.url);
          }
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(streamData.url)),
          );
          await _player.play();
          _fadeInVolume();
        }
      }
      if (_isBeatHaptic) {
        _startBeatHaptics();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fetchLyricsInBackground(Track track) async {
    if (track.lyrics.length > 3) return;
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
      _stopBeatHaptics();
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.idle) {
        await _loadAndPlayCurrent();
      } else {
        await _player.play();
        if (_isBeatHaptic) {
          _startBeatHaptics();
        }
      }
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void obliterate() {
    _stopBeatHaptics();
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
    if (_isShuffle) {
      _currentIndex = DateTime.now().millisecond % _queue.length;
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else if (_isAutoplay) {
        await _autoplaySimilar();
        return;
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

  void toggleAutoplay() {
    _isAutoplay = !_isAutoplay;
    notifyListeners();
  }

  void setVolume(double value) {
    _userTargetVolume = value.clamp(0.0, 1.0);
    _player.setVolume(_userTargetVolume);
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
    _stopBeatHaptics();
    _queue.clear();
    _currentIndex = 0;
    _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopBeatHaptics();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
