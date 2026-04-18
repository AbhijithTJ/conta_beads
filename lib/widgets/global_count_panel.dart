import 'dart:ui';
import 'package:flutter/material.dart';
import '../colors/colors.dart';

/// Frosted-glass "Top Offerings" panel shown as an overlay on the counting screen.
class GlobalCountPanel extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData;
  final Animation<double> blinkAnimation;
  final VoidCallback onClose;

  // Each row is 68px tall — keep in sync with _AnimatedLeaderboard.itemHeight
  static const double _itemHeight = 68.0;

  const GlobalCountPanel({
    super.key,
    required this.leaderboardData,
    required this.blinkAnimation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(
        scale: v,
        alignment: Alignment.bottomCenter,
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.93),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Row(
                  children: [
                    const Icon(Icons.public_rounded, color: AppColors.authPurple, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Top Offerings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.authBgBottom,
                      ),
                    ),
                    const Spacer(),
                    LiveBadge(blinkAnimation: blinkAnimation),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.authBgBottom.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Animated leaderboard ──
                _AnimatedLeaderboard(
                  items: leaderboardData,
                  itemHeight: _itemHeight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated leaderboard — rows slide to new positions on re-sort ─────────────
class _AnimatedLeaderboard extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double itemHeight;

  const _AnimatedLeaderboard({required this.items, required this.itemHeight});

  @override
  State<_AnimatedLeaderboard> createState() => _AnimatedLeaderboardState();
}

class _AnimatedLeaderboardState extends State<_AnimatedLeaderboard> {
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
  void didUpdateWidget(_AnimatedLeaderboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate target positions whenever the sorted list changes
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
          final count = item['count'] as int;
          final isYou = (item['isYou'] as bool?) ?? false;
          final top = _positions[name] ?? index * widget.itemHeight;
          return AnimatedPositioned(
            key: ValueKey(name),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            top: top,
            left: 0,
            right: 0,
            height: widget.itemHeight,
            child: LeaderRow(
              rank: index + 1,
              name: name,
              count: count,
              isYou: isYou,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Live blinking badge ───────────────────────────────────────────────────────
class LiveBadge extends StatelessWidget {
  final Animation<double> blinkAnimation;
  const LiveBadge({super.key, required this.blinkAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: blinkAnimation,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(blinkAnimation.value),
                boxShadow: [
                  if (blinkAnimation.value > 0.5)
                    BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.red,
              letterSpacing: 1,
            ),
          ),
        ],
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

  const LeaderRow({
    super.key,
    required this.rank,
    required this.name,
    required this.count,
    required this.isYou,
  });

  @override
  Widget build(BuildContext context) {
    final isGold = rank == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: isYou ? 12 : 4, vertical: 10),
      decoration: isYou
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary.withOpacity(0.15),
                  AppColors.goldLight.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.4),
                width: 1.5,
              ),
            )
          : null,
      child: Row(
        children: [
          // rank badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGold
                  ? AppColors.goldPrimary.withOpacity(0.12)
                  : AppColors.authPurple.withOpacity(0.06),
              border: Border.all(
                color: isGold
                    ? AppColors.goldPrimary.withOpacity(0.35)
                    : AppColors.authPurple.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isGold ? AppColors.goldDark : AppColors.authBgBottom,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // name + YOU badge
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isYou ? AppColors.goldDark : AppColors.authBgBottom,
                  ),
                ),
                if (isYou) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.goldPrimary],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
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
}
