import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/game_models.dart';
import '../widgets/game_card.dart';
import '../utils/theme.dart';
import 'game_screen.dart';
import 'game_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data
  List<Game> upcomingGames = [
    Game(
      id: '1',
      title: 'Trivia Night: Movies',
      description: 'Test your knowledge of Hollywood classics, blockbusters, and indie gems.',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(minutes: 60)),
      entryFee: 5.00,
      maxCapacity: 1000,
      currentParticipants: 450,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '2',
      title: 'Science & Tech',
      description: 'From quantum physics to AI — how well do you know the cutting edge?',
      imageUrl: 'https://images.unsplash.com/photo-1507413245164-6160d8298b31?w=600',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      entryFee: 0.00,
      maxCapacity: 2000,
      currentParticipants: 120,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '3',
      title: 'History Masters',
      description: 'Journey through ancient civilizations to modern world events.',
      imageUrl: 'https://images.unsplash.com/photo-1461360370896-922624d12a74?w=600',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 10, minutes: 30)),
      entryFee: 10.00,
      maxCapacity: 500,
      currentParticipants: 89,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '4',
      title: 'Sports Showdown',
      description: 'Football, cricket, basketball and more — prove you\'re the ultimate sports fan!',
      imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=600',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 19)),
      entryFee: 0.00,
      maxCapacity: 3000,
      currentParticipants: 1245,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '5',
      title: 'Geography Challenge',
      description: 'Capitals, flags, landmarks — test your world knowledge!',
      imageUrl: 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=600',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 14, minutes: 40)),
      entryFee: 15.00,
      maxCapacity: 800,
      currentParticipants: 234,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '6',
      title: 'Music Mania',
      description: 'From classical to pop — name that tune and artist!',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600',
      startTime: DateTime.now().add(const Duration(days: 3, hours: 20)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 21)),
      entryFee: 5.00,
      maxCapacity: 1500,
      currentParticipants: 678,
      status: GameStatus.upcoming,
    ),
    Game(
      id: '7',
      title: 'Literature & BooksR',
      description: 'Famous authors, classic novels, and literary trivia.',
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600',
      startTime: DateTime.now().add(const Duration(days: 5, hours: 16)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 16, minutes: 45)),
      entryFee: 0.00,
      maxCapacity: 600,
      currentParticipants: 45,
      status: GameStatus.upcoming,
    ),
  ];

  late Timer _timer;
  final Set<String> _joinedGameIds = {};

  Game? get _nextGame {
    final now = DateTime.now();
    final upcoming = upcomingGames.where((g) => g.startTime.isAfter(now)).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  Duration get _timeUntilNextGame {
    final game = _nextGame;
    if (game == null) return Duration.zero;
    final diff = game.startTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Widget> _buildCountdownBoxes() {
    final h = _timeUntilNextGame.inHours;
    final m = _timeUntilNextGame.inMinutes.remainder(60);
    final s = _timeUntilNextGame.inSeconds.remainder(60);
    Widget box(String value, String label) {
      return Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              value.padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    Widget sep() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          ':',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return [box('$h', 'HRS'), sep(), box('$m', 'MIN'), sep(), box('$s', 'SEC')];
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEE, MMM d').format(date);
    }
  }

  Widget _infoPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton() {
    final game = _nextGame!;
    final hasJoined = _joinedGameIds.contains(game.id);
    final canStart = _timeUntilNextGame.inSeconds <= 0;

    void openDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameDetailScreen(
            game: game,
            hasJoined: hasJoined,
            onJoin: () => _handleJoinGame(game),
          ),
        ),
      );
    }

    if (!hasJoined) {
      // Show "Join Game" button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: openDetail,
          icon: Icon(
            game.entryFee > 0 ? Icons.account_balance_wallet : Icons.sports_esports,
            size: 18,
          ),
          label: Text(
            game.entryFee > 0 ? 'Join - ₹${game.entryFee.toStringAsFixed(0)}' : 'Join Game - Free',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      );
    } else {
      // Show "Start Game" button — disabled until start time
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canStart ? openDetail : null,
          icon: Icon(
            canStart ? Icons.play_arrow_rounded : Icons.lock_clock,
            size: 18,
          ),
          label: Text(
            canStart ? 'Start Game' : 'Starts in ${_timeUntilNextGame.inMinutes}m ${_timeUntilNextGame.inSeconds.remainder(60)}s',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: canStart ? Colors.white : Colors.white.withValues(alpha: 0.25),
            foregroundColor: canStart ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.55),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      );
    }
  }

  void _handleJoinGame(Game game) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  game.entryFee > 0 ? Icons.account_balance_wallet : Icons.sports_esports,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Confirm Entry', style: AppTextStyles.heading2),
              const SizedBox(height: 6),
              Text(
                game.title,
                style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Fee card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Entry Fee',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.entryFee > 0 ? '₹${game.entryFee.toStringAsFixed(2)}' : 'FREE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: game.entryFee > 0 ? AppColors.primary : AppColors.correct,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processPaymentAndJoin(game);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        game.entryFee > 0 ? 'Pay & Join' : 'Join Now',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPaymentAndJoin(Game game) {
    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                game.entryFee > 0 ? 'Processing Payment...' : 'Registering...',
                style: AppTextStyles.body1,
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Remove loader

      // Mark game as joined
      setState(() {
        _joinedGameIds.add(game.id);
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.correct.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.correct, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  game.entryFee > 0 ? 'Payment Successful!' : 'Registered!',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.correct),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are registered for "${game.title}"',
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen(game: game)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Enter Game', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('YCT Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: _nextGame == null
                    ? const Center(
                        child: Text(
                          'No upcoming games',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.live_tv, color: Colors.white.withValues(alpha: 0.85), size: 16),
                              const SizedBox(width: 5),
                              Text(
                                'NEXT LIVE GAME',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Game title
                          Text(
                            _nextGame!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Date + Time in one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getDateLabel(_nextGame!.startTime),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${DateFormat('h:mm a').format(_nextGame!.startTime)} - ${DateFormat('h:mm a').format(_nextGame!.endTime)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Countdown boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildCountdownBoxes(),
                          ),
                          const SizedBox(height: 10),
                          // Entry fee & participants + status in one row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _infoPill(
                                icon: Icons.currency_rupee,
                                text: _nextGame!.entryFee > 0 ? '${_nextGame!.entryFee.toStringAsFixed(0)}' : 'FREE',
                              ),
                              const SizedBox(width: 8),
                              _infoPill(
                                icon: Icons.people_alt_outlined,
                                text: '${_nextGame!.currentParticipants}/${_nextGame!.maxCapacity}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Join / Start button
                          _buildHeroActionButton(),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Upcoming Games', style: AppTextStyles.heading2),
              ),

              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingGames.length,
                itemBuilder: (context, index) {
                  final game = upcomingGames[index];
                  void openDetail() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(
                          game: game,
                          hasJoined: _joinedGameIds.contains(game.id),
                          onJoin: () => _handleJoinGame(game),
                        ),
                      ),
                    );
                  }

                  return GameCard(
                    game: game,
                    hasJoined: _joinedGameIds.contains(game.id),
                    onJoin: openDetail,
                    onTap: openDetail,
                    onStart: openDetail,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
