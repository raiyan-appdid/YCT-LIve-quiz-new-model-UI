import 'package:audioplayers/audioplayers.dart';

class LiveQuizAudio {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _timerBgmPlayer = AudioPlayer();
  bool _muted = false;

  LiveQuizAudio() {
    _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    // Pre-warm the timer BGM player so Android initializes its
    // native audio session before the first question starts.
    _timerBgmPlayer.setReleaseMode(ReleaseMode.loop);
    _timerBgmPlayer.setVolume(0.65);
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    if (_muted) {
      await _bgmPlayer.stop();
      await _timerBgmPlayer.stop();
    }
  }

  Future<void> playLobbyLoop() async {
    if (_muted) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.stop);
      await _bgmPlayer.setVolume(0.52);
      await _bgmPlayer.play(AssetSource('audio/audioblocks-1289-frantic-tv-show-quiz-countdown_HqTDtWlYn_NWM.mp3'));
    } catch (_) {
      // Keep gameplay functional even when audio files are missing.
    }
  }

  Future<void> stopLobbyLoop() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> playQuestionTimerBgm() async {
    if (_muted) return;
    try {
      await _timerBgmPlayer.stop();
      await _timerBgmPlayer.play(AssetSource('audio/freesound_community-clock-timer-58830.mp3'));
    } catch (_) {}
  }

  Future<void> stopQuestionTimerBgm() async {
    try {
      await _timerBgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> playCountdownTick() => _playSfx('audio/countdown_tick.wav', 0.75);
  Future<void> playGameStart() => _playSfx('audio/game_start.wav', 0.95);
  Future<void> playAnswerSelect() => _playSfx('audio/answer_select.wav', 1);
  Future<void> playAnswerCorrect() => _playSfx('audio/answer_correct.wav', 0.95);
  Future<void> playAnswerWrong() => _playSfx('audio/answer_wrong.wav', 0.95);
  Future<void> playTimerTick() => _playSfx('audio/timer_tick.wav', 0.72);
  Future<void> playTimeUp() => _playSfx('audio/time_up.wav', 0.9);
  Future<void> playTransition() => _playSfx('audio/transition.wav', 0.50);
  Future<void> playGameEnd() => _playSfx('audio/game_end.wav', 1.0);

  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _bgmPlayer.dispose();
    await _timerBgmPlayer.dispose();
  }

  Future<void> _playSfx(String assetPath, double volume) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Missing audio files should not crash the UI.
    }
  }
}
