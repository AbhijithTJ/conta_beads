import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  Timer? _shuffleTimer;
  final _random = Random();
  final int goalCount = 150000000;
  final String quote = 'Every bead is a whisper of love to heaven.';

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
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF560737),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildGlobalCountCard(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildQuoteCard(),
                const SizedBox(height: 16),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Text(
            'COMMUNITY PRAYER',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              color: AppColors.goldLight,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Global Count',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'UNITED IN SPIRIT AND FAITH',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalCountCard() {
    final double percentage = goalCount > 0 ? (widget.globalCount / goalCount) * 100 : 0;

    return _GlassCard(
      child: Column(
        children: [
          Text(
            'TOTAL ROSARIES OFFERED',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.authBgMid.withOpacity(0.5),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatNumber(widget.globalCount),
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
                'Goal: ${_formatNumber(goalCount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.authBgMid.withOpacity(0.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.authPurple.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Together, we are building a river of prayer',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.authBgMid.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return _GlassCard(
      child: Column(
        children: [
          Text(
            'YOUR TOTAL',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.authBgMid.withOpacity(0.5),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.personalCount.toString(),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.authBgBottom,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'rosaries',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authBgMid.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: TextStyle(
              fontSize: 32,
              color: AppColors.authPurple.withOpacity(0.3),
              height: 1.0,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.authBgMid.withOpacity(0.8),
                fontStyle: FontStyle.italic,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
              const Text(
                'Top Offerings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.authBgBottom,
                ),
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.red,
              letterSpacing: 1,
            ),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isYou ? AppColors.goldDark : AppColors.authBgBottom,
                        ),
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
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'rosaries offered today',
                    style: TextStyle(
                      fontSize: 11,
                      color: isYou ? AppColors.goldDark.withOpacity(0.6) : AppColors.authBgMid.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
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
    Color bg = AppColors.authPurple.withOpacity(0.05);
    Color border = AppColors.authPurple.withOpacity(0.15);
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
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.5,
            ),
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
