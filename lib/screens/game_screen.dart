import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_models.dart';
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
  int _currentQuestionIndex = 0;
  int _timeRemaining = 10;
  int? _selectedOption;
  bool _answerLocked = false;
  bool _showLeaderboard = true;
  Timer? _timer;

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
    Future.delayed(const Duration(seconds: 3), _startGame);
  }

  void _startGame() {
    if (!mounted) return;
    setState(() {
      _gameStarted = true;
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _timeRemaining = _questions[_currentQuestionIndex].timeLimitSeconds;
    _answerLocked = false;
    _selectedOption = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _answerLocked = true);
      }
    });
  }

  void _onOptionSelected(int index) {
    if (_answerLocked) return;
    _timer?.cancel();
    setState(() {
      _selectedOption = index;
      _answerLocked = true;
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startQuestionTimer();
    } else {
      _endGame();
    }
  }

  void _endGame() {
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
    _timer?.cancel();
    super.dispose();
  }

  // ──────────────────────── BUILD ────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_gameStarted) return _buildWaitingRoom();

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Question counter - prominent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Q ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  color: AppColors.primary,
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
                color: _timeRemaining < 4 ? AppColors.error : Colors.white24,
                borderRadius: BorderRadius.circular(20),
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
          // Stats row - compact with labels
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                _buildStatPill(
                  label: 'Players',
                  value: '${widget.game.currentParticipants}',
                  icon: Icons.people,
                  iconColor: Colors.lightBlueAccent,
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  label: 'Rank',
                  value: '#${_currentUserEntry.rank}',
                  icon: Icons.emoji_events,
                  iconColor: Colors.orangeAccent,
                ),
                const SizedBox(width: 6),
                _buildStatPill(
                  label: 'Points',
                  value: '${_currentUserEntry.totalPoints}',
                  icon: Icons.star,
                  iconColor: Colors.amber,
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
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _timeRemaining < 4 ? AppColors.error : AppColors.primary,
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
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
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(
                    question.options.length,
                    (i) => _buildOption(i, question),
                  ),

                  // Next / Results button
                  if (_answerLocked) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _goToNextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1 ? 'Next Question  →' : 'See Results',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
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

    if (_answerLocked) {
      if (isCorrect) {
        bgColor = AppColors.correct.withValues(alpha: 0.12);
        borderColor = AppColors.correct;
        textColor = const Color(0xFF2E7D32);
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        bgColor = AppColors.incorrect.withValues(alpha: 0.12);
        borderColor = AppColors.incorrect;
        textColor = AppColors.incorrect;
        trailingIcon = Icons.cancel;
      } else {
        bgColor = AppColors.surface;
        borderColor = Colors.grey[300]!;
        textColor = Colors.grey;
        trailingIcon = null;
      }
    } else if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.10);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
      trailingIcon = null;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey[300]!;
      textColor = AppColors.onSurface;
      trailingIcon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _answerLocked ? null : () => _onOptionSelected(index),
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
                    color: (isSelected || (_answerLocked && isCorrect)) ? borderColor : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (isSelected || (_answerLocked && isCorrect)) ? Colors.white : Colors.grey[600],
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

  // ─────────────── LIVE LEADERBOARD (collapsible top panel) ───────────────

  Widget _buildCollapsibleLeaderboard() {
    return GestureDetector(
      onTap: () => setState(() => _showLeaderboard = !_showLeaderboard),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Always-visible header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[700], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE LEADERBOARD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Top ${_leaderboard.length}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _showLeaderboard ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.expand_more, size: 20, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            // Expandable chip list
            AnimatedCrossFade(
              firstChild: SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                  itemCount: _leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = _leaderboard[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _rankMedal(index + 1),
                          const SizedBox(width: 5),
                          Text(
                            entry.user.name,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.onSurface),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.totalPoints}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _showLeaderboard ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rankMedal(int rank) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 14));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 14));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 14));
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ─────────────── WAITING ROOM ───────────────

  Widget _buildWaitingRoom() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Get Ready!',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 28),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 3, end: 0),
              duration: const Duration(seconds: 3),
              builder: (context, value, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.10),
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${value.ceil()}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.game.currentParticipants} Players Ready',
                  style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
