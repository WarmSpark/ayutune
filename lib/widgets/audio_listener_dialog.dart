import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/track.dart';
import '../services/audio_player_service.dart';
import '../services/innertube_service.dart';
import '../theme/retro_theme.dart';
import 'retro_button.dart';

class AudioListenerDialog extends StatefulWidget {
  final RetroThemeData theme;

  const AudioListenerDialog({
    super.key,
    required this.theme,
  });

  @override
  State<AudioListenerDialog> createState() => _AudioListenerDialogState();
}

class _AudioListenerDialogState extends State<AudioListenerDialog> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _textController = TextEditingController();
  final InnerTubeService _tube = InnerTubeService();

  bool _isListening = false;
  bool _isSearching = false;
  bool _speechAvailable = false;
  String _recognizedWords = '';
  String _statusText = 'INITIALIZING RETRO EAR...';
  List<Track> _matchedTracks = [];
  Timer? _vuTimer;
  int _vuStep = 0;

  @override
  void initState() {
    super.initState();
    _initSpeechAndListen();
  }

  Future<void> _initSpeechAndListen() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (err) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusText = 'MIC IDLE: ${err.errorMsg.toUpperCase()}';
            });
          }
        },
        onStatus: (status) {
          if (mounted) {
            if (status == 'listening') {
              setState(() {
                _isListening = true;
                _statusText = 'LISTENING TO AUDIO / SINGING...';
              });
            } else if (status == 'notListening' || status == 'done') {
              setState(() {
                _isListening = false;
                if (_recognizedWords.isNotEmpty) {
                  _statusText = 'HEARD: "$_recognizedWords"';
                } else {
                  _statusText = 'MIC PAUSED. TAP LISTEN OR TYPE LYRICS';
                }
              });
            }
          }
        },
      );

      if (_speechAvailable) {
        _startListening();
      } else {
        setState(() {
          _statusText = 'MIC PERMISSION REQUIRED OR NOT AVAILABLE';
        });
      }
    } catch (_) {
      setState(() {
        _statusText = 'MIC NOT AVAILABLE. USE MANUAL SEARCH';
      });
    }
  }

  void _startListening() {
    if (!_speechAvailable) return;
    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _statusText = 'LISTENING TO AUDIO / SINGING...';
      _matchedTracks = [];
    });

    _vuTimer?.cancel();
    _vuTimer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      if (mounted && _isListening) {
        setState(() {
          _vuStep = (_vuStep + 1) % 8;
        });
      }
    });

    _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _recognizedWords = result.recognizedWords.trim().toUpperCase();
            _textController.text = _recognizedWords;
          });
          if (result.finalResult && _recognizedWords.isNotEmpty) {
            _searchTrackByLyrics(_recognizedWords);
          }
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    _vuTimer?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _searchTrackByLyrics(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    _stopListening();
    setState(() {
      _isSearching = true;
      _statusText = 'GUESSING TRACK FOR: "$clean"...';
    });

    try {
      final results = await _tube.searchTracks(clean);
      if (mounted) {
        setState(() {
          _matchedTracks = results;
          _isSearching = false;
          if (results.isEmpty) {
            _statusText = 'NO EXACT RETRO MATCH FOUND. TRY ANOTHER PHRASE';
          } else {
            _statusText = 'FOUND ${results.length} MATCHING TRACKS:';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _statusText = 'SEARCH ERROR. PLEASE RETRY';
        });
      }
    }
  }

  @override
  void dispose() {
    _vuTimer?.cancel();
    _speech.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final playerService = Provider.of<AudioPlayerService>(context, listen: false);

    return Dialog(
      backgroundColor: theme.panel,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.ink, width: 2.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: theme.ink,
                      child: Text(
                        'AUDIO EAR',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.background,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GUESS BY LYRICS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.ink,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.accentCoral,
                      border: Border.all(color: theme.ink, width: 1.5),
                    ),
                    child: const Text(
                      'X',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.background,
                border: Border.all(color: theme.ink, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isListening ? 'EAR STATUS: LISTENING' : 'EAR STATUS: IDLE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isListening ? theme.accentCoral : theme.inkDim,
                        ),
                      ),
                      Text(
                        _isListening ? '[ ${('|' * (_vuStep + 2)).padRight(10, '.')} ]' : '[ IDLE ]',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    label: _isListening ? 'STOP LISTENING' : 'LISTEN MIC',
                    theme: theme,
                    fontSize: 11,
                    backgroundColor: _isListening ? theme.accentCoral : theme.ink,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    onTap: () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: RetroButton(
                    label: 'GUESS TRACK',
                    theme: theme,
                    fontSize: 11,
                    backgroundColor: theme.accentTeal,
                    textColor: const Color(0xFF0C1626),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    onTap: () {
                      _searchTrackByLyrics(_textController.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: theme.ink,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.background,
                hintText: 'OR ENTER HEARD LYRICS / PHRASE...',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: theme.inkDim,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.ink, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.ink, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.accentTeal, width: 2.5),
                  borderRadius: BorderRadius.zero,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: theme.ink),
                  onPressed: () => _searchTrackByLyrics(_textController.text),
                ),
              ),
              onSubmitted: (val) => _searchTrackByLyrics(val),
            ),
            const SizedBox(height: 10),
            if (_isSearching)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'SEARCHING INVERTED AUDIO DATABASE...',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.accentTeal,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: _matchedTracks.isEmpty
                    ? Center(
                        child: Text(
                          'NO DETECTED TRACKS YET\nHUM, SING, OR PLAY NEAR MIC',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: theme.inkDim,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _matchedTracks.length,
                        itemBuilder: (context, idx) {
                          final trk = _matchedTracks[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.background,
                              border: Border.all(color: theme.ink, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.panel,
                                    border: Border.all(color: theme.ink, width: 1.2),
                                  ),
                                  child: trk.thumbnailUrl != null
                                      ? Image.network(
                                          trk.thumbnailUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Icon(Icons.music_note, color: theme.inkDim, size: 20),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(Icons.music_note, color: theme.inkDim, size: 20),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        trk.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.ink,
                                        ),
                                      ),
                                      Text(
                                        trk.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 9,
                                          color: theme.inkDim,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    playerService.playTrack(trk);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.accentTeal,
                                      border: Border.all(color: theme.ink, width: 1.2),
                                    ),
                                    child: const Text(
                                      'PLAY 320K',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0C1626),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
