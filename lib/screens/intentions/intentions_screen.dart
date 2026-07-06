import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import '../../providers/intentions_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/intentions_model.dart';
import '../../services/language_id_service.dart';
import '../../services/localization_service.dart' show LocalizationService, loc;
import 'intention_success_screen.dart';
import '../bottom_nav_wrapper.dart';
class IntentionsScreen extends StatefulWidget {
  const IntentionsScreen({super.key});

  @override
  State<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends State<IntentionsScreen> with TickerProviderStateMixin {
  final TextEditingController _intentionController = TextEditingController();
  final TextEditingController _rosaryCountController = TextEditingController();
  final FocusNode _intentionFocus = FocusNode();
  final FocusNode _rosaryCountFocus = FocusNode();
  int _myTotal = 300;
  bool _isRosaryMode = true;

  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  int _lastLanguageId = 1;

  int _getTotalCount() {
    final data = context.read<IntentionsProvider>().data;
    if (data == null) return 300;
    
    if (_isRosaryMode) {
      final rosary = data.personalPrayers.firstWhere(
        (p) => p.prayerType.toLowerCase() == 'rosary',
        orElse: () => const PersonalPrayer(prayerType: 'Rosary', personalCount: 0),
      );
      return rosary.personalCount;
    } else {
      final chaplet = data.personalPrayers.firstWhere(
        (p) => p.prayerType.toLowerCase() == 'chaplet',
        orElse: () => const PersonalPrayer(prayerType: 'Chaplet', personalCount: 0),
      );
      return chaplet.personalCount;
    }
  }

  @override
  void initState() {
    super.initState();
    _intentionFocus.addListener(() => setState(() {}));
    _rosaryCountFocus.addListener(() => setState(() {}));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntentionsProvider>().fetch();
      // Listen for language changes
      languageIdService.addListener(_onLanguageChanged);
      _lastLanguageId = languageIdService.languageId;
    });
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _rosaryCountController.dispose();
    _intentionFocus.dispose();
    _rosaryCountFocus.dispose();
    _quoteTimer?.cancel();
    languageIdService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _startQuoteTimer(int quoteCount) {
    _quoteTimer?.cancel();
    if (quoteCount > 0) {
      _quoteTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (!mounted) return;
        setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % quoteCount);
      });
    }
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    final currentLanguageId = languageIdService.languageId;
    if (currentLanguageId != _lastLanguageId) {
      _lastLanguageId = currentLanguageId;
      // Refresh intentions data with new language
      context.read<IntentionsProvider>().fetch();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return const Color(0xFF624294);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (_, languageProvider, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: themeNotifier,
          builder: (_, isDark, __) {
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
                    : const BoxDecoration(color: Color(0xFFF0EBF0)),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Consumer<IntentionsProvider>(
                          builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.goldPrimary,
                          ),
                        );
                      }

                      if (provider.isError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.7)),
                              const SizedBox(height: 16),
                              Text(
                                loc.tr('failed_to_load_intentions'),
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  provider.errorMessage ?? loc.tr('unknown_error'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.withOpacity(0.7)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => provider.fetch(),
                                child: Text(loc.tr('retry')),
                              ),
                            ],
                          ),
                        );
                      }

                      final data = provider.data;
                      if (data == null) {
                        return Center(
                          child: Text(loc.tr('no_data_available'), style: GoogleFonts.poppins()),
                        );
                      }

                      if (data.quotes.isNotEmpty && _quoteTimer == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startQuoteTimer(data.quotes.length);
                        });
                      }

                      return RefreshIndicator(
                        onRefresh: () => provider.fetch(),
                        color: AppColors.goldPrimary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              _buildHeader(isDark),
                              const SizedBox(height: 32),
                              _buildQuoteCard(isDark, data),
                              const SizedBox(height: 24),
                              _buildIntentionsGrid(data),
                              const SizedBox(height: 16),
                              _buildPrayerRequestsCard(data),
                              const SizedBox(height: 32),
                              _buildDivider(isDark),
                              const SizedBox(height: 32),
                              _buildRequestRosaryCard(isDark),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      );
                          },
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const BottomNavWrapper()),
                              );
                            }
                          },
                          child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.black.withOpacity(0.35)
                                    : Colors.white.withOpacity(0.75),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.4)
                                      : const Color(0xFF624294).withOpacity(0.25),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white : const Color(0xFF624294),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? Colors.white : AppColors.authBgBottom;
    final subColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.authBgMid.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.goldDark, AppColors.goldPrimary]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(loc.tr('intentions_title'),
            style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w900, color: titleColor, letterSpacing: -1, height: 1.0)),
        const SizedBox(height: 8),
        Text(loc.tr('hearts_united_in_prayer'),
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: subColor, letterSpacing: 2.5)),
      ],
    );
  }

  Widget _buildQuoteCard(bool isDark, IntentionsData data) {
    if (data.quotes.isEmpty) {
      return Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.12), width: isDark ? 2.0 : 1.5),
        ),
        child: Center(
          child: Text(loc.tr('no_quotes_available'), style: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.5))),
        ),
      );
    }

    final q = data.quotes[_currentQuoteIndex];
    final quoteTextColor = const Color(0xFF624294);
    final shadowColor = isDark ? AppColors.authBgBottom.withOpacity(0.20) : const Color(0xFF624294).withOpacity(0.15);
    final borderColor = isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.12);
    final activeDotColor = isDark ? const Color(0xFF624294) : AppColors.goldPrimary;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (!mounted) return;
        setState(() {
          if (details.primaryVelocity! < 0) {
            _currentQuoteIndex = (_currentQuoteIndex + 1) % data.quotes.length;
          } else {
            _currentQuoteIndex = (_currentQuoteIndex - 1 + data.quotes.length) % data.quotes.length;
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: 180,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.white : borderColor, width: isDark ? 2.0 : 1.5),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1500),
          child: Column(
            key: ValueKey<int>(_currentQuoteIndex),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u275D', style: TextStyle(fontSize: 20, color: const Color(0xFF624294).withOpacity(0.45), height: 1.0)),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      q.quotation,
                      textAlign: TextAlign.center,
                      style: RegExp(r'[\u0D00-\u0D7F]').hasMatch(q.quotation)
                          ? GoogleFonts.anekMalayalam(fontSize: 12, fontWeight: isDark ? FontWeight.w500 : FontWeight.w700, color: quoteTextColor, fontStyle: FontStyle.italic, height: 1.4, letterSpacing: 0.2)
                          : TextStyle(fontSize: 13, fontWeight: isDark ? FontWeight.w500 : FontWeight.w700, color: quoteTextColor, fontStyle: FontStyle.italic, height: 1.4, letterSpacing: 0.2),
                    ),
                  ),
                ),
              ),
              if (q.reference.isNotEmpty)
                Text('— ${q.reference}',
                    style: RegExp(r'[\u0D00-\u0D7F]').hasMatch(q.reference)
                        ? GoogleFonts.anekMalayalam(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294), letterSpacing: 1.2)
                        : const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF624294), letterSpacing: 1.2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(data.quotes.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentQuoteIndex ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _currentQuoteIndex ? activeDotColor : const Color(0xFF624294).withOpacity(0.25),
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

  Widget _buildIntentionsGrid(IntentionsData data) {
    if (data.adminIntentions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
        ),
        child: Center(
          child: Text(loc.tr('no_intentions_available'), style: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.5))),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    // Calculate aspect ratio: (screen width - horizontal padding - crossAxisSpacing) / 2
    final itemWidth = (size.width - 48 - 12) / 2;
    // Ensure height is at least 175 to prevent overflow
    final aspectRatio = itemWidth / 175.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: data.adminIntentions.length,
      itemBuilder: (context, index) {
        final intention = data.adminIntentions[index];
        return _buildIntentionGridCard(intention);
      },
    );
  }

  Widget _buildIntentionGridCard(AdminIntention intention) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 2, offset: const Offset(0, -1)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB347),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.church_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  intention.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF624294)),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    intention.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF624294).withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(intention.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              intention.status,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _getStatusColor(intention.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRequestsCard(IntentionsData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF624294).withOpacity(0.10), blurRadius: 16, spreadRadius: 1, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB57BEA).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFB57BEA).withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFFB57BEA), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.tr('community_prayers'),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF624294), letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Total community prayers count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB57BEA).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB57BEA).withOpacity(0.25), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tr('active_requests_label'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB57BEA).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.communityPrayersTotal.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB57BEA),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB57BEA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Color(0xFFB57BEA),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(PrayerCount prayer) {
    final bgColor = prayer.prayerType.toLowerCase() == 'rosary'
        ? const Color(0xFFFFB347).withOpacity(0.12)
        : const Color(0xFFB57BEA).withOpacity(0.12);
    final iconColor = prayer.prayerType.toLowerCase() == 'rosary'
        ? const Color(0xFFFFB347)
        : const Color(0xFFB57BEA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconColor.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(color: iconColor.withOpacity(0.08), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              prayer.prayerType.toLowerCase() == 'rosary' ? Icons.favorite_rounded : Icons.spa_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer.prayerType,
                style: RegExp(r'[\u0D00-\u0D7F]').hasMatch(prayer.prayerType)
                    ? GoogleFonts.anekMalayalam(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF624294))
                    : GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF624294)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  '${prayer.activeRequests} requests',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    final divColor = isDark ? Colors.white.withOpacity(0.2) : const Color(0xFF624294).withOpacity(0.15);
    return Row(
      children: [
        Expanded(child: Container(height: 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, divColor])))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('✦', style: TextStyle(fontSize: 14, color: AppColors.goldPrimary.withOpacity(0.6))),
        ),
        Expanded(child: Container(height: 1.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [divColor, Colors.transparent])))),
      ],
    );
  }

  Widget _buildRequestRosaryCard(bool isDark) {
    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBox(icon: Icons.auto_awesome_rounded),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isRosaryMode ? loc.tr('borrow_rosaries_heading') : loc.tr('borrow_chaplets_heading'),
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF624294).withOpacity(0.8), letterSpacing: 1.8)),
                    const SizedBox(height: 2),
                    Text(loc.tr('share_your_intention'),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.authBgBottom, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPrayerToggleButton(),
          const SizedBox(height: 20),
          Text(loc.tr('borrow_prayers_description'),
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.7), height: 1.6)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: _intentionController,
                focusNode: _intentionFocus,
                maxLines: 4,
                style: GoogleFonts.poppins(fontSize: 15, color: AppColors.authBgBottom, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: loc.tr('write_your_intention'),
                  hintStyle: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.7), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isRosaryMode ? loc.tr('borrow_rosaries_label') : loc.tr('borrow_chaplets_label'),
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294).withOpacity(0.7))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _rosaryCountController,
                      focusNode: _rosaryCountFocus,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF624294), fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: loc.tr('example_count'),
                        hintStyle: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.35), fontSize: 14),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.7), width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(loc.tr('your_total_label'),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294).withOpacity(0.7))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: _getTotalCount() < 0 ? Colors.red.withOpacity(0.1) : const Color(0xFF624294).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _getTotalCount() < 0 ? Colors.red.withOpacity(0.4) : Colors.white, width: 2.0),
                    ),
                    child: Text(
                      '${_getTotalCount()}',
                      style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w900,
                        color: _getTotalCount() < 0 ? Colors.red : const Color(0xFF624294),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(isDark),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return GestureDetector(
      onTap: () async {
        if (_intentionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(loc.tr('please_write_intention'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ));
          return;
        }

        final count = int.tryParse(_rosaryCountController.text.trim()) ?? 0;
        if (count <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(loc.tr('please_enter_valid_count'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ));
          return;
        }

        final prayerTypeId = _isRosaryMode ? 1 : 2;
        final intentionText = _intentionController.text;
        final provider = context.read<IntentionsProvider>();
        
        final borrowResponse = await provider.borrowPrayers(
          count: count,
          intentionText: intentionText,
          prayerTypeId: prayerTypeId,
        );

        if (borrowResponse != null && mounted) {
          _intentionController.clear();
          _rosaryCountController.clear();
          
          // Navigate to success screen
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => IntentionSuccessScreen(intention: intentionText),
          ));
          
          // When returning from success screen, refresh the intentions data
          if (mounted) {
            provider.resetBorrowStatus();
            provider.fetch(); // Refresh to get updated personal prayer counts
          }
        } else if (mounted) {
          final errorMessage = provider.errorMessage ?? 'Failed to borrow prayers';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(errorMessage, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      child: Consumer<IntentionsProvider>(
        builder: (context, provider, _) {
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B55A8), Color(0xFF624294)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: const Color(0xFF624294).withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Center(
              child: provider.isBorrowLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    )
                  : Text(_isRosaryMode ? loc.tr('borrow_button_rosary') : loc.tr('borrow_button_chaplet'),
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerToggleButton() {
    final activePill = const Color(0xFF3B0764);
    final activeText = AppColors.goldPrimary;
    final inactiveText = const Color(0xFF624294).withOpacity(0.55);
    final shadowColor = const Color(0xFF624294).withOpacity(0.35);

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

    return Center(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF624294).withOpacity(0.18), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF624294).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tab(loc.tr('rosary_toggle_intentions'), _isRosaryMode, () => setState(() => _isRosaryMode = true)),
            tab(loc.tr('chaplet_toggle_intentions'), !_isRosaryMode, () => setState(() => _isRosaryMode = false)),
          ],
        ),
      ),
    );
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
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF624294).withOpacity(0.08),
        border: Border.all(color: const Color(0xFF624294).withOpacity(0.15), width: 1),
      ),
      child: Icon(icon, color: const Color(0xFF624294), size: 22),
    );
  }
}
