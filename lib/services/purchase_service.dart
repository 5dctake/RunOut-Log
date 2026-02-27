import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final adFreeProvider = StateNotifierProvider<AdFreeNotifier, bool>((ref) {
  return AdFreeNotifier();
});

class AdFreeNotifier extends StateNotifier<bool> {
  AdFreeNotifier() : super(false) {
    _loadStatus();
  }

  static const _key = 'is_ad_free';

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setAdFree(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    state = value;
  }
}

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // ignore: unused_field
  final InAppPurchase _iap = InAppPurchase.instance;
  static const String adFreeProductId = 'remove_ads_permanent';

  Future<void> buyAdFree(WidgetRef ref) async {
    // 実際の課金ロジックのスケルトン
    // MVP/開発用として、シミュレーションで即時有効化
    // 本番では _iap.buyNonConsumable(...) を使用
    await ref.read(adFreeProvider.notifier).setAdFree(true);
  }

  Future<void> restorePurchase(WidgetRef ref) async {
    // リストアロジックのスケルトン
    await ref.read(adFreeProvider.notifier).setAdFree(true);
  }
}
