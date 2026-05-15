import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../colors/colors.dart';
import '../models/global_counts_model.dart';
import '../providers/global_counts_provider.dart';
import '../providers/reverb_provider.dart';
import '../theme/theme_notifier.dart';

/// Frosted-glass "Top Offerings" panel shown as an overlay on the counting screen.
class GlobalCountPanel extends StatefulWidget {
  final bool isRosary;
  final Animation<double> blinkAnimation;
  final VoidCallback onClose;

  // Each row is 68px tall — keep in sync with _AnimatedLeaderboard.itemHeight
  static const double _itemHeight = 68.0;

  const GlobalCountPanel({
    super.key,
    required this.isRosary,
    required this.blinkAnimation,
    required this.onClose,
  });

  @override
  State<GlobalCountPanel> createState() => _GlobalCountPanelState();
}

class _GlobalCountPanelState extends State<GlobalCountPanel> with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  // Cinematic Entry Animations
  late AnimationController _entryController;
  final List<Animation<double>> _staggeredAnims = [];

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

    // Cinematic Stagger Setup
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    for (int i = 0; i < 3; i++) {
      final start = i * 0.15;
      final end = (start + 0.6).clamp(0.0, 1.0);
      _staggeredAnims.add(
        CurvedAnimation(
          parent: _entryController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }
    _entryController.forward();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return Consumer<GlobalCountsProvider>(
      builder: (context, provider, _) {
        final data = provider.dataFor(widget.isRosary ? PrayerType.rosary : PrayerType.divineMercy);
        final leaderboard = data.leaderboard;
        return isDark ? _buildDarkPanel(leaderboard) : _buildLightPanel(leaderboard);
      },
    );
  }

  // ── Cinematic Helper ────────────────────────────────────────────────────────

  Widget _buildCinematicSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggeredAnims[index],
      builder: (context, child) {
        final value = _staggeredAnims[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildDarkPanel(List<LeaderboardEntry> leaderboard) {
    return SizedBox(
      width: 280,
      height: 380,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
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
            child: _buildContent(isDark: true, leaderboard: leaderboard),
          ),
        ),
      ),
    );
  }

  Widget _buildLightPanel(List<LeaderboardEntry> leaderboard) {
    return SizedBox(
      width: 280,
      height: 380,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
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
        child: _buildContent(isDark: false, leaderboard: leaderboard),
      ),
    );
  }

  Widget _buildContent({required bool isDark, required List<LeaderboardEntry> leaderboard}) {
    return Column(
      children: [
        // ── Header ──
        _buildCinematicSection(
          0,
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Icon(Icons.public_rounded, color: AppColors.authBgBottom, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Top Offerings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.authBgBottom,
                  ),
                ),
                const Spacer(),
                const _buildLiveBadge(),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(Icons.close_rounded, color: AppColors.authBgMid.withOpacity(0.5), size: 20),
                ),
              ],
            ),
          ),
        ),
        _buildCinematicSection(
          1,
          Divider(
            color: AppColors.authBgMid.withOpacity(0.1),
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
        ),
        // ── Scrollable Leaderboard ──
        Expanded(
          child: _buildCinematicSection(
            2,
            leaderboard.isEmpty
                ? Center(
                    child: Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.authBgMid.withOpacity(0.5),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _AnimatedLeaderboard(items: leaderboard, itemHeight: GlobalCountPanel._itemHeight, isDark: isDark),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Animated leaderboard — rows slide to new positions on re-sort ─────────────
class _AnimatedLeaderboard extends StatefulWidget {
  final List<LeaderboardEntry> items;
  final double itemHeight;
  final bool isDark;

  const _AnimatedLeaderboard({required this.items, required this.itemHeight, required this.isDark});

  @override
  State<_AnimatedLeaderboard> createState() => _AnimatedLeaderboardState();
}

class _AnimatedLeaderboardState extends State<_AnimatedLeaderboard> {
  late Map<int, double> _positions;

  @override
  void initState() {
    super.initState();
    _positions = {
      for (int i = 0; i < widget.items.length; i++)
        widget.items[i].userId: i * widget.itemHeight,
    };
  }

  @override
  void didUpdateWidget(_AnimatedLeaderboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate target positions whenever the sorted list changes
    setState(() {
      for (int i = 0; i < widget.items.length; i++) {
        _positions[widget.items[i].userId] = i * widget.itemHeight;
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
          final userId = item.userId;
          final index = widget.items.indexOf(item);
          final top = _positions[userId] ?? index * widget.itemHeight;
          return AnimatedPositioned(
            key: ValueKey(userId),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            top: top,
            left: 0,
            right: 0,
            height: widget.itemHeight,
            child: LeaderRow(
              rank: item.position,
              name: item.name,
              count: item.totalCount,
              isYou: item.isCurrentUser,
              isDark: widget.isDark,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Live blinking badge ───────────────────────────────────────────────────────
class _buildLiveBadge extends StatelessWidget {
  const _buildLiveBadge();

  @override
  Widget build(BuildContext context) {
    return Consumer<ReverbProvider>(
      builder: (_, reverbProvider, __) {
        final isConnected = reverbProvider.isConnected;
        final statusColor = isConnected ? Colors.green : Colors.red;
        final statusText = isConnected ? 'LIVE' : 'OFFLINE';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use the panel's blink animation
              _LiveDot(statusColor: statusColor),
              const SizedBox(width: 5),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Live dot with blinking animation ────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  final Color statusColor;
  const _LiveDot({required this.statusColor});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

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
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.statusColor.withOpacity(_blinkAnimation.value),
          boxShadow: [
            if (_blinkAnimation.value > 0.5)
              BoxShadow(color: widget.statusColor.withOpacity(0.5), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

// ── Single leaderboard row ────────────────────────────────────────────────────
class LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final bool isYou;
  final bool isDark;

  const LeaderRow({
    super.key,
    required this.rank,
    required this.name,
    required this.count,
    required this.isYou,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final isGold = rank == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: isYou
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
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
          // rank badge
          _buildRankBadge(rank, isYou),
          const SizedBox(width: 12),
          // name + YOU badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isYou ? AppColors.goldDark : AppColors.authBgBottom,
                        ),
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.goldDark, AppColors.goldPrimary]),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('YOU', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // count
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isYou ? AppColors.goldDark : AppColors.authBgBottom,
            ),
          ),
        ],
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
    } else if (isYou) {
      bg = AppColors.goldPrimary.withOpacity(0.08);
      border = AppColors.goldPrimary.withOpacity(0.25);
      text = AppColors.goldDark;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: Text('$rank', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: text)),
      ),
    );
  }
}
