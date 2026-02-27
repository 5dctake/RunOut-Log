import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runout_log/models/practice_record.dart';
import 'package:runout_log/repositories/record_repository.dart';

final recordRepositoryProvider = Provider((ref) => RecordRepository());

// 現在の種目 (3, 4, 5球)
final ballCountProvider = StateProvider<int>((ref) => 5);

final recordsProvider = StateNotifierProvider<RecordsNotifier, List<PracticeRecord>>((ref) {
  final repository = ref.watch(recordRepositoryProvider);
  return RecordsNotifier(repository);
});

class RecordsNotifier extends StateNotifier<List<PracticeRecord>> {
  final RecordRepository _repository;

  RecordsNotifier(this._repository) : super([]) {
    _loadRecords();
  }

  void _loadRecords() {
    state = _repository.getRecords();
  }

  // 特定の種目のみを取得する
  List<PracticeRecord> getRecordsByBallCount(int ballCount) {
    return state.where((record) => record.ballCount == ballCount).toList();
  }

  Future<void> addRecord(PracticeRecord record) async {
    await _repository.saveRecord(record);
    _loadRecords();
  }

  Future<void> removeRecord(int index) async {
    await _repository.deleteRecord(index);
    _loadRecords();
  }

  Future<void> clearRecords() async {
    await _repository.clearAll();
    _loadRecords();
  }
}
