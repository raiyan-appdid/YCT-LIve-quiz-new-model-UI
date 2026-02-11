import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';
import '../widgets/leaderboard_widget.dart';

class ResultsScreen extends StatelessWidget {
  final LeaderboardEntry currentUserEntry;
  final List<LeaderboardEntry> finalLeaderboard;
  final int totalQuestions;
  final int totalParticipants;

  const ResultsScreen({
    Key? key,
    required this.currentUserEntry,
    required this.finalLeaderboard,
    required this.totalQuestions,
    required this.totalParticipants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Game Results'),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Statistics
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                const Text('Your Performance', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Rank', '#${currentUserEntry.rank}', Colors.amber),
                    _buildStatItem('Points', '${currentUserEntry.totalPoints}', AppColors.secondary),
                    _buildStatItem('Correct', '${currentUserEntry.correctAnswers}/$totalQuestions', AppColors.correct),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Avg Time: ${currentUserEntry.avgResponseTime.toStringAsFixed(2)}s',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Final Leaderboard
          Expanded(
            child: LeaderboardWidget(
              entries: finalLeaderboard,
              // currentUserEntry is already in the list or we can highlight separately if needed
              // But standard UI usually shows top 10 list
            ),
          ),

          // Share Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shared to social media!')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('SHARE RESULT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body2,
        ),
      ],
    );
  }
}
