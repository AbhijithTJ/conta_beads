import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../colors/colors.dart';
import '../../models/home_model.dart';
import '../../providers/home_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/localization_service.dart';
import '../../services/language_id_service.dart';
import '../../theme/theme_notifier.dart';
import 'counting_screen.dart';
import '../adopt_priest/adopt_priest_screen.dart';
import '../everyday_prayers/everyday_prayers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Quote rotation
  late AnimationController _quoteController;
  late Animation<double> _quoteFadeAnim;
  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _languages = [
    {'code': 'EN', 'name': 'English'},
    {'code': 'ML', 'name': 'Malayalam'},
  ];

  late HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _quoteController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeInOut),
    );
    _quoteController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeProvider = context.read<HomeProvider>();
      _homeProvider.fetch();
      _homeProvider.addListener(_onHomeDataChanged);
    });
  }

  void _startQuoteTimer(int quoteCount) {
    _quoteTimer?.cancel();
    if (quoteCount <= 1) return;
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) => _nextQuote(quoteCount));
  }

  void _nextQuote(int quoteCount) {
    _quoteController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % quoteCount);
      _quoteController.forward();
    });
  }

  void _advanceQuote(bool forward, int quoteCount) {
    _quoteController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentQuoteIndex = forward
            ? (_currentQuoteIndex + 1) % quoteCount
            : (_currentQuoteIndex - 1 + quoteCount) % quoteCount;
      });
      _quoteController.forward();
    });
  }

  void _onHomeDataChanged() {
    if (!mounted) return;
    if (_homeProvider.hasData && _quoteTimer == null) {
      final count = _homeProvider.data!.quotes.length;
      if (count > 1) _startQuoteTimer(count);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Also check on dependency changes (e.g. provider already loaded)
    if (!mounted) return;
    final provider = context.read<HomeProvider>();
    if (provider.hasData && _quoteTimer == null) {
      final count = provider.data!.quotes.length;
      if (count > 1) _startQuoteTimer(count);
    }
  }

  @override
  void dispose() {
    _homeProvider.removeListener(_onHomeDataChanged);
    _quoteTimer?.cancel();
    _quoteController.dispose();
    super.dispose();
  }

  void _showLanguagePicker() {
    HapticFeedback.lightImpact();
    final languageProvider = context.read<LanguageProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.language_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text('Select Language',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ]),
              const SizedBox(height: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: _languages.map((lang) {
                  final isSelected = lang['name'] == languageProvider.selectedLanguage;
                  return GestureDetector(
                    onTap: () async {
                      // Only proceed if language is different
                      if (lang['name'] == languageProvider.selectedLanguage) {
                        Navigator.pop(ctx);
                        return;
                      }

                      await languageProvider.setLanguage(lang['name']!);
                      // Sync language ID with the service
                      languageIdService.setLanguageByName(lang['name']!);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      
                      // Refresh only text content (no images reload)
                      if (mounted) {
                        _homeProvider.refreshTextOnly();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.18)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.55)
                              : Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 38,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(lang['code']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(lang['name']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Navigation by section route ─────────────────────────────────────────────

  void _navigateTo(HomeSection section) {
    switch (section.route) {
      case '/rosary_prayer':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CountingScreen(prayerTypeId: section.id)));
        break;
      case '/chaplet_prayer':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CountingScreen(startWithChaplet: true, prayerTypeId: section.id)));
        break;
      case '/adopt_priest':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdoptPriestScreen()));
        break;
      case '/daily_prayers':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EverydayPrayersScreen()));
        break;
      default:
        break;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor =
            isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
        return _buildScaffold(context, size, isDark, bgColor);
      },
    );
  }

  Widget _buildScaffold(
      BuildContext context, Size size, bool isDark, Color bgColor) {
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
        child: Stack(
          children: [
            SafeArea(
              child: Consumer<HomeProvider>(
                builder: (_, provider, __) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetch(),
                    color: AppColors.goldPrimary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader(provider, isDark),
                          const SizedBox(height: 24),
                          _buildGreeting(provider, isDark),
                          const SizedBox(height: 20),
                          _buildQuoteCard(provider, isDark),
                          const SizedBox(height: 24),
                          _buildGrid(provider, size, isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildGreeting(HomeProvider provider, bool isDark) {
    final userName = provider.data?.user?.name ?? 'Guest';
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $userName \u{1F44B}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF22014D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's grow closer to God today.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF624294).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(HomeProvider provider, bool isDark) {
    final logoAsset =
        isDark ? 'assets/splash/ur_logo.png' : 'assets/splash/ur_logo_light.png';
    final langBg = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFF624294).withOpacity(0.08);
    final langText = isDark ? Colors.white : const Color(0xFF624294);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.30)
        : const Color(0xFF624294).withOpacity(0.25);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(logoAsset, width: 52, height: 52),
        Row(
          children: [
            Consumer<LanguageProvider>(
              builder: (_, languageProvider, __) {
                return GestureDetector(
                  onTap: _showLanguagePicker,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: langBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.language_rounded, color: langText, size: 16),
                      const SizedBox(width: 6),
                      Text(languageProvider.selectedLanguage,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: langText)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: langText.withOpacity(0.7), size: 16),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ── Quote card ──────────────────────────────────────────────────────────────

  Widget _buildQuoteCard(HomeProvider provider, bool isDark) {
    final shadowColor = isDark
        ? AppColors.authBgBottom.withOpacity(0.20)
        : const Color(0xFF624294).withOpacity(0.15);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.5)
        : const Color(0xFF624294).withOpacity(0.12);
    final activeDotColor =
        isDark ? const Color(0xFF624294) : AppColors.goldPrimary;

    // Loading skeleton
    if (provider.isLoading && !provider.hasData) {
      return _QuoteSkeleton(isDark: isDark);
    }

    // Error or empty — fall back to a static quote
    final quotes = provider.data?.quotes ?? [];
    if (quotes.isEmpty) {
      return _buildStaticQuoteCard(isDark, shadowColor, borderColor);
    }

    final safeIndex = _currentQuoteIndex.clamp(0, quotes.length - 1);
    final quote = quotes[safeIndex];

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity == null) return;
        _advanceQuote(d.primaryVelocity! < 0, quotes.length);
      },
      child: FadeTransition(
        opacity: _quoteFadeAnim,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: isDark ? Colors.white : borderColor,
                width: isDark ? 2.0 : 1.5),
            boxShadow: [
              BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Background image ────────────────────────────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: quote.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: quote.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            'assets/demo/qoutes.png',
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/demo/qoutes.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/demo/qoutes.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\u275D',
                        style: TextStyle(
                            fontSize: 20,
                            color: const Color(0xFF624294).withOpacity(0.45),
                            height: 1.0)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 30),
                        child: Text(
                          quote.quotation,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isDark ? FontWeight.w500 : FontWeight.w700,
                              color: const Color(0xFF624294),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              letterSpacing: 0.2),
                        ),
                      ),
                    ),
                    if (quote.reference.isNotEmpty)
                      Text(
                          quote.reference.startsWith('—')
                              ? quote.reference
                              : '— ${quote.reference}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF624294),
                              letterSpacing: 1.2)),
                  ],
                ),
              ),
              // Dots centered at bottom
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(quotes.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == safeIndex ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == safeIndex
                            ? activeDotColor
                            : const Color(0xFF624294).withOpacity(0.25),
                      ),
                    );
                  }),
                ),
              ),
              // Avatar positioned at right bottom end
              Positioned(
                bottom: -15,
                right: 16,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF624294).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: quote.image.isNotEmpty
                        ? quote.image.toLowerCase().endsWith('.svg')
                            ? SvgPicture.network(
                                quote.image,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                placeholderBuilder: (context) => Image.asset(
                                  'assets/demo/adopt a priest.png',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: quote.image,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                placeholder: (context, url) => Image.asset(
                                  'assets/demo/adopt a priest.png',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/demo/adopt a priest.png',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              )
                        : Image.asset(
                            'assets/demo/adopt a priest.png',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticQuoteCard(
      bool isDark, Color shadowColor, Color borderColor) {
    return Container(
      width: double.infinity,
      height: 180,
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background image ────────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/demo/qoutes.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ── Quote content (left side) ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\u275D',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF624294),
                        height: 1.0)),
                const SizedBox(height: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 30),
                    child: Text(
                      '"With God, all things are possible."',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF624294),
                          fontStyle: FontStyle.italic,
                          height: 1.5),
                    ),
                  ),
                ),
                Text('Matthew 19:26',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF624294),
                        letterSpacing: 1.2)),
              ],
            ),
          ),
          // Avatar positioned at right bottom end
          Positioned(
            bottom: -15,
            right: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF624294).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/demo/adopt a priest.png',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature grid ────────────────────────────────────────────────────────────

  Widget _buildGrid(HomeProvider provider, Size size, bool isDark) {
    // Loading skeleton
    if (provider.isLoading && !provider.hasData) {
      return _GridSkeleton(isDark: isDark);
    }

    final sections = provider.data?.sections ?? _fallbackSections();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, i) {
        final section = sections[i];
        return GestureDetector(
          onTap: () => _navigateTo(section),
          child: Container(
            decoration: isDark
                ? null
                : BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF624294).withOpacity(0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF624294).withOpacity(0.15),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: isDark
                        ? BorderRadius.circular(16)
                        : const BorderRadius.vertical(
                            top: Radius.circular(18)),
                    child: _buildSectionImage(section, isDark),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            section.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF624294),
                              height: 1.3,
                            ),
                          ),
                        ),
                        Icon(Icons.favorite_rounded,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF624294),
                            size: 20),
                      ],
                    ),
                  ),
                ),
                if (!isDark) const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionImage(HomeSection section, bool isDark) {
    if (section.image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: section.image,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFF624294).withOpacity(0.06),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.goldPrimary),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => _fallbackImage(section.route, isDark),
      );
    }
    return _fallbackImage(section.route, isDark);
  }

  Widget _fallbackImage(String route, bool isDark) {
    final assetMap = {
      '/rosary_prayer':  'assets/demo/mathav.png',
      '/adopt_priest':   'assets/demo/adopt a priest.png',
      '/chaplet_prayer': 'assets/demo/i trust you jesus.png',
      '/daily_prayers':  'assets/demo/every day.png',
    };
    final asset = assetMap[route];
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : const Color(0xFF624294).withOpacity(0.06),
      child: Icon(Icons.image_rounded,
          color: isDark
              ? Colors.white.withOpacity(0.3)
              : const Color(0xFF624294).withOpacity(0.3),
          size: 40),
    );
  }

  // Fallback sections if API fails — mirrors the original hardcoded list
  List<HomeSection> _fallbackSections() => [
    HomeSection(id: 1,    title: 'Rosary',            description: '', image: '', route: '/rosary_prayer',  icon: 'rosary',  type: 'prayer', order: 1),
    HomeSection(id: 1001, title: 'Adopt a Priest',    description: '', image: '', route: '/adopt_priest',   icon: 'priest',  type: 'other',  order: 2),
    HomeSection(id: 2,    title: 'Divine Mercy Chaplet', description: '', image: '', route: '/chaplet_prayer', icon: 'chaplet', type: 'prayer', order: 3),
    HomeSection(id: 1002, title: 'Every Day Prayers', description: '', image: '', route: '/daily_prayers',  icon: 'prayer',  type: 'other',  order: 4),
  ];
}

// ── Skeleton widgets ─────────────────────────────────────────────────────────

class _QuoteSkeleton extends StatelessWidget {
  final bool isDark;
  const _QuoteSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: isDark ? Colors.white : const Color(0xFF624294).withOpacity(0.12),
            width: isDark ? 2.0 : 1.5),
      ),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: AppColors.goldPrimary),
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  final bool isDark;
  const _GridSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFF624294).withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
