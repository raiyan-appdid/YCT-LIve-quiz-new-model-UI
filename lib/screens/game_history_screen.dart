import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';

class GameHistoryScreen extends StatelessWidget {
  final List<GameHistory> history;

  const GameHistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiveQuizColors.black,
      appBar: AppBar(
        title: const Text(
          'My Game History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: LiveQuizColors.blackSoft,
        foregroundColor: LiveQuizColors.gold,
        elevation: 0,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded, size: 64, color: LiveQuizColors.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'No games played yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: LiveQuizColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Join a live quiz to see your history here!',
                    style: TextStyle(fontSize: 13, color: LiveQuizColors.textMuted),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary bar
                _buildSummaryBar(),
                // Game list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return _GameHistoryCard(entry: history[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBar() {
    final totalGames = history.length;
    final totalWinnings = history.fold<double>(0, (sum, h) => sum + (h.prizeWon ?? 0));
    final bestRank = history.map((h) => h.rank).reduce((a, b) => a < b ? a : b);
    final avgAccuracy = history.isEmpty ? 0.0 : history.fold<double>(0, (sum, h) => sum + (h.correctAnswers / h.totalQuestions)) / history.length * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [LiveQuizColors.blackSoft, Color(0xFF332400), LiveQuizColors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            icon: Icons.sports_esports_rounded,
            value: '$totalGames',
            label: 'Played',
          ),
          _SummaryItem(
            icon: Icons.emoji_events_rounded,
            value: '#$bestRank',
            label: 'Best Rank',
          ),
          _SummaryItem(
            icon: Icons.account_balance_wallet_rounded,
            value: '₹${totalWinnings.toStringAsFixed(0)}',
            label: 'Winnings',
          ),
          _SummaryItem(
            icon: Icons.check_circle_outline,
            value: '${avgAccuracy.toStringAsFixed(0)}%',
            label: 'Accuracy',
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  final GameHistory entry;

  const _GameHistoryCard({required this.entry});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = entry.prizeWon != null && entry.prizeWon! > 0;
    final accuracy = (entry.correctAnswers / entry.totalQuestions * 100).toStringAsFixed(0);

    // Medal colours for top 3
    Color? rankColor;
    IconData? rankIcon;
    if (entry.rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankIcon = Icons.emoji_events_rounded;
    } else if (entry.rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankIcon = Icons.emoji_events_rounded;
    } else if (entry.rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankIcon = Icons.emoji_events_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: LiveQuizColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: isWinner
            ? Border.all(
                color: LiveQuizColors.success.withValues(alpha: 0.4),
                width: 1.5,
              )
            : Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: entry.imageUrl.isNotEmpty
                      ? Image.network(
                          entry.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: LiveQuizColors.blackSoft,
                            child: const Center(
                              child: Icon(Icons.quiz, size: 36, color: LiveQuizColors.gold),
                            ),
                          ),
                        )
                      : Container(
                          color: LiveQuizColors.blackSoft,
                          child: const Center(
                            child: Icon(Icons.quiz, size: 36, color: LiveQuizColors.gold),
                          ),
                        ),
                ),
                // Dark overlay
                Container(
                  width: double.infinity,
                  height: 90,
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
                // Title + time
                Positioned(
                  bottom: 10,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeAgo(entry.playedAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rank badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: rankColor ?? LiveQuizColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rankIcon != null) ...[
                          Icon(rankIcon, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '#${entry.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Prize won badge
                if (isWinner)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: LiveQuizColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '+₹${entry.prizeWon!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.stars_rounded,
                  label: '${entry.totalPoints} pts',
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: '${entry.correctAnswers}/${entry.totalQuestions} ($accuracy%)',
                  color: LiveQuizColors.success,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.speed,
                  label: '${entry.avgResponseTime.toStringAsFixed(1)}s avg',
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          // Date + participants
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(entry.playedAt),
                  style: const TextStyle(fontSize: 12, color: LiveQuizColors.textMuted),
                ),
                const Spacer(),
                Icon(Icons.people_alt_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${entry.totalParticipants} players',
                  style: const TextStyle(fontSize: 12, color: LiveQuizColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
