import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class AudioService {
  final FlutterTts _tts = FlutterTts();
  TtsState _state = TtsState.stopped;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _state = TtsState.playing);
    _tts.setCompletionHandler(() => _state = TtsState.stopped);
    _tts.setErrorHandler((msg) => _state = TtsState.stopped);

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (_state != TtsState.playing && text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  Future<void> stop() async {
    if (_state == TtsState.playing) {
      await _tts.stop();
      _state = TtsState.stopped;
    }
  }

  Future<void> dispose() async {
    try {
      await stop();
      // Solution sécurisée pour les handlers
      if (_isInitialized) {
        _tts.setStartHandler(() {});
        _tts.setCompletionHandler(() {});
        _tts.setErrorHandler((_) {});
      }
    } catch (e) {
      debugPrint('Error disposing TTS: $e');
    } finally {
      _isInitialized = false;
    }
  }

  TtsState get state => _state;
}