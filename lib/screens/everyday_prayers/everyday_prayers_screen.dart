import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        final bgColor = isDark ? const Color(0xFF1c023d) : const Color(0xFFF0EBF0);
        final titleColor = isDark ? Colors.white : const Color(0xFF22014D);
        final subColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF22014D).withOpacity(0.55);

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              // ── Hero image ──────────────────────────────────────────────
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.asset('assets/demo/every day.png', fit: BoxFit.cover),
                  ),
                  // gradient fade
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xBB220850),
                            Color(0xFF220850),
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // back button — only show when pushed via navigation
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
                            color: Colors.black.withOpacity(0.35),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Content ─────────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: isDark
                      ? const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(0.0, -0.4),
                            radius: 0.85,
                            colors: [
                              Color(0xFF321060),
                              Color(0xFF220850),
                              Color(0xFF1c023d),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        )
                      : const BoxDecoration(color: Color(0xFFF0EBF0)),
                  child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text('Everyday Prayers',
                            style: GoogleFonts.poppins(
                                fontSize: 24, fontWeight: FontWeight.w800, color: titleColor)),
                      ),
                      const SizedBox(height: 20),

                      // ── Prayer grid ──────────────────────────────────────
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _prayers.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, i) {
                          final prayer = _prayers[i];
                          return GestureDetector(
                            onTap: () {},
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white, width: 2.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      prayer['image']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
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
                      ),

                      const SizedBox(height: 24),

                      // ── Divider ──────────────────────────────────────────
                      Container(height: 1, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),

                      // ── Guide links ──────────────────────────────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(_guides.length, (i) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: i == 0 ? 8 : 0,
                                    left: i == 1 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white, width: 2.0),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
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
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF22014D), height: 1.4),
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
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
