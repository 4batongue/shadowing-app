# shadowing_app

英語シャドーイング学習アプリ（Flutter実装）

## 概要
月額500円の低価格でAI自動添削によるシャドーイング学習を提供するアプリです。

## 実装済み機能
- ✅ コンテンツ表示（ホーム/コンテンツタブ）
- ✅ 学習画面（スクリプト・語彙リスト表示）
- ✅ 音声プレーヤーUI（再生/一時停止・速度変更・進捗バー）
- ✅ 録音機能UI
- ✅ レベル別色分け表示

## 技術スタック
- Flutter
- Riverpod（状態管理）
- Material Design 3

## 開発フェーズ
- [x] Phase 1: JSONコンテンツ表示
- [x] Phase 2: 基本学習画面
- [x] Phase 3: 音声プレーヤーUI
- [ ] Phase 4: データ永続化
- [ ] Phase 5: Firebase連携

## 実行方法
```bash
flutter pub get
flutter run