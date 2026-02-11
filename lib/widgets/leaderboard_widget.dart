import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardWidget({
    Key? key,
    required this.entries,
    this.currentUserEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 22),
              const SizedBox(width: 8),
              const Text('Leaderboard', style: AppTextStyles.heading2),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildRankItem(entry, index + 1);
            },
          ),
        ),
        if (currentUserEntry != null) ...[
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: _buildRankItem(currentUserEntry!, currentUserEntry!.rank, isCurrentUser: true),
          ),
        ],
      ],
    );
  }

  Widget _buildRankItem(LeaderboardEntry entry, int displayRank, {bool isCurrentUser = false}) {
    Color rankBgColor = Colors.grey[200]!;
    if (displayRank == 1) {
      rankBgColor = Colors.amber;
    } else if (displayRank == 2) {
      rankBgColor = Colors.grey[400]!;
    } else if (displayRank == 3) {
      rankBgColor = Colors.brown[300]!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isCurrentUser ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: rankBgColor,
            child: Text(
              '$displayRank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.user.name,
              style: AppTextStyles.body1.copyWith(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalPoints} pts',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${entry.avgResponseTime.toStringAsFixed(1)}s',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
