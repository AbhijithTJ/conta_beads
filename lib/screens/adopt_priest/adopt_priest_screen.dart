import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme_notifier.dart';

// Full pool of priests to randomly pick from
const List<Map<String, String>> _priestPool = [
  {'name': 'Fr. Thomas'},
  {'name': 'Fr. Joseph'},
  {'name': 'Fr. Michael'},
  {'name': 'Fr. Anthony'},
  {'name': 'Fr. Sebastian'},
  {'name': 'Fr. George'},
  {'name': 'Fr. Paul'},
  {'name': 'Fr. James'},
  {'name': 'Fr. Peter'},
  {'name': 'Fr. Francis'},
  {'name': 'Fr. David'},
  {'name': 'Fr. John'},
];

class AdoptPriestScreen extends StatefulWidget {
  const AdoptPriestScreen({super.key});

  @override
  State<AdoptPriestScreen> createState() => _AdoptPriestScreenState();
}

class _AdoptPriestScreenState extends State<AdoptPriestScreen> {
  static const int _maxSlots = 3;

  // Each slot holds either null (empty) or a priest map
  final List<Map<String, String>?> _slots = [null, null, null];

  // Returns priests not already chosen in any slot
  List<Map<String, String>> _availablePriests() {
    final chosen = _slots
        .where((s) => s != null)
        .map((s) => s!['name'])
        .toSet();
    return _priestPool.where((p) => !chosen.contains(p['name'])).toList();
  }

  // Returns a shuffled random subset (up to 6) from available priests
  List<Map<String, String>> _randomSubset() {
    final available = _availablePriests();
    available.shuffle(Random());
    return available.take(6).toList();
  }

  void _openPickerForSlot(int slotIndex) {
    final candidates = _randomSubset();
    if (candidates.isEmpty) return;

    final isDark = themeNotifier.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF220850) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose a Priest',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF624294),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select one to add to your prayer list',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withOpacity(0.55)
                      : const Color(0xFF624294).withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 20),
              ...candidates.map((priest) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _slots[slotIndex] = priest;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : const Color(0xFFF0EBF0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : const Color(0xFF624294).withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEDE0ED),
                            border: Border.all(
                              color: const Color(0xFF624294).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 24,
                            color: Color(0xFF624294),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priest['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF624294),
                                ),
                              ),
                              Text(
                                'Pray for me',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : const Color(0xFF624294).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_rounded,
                          color: const Color(0xFF624294).withOpacity(0.7),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _removeSlot(int slotIndex) {
    setState(() {
      _slots[slotIndex] = null;
    });
  }

  int get _filledCount => _slots.where((s) => s != null).length;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? const Color(0xFF1c023d) : const Color(0xFFF0EBF0);
        final titleColor = isDark ? Colors.white : const Color(0xFF624294);
        final subColor = isDark
            ? Colors.white.withOpacity(0.65)
            : const Color(0xFF624294).withOpacity(0.6);

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
                    child: Image.asset(
                      'assets/demo/adopt a priest.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Bottom gradient — theme-aware fade into bgColor
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  Colors.transparent,
                                  const Color(0xBB220850),
                                  const Color(0xFF220850),
                                ]
                              : [
                                  Colors.transparent,
                                  bgColor.withOpacity(0.7),
                                  bgColor,
                                ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Back button
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Adopt a priest',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pray for God’s anointed ones',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Choose your Priest',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── 3 Slots ────────────────────────────────────────
                        Row(
                          children: List.generate(_maxSlots, (i) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: i == 0 ? 0 : 6,
                                  right: i == _maxSlots - 1 ? 0 : 6,
                                ),
                                child: _slots[i] == null
                                    ? _EmptySlot(
                                        slotNumber: i + 1,
                                        isDark: isDark,
                                        onAdd: () => _openPickerForSlot(i),
                                      )
                                    : _FilledCard(
                                        name: _slots[i]!['name']!,
                                        slotLabel: '${i + 1}/$_maxSlots',
                                        isDark: isDark,
                                        onRemove: () => _removeSlot(i),
                                      ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // ── Info box ───────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF624294).withOpacity(0.15),
                              width: isDark ? 2.0 : 1.5,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF624294).withOpacity(0.10),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 18, color: subColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You may select up to 3 priests',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : const Color(0xFF624294).withOpacity(0.7),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Adopt button (visible when ≥1 filled) ──────────
                        if (_filledCount > 0)
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$_filledCount priest${_filledCount > 1 ? 's' : ''} adopted!',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFF22014D),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
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
                                  const BoxShadow(
                                    color: Color(0xFF2A0A5E),
                                    blurRadius: 0,
                                    offset: Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF624294).withOpacity(0.45),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Adopt $_filledCount Priest${_filledCount > 1 ? 's' : ''}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
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

// ── Empty slot with + button ─────────────────────────────────────────────────
class _EmptySlot extends StatelessWidget {
  final int slotNumber;
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptySlot({
    required this.slotNumber,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.18)
                : const Color(0xFF624294).withOpacity(0.15),
            width: isDark ? 2.0 : 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: isDark
              ? null
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            // Dashed circle with + icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFEDE0ED),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.25)
                      : const Color(0xFF624294).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 32,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF624294).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Priest',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : const Color(0xFF624294).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$slotNumber/3',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFF624294).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filled priest card with remove button ────────────────────────────────────
class _FilledCard extends StatelessWidget {
  final String name;
  final String slotLabel;
  final bool isDark;
  final VoidCallback onRemove;

  const _FilledCard({
    required this.name,
    required this.slotLabel,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF624294)
              : const Color(0xFF624294).withOpacity(0.15),
          width: isDark ? 2.0 : 1.5,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF624294).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          // Avatar with remove button overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE0ED),
                  border: Border.all(
                    color: const Color(0xFF624294).withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: Color(0xFF624294),
                ),
              ),
              // Remove (×) button — top-right of avatar
              Positioned(
                top: -4, right: -4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE53935),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF624294),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pray for me',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: const Color(0xFF624294).withOpacity(0.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          // "Selected" badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF624294),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'SELECTED',
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            slotLabel,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF624294).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
