import 'dart:ui';
import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import 'intention_success_screen.dart';

class IntentionsScreen extends StatefulWidget {
  const IntentionsScreen({super.key});

  @override
  State<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends State<IntentionsScreen> {
  final TextEditingController _intentionController = TextEditingController();

  final String quote =
      '"Prayer joined to sacrifice constitutes the most powerful force in human history."';
  final String quoteAuthor = '— St. John Paul II';
  final String todayIntention = 'For the Healing of the Sick';
  final int prayerRequests = 23;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.homeBg,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildQuoteCard(),
                const SizedBox(height: 16),
                _buildTodayIntentionCard(),
                const SizedBox(height: 16),
                _buildPrayerRequestsCard(),
                const SizedBox(height: 32),
                _buildDivider(),
                const SizedBox(height: 32),
                _buildRequestRosaryCard(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.goldDark, AppColors.goldPrimary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Intentions',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'LIFT YOUR HEART IN PRAYER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return _GlassCard(
      child: Column(
        children: [
          Text(
            '\u275D',
            style: TextStyle(
              fontSize: 32,
              color: AppColors.authPurple.withOpacity(0.3),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.authBgMid,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quoteAuthor.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.authPurple.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
        ],
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withOpacity(0.2)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.goldPrimary.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestRosaryCard() {
    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.auto_awesome_rounded),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUEST A ROSARY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authPurple.withOpacity(0.8),
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Offer your intention',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authBgBottom,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Share your personal intention with the community in prayer and trust it to the Mother of God.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.authBgMid.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: _intentionController,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.authBgBottom,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your intention here...',
                  hintStyle: TextStyle(
                    color: AppColors.authPurple.withOpacity(0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.goldPrimary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
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
                  const SizedBox(width: 10),
                  Text(
                    'Please write your intention',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.homeBg, AppColors.homeBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.authPurple.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Request Rosary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
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

