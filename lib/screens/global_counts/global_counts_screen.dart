import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../home_page/counting_screen.dart';

class GlobalCountsScreen extends StatefulWidget {
  final int personalCount;
  final int globalCount;
  
  const GlobalCountsScreen({
    super.key,
    required this.personalCount,
    required this.globalCount,
  });

  @override
  State<GlobalCountsScreen> createState() => _GlobalCountsScreenState();
}

class _GlobalCountsScreenState extends State<GlobalCountsScreen> {
  late List<Map<String, dynamic>> communityData;

  @override
  void initState() {
    super.initState();
    // Sample community data - will be replaced with database data
    communityData = [
      {'name': 'You', 'count': widget.personalCount, 'isUser': true},
      {'name': 'Sarah', 'count': 1250, 'isUser': false},
      {'name': 'Michael', 'count': 980, 'isUser': false},
      {'name': 'Emma', 'count': 1540, 'isUser': false},
      {'name': 'John', 'count': 875, 'isUser': false},
      {'name': 'Lisa', 'count': 1120, 'isUser': false},
      {'name': 'David', 'count': 945, 'isUser': false},
      {'name': 'Rachel', 'count': 1380, 'isUser': false},
    ];
    // Sort by count descending
    communityData.sort((a, b) => b['count'].compareTo(a['count']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyTop, AppColors.skyMid, AppColors.skyBottom],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildGlobalStatsCard(),
                    const SizedBox(height: 32),
                    _buildLeaderboardTitle(),
                    const SizedBox(height: 16),
                    _buildLeaderboard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              // Back button
              Positioned(
                top: 12,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.goldDark, AppColors.goldPrimary, AppColors.goldLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Global Counts',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Community Prayer Statistics',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.15),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.person_rounded,
                label: 'Your Total',
                value: widget.personalCount.toString(),
                color: AppColors.goldPrimary,
              ),
              Container(
                width: 1.5,
                height: 60,
                color: AppColors.goldPrimary.withOpacity(0.2),
              ),
              _buildStatItem(
                icon: Icons.public_rounded,
                label: 'Community Total',
                value: widget.globalCount.toString(),
                color: AppColors.greenButton,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldPrimary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressCard(),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    double percentage = widget.globalCount > 0
        ? (widget.personalCount / widget.globalCount) * 100
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Contribution',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.goldPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppColors.goldPrimary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.goldPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.leaderboard_rounded,
            color: AppColors.goldPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Column(
      children: List.generate(
        communityData.length,
        (index) => _buildLeaderboardItem(index),
      ),
    );
  }

  Widget _buildLeaderboardItem(int index) {
    final item = communityData[index];
    final isUser = item['isUser'] as bool;
    final rank = index + 1;
    final name = item['name'] as String;
    final count = item['count'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser ? AppColors.goldPrimary.withOpacity(0.15) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser ? AppColors.goldPrimary.withOpacity(0.4) : AppColors.goldPrimary.withOpacity(0.2),
          width: isUser ? 2 : 1.5,
        ),
        boxShadow: isUser
            ? [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getRankGradient(rank),
              boxShadow: [
                BoxShadow(
                  color: _getRankColor(rank).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'beads counted',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Count
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _getRankColor(rank),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getRankGradient(int rank) {
    if (rank == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (rank == 2) {
      return const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFF808080)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (rank == 3) {
      return const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [AppColors.goldPrimary.withOpacity(0.6), AppColors.goldDark.withOpacity(0.6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.goldPrimary;
  }
}
