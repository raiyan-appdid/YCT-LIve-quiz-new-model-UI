import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';
import 'live_badge.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onJoin;
  final VoidCallback? onStart;
  final VoidCallback? onTap;
  final bool hasJoined;

  const GameCard({
    Key? key,
    required this.game,
    required this.onJoin,
    this.onStart,
    this.onTap,
    this.hasJoined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    final isToday = _isToday(game.startTime);
    final isTomorrow = _isTomorrow(game.startTime);
    final now = DateTime.now();
    final isLiveNow = game.startTime.isBefore(now) && game.endTime.isAfter(now);

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isTomorrow) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = dateFormat.format(game.startTime);
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: LiveQuizColors.panel,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: LiveQuizColors.gold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            if (game.imageUrl.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: Image.network(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        child: const Center(
                          child: Icon(Icons.quiz, size: 48, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  // Fee badge overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: game.entryFee == 0 ? LiveQuizColors.success : LiveQuizColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        game.entryFee == 0 ? 'FREE' : '₹${game.entryFee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: LiveQuizColors.black,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  // LIVE badge overlay
                  if (isLiveNow)
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: LiveBadge(),
                    ),
                  // Joined badge overlay (shifted down when live)
                  if (hasJoined)
                    Positioned(
                      top: isLiveNow ? 46 : 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: LiveQuizColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 14),
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
                    ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(game.title, style: AppTextStyles.heading3.copyWith(color: LiveQuizColors.textPrimary)),
                  if (game.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      game.description,
                      style: AppTextStyles.body2.copyWith(color: LiveQuizColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Date & Time row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LiveQuizColors.blackSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        // Date section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: LiveQuizColors.gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dateLabel,
                                style: const TextStyle(
                                  color: LiveQuizColors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isToday && !isTomorrow)
                                Text(
                                  DateFormat('yyyy').format(game.startTime),
                                  style: TextStyle(
                                    color: LiveQuizColors.black.withValues(alpha: 0.7),
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${timeFormat.format(game.startTime)} - ${timeFormat.format(game.endTime)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: LiveQuizColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Duration: ${game.endTime.difference(game.startTime).inMinutes} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: LiveQuizColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Participants
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: LiveQuizColors.panelAlt,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people, size: 14, color: LiveQuizColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${game.currentParticipants}/${game.maxCapacity}',
                                style: const TextStyle(fontSize: 12, color: LiveQuizColors.textMuted, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Capacity bar
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(4),
                  //   child: LinearProgressIndicator(
                  //     value: percentFull,
                  //     backgroundColor: Colors.grey[200],
                  //     valueColor: AlwaysStoppedAnimation<Color>(
                  //       percentFull > 0.9 ? AppColors.error : AppColors.primary,
                  //     ),
                  //     minHeight: 5,
                  //   ),
                  // ),
                  // const SizedBox(height: 14),

                  // Button - changes based on join state
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final now = DateTime.now();
    final canStart = game.startTime.isBefore(now) || game.startTime.difference(now).inSeconds <= 0;
    final timeUntilStart = game.startTime.difference(now);

    if (!hasJoined) {
      // Show "Join Game" button
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: LiveQuizColors.gold,
            foregroundColor: LiveQuizColors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            game.entryFee > 0 ? 'JOIN GAME - ₹${game.entryFee.toStringAsFixed(2)}' : 'JOIN GAME - FREE',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      );
    } else {
      // Show "Start Game" button - disabled until start time
      String buttonText;
      if (canStart) {
        buttonText = 'START GAME';
      } else if (timeUntilStart.inHours > 0) {
        buttonText = 'STARTS IN ${timeUntilStart.inHours}h ${timeUntilStart.inMinutes.remainder(60)}m';
      } else {
        buttonText = 'STARTS IN ${timeUntilStart.inMinutes}m ${timeUntilStart.inSeconds.remainder(60)}s';
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canStart ? onStart : null,
          icon: Icon(
            canStart ? Icons.play_arrow_rounded : Icons.lock_clock,
            size: 20,
          ),
          label: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: canStart ? LiveQuizColors.success : LiveQuizColors.panelAlt,
            foregroundColor: canStart ? LiveQuizColors.black : LiveQuizColors.textMuted,
            disabledBackgroundColor: LiveQuizColors.panelAlt,
            disabledForegroundColor: LiveQuizColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
}
