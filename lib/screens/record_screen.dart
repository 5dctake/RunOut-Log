import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/providers/records_provider.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/utils/stats_calculator.dart';
import 'package:runout_log/utils/l10n.dart';
import 'package:runout_log/widgets/hud_components.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late TabController _tabController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // 現在のProviderの値に基づいて初期インデックスを計算
    final initialBallCount = ref.read(ballCountProvider);
    final initialIndex = initialBallCount == 3 ? 0 : (initialBallCount == 4 ? 1 : 2);
    
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    final counts = [3, 4, 5];
    final selectedCount = counts[_tabController.index];
    if (ref.read(ballCountProvider) != selectedCount) {
      ref.read(ballCountProvider.notifier).state = selectedCount;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Providerの値が変更されたらTabControllerを同期（リスナーを使用）
    ref.listen<int>(ballCountProvider, (previous, next) {
      final targetIndex = next == 3 ? 0 : (next == 4 ? 1 : 2);
      if (_tabController.index != targetIndex) {
        _tabController.animateTo(targetIndex);
      }
    });

    final ballCount = ref.watch(ballCountProvider);

    final allRecords = ref.watch(recordsProvider);
    final filteredRecords = allRecords.where((r) => r.ballCount == ballCount).toList();
    
    final blocks = StatsCalculator.splitIntoBlocks(filteredRecords);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(L10n.s(ref, 'logs_title')),
        elevation: 0,
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
      body: filteredRecords.isEmpty
          ? Center(child: Text(L10n.s(ref, 'no_data'), style: const TextStyle(color: AppColors.textDim)))
          : Column(
              children: [
                _buildHeaderStats(filteredRecords),
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: blocks.length,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        itemBuilder: (context, index) {
                          final block = blocks[index];
                          return _buildBlockView(block, index, blocks.length);
                        },
                      ),
                      if (_currentPage < blocks.length - 1)
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildNavButton(Icons.arrow_forward_ios, () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuart,
                            )),
                          ),
                        ),
                      if (_currentPage > 0)
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _buildNavButton(Icons.arrow_back_ios_new, () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutQuart,
                            )),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: AppColors.softShadow,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHeaderStats(List<PracticeRecord> records) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CleanCard(
        title: L10n.s(ref, 'total_stats'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Row(
               children: [
                 const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                 const SizedBox(width: 12),
                 Text(L10n.s(ref, 'total_stats'), style: const TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
               ],
             ),
            Text(
              StatsCalculator.formatStats(records),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockView(List<PracticeRecord> block, int index, int totalBlocks) {
    final startNum = (totalBlocks - 1 - index) * 100 + 1;
    final blockTrials = block.fold(0, (sum, r) => sum + r.results.length);
    final endNum = startNum + blockTrials - 1;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  'BLOCK: $startNum – $endNum',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                Text(
                   StatsCalculator.formatStats(block),
                  style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...block.map((record) => _buildRecordRow(record)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRecordRow(PracticeRecord record) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              DateFormat('MM/dd').format(record.date),
              style: const TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double indicatorSize = (availableWidth / 10).clamp(16, 24);
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: record.results.map((r) {
                    final color = r ? AppColors.primary : AppColors.accent;
                    return Icon(
                      r ? Icons.check_circle : Icons.cancel,
                      color: color,
                      size: indicatorSize,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${record.successRate.toInt()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: record.successRate >= 60 ? AppColors.primary : AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
