import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/theme_notifier.dart';
import '../../providers/home_provider.dart';
import '../../models/home_model.dart';
import '../../config/app_config.dart';
import '../../services/api_client.dart';
import '../../services/localization_service.dart';
import '../../models/priest_model.dart';
import '../../providers/adopt_priest_provider.dart';
import '../../providers/language_provider.dart';
import 'adopt_priest_success_screen.dart';
import 'suggest_priest_screen.dart';

class AdoptPriestScreen extends StatefulWidget {
  const AdoptPriestScreen({super.key});

  @override
  State<AdoptPriestScreen> createState() => _AdoptPriestScreenState();
}

class _AdoptPriestScreenState extends State<AdoptPriestScreen> {
  static const int _maxSlots = 3;

  // Each slot holds either null (empty) or a priest
  final List<Priest?> _slots = [null, null, null];

  // Loading state for the picker
  bool _isLoadingPriests = false;

  @override
  void initState() {
    super.initState();
    // Fetch saved priests when screen loads
    _loadSavedPriests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This gets called when dependencies change, including when returning from another screen
    _loadSavedPriests();
  }

  void _loadSavedPriests() {
    Future.microtask(() {
      if (mounted) {
        context.read<AdoptPriestProvider>().fetchSavedPriests();
      }
    });
  }

  // Returns priest IDs already chosen in any slot (including saved priests)
  Set<int> _chosenPriestIds(List<AdoptedPriest> savedPriests) {
    final newlySelected = _slots
        .where((s) => s != null)
        .map((s) => s!.id)
        .toSet();
    
    final saved = savedPriests
        .map((p) => p.id)
        .toSet();
    
    return {...newlySelected, ...saved};
  }

  // Returns priests not already chosen in any slot
  List<Priest> _availablePriests(List<Priest> allPriests, List<AdoptedPriest> savedPriests) {
    final chosen = _chosenPriestIds(savedPriests);
    return allPriests.where((p) => !chosen.contains(p.id)).toList();
  }

  Future<void> _openPickerForSlot(int slotIndex) async {
    final isDark = themeNotifier.isDark;
    final provider = context.read<AdoptPriestProvider>();

    // Show loading state
    setState(() {
      _isLoadingPriests = true;
    });

    try {
      // Fetch random priests from API
      final response = await ApiClient.instance.get(
        AppConfig.priestsPath,
        query: {'type': 'random'},
      );
      
      if (!mounted) return;

      final priestsData = PriestsData.fromJson(response.data);
      
      // Filter out already chosen priests (including saved ones)
      final candidates = _availablePriests(priestsData.priests, provider.savedPriests);
      
      if (candidates.isEmpty) {
        setState(() {
          _isLoadingPriests = false;
        });
        return;
      }

      setState(() {
        _isLoadingPriests = false;
      });

      // Show the picker
      if (mounted) {
        _showPriestPicker(slotIndex, candidates, isDark);
      }
    } on ApiException catch (e) {
      setState(() {
        _isLoadingPriests = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.tr('error_loading_priests', args: {'error': e.message}),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showPriestPicker(int slotIndex, List<Priest> candidates, bool isDark) {
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
                loc.tr('choose_a_priest'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF624294),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.tr('select_one_to_add'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withOpacity(0.55)
                      : const Color(0xFF624294).withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable list of priests
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final priest = candidates[index];
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
                                    priest.displayName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF624294),
                                    ),
                                  ),
                                  Text(
                                    loc.tr('pray_for_me'),
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
                  },
                ),
              ),
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

  Future<void> _adoptPriests() async {
    final priestIds = _slots
        .where((s) => s != null)
        .map((s) => s!.id)
        .toList();

    if (priestIds.isEmpty) return;

    // Call the provider to handle adoption
    final provider = context.read<AdoptPriestProvider>();
    await provider.adoptPriests(priestIds);

    if (!mounted) return;

    // Check the result from the provider
    if (provider.isSuccess && provider.response != null) {
      // Navigate to success screen and wait for it to pop
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdoptPriestSuccessScreen(
              response: provider.response!,
            ),
          ),
        );
        
        // When returning from success screen, refresh the data
        if (mounted) {
          _loadSavedPriests();
          _resetSlots();
        }
      }
    } else if (provider.isError) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  int get _filledCount => _slots.where((s) => s != null).length;

  void _resetSlots() {
    setState(() {
      _slots[0] = null;
      _slots[1] = null;
      _slots[2] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Clear slots when leaving the screen
              _resetSlots();
            }
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: themeNotifier,
            builder: (_, isDark, __) {
              final titleColor = isDark ? Colors.white : const Color(0xFF624294);
              final subColor = isDark
                ? Colors.white.withOpacity(0.65)
                : const Color(0xFF624294).withOpacity(0.6);

            return Scaffold(
              body: Stack(
                children: [
                  // ── Base dark bg ─────────────────────────────────────────
              if (isDark)
                Positioned.fill(
                  child: Container(color: const Color(0xFF1c023d)),
                ),
              // ── Radial glow — behind priest cards ────────────────────
              if (isDark)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, 0.5),
                        radius: 0.6,
                        colors: [
                          Color(0xFF2A2050),
                          Color(0xFF1E1640),
                          Color(0xFF1c023d),
                        ],
                        stops: [0.0, 0.50, 1.0],
                      ),
                    ),
                  ),
                ),
              // ── Linear fade at the bottom ────────────────────────────
              if (isDark)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: 260,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x001c023d),
                          Color(0xFF1c023d),
                        ],
                      ),
                    ),
                  ),
                ),
              // ── Light mode flat bg ───────────────────────────────────
              if (!isDark)
                Positioned.fill(
                  child: Container(color: const Color(0xFFF0EBF0)),
                ),
              // ── Main content ─────────────────────────────────────────
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Column(
                  children: [
              // ── Hero image ──────────────────────────────────────────────
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        final homeProvider = Provider.of<HomeProvider>(context);
                        final sections = homeProvider.data?.sections ?? [];
                        final section = sections.firstWhere(
                          (s) => s.id == 1001, // Adopt a Priest ID
                          orElse: () => HomeSection(id: -1, title: '', description: '', image: '', route: '', icon: '', type: '', order: 0)
                        );
                        
                        if (section.image.isNotEmpty) {
                          return CachedNetworkImage(
                            imageUrl: section.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Image.asset(
                              'assets/demo/adopt a priest.png',
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/demo/adopt a priest.png',
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Image.asset(
                          'assets/demo/adopt a priest.png',
                          fit: BoxFit.cover,
                        );
                      }
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
                                  const Color(0x001c023d),
                                  const Color(0xCC1c023d),
                                  const Color(0xFF1c023d),
                                ]
                              : [
                                  const Color(0x00F0EBF0),
                                  const Color(0xCCF0EBF0),
                                  const Color(0xFFF0EBF0),
                                ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Top fade — dark mode only
                  if (isDark)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x881c023d),
                            Color(0x001c023d),
                          ],
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          loc.tr('adopt_a_priest'),
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.tr('pray_for_anointed'),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: subColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.tr('choose_your_priest'),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── 3 Slots (Saved + New Selection) ────────────────
                        Consumer<AdoptPriestProvider>(
                          builder: (context, provider, _) {
                            return Row(
                                children: List.generate(_maxSlots, (i) {
                                  // Check if this slot has a saved priest
                                  final hasSavedPriest = i < provider.savedPriests.length;
                                  final savedPriest = hasSavedPriest 
                                      ? provider.savedPriests[i] 
                                      : null;

                                  // If there's a saved priest, show it
                                  if (savedPriest != null) {
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: i == 0 ? 0 : 6,
                                          right: i == _maxSlots - 1 ? 0 : 6,
                                        ),
                                        child: _SavedSlotCard(
                                          priest: savedPriest,
                                          slotNumber: i + 1,
                                          isDark: isDark,
                                          onUnadopt: () async {
                                            final success = await provider.unadoptPriest(savedPriest.id);
                                            if (success && mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    loc.tr('priest_unadopted'),
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(14)),
                                                  margin: const EdgeInsets.all(16),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }

                                  // Otherwise, show empty slot or newly selected priest
                                  final newSlotIndex = i - provider.savedPriests.length;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: i == 0 ? 0 : 6,
                                        right: i == _maxSlots - 1 ? 0 : 6,
                                      ),
                                      child: _slots[newSlotIndex] == null
                                          ? _EmptySlot(
                                              slotNumber: i + 1,
                                              isDark: isDark,
                                              isLoading: _isLoadingPriests,
                                              onAdd: () => _openPickerForSlot(newSlotIndex),
                                            )
                                          : _FilledCard(
                                              priest: _slots[newSlotIndex]!,
                                              slotLabel: '${i + 1}/$_maxSlots',
                                              isDark: isDark,
                                              onRemove: () => _removeSlot(newSlotIndex),
                                            ),
                                    ),
                                  );
                                }),
                            );
                          },
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
                                  loc.tr('select_up_to_3_priests'),
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
                          Consumer<AdoptPriestProvider>(
                            builder: (context, provider, _) {
                              return GestureDetector(
                                onTap: provider.isLoading ? null : _adoptPriests,
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
                                    child: provider.isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            _filledCount > 1
                                                ? loc.tr('adopt_button_plural', args: {'count': _filledCount.toString()})
                                                : loc.tr('adopt_button', args: {'count': _filledCount.toString()}),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 40),
                        
                        // ── Suggest a Priest button ──────────────────────
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const SuggestPriestScreen(),
                            ));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : const Color(0xFF624294).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : const Color(0xFF624294).withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                loc.tr('suggest_a_priest'),
                                style: GoogleFonts.poppins(
                                  color: titleColor,
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
              ], // Column children
            ), // Column
          ), // inner Container
            ], // outer Stack children
          ), // outer Stack
        );
        },
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
  final bool isLoading;
  final VoidCallback onAdd;

  const _EmptySlot({
    required this.slotNumber,
    required this.isDark,
    required this.isLoading,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onAdd,
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
            // Dashed circle with + icon or loading
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
              child: isLoading
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? Colors.white.withOpacity(0.6)
                              : const Color(0xFF624294).withOpacity(0.6),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.add_rounded,
                      size: 32,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : const Color(0xFF624294).withOpacity(0.6),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              loc.tr('add_priest'),
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
  final Priest priest;
  final String slotLabel;
  final bool isDark;
  final VoidCallback onRemove;

  const _FilledCard({
    required this.priest,
    required this.slotLabel,
    required this.isDark,
    required this.onRemove,
  });

  void _showPriestDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF624294).withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Priest Avatar ──
              Container(
                width: 80,
                height: 80,
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
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // ── Full Priest Name ──
              Text(
                priest.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF624294),
                ),
              ),
              const SizedBox(height: 24),
              // ── Remove Button ──
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          loc.tr('remove_priest'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMalayalam = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage == 'Malayalam';

    return GestureDetector(
      onTap: () => _showPriestDetail(context),
      child: AnimatedContainer(
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
          mainAxisSize: MainAxisSize.min,
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
            // Priest name with ellipsis for long names
            SizedBox(
              height: 18,
              child: Text(
                priest.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF624294),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              loc.tr('pray_for_me'),
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
                loc.tr('selected'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: isMalayalam ? 7 : 9,
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
      ),
    );
  }
}

// ── Saved Slot Card Widget ──────────────────────────────────────────────────
class _SavedSlotCard extends StatelessWidget {
  final AdoptedPriest priest;
  final int slotNumber;
  final bool isDark;
  final VoidCallback onUnadopt;

  const _SavedSlotCard({
    required this.priest,
    required this.slotNumber,
    required this.isDark,
    required this.onUnadopt,
  });

  void _showPriestDetail(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF624294).withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Priest Avatar ──
              Container(
                width: 80,
                height: 80,
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
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // ── Full Priest Name ──
              Text(
                priest.displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF624294),
                ),
              ),
              const SizedBox(height: 24),
              // ── Remove Button ──
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  onUnadopt();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.tr('unadopt_priest'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPriestDetail(context),
      child: AnimatedContainer(
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
          mainAxisSize: MainAxisSize.min,
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
                    onTap: onUnadopt,
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
            // Priest name with ellipsis for long names
            SizedBox(
              height: 18,
              child: Text(
                priest.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF624294),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              loc.tr('pray_for_me'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFF624294).withOpacity(0.55),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            // "SAVED" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                loc.tr('saved'),
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
              '$slotNumber/3',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF624294).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Saved Priest Card Widget ─────────────────────────────────────────────────
class _SavedPriestCard extends StatelessWidget {
  final AdoptedPriest priest;
  final bool isDark;
  final VoidCallback onUnadopt;

  const _SavedPriestCard({
    required this.priest,
    required this.isDark,
    required this.onUnadopt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : const Color(0xFF624294).withOpacity(0.15),
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
          // ── Avatar ──────────────────────────────────────────────────
          Container(
            width: 50,
            height: 50,
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
                    color: isDark ? Colors.white : const Color(0xFF624294),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priest.originalName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : const Color(0xFF624294).withOpacity(0.5),
                  ),
                ),
                if (priest.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    priest.note,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : const Color(0xFF624294).withOpacity(0.4),
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

          // ── Unadopt Button ──────────────────────────────────────────
          GestureDetector(
            onTap: onUnadopt,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
