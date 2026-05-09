import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme_notifier.dart';
import '../../models/priest_model.dart';

class AdoptPriestSuccessScreen extends StatefulWidget {
  final AdoptPriestsResponse response;

  const AdoptPriestSuccessScreen({
    super.key,
    required this.response,
  });

  @override
  State<AdoptPriestSuccessScreen> createState() =>
      _AdoptPriestSuccessScreenState();
}

class _AdoptPriestSuccessScreenState extends State<AdoptPriestSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleController.forward();
    _slideController.forward();

    // Auto-pop after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ── Success Icon Animation ──────────────────────
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7B55A8),
                              Color(0xFF624294),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF624294)
                                  .withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Success Message ─────────────────────────────
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Priests Adopted!',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF624294),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.response.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF624294)
                                  .withOpacity(0.7),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Adopted Priests List ─────────────────────────
                    Text(
                      'Your Adopted Priests',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF624294),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ...List.generate(
                      widget.response.adoptedPriests.length,
                      (index) {
                        final priest =
                            widget.response.adoptedPriests[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PriestCard(
                            priest: priest,
                            index: index,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Stats Box ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF624294).withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF624294)
                                .withOpacity(0.10),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Adopted',
                            value: '${widget.response.adoptedCount}',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF624294).withOpacity(0.1),
                          ),
                          _StatItem(
                            label: 'Total',
                            value: '${widget.response.totalAdopted}',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: const Color(0xFF624294).withOpacity(0.1),
                          ),
                          _StatItem(
                            label: 'Remaining',
                            value: '${widget.response.remainingSlots}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Priest Card Widget ───────────────────────────────────────────────────────
class _PriestCard extends StatelessWidget {
  final AdoptedPriest priest;
  final int index;

  const _PriestCard({
    required this.priest,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7B55A8).withOpacity(0.8),
                  const Color(0xFF624294).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF624294).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ── Priest Info ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  priest.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF624294),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priest.originalName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF624294).withOpacity(0.5),
                  ),
                ),
                if (priest.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    priest.note,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF624294).withOpacity(0.4),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Check Icon ──────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(0.2),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Item Widget ────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF624294),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF624294).withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
