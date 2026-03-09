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
              const Icon(Icons.emoji_events, color: LiveQuizColors.gold, size: 22),
              const SizedBox(width: 8),
              const Text('Leaderboard', style: TextStyle(color: LiveQuizColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
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
              color: LiveQuizColors.panel,
              border: Border(top: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.2))),
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
        color: isCurrentUser ? LiveQuizColors.blackSoft : LiveQuizColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentUser ? LiveQuizColors.gold.withValues(alpha: 0.45) : LiveQuizColors.gold.withValues(alpha: 0.2),
          width: isCurrentUser ? 1.5 : 1,
        ),
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
                color: isCurrentUser ? LiveQuizColors.gold : LiveQuizColors.textPrimary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalPoints} pts',
                style: const TextStyle(
                  color: LiveQuizColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${entry.avgResponseTime.toStringAsFixed(1)}s',
                style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
