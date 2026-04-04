import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../colors/colors.dart';

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
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  Timer? _shuffleTimer;
  final _random = Random();
  // GlobalCounts - Track previous order for slide direction
  Map<String, int> _previousRanks = {};
  final int goalCount = 150000000;
  final String quote = 'Every bead is a whisper of love to heaven.';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    communityData = [
      {'name': 'Emma',     'count': 56, 'isYou': false},
      {'name': 'Rachel',   'count': 42, 'isYou': false},
      {'name': 'James T.', 'count': 38, 'isYou': false},
      {'name': 'You',      'count': widget.personalCount, 'isYou': true},
    ];
    // GlobalCounts - Store initial ranks
    _previousRanks = {
      for (int i = 0; i < communityData.length; i++)
        communityData[i]['name'] as String: i
    };

    // GlobalCounts - Shuffle timer: randomly increment and re-sort with slide animation
    _shuffleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      // Save old ranks before sort
      final oldRanks = {
        for (int i = 0; i < communityData.length; i++)
          communityData[i]['name'] as String: i
      };
      setState(() {
        final nonYou = communityData
            .where((e) => !(e['isYou'] as bool? ?? false))
            .toList();
        if (nonYou.isNotEmpty) {
          final pick = nonYou[_random.nextInt(nonYou.length)];
          pick['count'] = (pick['count'] as int) + _random.nextInt(3) + 1;
        }
        communityData.sort((a, b) =>
            (b['count'] as int).compareTo(a['count'] as int));
        _previousRanks = oldRanks;
      });
    });
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _glowController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GlobalCounts - Background matches intentions screen light gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.skyTop.withOpacity(0.05),
              AppColors.skyMid.withOpacity(0.05),
              AppColors.skyBottom.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildGlobalCountCard(),
                const SizedBox(height: 14),
                _buildStatsRow(),
                const SizedBox(height: 14),
                _buildQuoteCard(),
                const SizedBox(height: 14),
                _buildTopOfferingsCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // GlobalCounts - Label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.goldPrimary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.goldPrimary.withOpacity(0.25),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'COMMUNITY PRAYER',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // GlobalCounts - Title with gold gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Global Count',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalCountCard() {
    final double percentage =
        goalCount > 0 ? (widget.globalCount / goalCount) * 100 : 0;

    return _glowCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // GlobalCounts - Total rosaries label
          Text(
            'TOTAL ROSARIES OFFERED',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // GlobalCounts - Global count number
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              _formatNumber(widget.globalCount),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -2,
                height: 1,
              ),
            ),
          ),
          _divider(),
          // GlobalCounts - Goal progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal: ${_formatNumber(goalCount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // GlobalCounts - Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.goldPrimary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),
          const SizedBox(height: 14),
          // GlobalCounts - Motivational text
          Text(
            'Together, we are building a river of prayer',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildStatsRow() {
    return _buildStatCard('YOUR TOTAL', widget.personalCount.toString(), 'rosaries');
  }

  Widget _buildStatCard(String label, String value, String sub) {
    return _glowCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // GlobalCounts - Stat label
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // GlobalCounts - Stat value with gold gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.goldDark, AppColors.goldPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // GlobalCounts - Stat sub label
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return _glowCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GlobalCounts - Quote mark
            Text(
              '"',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.goldPrimary.withOpacity(0.5),
                height: 1,
              ),
            ),
            const SizedBox(width: 8),
            // GlobalCounts - Quote text
            Expanded(
              child: Text(
                quote,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.75),
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOfferingsCard() {
    return _glowCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // GlobalCounts - Top offerings title
                const Text(
                  'Top offerings today',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                // GlobalCounts - Live badge with fixed size
                SizedBox(
                  height: 28,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // GlobalCounts - Live blinking red dot indicator
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
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5 * _blinkAnimation.value),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // GlobalCounts - Premium live leaderboard with smooth slot-swap animation
            _LiveLeaderboard(
              items: communityData,
              buildItem: _buildOfferingItem,
              itemHeight: 90.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingItem(int index) {
    final item   = communityData[index];
    final rank   = index + 1;
    final name   = item['name'] as String;
    final count  = item['count'] as int;
    final isYou  = (item['isYou'] as bool?) ?? false;

    final rankStyle = isYou ? _getYouStyle() : _getRankStyle(rank);

    return Column(
      children: [
        if (index > 0) _divider(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: isYou
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
              : EdgeInsets.zero,
          decoration: isYou
              ? BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // GlobalCounts - Rank circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rankStyle['bg'] as Color,
                    border: Border.all(
                      color: rankStyle['border'] as Color,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: rankStyle['text'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GlobalCounts - Offering name
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: rankStyle['nameColor'] as Color,
                            ),
                          ),
                          if (isYou) ...[
                            const SizedBox(width: 6),
                            // GlobalCounts - You badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldDark,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // GlobalCounts - Offering sub label
                      Text(
                        'rosaries offered today',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                // GlobalCounts - Offering count with gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: rankStyle['numGradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // GlobalCounts - "You" row style with gold highlight
  Map<String, dynamic> _getYouStyle() {
    return {
      'bg': AppColors.goldPrimary.withOpacity(0.2),
      'border': AppColors.goldPrimary.withOpacity(0.5),
      'text': AppColors.goldDark,
      'nameColor': AppColors.textPrimary,
      'numGradient': [AppColors.goldDark, AppColors.goldPrimary],
    };
  }

  Map<String, dynamic> _getRankStyle(int rank) {
    if (rank == 1) {
      // GlobalCounts - Gold rank style
      return {
        'bg': AppColors.goldPrimary.withOpacity(0.12),
        'border': AppColors.goldPrimary.withOpacity(0.35),
        'text': AppColors.goldDark,
        'nameColor': AppColors.textPrimary,
        'numGradient': [AppColors.goldDark, AppColors.goldPrimary],
      };
    } else if (rank == 2) {
      // GlobalCounts - Silver rank style
      return {
        'bg': AppColors.greyButton.withOpacity(0.12),
        'border': AppColors.greyButton.withOpacity(0.3),
        'text': AppColors.greyDark,
        'nameColor': AppColors.textSecondary,
        'numGradient': [AppColors.greyDark, AppColors.greyButton],
      };
    } else {
      // GlobalCounts - Bronze rank style
      return {
        'bg': AppColors.skyMid.withOpacity(0.2),
        'border': AppColors.textSecondary.withOpacity(0.2),
        'text': AppColors.textSecondary,
        'nameColor': AppColors.textSecondary,
        'numGradient': [AppColors.textSecondary, AppColors.skyBottom],
      };
    }
  }

  // GlobalCounts - Shared card decoration with pulsing glow effect
  BoxDecoration _cardDecoration({double glowValue = 0.5}) {
    return BoxDecoration(
      color: AppColors.skyMid.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.skyBottom.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        // GlobalCounts - Pulsing blue glow
        BoxShadow(
          color: AppColors.skyMid.withOpacity(0.15 + 0.25 * glowValue),
          blurRadius: 16 + 14 * glowValue,
          spreadRadius: 1 + 2 * glowValue,
          offset: const Offset(0, 4),
        ),
        // GlobalCounts - Static white inner glow
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(-2, -2),
        ),
      ],
    );
  }

  // GlobalCounts - Animated glow card wrapper
  Widget _glowCard({required Widget child}) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          decoration: _cardDecoration(glowValue: _glowAnimation.value),
          child: child,
        );
      },
    );
  }

  // GlobalCounts - Divider between list items
  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.goldPrimary.withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
      );

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
  }
}

/// Premium live leaderboard — each tile animates to its new slot position
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
  // Maps name → current animated top position
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
    // Update target positions based on new order
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
            child: ClipRect(
              child: widget.buildItem(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}
