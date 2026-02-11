import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Timer _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Next game data (in a real app this would come from your backend)
  final String _nextGameTitle = 'Trivia Night: Movies';
  final DateTime _nextGameTime = DateTime.now().add(const Duration(minutes: 30));
  final DateTime _nextGameEndTime = DateTime.now().add(const Duration(minutes: 60));

  Duration get _timeLeft {
    final diff = _nextGameTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get _countdownText {
    final d = _timeLeft;
    if (d.inSeconds <= 0) return 'LIVE NOW';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('YCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner Carousel ──
            _buildBannerCarousel(),

            const SizedBox(height: 20),

            // ── Live Quiz Entry (the new feature highlight) ──
            _buildQuizBanner(context),

            const SizedBox(height: 24),

            // ── Categories Row ──
            _buildSectionHeader('Categories'),
            const SizedBox(height: 12),
            _buildCategoryChips(),

            const SizedBox(height: 24),

            // ── Popular Books ──
            _buildSectionHeader('Popular Books'),
            const SizedBox(height: 12),
            _buildBooksList(),

            const SizedBox(height: 24),

            // ── eBooks ──
            _buildSectionHeader('eBooks'),
            const SizedBox(height: 12),
            _buildEbooksList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline_rounded), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  // ── Banner Carousel ──
  Widget _buildBannerCarousel() {
    final banners = [
      _BannerData('New Arrivals', 'Explore the latest additions to our collection', Icons.auto_stories_rounded, const Color(0xFF5C6BC0)),
      _BannerData('50% Off', 'Mega sale on premium eBooks this week', Icons.local_offer_rounded, const Color(0xFFEF6C00)),
      _BannerData('Study Material', 'Curated books for competitive exams', Icons.school_rounded, const Color(0xFF00897B)),
    ];

    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final b = banners[index];
          return Container(
            margin: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [b.color, b.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(b.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13), maxLines: 2),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(b.icon, color: Colors.white.withValues(alpha: 0.3), size: 64),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Live Quiz Feature Banner with live countdown ──
  Widget _buildQuizBanner(BuildContext context) {
    final isLive = _timeLeft.inSeconds <= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryVariant],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row: icon + title + LIVE/NEW badge
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Live Quiz',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          // Pulsing LIVE dot or NEW badge
                          if (isLive)
                            FadeTransition(
                              opacity: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _nextGameTitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getDateLabel(_nextGameTime)} • ${DateFormat('h:mm a').format(_nextGameTime)} - ${DateFormat('h:mm a').format(_nextGameEndTime)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.90
                        
                        ), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bottom row: countdown + play button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Timer icon
                  Icon(
                    isLive ? Icons.play_circle_fill_rounded : Icons.timer_rounded,
                    color: isLive ? Colors.greenAccent.shade200 : Colors.amber.shade300,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  // Countdown or LIVE NOW
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLive ? 'Game is live — join now!' : 'Next game starts in',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.90), fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _countdownText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLive ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: isLive ? 0 : 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow / Play button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isLive ? 'Play' : 'View',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onBackground)),
          Text('See all', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }

  // ── Category Chips ──
  Widget _buildCategoryChips() {
    final categories = [
      ('Science', Icons.science_rounded),
      ('Maths', Icons.calculate_rounded),
      ('History', Icons.history_edu_rounded),
      ('English', Icons.translate_rounded),
      ('GK', Icons.public_rounded),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (label, icon) = categories[i];
          return Chip(
            avatar: Icon(icon, size: 18, color: AppColors.primary),
            label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  // ── Popular Books ──
  Widget _buildBooksList() {
    final books = [
      _BookData('Physics NCERT', 'Class 12', Colors.blue.shade700),
      _BookData('Chemistry', 'Organic & Inorganic', Colors.green.shade700),
      _BookData('Mathematics', 'Advanced Calculus', Colors.orange.shade700),
      _BookData('Biology', 'Human Physiology', Colors.red.shade700),
      _BookData('English', 'Grammar & Comp.', Colors.purple.shade700),
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final b = books[i];
          return SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  width: 120,
                  decoration: BoxDecoration(
                    color: b.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Icon(Icons.menu_book_rounded, size: 40, color: b.color)),
                ),
                const SizedBox(height: 8),
                Text(b.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(b.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── eBooks ──
  Widget _buildEbooksList() {
    final ebooks = [
      _BookData('Digital Marketing', 'Beginner Guide', Colors.teal.shade700),
      _BookData('AI & ML Basics', 'Introduction', Colors.indigo.shade700),
      _BookData('Web Dev', 'HTML, CSS, JS', Colors.amber.shade800),
      _BookData('Data Science', 'Python & R', Colors.cyan.shade700),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ebooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final e = ebooks[i];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: e.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: e.color.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.tablet_mac_rounded, color: e.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(e.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), maxLines: 1),
                      const SizedBox(height: 6),
                      Text('Read now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: e.color)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _BannerData(this.title, this.subtitle, this.icon, this.color);
}

class _BookData {
  final String title;
  final String subtitle;
  final Color color;
  _BookData(this.title, this.subtitle, this.color);
}
