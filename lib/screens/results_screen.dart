import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/theme.dart';

class ResultsScreen extends StatefulWidget {
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
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _ringAnim = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = widget.currentUserEntry.rank;
    final accuracy = widget.totalQuestions > 0 ? widget.currentUserEntry.correctAnswers / widget.totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: LiveQuizColors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        _buildHeroSection(rank),
                        const SizedBox(height: 20),
                        _buildPerformanceCard(accuracy),
                        const SizedBox(height: 20),
                        _buildLeaderboardSection(),
                        const SizedBox(height: 20),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LiveQuizColors.blackSoft,
        border: Border(bottom: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Game Results',
              style: TextStyle(color: LiveQuizColors.gold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: LiveQuizColors.panel,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded, color: LiveQuizColors.textMuted, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Section ─────────────────────────────────────────────────────
  Widget _buildHeroSection(int rank) {
    final isTop3 = rank <= 3;
    final medal = rank == 1
        ? ('🥇', const Color(0xFFFFD700))
        : rank == 2
            ? ('🥈', const Color(0xFFB0BEC5))
            : rank == 3
                ? ('🥉', const Color(0xFFCD7F32))
                : (null, LiveQuizColors.panelAlt);

    final headline = rank == 1
        ? 'Champion!'
        : rank <= 3
            ? 'Top Performer!'
            : rank <= 10
                ? 'Great Game!'
                : 'Well Played!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTop3 ? [const Color(0xFF1A1400), const Color(0xFF2B1F00), LiveQuizColors.blackSoft] : [LiveQuizColors.blackSoft, LiveQuizColors.panel],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTop3 ? LiveQuizColors.gold.withValues(alpha: 0.55) : LiveQuizColors.gold.withValues(alpha: 0.18),
          width: isTop3 ? 1.5 : 1,
        ),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: LiveQuizColors.gold.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          if (medal.$1 != null)
            Text(medal.$1!, style: const TextStyle(fontSize: 52))
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LiveQuizColors.panelAlt,
                border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.person_rounded, color: LiveQuizColors.textMuted, size: 30),
            ),
          const SizedBox(height: 10),
          Text(
            widget.currentUserEntry.user.name,
            style: const TextStyle(color: LiveQuizColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            headline,
            style: TextStyle(color: isTop3 ? LiveQuizColors.gold : LiveQuizColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          // Rank + Participants row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeroStat('#$rank', 'Rank', isTop3 ? LiveQuizColors.gold : LiveQuizColors.textPrimary),
              _buildHeroStatDivider(),
              _buildHeroStat('${widget.currentUserEntry.totalPoints}', 'Points', LiveQuizColors.goldSoft),
              _buildHeroStatDivider(),
              _buildHeroStat('${widget.totalParticipants}', 'Players', LiveQuizColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 11, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildHeroStatDivider() {
    return Container(width: 1, height: 40, color: LiveQuizColors.gold.withValues(alpha: 0.2));
  }

  // ── Performance Card ─────────────────────────────────────────────────
  Widget _buildPerformanceCard(double accuracy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LiveQuizColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: LiveQuizColors.gold, size: 18),
              SizedBox(width: 8),
              Text('Your Performance', style: TextStyle(color: LiveQuizColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Accuracy ring
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (context, _) {
                  return SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _AccuracyRingPainter(progress: _ringAnim.value * accuracy),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(accuracy * 100).round()}%',
                              style: const TextStyle(color: LiveQuizColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Text('Accuracy', style: TextStyle(color: LiveQuizColors.textMuted, fontSize: 9)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              // Stats column
              Expanded(
                child: Column(
                  children: [
                    _buildPerfRow(Icons.check_circle_rounded, 'Correct', '${widget.currentUserEntry.correctAnswers} / ${widget.totalQuestions}', LiveQuizColors.success),
                    const SizedBox(height: 10),
                    _buildPerfRow(Icons.cancel_rounded, 'Wrong', '${widget.totalQuestions - widget.currentUserEntry.correctAnswers} / ${widget.totalQuestions}', LiveQuizColors.danger),
                    const SizedBox(height: 10),
                    _buildPerfRow(Icons.timer_rounded, 'Avg Time', '${widget.currentUserEntry.avgResponseTime.toStringAsFixed(1)}s', LiveQuizColors.goldSoft),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Accuracy bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Score Accuracy', style: TextStyle(color: LiveQuizColors.textMuted, fontSize: 11)),
                  Text('${widget.currentUserEntry.correctAnswers}/${widget.totalQuestions} correct', style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _ringAnim.value * accuracy,
                    minHeight: 8,
                    backgroundColor: LiveQuizColors.blackSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      accuracy >= 0.8
                          ? LiveQuizColors.success
                          : accuracy >= 0.5
                              ? LiveQuizColors.gold
                              : LiveQuizColors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerfRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 12)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Leaderboard Section ───────────────────────────────────────────────
  Widget _buildLeaderboardSection() {
    final entries = widget.finalLeaderboard;
    final currentRank = widget.currentUserEntry.rank;
    final currentInList = entries.any((e) => e.user.name == widget.currentUserEntry.user.name);
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: LiveQuizColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LiveQuizColors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: LiveQuizColors.gold, size: 18),
                const SizedBox(width: 8),
                const Text('Leaderboard', style: TextStyle(color: LiveQuizColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${entries.length} players', style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 11)),
              ],
            ),
          ),

          // Podium for top 3
          if (top3.isNotEmpty) _buildPodium(top3),

          // Flat list for rank 4+
          if (rest.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            ...rest.map((entry) {
              final isMe = entry.user.name == widget.currentUserEntry.user.name;
              return _buildListRow(entry, entry.rank, isMe);
            }),
          ],

          // Sticky "You" row if not in list
          if (!currentInList) ...[
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            _buildListRow(widget.currentUserEntry, currentRank, true, isSticky: true),
          ],

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    // Layout order: 2nd (left), 1st (center, tallest), 3rd (right)
    final ordered = [
      if (top3.length > 1) top3[1],
      top3[0],
      if (top3.length > 2) top3[2],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ordered.map((entry) {
          final rank = entry.rank;
          final medal = rank == 1
              ? '🥇'
              : rank == 2
                  ? '🥈'
                  : '🥉';
          final barHeight = rank == 1
              ? 88.0
              : rank == 2
                  ? 68.0
                  : 52.0;
          final barColor = rank == 1
              ? const Color(0xFFFFD700)
              : rank == 2
                  ? const Color(0xFFB0BEC5)
                  : const Color(0xFFCD7F32);
          final isMe = entry.user.name == widget.currentUserEntry.user.name;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(medal, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    entry.user.name,
                    style: TextStyle(
                      color: isMe ? LiveQuizColors.gold : LiveQuizColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.correctAnswers}/${widget.totalQuestions}',
                    style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.13),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border.all(color: barColor.withValues(alpha: 0.45)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.totalPoints} pts',
                      style: TextStyle(
                        color: barColor,
                        fontSize: rank == 1 ? 13 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListRow(LeaderboardEntry entry, int rank, bool isMe, {bool isSticky = false}) {
    final medal = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : null;
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFB0BEC5)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : isMe
                    ? LiveQuizColors.gold
                    : LiveQuizColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isMe
            ? LiveQuizColors.gold.withValues(alpha: 0.07)
            : rank <= 3
                ? rankColor.withValues(alpha: 0.04)
                : Colors.transparent,
        border: isSticky ? Border(top: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.35))) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: medal != null ? 28 : 28,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text(
                    '#$rank',
                    style: TextStyle(color: rankColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  entry.user.name,
                  style: TextStyle(color: isMe ? LiveQuizColors.gold : LiveQuizColors.textPrimary, fontSize: 13, fontWeight: isMe ? FontWeight.bold : FontWeight.w500),
                ),
                if (isMe && !isSticky) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: LiveQuizColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('YOU', style: TextStyle(color: LiveQuizColors.gold, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry.correctAnswers}/${widget.totalQuestions}',
            style: const TextStyle(color: LiveQuizColors.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.totalPoints} pts',
            style: TextStyle(color: isMe ? LiveQuizColors.gold : LiveQuizColors.goldSoft, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shared!')),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LiveQuizColors.textPrimary,
              side: BorderSide(color: LiveQuizColors.gold.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: LiveQuizColors.gold,
              foregroundColor: LiveQuizColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Accuracy Ring Painter ─────────────────────────────────────────────
class _AccuracyRingPainter extends CustomPainter {
  final double progress;
  _AccuracyRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.shortestSide / 2) - 6;
    const strokeWidth = 7.0;

    // Background ring
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = LiveQuizColors.blackSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    final Color arcColor;
    if (progress >= 0.8) {
      arcColor = LiveQuizColors.success;
    } else if (progress >= 0.5) {
      arcColor = LiveQuizColors.gold;
    } else {
      arcColor = LiveQuizColors.danger;
    }

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AccuracyRingPainter old) => old.progress != progress;
}
