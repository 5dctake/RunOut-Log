import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  // テスト用ユニットID
  static String get bannerAdUnitId {
    if (kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-1389375416993430/2615836577'
          : 'ca-app-pub-1389375416993430/5789299404';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
  }

  static String get interstitialAdUnitId {
    if (kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-1389375416993430/5036920129'
          : 'ca-app-pub-1389375416993430/1801448356';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-3940256099942544/4411468910';
  }

  Future<void> init() async {
    try {
      // iOSの場合はATTの許可リクエストを行う
      if (Platform.isIOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }

      // 初期化処理全体にタイムアウトを設定（最大10秒）
      await MobileAds.instance.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('AdService: MobileAds initialization timed out');
          return InitializationStatus({});
        },
      );
      
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: Error during init: $e');
    }
  }

  void loadInterstitialAd() {
    if (_isInterstitialAdLoading) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd loaded');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onDismiss}) {
    if (_interstitialAd == null) {
      debugPrint('AdService: InterstitialAd not ready');
      onDismiss();
      loadInterstitialAd(); // Load for next time
      return;
    }

    // Safety timeout: If the ad doesn't dismiss within 30 seconds for any reason,
    // force call onDismiss to prevent blocking the user.
    bool dismissed = false;
    final timeout = Future.delayed(const Duration(seconds: 30), () {
      if (!dismissed) {
        debugPrint('AdService: Ad display timed out, forcing dismissal');
        dismissed = true;
        onDismiss();
      }
    });

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: Ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Ad dismissed full screen content.');
        ad.dispose();
        _interstitialAd = null;
        if (!dismissed) {
          dismissed = true;
          onDismiss();
          loadInterstitialAd(); // Load for next time
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Ad failed to show full screen content: $error');
        ad.dispose();
        _interstitialAd = null;
        if (!dismissed) {
          dismissed = true;
          onDismiss();
          loadInterstitialAd();
        }
      },
      onAdImpression: (ad) => debugPrint('AdService: Ad impression recorded.'),
    );

    debugPrint('AdService: Attempting to show InterstitialAd');
    _interstitialAd!.show();
  }
}
