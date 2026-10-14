import 'dart:async';
import 'package:audio_service/audio_service.dart';
import '../models/track.dart';

class VelvetuneAudioHandler extends BaseAudioHandler with SeekHandler {
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;
  Future<void> Function(Duration position)? onSeek;
  void Function()? onStop;

  void updateTrack(
    Track track, {
    required bool isPlaying,
    required Duration position,
    Duration? duration,
  }) {
    mediaItem.add(MediaItem(
      id: track.id,
      album: track.genreTag.isNotEmpty ? track.genreTag : 'Velvetune Mixtape',
      title: track.title,
      artist: track.artist,
      duration: duration ?? track.duration,
      artUri: (track.thumbnailUrl != null && track.thumbnailUrl!.isNotEmpty)
          ? Uri.tryParse(track.thumbnailUrl!)
          : null,
    ));

    updatePlaybackState(
      isPlaying: isPlaying,
      position: position,
      duration: duration ?? track.duration,
    );
  }

  void updatePlaybackState({
    required bool isPlaying,
    required Duration position,
    Duration? duration,
  }) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: position,
      speed: 1.0,
    ));
  }

  void stopPlayback() {
    playbackState.add(PlaybackState(
      controls: const [],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  @override
  Future<void> play() async {
    if (onPlay != null) {
      await onPlay!();
    }
  }

  @override
  Future<void> pause() async {
    if (onPause != null) {
      await onPause!();
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onNext != null) {
      await onNext!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPrevious != null) {
      await onPrevious!();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeek != null) {
      await onSeek!(position);
    }
  }

  @override
  Future<void> stop() async {
    if (onStop != null) {
      onStop!();
    }
    stopPlayback();
  }
}
