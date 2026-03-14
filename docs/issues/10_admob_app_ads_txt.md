# Issue #10: AdMob app-ads.txt Verification Setup

## 背景
AdMobの広告配信を正常に行うためには、アプリストアに登録された「デベロッパWebサイト」のドメインのルートに `app-ads.txt` が配置されている必要があります。
現在、ストアのURLがリポジトリ（github.com/5dctake/...）になっている場合、AdMobは `github.com/app-ads.txt` を探しに行ってしまい、自身の管理下ではないためエラーになります。

## 解決策
ストアのURLを GitHub Pages のURLに変更し、そこで `app-ads.txt` を公開します。

- 候補URL: `https://5dctake.github.io/RunOut-Log/`
- 対応内容: 
  - `docs/` フォルダを GitHub Pages のソースとして使用する。
  - `docs/app-ads.txt` を配置（済）。
  - `docs/index.html` を作成し、開発者サイトとして機能させる。

## 完了条件
- `docs/index.html` が作成され、プロフェッショナルなランディングページが表示されること。
- `README.md` に新しいサイトURLが記載されていること。
- ユーザーにストアURLの変更手順を共有すること。
