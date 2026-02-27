import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/providers/records_provider.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/utils/l10n.dart';
import 'package:runout_log/widgets/hud_components.dart';
import 'package:runout_log/widgets/tutorial_overlay.dart';
import 'package:runout_log/services/ad_service.dart';
import 'package:runout_log/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final List<bool?> _results = List.generate(10, (_) => null);
  late TabController _tabController;
  bool _showTutorial = false;
  int _tutorialStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _tabController.addListener(_handleTabSelection);
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;
    if (!hasSeenTutorial && mounted) {
      setState(() {
        _showTutorial = true;
        _tutorialStep = 0;
      });
    }
  }

  Future<void> _dismissTutorial() async {
    if (_tutorialStep < 2) {
      setState(() => _tutorialStep++);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    final counts = [3, 4, 5];
    ref.read(ballCountProvider.notifier).state = counts[_tabController.index];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleResult(int index) {
    setState(() {
      if (_results[index] == null) {
        _results[index] = true;
      } else if (_results[index] == true) {
        _results[index] = false;
      } else {
        _results[index] = null;
      }
    });
  }

  int get _solvedCount => _results.where((r) => r == true).length;
  int get _totalCount => _results.where((r) => r != null).length;
  double get _successRate {
    if (_totalCount == 0) return 0;
    return (_solvedCount / _totalCount) * 100;
  }

  Future<void> _save() async {
    final validResults = _results.whereType<bool>().toList();
    
    if (validResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.s(ref, 'empty_error'))),
      );
      return;
    }

    if (validResults.length < 10) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(L10n.s(ref, 'save'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          content: Text(L10n.s(ref, 'confirm_partial')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(ref.watch(languageProvider) == Language.jp ? 'キャンセル' : 'Cancel', style: const TextStyle(color: AppColors.textDim)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(ref.watch(languageProvider) == Language.jp ? '保存' : 'Save', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final ballCount = ref.read(ballCountProvider);
    final record = PracticeRecord(
      date: _selectedDate,
      ballCount: ballCount,
      results: validResults,
    );

    await ref.read(recordsProvider.notifier).addRecord(record);

    final isAdFree = ref.read(adFreeProvider);
    if (!isAdFree) {
      AdService().showInterstitialAd(onDismiss: () {
        _onSaveComplete();
      });
    } else {
      _onSaveComplete();
    }
  }

  void _onSaveComplete() {
    setState(() {
      _results.fillRange(0, 10, null);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(L10n.s(ref, 'recorded_msg'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Providerの値が変更されたらTabControllerを同期（ビルド中ではなくリスナーで実行）
    ref.listen<int>(ballCountProvider, (previous, next) {
      final targetIndex = next == 3 ? 0 : (next == 4 ? 1 : 2);
      if (_tabController.index != targetIndex) {
        _tabController.animateTo(targetIndex);
      }
    });

    final ballCount = ref.watch(ballCountProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(L10n.s(ref, 'input_title')),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textDim,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: '3 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
                Tab(text: '4 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
                Tab(text: '5 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDateSelector(),
                const SizedBox(height: 24),
                CleanCard(
                  title: L10n.s(ref, 'analytics_title'),
                  child: Column(
                    children: [
                       const SizedBox(height: 8),
                      _buildCircularProgress(),
                      const SizedBox(height: 16),
                      Text(
                        '$_solvedCount / $_totalCount ${L10n.s(ref, 'attempts')}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Target Mode: $ballCount Balls',
                        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CleanCard(
                  title: '記録入力 (Tap to toggle)',
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final color = result == true 
                          ? AppColors.primary 
                          : result == false 
                              ? AppColors.accent 
                              : AppColors.background;
                      
                      return GestureDetector(
                        onTap: () => _toggleResult(index),
                        onLongPress: () {
                          setState(() => _results[index] = null);
                          HapticFeedback.selectionClick();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: result == null ? AppColors.background : color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: result != null 
                                ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Center(
                            child: Icon(
                              result == true 
                                  ? Icons.check_circle 
                                  : result == false 
                                      ? Icons.cancel 
                                      : Icons.circle_outlined,
                              color: result == null ? AppColors.textDim.withValues(alpha: 0.3) : AppColors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: ref.watch(adFreeProvider) ? L10n.s(ref, 'save') : L10n.s(ref, 'save_with_ad'),
                  onPressed: _save,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: L10n.s(ref, 'clear'),
                  isSecondary: true,
                  onPressed: () {
                    setState(() => _results.fillRange(0, 10, null));
                    HapticFeedback.mediumImpact();
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        if (_showTutorial)
          TutorialOverlay(
            step: _tutorialStep,
            onNext: _dismissTutorial,
          ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DATE', style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    DateFormat('yyyy/MM/dd').format(_selectedDate),
                    style: const TextStyle(fontSize: 16, color: AppColors.textMain, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: _successRate / 100,
            strokeWidth: 12,
            backgroundColor: AppColors.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_successRate.toInt()}%',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            Text(
              L10n.s(ref, 'ratio'),
              style: const TextStyle(fontSize: 10, color: AppColors.textDim, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
