# Issue #11: iOSでの広告配信設定（SKAdNetwork, ATT）の修正

## 背景
iOS版において広告が表示されない、または配信が不安定である問題が発生しています。
調査の結果、`Info.plist` に必要な設定（SKAdNetworkItems, NSUserTrackingUsageDescription 等）が不足していること、および App Tracking Transparency (ATT) の対応が不十分であることが判明しました。

## 修正内容
1. `ios/Runner/Info.plist` への設定追加および整理
   - `SKAdNetworkItems`, `NSUserTrackingUsageDescription` 等の追加。
   - `UIApplicationSceneManifest` の削除による起動プロセスの安定化。
2. `pubspec.yaml` への依存関係追加とバージョン更新
   - `app_tracking_transparency` の追加。
   - バージョンを `1.0.4+6` に更新。
3. 起動フローの刷新 (lib/main.dart, lib/screens/splash_screen.dart)
   - 「Zero-Delay Startup」を導入し、起動時のフリーズを解消。
4. 広告表示ロジックの強化 (lib/services/ad_service.dart, lib/screens/input_screen.dart)
   - 保存時のブラックアウト問題を修正し、安定した広告表示を実現。

## 完了条件
- iOSで起動時にフリーズせず、スプラッシュ画面が表示されること。
- 保存時に広告が正常に再生され、完了後に画面が戻ること。
- App Storeへの申請準備 (1.0.4+6) が完了していること。
