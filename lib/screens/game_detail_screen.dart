import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';
import 'game_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;
  final bool hasJoined;
  final VoidCallback onJoin;

  const GameDetailScreen({
    Key? key,
    required this.game,
    required this.hasJoined,
    required this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final durationMinutes = game.endTime.difference(game.startTime).inMinutes;
    final percentFull = game.currentParticipants / game.maxCapacity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Collapsing App Bar with image ───
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  game.imageUrl.isNotEmpty
                      ? Image.network(
                          game.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary,
                            child: const Center(
                              child: Icon(Icons.quiz, size: 60, color: Colors.white54),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary,
                          child: const Center(
                            child: Icon(Icons.quiz, size: 60, color: Colors.white54),
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Fee badge
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: game.entryFee == 0 ? AppColors.correct : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        game.entryFee == 0 ? 'FREE' : '₹${game.entryFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasJoined)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.correct,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 13),
                                SizedBox(width: 4),
                                Text(
                                  'JOINED',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          game.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Body ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (game.description.isNotEmpty) ...[
                    Text(game.description, style: AppTextStyles.body1.copyWith(height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // ─── Date, Time & Duration Card ───
                  _SectionCard(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today,
                        iconColor: AppColors.primary,
                        label: 'Date',
                        value: dateFormat.format(game.startTime),
                      ),
                      const _CardDivider(),
                      _DetailRow(
                        icon: Icons.access_time_rounded,
                        iconColor: Colors.orange,
                        label: 'Time',
                        value: '${timeFormat.format(game.startTime)} – ${timeFormat.format(game.endTime)}',
                      ),
                      const _CardDivider(),
                      _DetailRow(
                        icon: Icons.timer_outlined,
                        iconColor: Colors.blue,
                        label: 'Duration',
                        value: '$durationMinutes minutes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Game Stats Card ───
                  _SectionCard(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.help_outline_rounded,
                              iconColor: AppColors.primary,
                              label: 'Questions',
                              value: '${game.totalQuestions}',
                            ),
                          ),
                          Container(width: 1, height: 50, color: Colors.grey.shade200),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.timer,
                              iconColor: Colors.orange,
                              label: 'Per Question',
                              value: '${game.timePerQuestionSeconds}s',
                            ),
                          ),
                          Container(width: 1, height: 50, color: Colors.grey.shade200),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.stars_rounded,
                              iconColor: Colors.amber.shade700,
                              label: 'Per Answer',
                              value: '${game.pointsPerCorrectAnswer} pts',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Participants & Prize Pool Card ───
                  _SectionCard(
                    children: [
                      _DetailRow(
                        icon: Icons.people_alt_rounded,
                        iconColor: Colors.indigo,
                        label: 'Participants',
                        value: '${game.currentParticipants} / ${game.maxCapacity}',
                        trailing: Text(
                          '${(percentFull * 100).toStringAsFixed(0)}% full',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: percentFull > 0.8 ? AppColors.error : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentFull,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentFull > 0.9 ? AppColors.error : AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _CardDivider(),
                      _DetailRow(
                        icon: Icons.emoji_events_rounded,
                        iconColor: Colors.amber.shade700,
                        label: 'Prize Pool',
                        value: '₹${game.prizePool.toStringAsFixed(0)}',
                      ),
                      const _CardDivider(),
                      _DetailRow(
                        icon: Icons.currency_rupee,
                        iconColor: AppColors.correct,
                        label: 'Entry Fee',
                        value: game.entryFee == 0 ? 'FREE' : '₹${game.entryFee.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Rules Section ───
                  const Text('Game Rules', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  _RuleItem(
                    number: 1,
                    icon: Icons.play_circle_outline,
                    text: 'Once the game starts, you cannot pause or restart it. Make sure you are ready before joining.',
                    color: Colors.blue,
                  ),
                  _RuleItem(
                    number: 2,
                    icon: Icons.touch_app,
                    text: 'Each question has ${game.timePerQuestionSeconds} seconds to answer. If time runs out, the question is marked as unanswered.',
                    color: Colors.orange,
                  ),
                  _RuleItem(
                    number: 3,
                    icon: Icons.lock_outline,
                    text: 'Once you select an answer, it is final — you cannot change or undo it.',
                    color: AppColors.primary,
                  ),
                  _RuleItem(
                    number: 4,
                    icon: Icons.block,
                    text: 'You cannot go back to a previous question. If you leave or navigate away, your game will end immediately and results will be generated based on your progress.',
                    color: AppColors.error,
                  ),
                  _RuleItem(
                    number: 5,
                    icon: Icons.stars_rounded,
                    text: 'Each correct answer earns ${game.pointsPerCorrectAnswer} points. No negative marking for wrong answers.',
                    color: Colors.amber.shade700,
                  ),
                  _RuleItem(
                    number: 6,
                    icon: Icons.speed,
                    text: 'Faster correct answers earn bonus points. Be quick but accurate!',
                    color: Colors.green,
                  ),
                  _RuleItem(
                    number: 7,
                    icon: Icons.leaderboard_rounded,
                    text: 'Final rankings are based on total points. Ties are broken by average response time.',
                    color: Colors.indigo,
                  ),

                  const SizedBox(height: 100), // space for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom Join / Start Button ───
      bottomNavigationBar: _BottomActionBar(
        game: game,
        hasJoined: hasJoined,
        onJoin: onJoin,
        onStart: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameScreen(game: game)),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Private widget helpers
// ═══════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _RuleItem extends StatelessWidget {
  final int number;
  final IconData icon;
  final String text;
  final Color color;

  const _RuleItem({
    required this.number,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final Game game;
  final bool hasJoined;
  final VoidCallback onJoin;
  final VoidCallback onStart;

  const _BottomActionBar({
    required this.game,
    required this.hasJoined,
    required this.onJoin,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canStart = game.startTime.isBefore(now) || game.startTime.difference(now).inSeconds <= 0;
    final timeUntilStart = game.startTime.difference(now);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: !hasJoined
          ? SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onJoin,
                icon: Icon(
                  game.entryFee > 0 ? Icons.account_balance_wallet : Icons.sports_esports,
                  size: 20,
                ),
                label: Text(
                  game.entryFee > 0 ? 'JOIN GAME – ₹${game.entryFee.toStringAsFixed(2)}' : 'JOIN GAME – FREE',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            )
          : Row(
              children: [
                // Info chip
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.correct.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.correct.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.correct, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: AppColors.correct,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Start button
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: canStart ? onStart : null,
                      icon: Icon(
                        canStart ? Icons.play_arrow_rounded : Icons.lock_clock,
                        size: 20,
                      ),
                      label: Text(
                        canStart
                            ? 'START GAME'
                            : timeUntilStart.inHours > 0
                                ? 'IN ${timeUntilStart.inHours}h ${timeUntilStart.inMinutes.remainder(60)}m'
                                : 'IN ${timeUntilStart.inMinutes}m ${timeUntilStart.inSeconds.remainder(60)}s',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canStart ? AppColors.correct : Colors.grey.shade300,
                        foregroundColor: canStart ? Colors.white : Colors.grey.shade600,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
