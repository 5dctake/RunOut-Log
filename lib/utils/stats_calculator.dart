import 'package:runout_log/models/practice_record.dart';

class StatsCalculator {
  static String formatStats(List<PracticeRecord> records) {
    if (records.isEmpty) return '0/0 (0%)';
    int totalSuccess = 0;
    int totalTrials = 0;
    for (var record in records) {
      totalSuccess += record.results.where((r) => r).length;
      totalTrials += record.results.length;
    }
    double rate = (totalSuccess / totalTrials) * 100;
    return '$totalSuccess/$totalTrials (${rate.toInt()}%)';
  }

  static double calculateTotalSuccessRate(List<PracticeRecord> records) {
    if (records.isEmpty) return 0;
    int totalSuccess = 0;
    int totalTrials = 0;
    for (var record in records) {
      totalSuccess += record.results.where((r) => r).length;
      totalTrials += record.results.length;
    }
    return (totalSuccess / totalTrials) * 100;
  }

  static int calculateTotalTrials(List<PracticeRecord> records) {
    return records.fold(0, (sum, record) => sum + record.results.length);
  }

  // ブロック（100回単位）の計算
  static List<List<PracticeRecord>> splitIntoBlocks(List<PracticeRecord> records) {
    List<List<PracticeRecord>> blocks = [];
    List<PracticeRecord> currentBlock = [];
    int currentTrialsInBlock = 0;

    for (var record in records) {
      currentBlock.add(record);
      currentTrialsInBlock += record.results.length;
      
      if (currentTrialsInBlock >= 100) {
        blocks.add(currentBlock);
        currentBlock = [];
        currentTrialsInBlock = 0;
      }
    }
    
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock);
    }
    
    return blocks.reversed.toList(); // 最新ブロックが先に来るように
  }

  /// 月別でグループ化
  static Map<String, List<PracticeRecord>> groupByMonth(List<PracticeRecord> records) {
    final Map<String, List<PracticeRecord>> groups = {};
    for (var record in records) {
      final key = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(record);
    }
    // キー（日付）で昇順ソートして返す
    final sortedKeys = groups.keys.toList()..sort();
    return {for (var k in sortedKeys) k: groups[k]!};
  }

  /// 年別でグループ化
  static Map<String, List<PracticeRecord>> groupByYear(List<PracticeRecord> records) {
    final Map<String, List<PracticeRecord>> groups = {};
    for (var record in records) {
      final key = '${record.date.year}';
      groups.putIfAbsent(key, () => []).add(record);
    }
    final sortedKeys = groups.keys.toList()..sort();
    return {for (var k in sortedKeys) k: groups[k]!};
  }
}
