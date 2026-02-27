import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/providers/records_provider.dart';
import 'package:runout_log/utils/constants.dart';
import 'package:runout_log/utils/stats_calculator.dart';
import 'package:runout_log/utils/l10n.dart';
import 'package:runout_log/widgets/hud_components.dart';

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> with TickerProviderStateMixin {
  late TabController _ballTabController;
  late TabController _typeTabController;

  @override
  void initState() {
    super.initState();
    // 種目タブ (3, 4, 5)
    final initialBallCount = ref.read(ballCountProvider);
    final initialIndex = initialBallCount == 3 ? 0 : (initialBallCount == 4 ? 1 : 2);
    _ballTabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _ballTabController.addListener(() {
      if (!_ballTabController.indexIsChanging) {
        final counts = [3, 4, 5];
        ref.read(ballCountProvider.notifier).state = counts[_ballTabController.index];
      }
    });

    // 分析タイプタブ (ブロック, 日別, 月別, 年別)
    _typeTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _ballTabController.dispose();
    _typeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Providerの値が変更されたらTabControllerを同期（リスナーを使用）
    ref.listen<int>(ballCountProvider, (previous, next) {
      final targetIndex = next == 3 ? 0 : (next == 4 ? 1 : 2);
      if (_ballTabController.index != targetIndex) {
        _ballTabController.animateTo(targetIndex);
      }
    });

    final ballCount = ref.watch(ballCountProvider);

    final allRecords = ref.watch(recordsProvider);
    final filteredRecords = allRecords.where((r) => r.ballCount == ballCount).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(L10n.s(ref, 'analytics_title')),
        bottom: TabBar(
          controller: _ballTabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textDim,
          tabs: [
            Tab(text: '3 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
            Tab(text: '4 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
            Tab(text: '5 ${L10n.s(ref, 'mode') == '種目' ? '球' : 'Balls'}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _typeTabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textDim,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: L10n.s(ref, 'sector_trend')),
                Tab(text: L10n.s(ref, 'seq_trend')),
                Tab(text: L10n.s(ref, 'monthly')),
                Tab(text: L10n.s(ref, 'yearly')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _typeTabController,
              children: [
                _buildSectorChart(filteredRecords),
                _buildSequenceChart(filteredRecords),
                _buildMonthlyChart(filteredRecords),
                _buildYearlyChart(filteredRecords),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorChart(List<PracticeRecord> records) {
    final blocks = StatsCalculator.splitIntoBlocks(records);
    if (blocks.isEmpty) return _buildNoData();

    final points = blocks.asMap().entries.map((e) {
      final successRate = StatsCalculator.calculateTotalSuccessRate(e.value);
      return FlSpot(e.key.toDouble(), successRate);
    }).toList();

    return _buildChartFrame(
      title: L10n.s(ref, 'sector_trend'),
      child: spotsToWidget(points),
    );
  }

  Widget _buildSequenceChart(List<PracticeRecord> records) {
    if (records.isEmpty) return _buildNoData();

    final points = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.successRate);
    }).toList();

    return _buildChartFrame(
      title: L10n.s(ref, 'seq_trend'),
      child: spotsToWidget(points),
    );
  }

  Widget _buildMonthlyChart(List<PracticeRecord> records) {
    final monthlyGroups = StatsCalculator.groupByMonth(records);
    if (monthlyGroups.isEmpty) return _buildNoData();

    final points = monthlyGroups.entries.toList().asMap().entries.map((e) {
      final successRate = StatsCalculator.calculateTotalSuccessRate(e.value.value);
      return FlSpot(e.key.toDouble(), successRate);
    }).toList();

    final labels = monthlyGroups.keys.toList();

    return _buildChartFrame(
      title: L10n.s(ref, 'monthly'),
      child: spotsToWidget(points, labels: labels),
    );
  }

  Widget _buildYearlyChart(List<PracticeRecord> records) {
    final yearlyGroups = StatsCalculator.groupByYear(records);
    if (yearlyGroups.isEmpty) return _buildNoData();

    final points = yearlyGroups.entries.toList().asMap().entries.map((e) {
      final successRate = StatsCalculator.calculateTotalSuccessRate(e.value.value);
      return FlSpot(e.key.toDouble(), successRate);
    }).toList();

    final labels = yearlyGroups.keys.toList();

    return _buildChartFrame(
      title: L10n.s(ref, 'yearly'),
      child: spotsToWidget(points, labels: labels),
    );
  }

  Widget _buildNoData() {
    return Center(child: Text(L10n.s(ref, 'no_data'), style: const TextStyle(color: AppColors.textDim)));
  }

  Widget spotsToWidget(List<FlSpot> points, {List<String>? labels}) {
    if (points.isEmpty) return _buildNoData();
    return _buildLineChart(points, labels: labels);
  }

  Widget _buildChartFrame({required String title, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: CleanCard(
        title: title,
        child: SizedBox(
          height: 350,
          child: Padding(
            padding: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<FlSpot> spots, {List<String>? labels}) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.textDim.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: labels != null,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (labels != null && index >= 0 && index < labels.length) {
                  // ラベルが多い場合は間引く
                  if (labels.length > 6 && index % (labels.length ~/ 4) != 0 && index != labels.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index].substring(labels[index].length > 5 ? 2 : 0), // YY-MM または YYYY
                      style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primary.withValues(alpha: 0.9),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                String label = '';
                if (labels != null && s.x.toInt() < labels.length) {
                  label = '${labels[s.x.toInt()]}\n';
                }
                return LineTooltipItem(
                  '$label${s.y.toInt()}%',
                  const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: spots.length > 1,
            color: AppColors.primary,
            barWidth: 6,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.white,
                strokeWidth: 3,
                strokeColor: AppColors.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
