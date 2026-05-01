import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../colors/colors.dart';
import '../../theme/theme_notifier.dart';
import 'intention_success_screen.dart';

class IntentionsScreen extends StatefulWidget {
  const IntentionsScreen({super.key});

  @override
  State<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends State<IntentionsScreen> with TickerProviderStateMixin {
  final TextEditingController _intentionController = TextEditingController();
  final TextEditingController _rosaryCountController = TextEditingController();
  int _myTotal = 300; // user's rosary total

  late AnimationController _quoteFadeController;
  late Animation<double> _quoteFadeAnim;
  Timer? _quoteTimer;
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {'text': '"Prayer joined to sacrifice constitutes the most powerful force in human history."', 'author': '— St. John Paul II'},
    {'text': '"The rosary is the most excellent form of prayer."', 'author': 'Pope Paul VI'},
    {'text': '"To pray is to let Jesus into our lives."', 'author': 'Ole Hallesby'},
    {'text': '"Prayer is the key of the morning and the bolt of the evening."', 'author': 'Mahatma Gandhi'},
    {'text': '"With God, all things are possible."', 'author': 'Matthew 19:26'},
  ];

  final String todayIntention = 'For the Healing of the Sick';
  final int prayerRequests = 23;

  @override
  void initState() {
    super.initState();
    _quoteFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _quoteFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _quoteFadeController, curve: Curves.easeInOut),
    );
    _quoteFadeController.forward();
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _quoteFadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length);
        _quoteFadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _rosaryCountController.dispose();
    _quoteTimer?.cancel();
    _quoteFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? const Color(0xFF22014D) : const Color(0xFFF0EBF0);
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeader(isDark),
                    const SizedBox(height: 32),
                    _buildQuoteCard(isDark),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTodayIntentionCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPrayerRequestsCard()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDivider(isDark),
                    const SizedBox(height: 32),
                    _buildRequestRosaryCard(isDark),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
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
        Text('Intentions',
            style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w900, color: titleColor, letterSpacing: -1, height: 1.0)),
        const SizedBox(height: 8),
        Text('LIFT YOUR HEART IN PRAYER',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: subColor, letterSpacing: 2.5)),
      ],
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    final q = _quotes[_currentQuoteIndex];
    final quoteTextColor = isDark ? const Color(0xFF333333) : AppColors.authBgBottom;
    final shadowColor = isDark ? AppColors.authBgBottom.withOpacity(0.20) : const Color(0xFF624294).withOpacity(0.10);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        _quoteFadeController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            if (details.primaryVelocity! < 0) {
              _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
            } else {
              _currentQuoteIndex = (_currentQuoteIndex - 1 + _quotes.length) % _quotes.length;
            }
          });
          _quoteFadeController.forward();
        });
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
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u275D', style: TextStyle(fontSize: 20, color: const Color(0xFF624294).withOpacity(0.45), height: 1.0)),
              const SizedBox(height: 6),
              Text(q['text']!,
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w500, color: quoteTextColor, fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0.2)),
              const SizedBox(height: 8),
              Text(q['author']!, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294), letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_quotes.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentQuoteIndex ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == _currentQuoteIndex ? const Color(0xFF624294) : const Color(0xFF624294).withOpacity(0.25),
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
  Widget _buildTodayIntentionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB347),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.church_rounded, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF624294).withOpacity(0.35), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(todayIntention,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF624294))),
          const SizedBox(height: 4),
          Text("Today's Intention",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF624294).withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildPrayerRequestsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB57BEA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF624294).withOpacity(0.35), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text('Community Prayers',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF624294))),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
              const SizedBox(width: 6),
              Text('$prayerRequests active requests',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF624294).withOpacity(0.5))),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('REQUEST A ROSARY',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF624294).withOpacity(0.8), letterSpacing: 1.8)),
                  const SizedBox(height: 2),
                  Text('Offer your intention',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.authBgBottom, letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Share your personal intention with the community in prayer and trust it to the Mother of God.',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.7), height: 1.6)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: _intentionController,
                maxLines: 4,
                style: GoogleFonts.poppins(fontSize: 15, color: AppColors.authBgBottom, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Write your intention here...',
                  hintStyle: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.5), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Rosary count row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rosaries to offer',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294).withOpacity(0.7))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _rosaryCountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF624294), fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: 'e.g. 3',
                        hintStyle: GoogleFonts.poppins(color: const Color(0xFF624294).withOpacity(0.35), fontSize: 14),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white, width: 2.0)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white, width: 2.0)),
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
                  Text('Your Total',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF624294).withOpacity(0.7))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: _myTotal < 0 ? Colors.red.withOpacity(0.1) : const Color(0xFF624294).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _myTotal < 0 ? Colors.red.withOpacity(0.4) : Colors.white, width: 2.0),
                    ),
                    child: Text(
                      '$_myTotal',
                      style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w900,
                        color: _myTotal < 0 ? Colors.red : const Color(0xFF624294),
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
      onTap: () {
        if (_intentionController.text.isNotEmpty) {
          final count = int.tryParse(_rosaryCountController.text.trim()) ?? 0;
          setState(() => _myTotal -= count);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => IntentionSuccessScreen(intention: _intentionController.text),
          ));
          _intentionController.clear();
          _rosaryCountController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: const [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Please write your intention', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ));
        }
      },
      child: Container(
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
          child: Text('Request Rosary',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

// ── Glassmorphic Card (Matches Login/Profile Style) ─────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
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
}

// ── Icon Box (Consistent with Profile Screen) ───────────────────────────────
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

