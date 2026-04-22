import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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
    _quoteTimer?.cancel();
    _quoteFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (_, isDark, __) {
        final bgColor = isDark ? AppColors.homeBg : const Color(0xFFF0EBF0);
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: bgColor),
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
                    _buildTodayIntentionCard(),
                    const SizedBox(height: 16),
                    _buildPrayerRequestsCard(),
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
    final subColor = isDark ? Colors.white.withOpacity(0.6) : AppColors.authBgMid.withOpacity(0.5);

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
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: titleColor, letterSpacing: -1, height: 1.0)),
        const SizedBox(height: 8),
        Text('LIFT YOUR HEART IN PRAYER',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: subColor, letterSpacing: 2.5)),
      ],
    );
  }

  Widget _buildQuoteCard(bool isDark) {
    final q = _quotes[_currentQuoteIndex];
    final quoteTextColor = isDark ? const Color(0xFF333333) : AppColors.authBgBottom;
    final shadowColor = isDark ? AppColors.authBgBottom.withOpacity(0.20) : AppColors.authPurple.withOpacity(0.10);

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
            border: Border.all(color: AppColors.authPurpleLight.withOpacity(0.30), width: 1.5),
            boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\u275D', style: TextStyle(fontSize: 20, color: AppColors.authPurple.withOpacity(0.45), height: 1.0)),
              const SizedBox(height: 6),
              Text(q['text']!,
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: quoteTextColor, fontStyle: FontStyle.italic, height: 1.5, letterSpacing: 0.2)),
              const SizedBox(height: 8),
              Text(q['author']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.authPurple, letterSpacing: 1.2)),
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
                      color: i == _currentQuoteIndex ? AppColors.authPurple : AppColors.authPurple.withOpacity(0.25),
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
    return _GlassCard(
      child: Row(
        children: [
          _IconBox(icon: Icons.church_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TODAY'S INTENTION",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authBgMid.withOpacity(0.5),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayIntention,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authBgBottom,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.authPurple.withOpacity(0.3),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRequestsCard() {
    return _GlassCard(
      child: Row(
        children: [
          _IconBox(icon: Icons.people_alt_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Prayers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authBgBottom,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$prayerRequests active requests',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authBgMid.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.authPurple.withOpacity(0.3),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    final divColor = isDark ? Colors.white.withOpacity(0.2) : AppColors.authPurple.withOpacity(0.15);
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
    final btnColor = isDark ? AppColors.homeBg : AppColors.authPurple;
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
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.authPurple.withOpacity(0.8), letterSpacing: 1.8)),
                  const SizedBox(height: 2),
                  const Text('Offer your intention',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.authBgBottom, letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Share your personal intention with the community in prayer and trust it to the Mother of God.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.authBgMid.withOpacity(0.7), height: 1.6)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: _intentionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 15, color: AppColors.authBgBottom, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Write your intention here...',
                  hintStyle: TextStyle(color: AppColors.authPurple.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.w500),
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
          _buildSubmitButton(btnColor),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color btnColor) {
    return GestureDetector(
      onTap: () {
        if (_intentionController.text.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => IntentionSuccessScreen(intention: _intentionController.text),
          ));
          _intentionController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Row(children: [
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
          color: btnColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.authPurple.withOpacity(0.35), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('Request Rosary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
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
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.5,
            ),
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
        color: AppColors.authPurple.withOpacity(0.08),
        border: Border.all(
          color: AppColors.authPurple.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Icon(icon, color: AppColors.authPurple, size: 22),
    );
  }
}

