import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';

class AdoptPriestScreen extends StatefulWidget {
  const AdoptPriestScreen({super.key});

  @override
  State<AdoptPriestScreen> createState() => _AdoptPriestScreenState();
}

class _AdoptPriestScreenState extends State<AdoptPriestScreen> {
  final Set<int> _selected = {};
  static const int _maxSelection = 3;

  final List<Map<String, String>> _priests = [
    {'name': 'Fr. Thomas', 'subtitle': 'Your Prayer\nmatters for me', 'slot': '1/3'},
    {'name': 'Fr. Joseph', 'subtitle': 'Your Prayer\nmatters for me', 'slot': '2/3'},
    {'name': 'Fr. Michael', 'subtitle': 'Your Prayer\nmatters for me', 'slot': '3/3'},
  ];

  void _toggleSelect(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else if (_selected.length < _maxSelection) {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
        final titleColor = isDark ? Colors.white : const Color(0xFF22014D);
        final subColor = isDark ? Colors.white.withOpacity(0.65) : const Color(0xFF22014D).withOpacity(0.6);

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              // Hero image
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/demo/adopt a priest.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // gradient fade bottom
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Text('Adopt a priest',
                          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: titleColor)),
                      const SizedBox(height: 4),
                      Text('Support a Spiritual Journey',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: subColor)),
                      const SizedBox(height: 24),
                      Text('Choose your Priest',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: titleColor)),
                      const SizedBox(height: 16),

                      // Priest cards row
                      Row(
                        children: List.generate(_priests.length, (i) {
                          final priest = _priests[i];
                          final isSelected = _selected.contains(i);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : 6,
                                right: i == _priests.length - 1 ? 0 : 6,
                              ),
                              child: _PriestCard(
                                name: priest['name']!,
                                subtitle: priest['subtitle']!,
                                slot: priest['slot']!,
                                isSelected: isSelected,
                                onTap: () => _toggleSelect(i),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDark ? 0.07 : 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: subColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You may select up to three priests for Spiritual partnership',
                                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF22014D).withOpacity(0.7), height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      if (_selected.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${_selected.length} priest(s) adopted!',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                              backgroundColor: const Color(0xFF22014D),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              margin: const EdgeInsets.all(16),
                            ));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7B55A8), Color(0xFF624294)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF2A0A5E), blurRadius: 0, offset: const Offset(0, 5)),
                                BoxShadow(color: const Color(0xFF624294).withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(
                              child: Text('Adopt ${_selected.length} Priest${_selected.length > 1 ? 's' : ''}',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ),
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

class _PriestCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriestCard({
    required this.name,
    required this.subtitle,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF624294) : Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF624294).withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            // Priest avatar placeholder
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDE0ED),
                border: Border.all(color: const Color(0xFF22014D).withOpacity(0.15), width: 1.5),
              ),
              child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFF22014D)),
            ),
            const SizedBox(height: 8),
            Text(name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF22014D))),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF22014D).withOpacity(0.55), height: 1.4)),
            const SizedBox(height: 10),
            // Select button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF624294) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF624294), width: 1.5),
              ),
              child: Text('SELECT',
                  style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF624294),
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 6),
            Text(slot,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF22014D).withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}
