import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../models/global_counts_model.dart';
import '../../models/home_model.dart';
import '../../providers/global_counts_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/reverb_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/theme_notifier.dart';

class GlobalCountsScreen extends StatefulWidget {
  const GlobalCountsScreen({super.key});

  @override
  State<GlobalCountsScreen> createState() => _GlobalCountsScreenState();
}

class _GlobalCountsScreenState extends State<GlobalCountsScreen>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _quoteFadeController;
  late Animation<double> _quoteFadeAnim;
  
  // Cinematic Entry Animations
  late AnimationController _entryController;
  final List<Animation<double>> _staggeredAnims = [];

  int _currentQuotePage = 0;
  bool _isRosaryMode = true;

  static const int rosaryGoal      = 150000000;
  static const int divineMercyGoal = 100000000;

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

    _quoteFadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteFadeController, curve: Curves.easeInOut),
    );
    _quoteFadeController.forward();

    // Cinematic Stagger Setup (5 sections)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    for (int i = 0; i < 5; i++) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      _staggeredAnims.add(
        CurvedAnimation(
          parent: _entryController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }

    // Fetch both prayer types on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GlobalCountsProvider>().fetchAll();
      _entryController.forward();
      // Setup WebSocket listeners and subscribe to dashboard
      _setupWebSocket();
    });
  }

  /// Setup WebSocket connection and subscriptions
  void _setupWebSocket() {
    // WebSocket is already initialized and subscribed in main.dart
    // No need to do anything here
    debugPrint('[GlobalCountsScreen] Reverb already initialized in main.dart');
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _quoteFadeController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onToggle(bool rosary) {
    if (_isRosaryMode == rosary) return;
    setState(() => _isRosaryMode = rosary);
    // Fetch the newly selected type if not yet loaded
    final provider = context.read<GlobalCountsProvider>();
    final typeId = rosary ? PrayerType.rosary : PrayerType.divineMercy;
    final cached = rosary ? provider.rosaryData : provider.divineMercyData;
    if (cached == null) provider.fetchOne(typeId);
  }

  void _advanceQuote(bool forward, int quoteCount) {
    _quoteFadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentQuotePage = forward
            ? (_currentQuotePage + 1) % quoteCount
            : (_currentQuotePage - 1 + quoteCount) % quoteCount;
      });
      _quoteFadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor =
            isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isDark
                ? const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.2,
                      colors: [
                        Color(0xFF4A4080),
                        Color(0xFF2A1F5E),
                        Color(0xFF100828),
                      ],
                      stops: [0.0, 0.50, 1.0],
                    ),
                  )
                : BoxDecoration(color: bgColor),
            child: SafeArea(
              child: Consumer2<GlobalCountsProvider, UserProvider>(
                builder: (_, provider, userProvider, __) {
                  final homeQuotes = context.read<HomeProvider>().data?.quotes ?? [];
                  final currentUserId = userProvider.userId;
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchAll(),
                    color: AppColors.goldPrimary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildCinematicSection(0, _buildHeader(isDark)),
                          const SizedBox(height: 16),
                          _buildCinematicSection(1, _buildQuoteCard(isDark, homeQuotes)),
                          const SizedBox(height: 16),
                          _buildCinematicSection(2, _buildGlobalCountCard(provider, isDark)),
                          const SizedBox(height: 16),
                          _buildCinematicSection(3, _buildStatsRow(provider)),
                          const SizedBox(height: 16),
                          _buildCinematicSection(4, _buildTopOfferingsCard(provider, currentUserId)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
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
            offset: Offset(0, 30 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    final badgeBg     = isDark ? Colors.white.withOpacity(0.1)  : const Color(0xFF22014D).withOpacity(0.08);
    final badgeBorder = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFF22014D).withOpacity(0.2);
    final badgeText   = isDark ? AppColors.goldLight : AppColors.goldDark;
    final titleColor  = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor    = isDark ? Colors.white.withOpacity(0.5) : AppColors.authBgMid.withOpacity(0.5);

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
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                  color: badgeText)),
        ),
        const SizedBox(height: 18),
        Text('Global Count',
            style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: -1)),
        const SizedBox(height: 6),
        Text('EVERY BEAD COUNTS',
            style: GoogleFonts.poppins(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: subColor)),
        const SizedBox(height: 20),
        _buildToggleButton(isDark),
      ],
    );
  }

  Widget _buildToggleButton(bool isDark) {
    final outerBg    = isDark ? const Color(0xFF2D1B4E) : Colors.white;
    final outerBorder = isDark
        ? const Color(0xFF3D2560)
        : const Color(0xFF22014D).withOpacity(0.18);
    final activePill = isDark ? Colors.white : const Color(0xFF3B0764);
    final activeText = isDark ? const Color(0xFF3B0764) : AppColors.goldPrimary;
    final inactiveText = isDark
        ? Colors.white.withOpacity(0.45)
        : AppColors.authBgMid.withOpacity(0.55);
    final shadowColor = isDark
        ? Colors.white.withOpacity(0.20)
        : const Color(0xFF22014D).withOpacity(0.35);

    Widget tab(String label, bool active, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          decoration: BoxDecoration(
            color: active ? activePill : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: active
                ? [BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, 3))]
                : [],
          ),
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? activeText : inactiveText,
                  letterSpacing: 0.3)),
        ),
      );
    }

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
          tab('Rosary',  _isRosaryMode,  () => _onToggle(true)),
          tab('Chaplet', !_isRosaryMode, () => _onToggle(false)),
        ],
      ),
    );
  }

  // ── Global count card ───────────────────────────────────────────────────────

  Widget _buildGlobalCountCard(GlobalCountsProvider provider, bool isDark) {
    final data        = provider.dataFor(_isRosaryMode ? PrayerType.rosary : PrayerType.divineMercy);
    final goal        = _isRosaryMode ? rosaryGoal : divineMercyGoal;
    final total       = data.communityTotal;
    final percentage  = goal > 0 ? (total / goal) * 100 : 0.0;
    final countLabel  = _isRosaryMode
        ? 'ROSARIES PRAYED WORLDWIDE'
        : 'TOTAL DIVINE MERCY CHAPLETS OFFERED';

    return _GlassCard(
      child: Column(
        children: [
          Text(countLabel,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: AppColors.authBgMid.withOpacity(0.5),
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          provider.isLoading
              ? const SizedBox(
                  height: 56,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.goldPrimary, strokeWidth: 2)))
              : Text(
                  _formatNumber(total),
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
              Text('Goal: ${_formatNumber(goal)}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.authBgMid.withOpacity(0.5),
                      fontWeight: FontWeight.w700)),
              Text('${percentage.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF22014D).withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(provider.errorMessage!,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  // ── Your contribution ───────────────────────────────────────────────────────

  Widget _buildStatsRow(GlobalCountsProvider provider) {
    final data  = provider.dataFor(_isRosaryMode ? PrayerType.rosary : PrayerType.divineMercy);
    final label = _isRosaryMode ? 'Rosaries' : 'Chaplets';

    return _GlassCard(
      child: Column(
        children: [
          Text('YOUR CONTRIBUTION',
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: AppColors.authBgMid.withOpacity(0.5),
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          provider.isLoading
              ? const SizedBox(
                  height: 42,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.goldPrimary, strokeWidth: 2)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(data.yourTotal.toString(),
                        style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.authBgBottom)),
                    const SizedBox(width: 8),
                    Text(label,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authBgMid.withOpacity(0.5))),
                  ],
                ),
          const SizedBox(height: 4),
          Text('Today: ${data.yourToday}',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldDark)),
          if (data.yourPosition > 0) ...[
            const SizedBox(height: 6),
            Text('Rank #${data.yourPosition}',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark)),
          ],
        ],
      ),
    );
  }

  // ── Quote card ──────────────────────────────────────────────────────────────

  Widget _buildQuoteCard(bool isDark, List<HomeQuote> quotes) {
    // Fallback static quotes if HomeProvider hasn't loaded yet
    final hasApiQuotes = quotes.isNotEmpty;
    final quoteCount   = hasApiQuotes ? quotes.length : 1;
    final safeIndex    = _currentQuotePage.clamp(0, quoteCount - 1);

    final shadowColor    = isDark ? AppColors.authBgBottom.withOpacity(0.20) : const Color(0xFF624294).withOpacity(0.15);
    final borderColor    = isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.12);
    final activeDotColor = isDark ? const Color(0xFF624294) : AppColors.goldPrimary;

    String quoteText;
    String quoteAuthor;
    if (hasApiQuotes) {
      final q = quotes[safeIndex];
      quoteText   = q.quotation;
      final ref   = q.reference.trim();
      quoteAuthor = ref.isEmpty ? '' : (ref.startsWith('—') ? ref : '— $ref');
    } else {
      quoteText   = '"With God, all things are possible."';
      quoteAuthor = '— Matthew 19:26';
    }

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity == null) return;
        _advanceQuote(d.primaryVelocity! < 0, quoteCount);
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
            border: Border.all(
                color: isDark ? Colors.white : borderColor,
                width: isDark ? 2.0 : 1.5),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u275D',
                  style: TextStyle(
                      fontSize: 20,
                      color: const Color(0xFF624294).withOpacity(0.45),
                      height: 1.0)),
              const SizedBox(height: 6),
              Text(
                quoteText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isDark ? FontWeight.w500 : FontWeight.w700,
                    color: const Color(0xFF624294),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    letterSpacing: 0.2),
              ),
              const SizedBox(height: 8),
              if (quoteAuthor.isNotEmpty)
                Text(quoteAuthor,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF624294),
                        letterSpacing: 1.2)),
              const SizedBox(height: 10),
              if (quoteCount > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(quoteCount, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == safeIndex ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == safeIndex
                            ? activeDotColor
                            : const Color(0xFF624294).withOpacity(0.25),
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

  // ── Top offerings / leaderboard ─────────────────────────────────────────────

  Widget _buildTopOfferingsCard(GlobalCountsProvider provider, int currentUserId) {
    final data        = provider.dataFor(_isRosaryMode ? PrayerType.rosary : PrayerType.divineMercy);
    final leaderboard = data.leaderboard;
    final prayerLabel = _isRosaryMode ? 'Rosaries offered' : 'Chaplets offered';

    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Offerings',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authBgBottom)),
              _buildLiveBadge(),
            ],
          ),
          const SizedBox(height: 24),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                  color: AppColors.goldPrimary, strokeWidth: 2),
            )
          else if (leaderboard.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('No data yet',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.authBgMid.withOpacity(0.5))),
            )
          else
            _buildLeaderboardList(leaderboard, prayerLabel, currentUserId),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(
      List<LeaderboardEntry> entries, String prayerLabel, int currentUserId) {
    const double itemHeight = 80.0;
    final totalHeight = entries.length * itemHeight;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: entries.map((entry) {
          // position is 1-based from API — convert to 0-based top offset
          final top = (entry.position - 1) * itemHeight;
          return AnimatedPositioned(
            key: ValueKey(entry.userId),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            top: top,
            left: 0,
            right: 0,
            height: itemHeight,
            child: _buildOfferingItem(entry, prayerLabel, currentUserId),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfferingItem(LeaderboardEntry entry, String prayerLabel, int currentUserId) {
    final isYou = entry.userId == currentUserId;
    return Container(
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
              border: Border.all(
                  color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            )
          : null,
      child: Row(
        children: [
          _buildRankBadge(entry.position, isYou),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isYou
                                  ? AppColors.goldDark
                                  : AppColors.authBgBottom)),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.goldDark, AppColors.goldPrimary]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('YOU',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                Text(prayerLabel,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isYou
                            ? AppColors.goldDark.withOpacity(0.6)
                            : AppColors.authBgMid.withOpacity(0.4),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.totalCount.toString(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isYou ? AppColors.goldDark : AppColors.authBgBottom)),
              Text('today: ${entry.todayCount}',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isYou
                          ? AppColors.goldDark.withOpacity(0.6)
                          : AppColors.authBgMid.withOpacity(0.4),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, bool isYou) {
    Color bg     = const Color(0xFF22014D).withOpacity(0.05);
    Color border = const Color(0xFF22014D).withOpacity(0.15);
    Color text   = AppColors.authBgBottom;

    if (rank == 1) {
      bg     = AppColors.goldPrimary.withOpacity(0.1);
      border = AppColors.goldPrimary.withOpacity(0.3);
      text   = AppColors.goldDark;
    } else if (isYou) {
      bg     = AppColors.goldPrimary.withOpacity(0.08);
      border = AppColors.goldPrimary.withOpacity(0.25);
      text   = AppColors.goldDark;
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
        child: Text('$rank',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: text)),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Consumer<ReverbProvider>(
      builder: (_, reverbProvider, __) {
        final isConnected = reverbProvider.isConnected;
        final statusColor = isConnected ? Colors.green : Colors.red;
        final statusText = isConnected ? 'LIVE' : 'OFFLINE';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (_, __) => Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(_blinkAnimation.value),
                    boxShadow: [
                      if (_blinkAnimation.value > 0.5)
                        BoxShadow(
                            color: statusColor.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(statusText,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 1)),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatNumber(int number) {
    if (number >= 1000000) {
      final m = number / 1000000;
      return m == m.toInt() ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
  }
}

// ── _GlassCard ───────────────────────────────────────────────────────────────

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
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 12)),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF624294).withOpacity(0.10),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.white.withOpacity(0.80),
              blurRadius: 4,
              offset: const Offset(0, -2)),
        ],
      ),
      child: child,
    );
  }
}
