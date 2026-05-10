import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../models/prayer_history_model.dart';
import '../../providers/prayer_history_provider.dart';
import '../../theme/theme_notifier.dart';

class PrayerHistoryScreen extends StatefulWidget {
  const PrayerHistoryScreen({super.key});

  @override
  State<PrayerHistoryScreen> createState() => _PrayerHistoryScreenState();
}

class _PrayerHistoryScreenState extends State<PrayerHistoryScreen> {
  bool _isRosaryMode = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerHistoryProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final provider = context.read<PrayerHistoryProvider>();
      if (!provider.isLoading && provider.hasNextPage) {
        provider.nextPage();
      }
    }
  }

  void _onToggle(bool rosary) {
    if (_isRosaryMode == rosary) return;
    setState(() => _isRosaryMode = rosary);
    final prayerTypeId = rosary ? 1 : 2;
    context.read<PrayerHistoryProvider>().changePrayerType(prayerTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark
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
            : const BoxDecoration(color: Color(0xFFF0EBF0));
        return Scaffold(
          appBar: AppBar(
            title: Text('Prayer History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark ? const Color(0xFF22014D) : Colors.white,
            foregroundColor: isDark ? Colors.white : AppColors.authBgBottom,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: bgColor,
            child: SafeArea(
              child: Consumer<PrayerHistoryProvider>(
                builder: (_, provider, __) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetch(),
                    color: AppColors.goldPrimary,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          _buildToggleButton(isDark),
                          const SizedBox(height: 20),
                          if (provider.isLoading && provider.data == null)
                            _buildLoadingState()
                          else if (provider.isError)
                            _buildErrorState(provider, isDark)
                          else if (provider.data == null || provider.data!.data.isEmpty)
                            _buildEmptyState(isDark)
                          else
                            _buildHistoryContent(provider, isDark),
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

  // ── Toggle Button ────────────────────────────────────────────────────────────

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

  // ── History Content ─────────────────────────────────────────────────────────

  Widget _buildHistoryContent(PrayerHistoryProvider provider, bool isDark) {
    final data = provider.data;
    if (data == null || data.data.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        _buildHistoryList(data.data, isDark),
        if (provider.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.goldPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryList(List<PrayerHistoryEntry> entries, bool isDark) {
    return Column(
      children: entries.map((entry) => _buildHistoryCard(entry, isDark)).toList(),
    );
  }

  Widget _buildHistoryCard(PrayerHistoryEntry entry, bool isDark) {
    if (isDark) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 40, spreadRadius: 2, offset: const Offset(0, 12))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.userName,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.authBgBottom,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(entry.dateKey),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.authBgMid.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.countAdded}',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldDark,
                            ),
                          ),
                          if (entry.isBorrowed)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Borrowed',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (entry.intentionText != null && entry.intentionText!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF624294).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        entry.intentionText!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.authBgMid.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Light mode
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF624294).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.authBgBottom,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(entry.dateKey),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authBgMid.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.countAdded}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldDark,
                    ),
                  ),
                  if (entry.isBorrowed)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Borrowed',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (entry.intentionText != null && entry.intentionText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF624294).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                entry.intentionText!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.authBgMid.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.authBgMid.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: subColor),
          const SizedBox(height: 16),
          Text(
            'No Prayer History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start praying to see your history here',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldPrimary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(PrayerHistoryProvider provider, bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.authBgMid.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'Failed to Load History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => provider.fetch(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDate(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateKey;
    }
  }
}
