import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme_notifier.dart';

class EverydayPrayersScreen extends StatelessWidget {
  const EverydayPrayersScreen({super.key});

  static const List<Map<String, dynamic>> _prayers = [
    {'title': 'Divine Mercy Chaplet',       'image': 'assets/demo/i trust you jesus.png'},
    {'title': 'Divine Mercy Novena and Litany', 'image': 'assets/demo/mathav.png'},
    {'title': 'Way of the Cross MCRC',      'image': 'assets/demo/adopt a priest.png'},
    {'title': 'Prayer to be Merciful',      'image': 'assets/demo/mathav.png'},
    {'title': 'Prayer to the Holy Face',    'image': 'assets/demo/i trust you jesus.png'},
  ];

  static const List<String> _guides = [
    'Confession Assistant',
    'Living Divine Mercy A Daily Guide',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
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
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, bgColor],
                        ),
                      ),
                    ),
                  ),
                  // back button
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
                          children: _guides.map((guide) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: guide == _guides.first ? 8 : 0,
                                  left: guide == _guides.last ? 8 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      guide.contains('Confession')
                                          ? Icons.church_rounded
                                          : Icons.menu_book_rounded,
                                      color: const Color(0xFF22014D),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      guide,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF22014D),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
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
