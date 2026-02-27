import 'package:hive/hive.dart';

part 'practice_record.g.dart';

@HiveType(typeId: 0)
class PracticeRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int ballCount;

  @HiveField(2)
  final List<bool> results; // 10要素固定 (true=○, false=×)

  PracticeRecord({
    required this.date,
    required this.ballCount,
    required this.results,
  });

  // 派生プロパティ
  int get successCount => results.where((r) => r).length;
  double get successRate => results.isEmpty ? 0 : (successCount / results.length * 100);
}
