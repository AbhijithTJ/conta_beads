import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';

class EverydayPrayersScreen extends StatelessWidget {
  const EverydayPrayersScreen({super.key});

  static const List<Map<String, dynamic>> _prayers = [
    {'title': 'Divine Mercy Chaplet',           'image': 'assets/demo/Divine Mercy Chaplet.png'},
    {'title': 'Divine Mercy Novena and Litany', 'image': 'assets/demo/Novena and Litany.png'},
    {'title': 'Way of the Cross MCRC',          'image': 'assets/demo/Way of the cross.png'},
    {'title': 'Prayer to be Merciful',          'image': 'assets/demo/Prayers to be Merciful.png'},
    {'title': 'Prayer to the Holy Face',        'image': 'assets/demo/Prayer-to-the-Holy-Face.jpg.jpeg'},
  ];

  static const List<String> _guides = [
    'Confession Assistant',
    'Living Divine Mercy A Daily Guide',
  ];

  static const List<String> _guideImages = [
    'assets/demo/Confession Assistant.png',
    'assets/demo/Divine Mercy Guide.png',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final titleColor   = isDark ? Colors.white : AppColors.authBgBottom;
        final subColor     = isDark
            ? Colors.white.withOpacity(0.65)
            : AppColors.authBgMid.withOpacity(0.6);
        final dividerColor = isDark
            ? Colors.white.withOpacity(0.15)
            : const Color(0xFF624294).withOpacity(0.12);

        return Scaffold(
          body: Stack(
            children: [
              // ── Base radial glow (mid section) ──────────────────────
              if (isDark)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, 0.3),
                        radius: 0.6,
                        colors: [
                          Color(0xFF2A2050),
                          Color(0xFF1E1640),
                          Color(0xFF1c023d),
                        ],
                        stops: [0.0, 0.50, 1.0],
                      ),
                    ),
                  ),
                ),
              // ── Linear fade at the bottom ────────────────────────────
              if (isDark)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: 260,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x001c023d),
                          Color(0xFF1c023d),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              // ── Light mode flat bg ───────────────────────────────────
              if (!isDark)
                Positioned.fill(
                  child: Container(color: const Color(0xFFF0EBF0)),
                ),
              // ── Main content ─────────────────────────────────────────
              Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Column(
              children: [
                // ── Hero image ──────────────────────────────────────────
                Stack(
                  children: [
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/demo/every day.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // gradient fade — blends image into background (bottom)
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDark
                                ? [
                                    const Color(0x001c023d),
                                    const Color(0xCC1c023d),
                                    const Color(0xFF1c023d),
                                  ]
                                : [
                                    const Color(0x00F0EBF0),
                                    const Color(0xCCF0EBF0),
                                    const Color(0xFFF0EBF0),
                                  ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (isDark)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x881c023d),
                              Color(0x001c023d),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // back button — only when pushed via navigation
                    if (Navigator.of(context).canPop())
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
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
                      ),
                  ],
                ),

                // ── Scrollable content ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        // Title
                        Center(
                          child: Text(
                            'Everyday Prayers',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'Your daily path to grace',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: subColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Prayer grid ─────────────────────────────────
                        _buildSectionLabel('Prayers', titleColor),
                        const SizedBox(height: 12),
                        _buildPrayerGrid(isDark, titleColor),

                        const SizedBox(height: 24),

                        // ── Divider ──────────────────────────────────────
                        Container(height: 1, color: dividerColor),
                        const SizedBox(height: 20),

                        // ── Guide cards ──────────────────────────────────
                        _buildSectionLabel('Guides', titleColor),
                        const SizedBox(height: 12),
                        _buildGuideCards(isDark),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ), // inner Container
            ], // outer Stack children
          ), // outer Stack
        );
      },
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.4,
      ),
    );
  }

  // ── Prayer grid ─────────────────────────────────────────────────────────────
  Widget _buildPrayerGrid(bool isDark, Color titleColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _prayers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, i) {
        final prayer = _prayers[i];
        return GestureDetector(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlassCard(
                isDark: isDark,
                height: 92,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    prayer['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prayer['title']!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Guide cards ─────────────────────────────────────────────────────────────
  Widget _buildGuideCards(bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_guides.length, (i) {
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.only(
                  right: i == 0 ? 8 : 0,
                  left:  i == 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF624294).withOpacity(0.15),
                    width: isDark ? 2.0 : 1.5,
                  ),
                  boxShadow: isDark
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))]
                      : [
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        _guideImages[i],
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _guides[i],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF624294),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Frosted glass card — mirrors login screen card style ────────────────────
  Widget _buildGlassCard({
    required bool isDark,
    required Widget child,
    double? height,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    if (isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    // Light mode — matches login screen light card
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
