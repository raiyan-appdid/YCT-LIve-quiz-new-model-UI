import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_models.dart';
import '../utils/live_quiz_audio.dart';
import '../utils/theme.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({Key? key, required this.game}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _gameStarted = false;
  bool _showTransitionScreen = false;
  int _currentQuestionIndex = 0;
  int _nextQuestionCountdown = 3;
  int _timeRemaining = 10;
  Duration _timeUntilArenaStart = Duration.zero;
  int? _selectedOption;
  bool _answerRevealed = false;
  bool _isMuted = false;
  int _lastPregameTickSecond = -1;
  Timer? _questionTimer;
  Timer? _pregameTimer;
  Timer? _nextQuestionTimer;
  Timer? _revealPauseTimer;
  final LiveQuizAudio _audio = LiveQuizAudio();

  // Mock Questions
  final List<Question> _questions = [
    Question(
      id: '1',
      text: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctOptionIndex: 2,
      timeLimitSeconds: 10,
    ),
    Question(
      id: '2',
      text: 'Which planet is known as the Red Planet?',
      options: ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      correctOptionIndex: 0,
      timeLimitSeconds: 10,
    ),
    Question(
      id: '3',
      text: 'Who wrote "Romeo and Juliet"?',
      options: ['Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain'],
      correctOptionIndex: 1,
      timeLimitSeconds: 10,
    ),
  ];

  // Mock Leaderboard – top 10 players
  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(user: User(id: '1', name: 'Alice', avatarUrl: ''), rank: 1, totalPoints: 250, avgResponseTime: 2.1, correctAnswers: 3),
    LeaderboardEntry(user: User(id: '2', name: 'Bob', avatarUrl: ''), rank: 2, totalPoints: 230, avgResponseTime: 2.5, correctAnswers: 3),
    LeaderboardEntry(user: User(id: '3', name: 'Charlie', avatarUrl: ''), rank: 3, totalPoints: 210, avgResponseTime: 2.8, correctAnswers: 2),
    LeaderboardEntry(user: User(id: '4', name: 'Diana', avatarUrl: ''), rank: 4, totalPoints: 190, avgResponseTime: 3.0, correctAnswers: 2),
    LeaderboardEntry(user: User(id: '5', name: 'Ethan', avatarUrl: ''), rank: 5, totalPoints: 180, avgResponseTime: 3.2, correctAnswers: 2),
    LeaderboardEntry(user: User(id: '6', name: 'Fiona', avatarUrl: ''), rank: 6, totalPoints: 160, avgResponseTime: 3.4, correctAnswers: 2),
    LeaderboardEntry(user: User(id: '7', name: 'George', avatarUrl: ''), rank: 7, totalPoints: 140, avgResponseTime: 3.6, correctAnswers: 1),
    LeaderboardEntry(user: User(id: '8', name: 'Hannah', avatarUrl: ''), rank: 8, totalPoints: 120, avgResponseTime: 3.8, correctAnswers: 1),
    LeaderboardEntry(user: User(id: '9', name: 'Ivan', avatarUrl: ''), rank: 9, totalPoints: 100, avgResponseTime: 4.0, correctAnswers: 1),
    LeaderboardEntry(user: User(id: '10', name: 'Julia', avatarUrl: ''), rank: 10, totalPoints: 80, avgResponseTime: 4.2, correctAnswers: 1),
  ];

  final LeaderboardEntry _currentUserEntry = LeaderboardEntry(
    user: User(id: 'me', name: 'You', avatarUrl: ''),
    rank: 15,
    totalPoints: 0,
    avgResponseTime: 0,
    correctAnswers: 0,
  );

  @override
  void initState() {
    super.initState();
    _audio.playLobbyLoop();
    _startPregameSyncTimer();
  }

  DateTime get _arenaStartTime => widget.game.startTime.add(const Duration(minutes: 5));

  void _startPregameSyncTimer() {
    _pregameTimer?.cancel();
    _syncPregameClock();
    _pregameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncPregameClock();
    });
  }

  void _syncPregameClock() {
    final diff = _arenaStartTime.difference(DateTime.now());
    if (diff.inSeconds <= 0) {
      _pregameTimer?.cancel();
      _startGame();
      return;
    }

    if (mounted) {
      setState(() {
        _timeUntilArenaStart = diff;
      });
    }

    final seconds = diff.inSeconds;
    if (seconds <= 3 && seconds != _lastPregameTickSecond) {
      _lastPregameTickSecond = seconds;
      _audio.playCountdownTick();
    }
  }

  void _startGame() {
    if (!mounted || _gameStarted) return;
    _audio.stopLobbyLoop();
    _audio.playGameStart();
    setState(() {
      _gameStarted = true;
    });
    _startQuestionTimer();
  }

  void _skipPregameForTesting() {
    _pregameTimer?.cancel();
    setState(() {
      _timeUntilArenaStart = Duration.zero;
      _lastPregameTickSecond = -1;
    });
    _startGame();
  }

  void _startQuestionTimer() {
    _timeRemaining = _questions[_currentQuestionIndex].timeLimitSeconds;
    _answerRevealed = false;
    _selectedOption = null;
    _questionTimer?.cancel();
    _audio.playQuestionTimerBgm();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
        if (_timeRemaining > 0 && _timeRemaining <= 3) {
          _audio.playTimerTick();
        }
      } else {
        _questionTimer?.cancel();
        _revealAnswer();
      }
    });
  }

  void _revealAnswer() {
    if (_answerRevealed) return;
    _audio.stopQuestionTimerBgm();

    final isCorrect = _selectedOption == _questions[_currentQuestionIndex].correctOptionIndex;
    if (_selectedOption == null) {
      _audio.playTimeUp();
    } else {
      if (isCorrect) {
        _audio.playAnswerCorrect();
      } else {
        _audio.playAnswerWrong();
      }
    }

    if (mounted) {
      setState(() {
        _answerRevealed = true;
      });
    }

    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _revealPauseTimer?.cancel();
    _revealPauseTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _goToNextQuestion();
    });
  }

  void _onOptionSelected(int index) {
    if (_answerRevealed) return;
    _audio.playAnswerSelect();
    setState(() {
      _selectedOption = index;
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _startNextQuestionTransition();
    } else {
      _endGame();
    }
  }

  void _startNextQuestionTransition() {
    _audio.playTransition();
    _audio.playLobbyLoop();
    _nextQuestionTimer?.cancel();
    setState(() {
      _showTransitionScreen = true;
      _nextQuestionCountdown = 3;
    });

    _nextQuestionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextQuestionCountdown > 1) {
        _audio.playCountdownTick();
        setState(() {
          _nextQuestionCountdown--;
        });
      } else {
        _nextQuestionTimer?.cancel();
        _audio.stopLobbyLoop();
        setState(() {
          _currentQuestionIndex++;
          _showTransitionScreen = false;
        });
        _startQuestionTimer();
      }
    });
  }

  void _endGame() {
    _audio.playGameEnd();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          currentUserEntry: _currentUserEntry,
          finalLeaderboard: _leaderboard,
          totalQuestions: _questions.length,
          totalParticipants: widget.game.currentParticipants,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _pregameTimer?.cancel();
    _nextQuestionTimer?.cancel();
    _revealPauseTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  // ──────────────────────── BUILD ────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) return _buildWaitingRoom();

    if (_showTransitionScreen) {
      return _buildNextQuestionTransition();
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: LiveQuizColors.black,
      appBar: AppBar(
        backgroundColor: LiveQuizColors.blackSoft,
        foregroundColor: LiveQuizColors.gold,
        elevation: 0,
        toolbarHeight: 56,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Question counter - prominent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: LiveQuizColors.panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Q ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: LiveQuizColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Timer - prominent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeRemaining < 4 ? LiveQuizColors.danger : LiveQuizColors.panelAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: _timeRemaining < 4 ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_timeRemaining}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              _audio.setMuted(_isMuted);
              if (!_isMuted && !_gameStarted) {
                _audio.playLobbyLoop();
              }
            },
            icon: Icon(_isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
          ),
          // Stats row - compact with labels
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _buildStatPill(
                  label: 'Players',
                  value: '${widget.game.currentParticipants}',
                  icon: Icons.people,
                  iconColor: LiveQuizColors.goldSoft,
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  label: 'Rank',
                  value: '#${_currentUserEntry.rank}',
                  icon: Icons.emoji_events,
                  iconColor: LiveQuizColors.gold,
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  label: 'Points',
                  value: '${_currentUserEntry.totalPoints}',
                  icon: Icons.star,
                  iconColor: LiveQuizColors.goldSoft,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer progress bar
          LinearProgressIndicator(
            value: _timeRemaining / question.timeLimitSeconds,
            backgroundColor: LiveQuizColors.panelAlt,
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeRemaining < 4 ? LiveQuizColors.danger : LiveQuizColors.gold,
            ),
            minHeight: 4,
          ),

          // Collapsible live leaderboard at top
          _buildCollapsibleLeaderboard(),

          // Question & Options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: LiveQuizColors.panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      question.text,
                      style: AppTextStyles.heading2.copyWith(color: LiveQuizColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(
                    question.options.length,
                    (i) => _buildOption(i, question),
                  ),

                  // Auto-advance indicator
                  if (_answerRevealed) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: LiveQuizColors.panel,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(LiveQuizColors.gold),
                              backgroundColor: LiveQuizColors.panelAlt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _currentQuestionIndex < _questions.length - 1 ? 'Revealed. Moving to next question...' : 'Revealed. Showing results...',
                            style: const TextStyle(
                              color: LiveQuizColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── STAT PILL HELPER ───────────────

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LiveQuizColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 3),
              Text(
                value,
                style: const TextStyle(
                  color: LiveQuizColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: LiveQuizColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── OPTIONS ───────────────

  Widget _buildOption(int index, Question question) {
    final bool isSelected = _selectedOption == index;
    final bool isCorrect = index == question.correctOptionIndex;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (_answerRevealed) {
      if (isCorrect) {
        bgColor = LiveQuizColors.success.withValues(alpha: 0.12);
        borderColor = LiveQuizColors.success;
        textColor = LiveQuizColors.success;
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        bgColor = LiveQuizColors.danger.withValues(alpha: 0.12);
        borderColor = LiveQuizColors.danger;
        textColor = LiveQuizColors.danger;
        trailingIcon = Icons.cancel;
      } else {
        bgColor = LiveQuizColors.panel;
        borderColor = LiveQuizColors.panelAlt;
        textColor = LiveQuizColors.textMuted;
        trailingIcon = null;
      }
    } else if (isSelected) {
      bgColor = LiveQuizColors.gold.withValues(alpha: 0.12);
      borderColor = LiveQuizColors.gold;
      textColor = LiveQuizColors.gold;
      trailingIcon = null;
    } else {
      bgColor = LiveQuizColors.panel;
      borderColor = LiveQuizColors.panelAlt;
      textColor = LiveQuizColors.textPrimary;
      trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _answerRevealed ? null : () => _onOptionSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                // Letter badge
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (isSelected || (_answerRevealed && isCorrect)) ? borderColor : LiveQuizColors.blackSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (isSelected || (_answerRevealed && isCorrect)) ? LiveQuizColors.black : LiveQuizColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) Icon(trailingIcon, color: borderColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────── LIVE LEADERBOARD (header + popup button) ───────────────

  void _showLiveLeaderboardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LiveQuizColors.panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle + header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.2))),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: LiveQuizColors.textMuted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: LiveQuizColors.gold, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'LIVE LEADERBOARD',
                            style: TextStyle(
                              color: LiveQuizColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Top ${_leaderboard.length}',
                            style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = _leaderboard[index];
                      final rank = index + 1;
                      final medal = rank == 1
                          ? '🥇'
                          : rank == 2
                              ? '🥈'
                              : rank == 3
                                  ? '🥉'
                                  : null;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.08))),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: medal != null
                                  ? Text(medal, style: const TextStyle(fontSize: 18))
                                  : Text(
                                      '#$rank',
                                      style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.user.name,
                                style: const TextStyle(color: LiveQuizColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${entry.correctAnswers} correct',
                              style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${entry.totalPoints} pts',
                              style: const TextStyle(color: LiveQuizColors.gold, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCollapsibleLeaderboard() {
    return Container(
      decoration: BoxDecoration(
        color: LiveQuizColors.blackSoft,
        border: Border(bottom: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.2))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: LiveQuizColors.gold, size: 16),
          const SizedBox(width: 6),
          const Text(
            'LIVE LEADERBOARD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: LiveQuizColors.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showLiveLeaderboardSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: LiveQuizColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.leaderboard_rounded, size: 13, color: LiveQuizColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    'Top ${_leaderboard.length}',
                    style: const TextStyle(fontSize: 11, color: LiveQuizColors.gold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────── WAITING ROOM ───────────────

  Widget _buildWaitingRoom() {
    final h = _timeUntilArenaStart.inHours;
    final m = _timeUntilArenaStart.inMinutes.remainder(60);
    final s = _timeUntilArenaStart.inSeconds.remainder(60);
    final pregameSeconds = _timeUntilArenaStart.inSeconds;
    final formattedArenaTime = '${_arenaStartTime.hour % 12 == 0 ? 12 : _arenaStartTime.hour % 12}:${_arenaStartTime.minute.toString().padLeft(2, '0')} ${_arenaStartTime.hour >= 12 ? 'PM' : 'AM'}';
    final countdownLabel = pregameSeconds <= 3 ? '$pregameSeconds' : '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: LiveQuizColors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050505), Color(0xFF17110A), Color(0xFF050505)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 32,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LiveQuizColors.gold.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 70,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LiveQuizColors.gold.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: LiveQuizColors.panel,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.28)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq_rounded, color: LiveQuizColors.gold, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'LIVE ARENA',
                                style: TextStyle(
                                  color: LiveQuizColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: _isMuted ? 'Unmute' : 'Mute',
                          onPressed: () {
                            setState(() => _isMuted = !_isMuted);
                            _audio.setMuted(_isMuted);
                            if (!_isMuted) {
                              _audio.playLobbyLoop();
                            }
                          },
                          icon: Icon(
                            _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: LiveQuizColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [LiveQuizColors.blackSoft, Color(0xFF2F2300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.42)),
                        boxShadow: [
                          BoxShadow(
                            color: LiveQuizColors.gold.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiveQuizColors.gold.withValues(alpha: 0.12),
                              border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.sports_esports, size: 38, color: LiveQuizColors.gold),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Arena Sync In Progress',
                            style: AppTextStyles.heading1.copyWith(color: LiveQuizColors.textPrimary, fontSize: 30),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Relax for a moment. Background audio stays on while all players lock in and the arena opens together.',
                            style: TextStyle(color: LiveQuizColors.textMuted, fontSize: 13.5, height: 1.45),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: LiveQuizColors.panel,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.24)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Arena Opens In',
                                  style: TextStyle(
                                    color: LiveQuizColors.textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  countdownLabel,
                                  style: TextStyle(
                                    fontSize: pregameSeconds <= 3 ? 64 : 42,
                                    fontWeight: FontWeight.w800,
                                    color: LiveQuizColors.gold,
                                    fontFamily: 'monospace',
                                    letterSpacing: pregameSeconds <= 3 ? 1 : 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: pregameSeconds <= 0 ? 1 : ((300 - _timeUntilArenaStart.inSeconds).clamp(0, 300) / 300),
                                    minHeight: 8,
                                    backgroundColor: LiveQuizColors.panelAlt,
                                    valueColor: const AlwaysStoppedAnimation<Color>(LiveQuizColors.gold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _buildWaitingInfoTile(
                                  icon: Icons.schedule_rounded,
                                  label: 'Entry Closes',
                                  value: formattedArenaTime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildWaitingInfoTile(
                                  icon: Icons.people_alt_rounded,
                                  label: 'Players Ready',
                                  value: '${widget.game.currentParticipants}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _skipPregameForTesting,
                              icon: const Icon(Icons.skip_next_rounded),
                              label: const Text('Skip Timer And Start Game'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LiveQuizColors.gold,
                                foregroundColor: LiveQuizColors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Testing only: bypasses the sync wait and enters the first question immediately.',
                            style: TextStyle(color: LiveQuizColors.textMuted, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: LiveQuizColors.blackSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: LiveQuizColors.goldSoft, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: LiveQuizColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: LiveQuizColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextQuestionTransition() {
    return Scaffold(
      backgroundColor: LiveQuizColors.black,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [LiveQuizColors.blackSoft, Color(0xFF2A1F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.45)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Next Question In',
                style: TextStyle(
                  color: LiveQuizColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '$_nextQuestionCountdown',
                style: const TextStyle(
                  color: LiveQuizColors.gold,
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Stay focused. Everyone advances together.',
                style: TextStyle(color: LiveQuizColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
