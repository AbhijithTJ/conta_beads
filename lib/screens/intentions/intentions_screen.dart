import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import 'intention_success_screen.dart';

class IntentionsScreen extends StatefulWidget {
  const IntentionsScreen({super.key});

  @override
  State<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends State<IntentionsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _intentionController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final String quote =
      '"Prayer joined to sacrifice constitutes the most powerful force in human history."';
  final String quoteAuthor = '— St. John Paul II';
  final String todayIntention = 'For the Healing of the Sick';
  final int prayerRequests = 23;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Static orb bubbles ──
            _Orb(left: size.width * 0.2,   top: -size.height * 0.08, size: size.width * 0.72,
              colors: [AppColors.plumMid.withOpacity(0.55),     AppColors.plumDeep.withOpacity(0.30)]),
            _Orb(left: -size.width * 0.22, top: size.height * 0.28,  size: size.width * 0.65,
              colors: [AppColors.dustyRose.withOpacity(0.60),   AppColors.dustyRose.withOpacity(0.25)]),
            _Orb(left: size.width * 0.55,  top: size.height * 0.38,  size: size.width * 0.60,
              colors: [AppColors.lavenderSoft.withOpacity(0.70), AppColors.plumMid.withOpacity(0.20)]),
            _Orb(left: size.width * 0.1,   top: size.height * 0.72,  size: size.width * 0.55,
              colors: [AppColors.goldPrimary.withOpacity(0.22),  AppColors.dustyRose.withOpacity(0.30)]),
            // ── Content ──
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildQuoteCard(),
                      const SizedBox(height: 14),
                      _buildTodayIntentionCard(),
                      const SizedBox(height: 14),
                      _buildPrayerRequestsCard(),
                      const SizedBox(height: 28),
                      _buildDivider(),
                      const SizedBox(height: 28),
                      _buildRequestRosaryCard(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intentions - Decorative gold line
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.goldPrimary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        // Intentions - Title with gold gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Intentions',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Intentions - Subtitle text
        Text(
          'Lift your heart in prayer',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary.withOpacity(0.7),
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        // Intentions - Quote card border with gold accent
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          // Intentions - Gold shadow for depth
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          // Intentions - White inner glow
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Intentions - Quote ornament
          Text(
            '\u275D',
            style: TextStyle(
              fontSize: 28,
              color: AppColors.goldPrimary.withOpacity(0.6),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          // Intentions - Quote text
          Text(
            quote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary.withOpacity(0.85),
              fontStyle: FontStyle.italic,
              height: 1.65,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          // Intentions - Quote author
          Text(
            quoteAuthor,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.goldDark,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayIntentionCard() {
    return _LightCard(
      child: Row(
        children: [
          // Intentions - Today's intention icon box
          _IconBox(
            emoji: '⛪',
            bgColor: AppColors.goldPrimary.withOpacity(0.1),
            borderColor: AppColors.goldPrimary.withOpacity(0.25),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intentions - Today's intention label
                Text(
                  "TODAY'S INTENTION",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                // Intentions - Today's intention text
                Text(
                  todayIntention,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          // Intentions - Chevron icon
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary.withOpacity(0.4),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRequestsCard() {
    return _LightCard(
      child: Row(
        children: [
          // Intentions - Prayer requests icon box
          _IconBox(
            emoji: '👥',
            bgColor: AppColors.lavenderSoft.withOpacity(0.4),
            borderColor: AppColors.plumMid.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intentions - Prayer requests title
                const Text(
                  'Pray for One Another',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Intentions - Prayer requests indicator dot
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Intentions - Prayer requests count
                    Text(
                      '$prayerRequests active prayer requests',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withOpacity(0.7),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Intentions - Chevron icon
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary.withOpacity(0.4),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            // Intentions - Divider gradient left
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldPrimary.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // Intentions - Divider ornament
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.goldPrimary.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            // Intentions - Divider gradient right
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestRosaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.15),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Intentions - Request rosary icon box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.goldPrimary.withOpacity(0.12),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text('🙏', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intentions - Request rosary label
                  Text(
                    'REQUEST A ROSARY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldDark,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Intentions - Request rosary title
                  const Text(
                    'Offer your intention',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Intentions - Request rosary description
          Text(
            'Share your personal intention with the community in prayer and trust it to the Mother of God.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary.withOpacity(0.75),
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          // Intentions - Text input field
          TextField(
            controller: _intentionController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            cursorColor: AppColors.goldPrimary,
            decoration: InputDecoration(
              hintText: 'Write your intention here...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.4),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.goldPrimary.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.goldPrimary.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.goldPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Intentions - Submit button
          GestureDetector(
            onTap: () {
              if (_intentionController.text.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => IntentionSuccessScreen(
                      intention: _intentionController.text,
                    ),
                  ),
                );
                _intentionController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Please write your intention',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Intentions - Error snackbar background
                    backgroundColor: AppColors.textSecondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                // Intentions - Rosary button gradient
                gradient: const LinearGradient(
                  colors: [AppColors.rosaryButtonPrimary, AppColors.rosaryButtonDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  // Intentions - Rosary button shadow
                  BoxShadow(
                    color: AppColors.rosaryButtonPrimary,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Request Rosary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LightCard extends StatelessWidget {
  final Widget child;
  const _LightCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        // Intentions - Light card border
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          // Intentions - Gold shadow for depth
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          // Intentions - White inner glow
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Intentions - Icon box widget for card headers
class _IconBox extends StatelessWidget {
  final String emoji;
  final Color bgColor;
  final Color borderColor;

  const _IconBox({
    required this.emoji,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}

// ── Orb bubble widget ─────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final List<Color> colors;

  const _Orb({
    required this.left,
    required this.top,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.85,
            colors: colors,
            stops: const [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.25),
              blurRadius: size * 0.35,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
