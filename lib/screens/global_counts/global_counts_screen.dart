import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';

class GlobalCountsScreen extends StatefulWidget {
  final int personalCount;
  final int globalCount;

  const GlobalCountsScreen({
    super.key,
    required this.personalCount,
    required this.globalCount,
  });

  @override
  State<GlobalCountsScreen> createState() => _GlobalCountsScreenState();
}

class _GlobalCountsScreenState extends State<GlobalCountsScreen>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> communityData;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _quoteFadeController;
  late Animation<double> _quoteFadeAnim;

  Timer? _shuffleTimer;
  Timer? _quoteTimer;
  int _currentQuotePage = 0;
  final _random = Random();
  final int goalCount = 150000000;
  
  // Toggle state for Rosary vs Divine Mercy
  bool _isRosaryMode = true;
  final int divineMercyGoalCount = 100000000;
  final List<Map<String, String>> quotes = [
    {'text': 'Every bead is a whisper of love to heaven.', 'author': ''},
    {'text': '"The rosary is the most excellent form of prayer."', 'author': 'Pope Paul VI'},
    {'text': '"To pray is to let Jesus into our lives."', 'author': 'Ole Hallesby'},
    {'text': '"Prayer is the key of the morning and the bolt of the evening."', 'author': 'Mahatma Gandhi'},
    {'text': '"With God, all things are possible."', 'author': 'Matthew 19:26'},
  ];

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _quoteFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteFadeController, curve: Curves.easeInOut),
    );
    _quoteFadeController.forward();

    communityData = [
      {'name': 'Emma', 'count': 56, 'isYou': false},
      {'name': 'Rachel', 'count': 42, 'isYou': false},
      {'name': 'James T.', 'count': 38, 'isYou': false},
      {'name': 'You', 'count': widget.personalCount, 'isYou': true},
    ];

    _shuffleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final nonYou = communityData
            .where((e) => !(e['isYou'] as bool? ?? false))
            .toList();
        if (nonYou.isNotEmpty) {
          final pick = nonYou[_random.nextInt(nonYou.length)];
          pick['count'] = (pick['count'] as int) + _random.nextInt(3) + 1;
        }
        communityData.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      });
    });

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _quoteFadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentQuotePage = (_currentQuotePage + 1) % quotes.length);
        _quoteFadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _quoteTimer?.cancel();
    _quoteFadeController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: bgColor),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(isDark),
                    const SizedBox(height: 16),
                    _buildQuoteCard(isDark),
                    const SizedBox(height: 16),
                    _buildGlobalCountCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildTopOfferingsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final badgeBg = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF22014D).withOpacity(0.08);
    final badgeBorder = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF22014D).withOpacity(0.2);
    final badgeText = isDark ? AppColors.goldLight : AppColors.goldDark;
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.authBgMid.withOpacity(0.5);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: badgeBorder),
          ),
          child: Text('COMMUNITY PRAYER',
              style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800, color: badgeText)),
        ),
        const SizedBox(height: 18),
        Text('Global Count',
            style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w900, color: titleColor, letterSpacing: -1)),
        const SizedBox(height: 6),
        Text('UNITED IN SPIRIT AND FAITH',
            style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: subColor)),
        const SizedBox(height: 20),
        _buildToggleButton(isDark),
      ],
    );
  }

  Widget _buildToggleButton(bool isDark) {
    // ── Dark mode colours (from reference image) ──
    // Outer pill: deep dark purple background
    // Active pill: white
    // Active text: deep purple
    // Inactive text: muted light grey

    // ── Light mode colours (unchanged) ──
    // Outer pill: white
    // Active pill: deep dark purple (#3B0764)
    // Active text: gold
    // Inactive text: muted purple-grey

    final outerBg = isDark
        ? const Color(0xFF2D1B4E)          // dark purple pill track
        : Colors.white;
    final outerBorder = isDark
        ? const Color(0xFF3D2560)          // slightly lighter purple border
        : const Color(0xFF22014D).withOpacity(0.18);

    final activePillColor = isDark
        ? Colors.white                     // white pill in dark mode
        : const Color(0xFF3B0764);         // dark purple pill in light mode

    final activeTextColor = isDark
        ? const Color(0xFF3B0764)          // deep purple text on white pill
        : AppColors.goldPrimary;           // gold text on dark pill

    final inactiveTextColor = isDark
        ? Colors.white.withOpacity(0.45)   // muted white in dark mode
        : AppColors.authBgMid.withOpacity(0.55);

    final activeShadowColor = isDark
        ? Colors.white.withOpacity(0.20)
        : const Color(0xFF22014D).withOpacity(0.35);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: outerBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22014D).withOpacity(isDark ? 0.0 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Rosary tab ──
          GestureDetector(
            onTap: () => setState(() => _isRosaryMode = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                color: _isRosaryMode ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                boxShadow: _isRosaryMode
                    ? [BoxShadow(color: activeShadowColor, blurRadius: 10, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Text(
                'Rosary',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _isRosaryMode ? activeTextColor : inactiveTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          // ── Chaplet tab ──
          GestureDetector(
            onTap: () => setState(() => _isRosaryMode = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                color: !_isRosaryMode ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
                boxShadow: !_isRosaryMode
                    ? [BoxShadow(color: activeShadowColor, blurRadius: 10, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Text(
                'Chaplet',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: !_isRosaryMode ? activeTextColor : inactiveTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalCountCard() {
    final currentGoal = _isRosaryMode ? goalCount : divineMercyGoalCount;
    final currentGlobalCount = _isRosaryMode ? widget.globalCount : (widget.globalCount * 80 ~/ 100); // Divine Mercy is 80% of Rosary for demo
    final double percentage = currentGoal > 0 ? (currentGlobalCount / currentGoal) * 100 : 0;
    final countLabel = _isRosaryMode ? 'TOTAL ROSARIES OFFERED' : 'TOTAL DIVINE MERCY CHAPLETS OFFERED';

    return _GlassCard(
      child: Column(
        children: [
          Text(
            countLabel,
            style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 2, color: AppColors.authBgMid.withOpacity(0.5), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            _formatNumber(currentGlobalCount),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: AppColors.authBgBottom,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal: ${_formatNumber(currentGoal)}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.authBgMid.withOpacity(0.5), fontWeight: FontWeight.w700),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.goldDark, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF22014D).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _isRosaryMode 
              ? 'Together, we are building a river of prayer'
              : 'Together, we are spreading Divine Mercy',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.authBgMid.withOpacity(0.6), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final personalCountDisplay = _isRosaryMode 
      ? widget.personalCount 
      : (widget.personalCount * 75 ~/ 100); // Divine Mercy is 75% of Rosary for demo
    final label = _isRosaryMode ? 'rosaries' : 'chaplets';

    return _GlassCard(
      child: Column(
        children: [
          Text(
            'YOUR TOTAL',
            style: GoogleFonts.poppins(fontSize: 10, letterSpacing: 2, color: AppColors.authBgMid.withOpacity(0.5), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                personalCountDisplay.toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.authBgBottom,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.authBgMid.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    final quote = quotes[_currentQuotePage];
    final quoteTextColor = const Color(0xFF624294);
    final shadowColor = isDark ? AppColors.authBgBottom.withOpacity(0.20) : const Color(0xFF624294).withOpacity(0.15);
    final borderColor = isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.12);
    final activeDotColor = isDark ? const Color(0xFF624294) : AppColors.goldPrimary;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        _quoteFadeController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            if (details.primaryVelocity! < 0) {
              _currentQuotePage = (_currentQuotePage + 1) % quotes.length;
            } else {
              _currentQuotePage = (_currentQuotePage - 1 + quotes.length) % quotes.length;
            }
          });
          _quoteFadeController.forward();
        });
      },
      child: FadeTransition(
        opacity: _quoteFadeAnim,
        child: Container(
          width: double.infinity,
          height: 160,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? Colors.white : borderColor, width: isDark ? 2.0 : 1.5),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u275D', style: TextStyle(fontSize: 20, color: const Color(0xFF624294).withOpacity(0.45), height: 1.0)),
              const SizedBox(height: 6),
              Text(
                quote['text']!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.5, fontWeight: isDark ? FontWeight.w500 : FontWeight.w700, color: quoteTextColor, fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0.2),
              ),
              const SizedBox(height: 8),
              if (quote['author']!.isNotEmpty)
                Text(quote['author']!,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF624294), letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(quotes.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentQuotePage ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _currentQuotePage ? activeDotColor : const Color(0xFF624294).withOpacity(0.25),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTopOfferingsCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Offerings',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.authBgBottom),
              ),
              _buildLiveBadge(),
            ],
          ),
          const SizedBox(height: 24),
          _LiveLeaderboard(
            items: communityData,
            buildItem: _buildOfferingItem,
            itemHeight: 80.0,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _blinkAnimation,
            builder: (context, _) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(_blinkAnimation.value),
                  boxShadow: [
                    if (_blinkAnimation.value > 0.5)
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingItem(int index) {
    final item = communityData[index];
    final rank = index + 1;
    final name = item['name'] as String;
    final count = item['count'] as int;
    final isYou = (item['isYou'] as bool?) ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: isYou ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12) : const EdgeInsets.symmetric(horizontal: 4),
        decoration: isYou
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldPrimary.withOpacity(0.15),
                    AppColors.goldLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.goldPrimary.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Row(
          children: [
            _buildRankBadge(rank, isYou),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: isYou ? AppColors.goldDark : AppColors.authBgBottom),
                      ),
                      if (isYou) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.goldDark, AppColors.goldPrimary],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('YOU', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'rosaries offered today',
                    style: GoogleFonts.poppins(fontSize: 11, color: isYou ? AppColors.goldDark.withOpacity(0.6) : AppColors.authBgMid.withOpacity(0.4), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isYou ? AppColors.goldDark : AppColors.authBgBottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank, bool isYou) {
    Color bg = const Color(0xFF22014D).withOpacity(0.05);
    Color border = const Color(0xFF22014D).withOpacity(0.15);
    Color text = AppColors.authBgBottom;

    if (rank == 1) {
      bg = AppColors.goldPrimary.withOpacity(0.1);
      border = AppColors.goldPrimary.withOpacity(0.3);
      text = AppColors.goldDark;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    // Light mode — matches home screen card style
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF624294).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF624294).withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.80),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LiveLeaderboard extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Widget Function(int index) buildItem;
  final double itemHeight;

  const _LiveLeaderboard({
    required this.items,
    required this.buildItem,
    required this.itemHeight,
  });

  @override
  State<_LiveLeaderboard> createState() => _LiveLeaderboardState();
}

class _LiveLeaderboardState extends State<_LiveLeaderboard> {
  late Map<String, double> _positions;

  @override
  void initState() {
    super.initState();
    _positions = {
      for (int i = 0; i < widget.items.length; i++)
        widget.items[i]['name'] as String: i * widget.itemHeight,
    };
  }

  @override
  void didUpdateWidget(_LiveLeaderboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      for (int i = 0; i < widget.items.length; i++) {
        _positions[widget.items[i]['name'] as String] = i * widget.itemHeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.items.length * widget.itemHeight;
    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: widget.items.map((item) {
          final name = item['name'] as String;
          final index = widget.items.indexOf(item);
          final top = _positions[name] ?? index * widget.itemHeight;
          return AnimatedPositioned(
            key: ValueKey(name),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            top: top,
            left: 0,
            right: 0,
            height: widget.itemHeight,
            child: widget.buildItem(index),
          );
        }).toList(),
      ),
    );
  }
}
