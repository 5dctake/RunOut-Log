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

  final InAppPurchase _iap = InAppPurchase.instance;
  static const String adFreeProductId = 'remove_ads_permanent';

  /// 決済ストリームの監視を開始する（main.dart または初期画面で呼ぶ）
  void initialize(WidgetRef ref) {
    final purchaseUpdated = _iap.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList, ref);
    }, onDone: () {
      // ストリーム終了
    }, onError: (error) {
      // エラー処理
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList, WidgetRef ref) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 処理待機中
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // エラー
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // 購入完了 または リストア完了
          await ref.read(adFreeProvider.notifier).setAdFree(true);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> buyAdFree(WidgetRef ref) async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails({adFreeProductId});
    if (response.notFoundIDs.isNotEmpty) {
      // プロダクトが見つからない
      return;
    }

    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    // 決済開始
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchase(WidgetRef ref) async {
    await _iap.restorePurchases();
  }
}
