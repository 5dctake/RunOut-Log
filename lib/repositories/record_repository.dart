import 'package:hive_flutter/hive_flutter.dart';
import 'package:runout_log/models/practice_record.dart';

class RecordRepository {
  static const String boxName = 'practice_records';

  Future<void> saveRecord(PracticeRecord record) async {
    final box = Hive.box<PracticeRecord>(boxName);
    await box.add(record);
  }

  List<PracticeRecord> getRecords() {
    final box = Hive.box<PracticeRecord>(boxName);
    return box.values.toList();
  }

  Future<void> deleteRecord(int index) async {
    final box = Hive.box<PracticeRecord>(boxName);
    await box.deleteAt(index);
  }

  Future<void> clearAll() async {
    final box = Hive.box<PracticeRecord>(boxName);
    await box.clear();
  }
}
