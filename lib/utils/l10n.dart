import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Language { en, jp }

final languageProvider = StateProvider<Language>((ref) {
  final systemLocale = PlatformDispatcher.instance.locale.languageCode;
  return systemLocale == 'ja' ? Language.jp : Language.en;
});

class L10n {
  static const Map<Language, Map<String, String>> _strings = {
    Language.en: {
      'logs_title': 'Record History', // 以前のHUD用語からクリーンな用語へ
      'input_title': 'New Entry',
      'analytics_title': 'Performance',
      'settings_title': 'Settings',
      'total_stats': 'Lifetime Stats',
      'mode': 'Target',
      'type': 'Type',
      'attempts': 'Total Attempts',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'ratio': 'Success Ratio',
      'no_data': 'No records found',
      'save': 'Save Entry',
      'save_with_ad': 'Save (Ad will play)',
      'remove_ads': 'Remove Ads (Paid)',
      'remove_ads_desc': 'Remove all ads forever.',
      'restore_purchase': 'Restore Purchase',
      'purchased': 'Already Purchased',
      'reset_all': 'Reset All Data',
      'purge_warning': 'This will permanently delete all your practice history. This action cannot be undone.',
      'purge': 'Reset All Logs',
      'clear': 'Clear Entry',
      'language': 'Language Settings',
      'theme': 'Choose Theme Color', // 今回はカラープリセットの概念を簡略化するか検討
      'recorded_msg': 'Entry successfully saved',
      'incomplete_msg': 'Please fill in all results',
      'confirm_purge': 'Are you sure you want to reset everything?',
      'confirm_partial': 'Finish and save current results?',
      'empty_error': 'No results to save',
      'onboarding_1_title': 'Record Precisely',
      'onboarding_1_desc': 'Keep track of every runout attempt with a single tap.',
      'onboarding_2_title': 'Analyze Trends',
      'onboarding_2_desc': 'Visualize your progress with daily, monthly, and yearly charts.',
      'onboarding_3_title': 'Master Your Skills',
      'onboarding_3_desc': 'Clear your target ball counts and reach the next level.',
      'onboarding_4_title': 'Ball in Hand',
      'onboarding_4_desc': 'After the break, please start with the cue ball in hand.',
      'next': 'NEXT',
      'get_started': 'GET STARTED',
      'tutorial_input_title': 'How to Record',
      'tutorial_tab_title': 'Select Ball Count',
      'tutorial_tab_desc': 'First, select the number of balls for your practice session.',
      'tutorial_input_desc': 'Tap the circles (O/X) to record your results.',
      'tutorial_reset_desc': 'Finally, tap the "SAVE" button to store your records.',
      'sector_trend': 'Sector History',
      'seq_trend': 'Session Trend',
    },
    Language.jp: {
      'logs_title': '履歴',
      'input_title': '記録する',
      'analytics_title': '分析',
      'settings_title': '設定',
      'total_stats': '累計スコア',
      'mode': '種目',
      'type': '種目',
      'attempts': '総試行回数',
      'monthly': '月別',
      'yearly': '年別',
      'ratio': '成功率',
      'no_data': '記録がありません',
      'save': '記録を保存する',
      'save_with_ad': '記録を保存（広告再生）',
      'remove_ads': '広告を非表示にする（有料）',
      'remove_ads_desc': 'すべての広告が永久に消えます。',
      'restore_purchase': '購入を復元する',
      'purchased': '購入済み',
      'reset_all': '全データの初期化',
      'purge_warning': 'これまでの練習履歴がすべて削除されます。この操作は取り消せません。',
      'clear': '入力をクリア',
      'language': '言語',
      'theme': 'カラーテーマ',
      'recorded_msg': '記録されました',
      'incomplete_msg': '全ての項目を入力してください',
      'confirm_purge': '本当に全てのデータを削除してもよろしいですか？',
      'confirm_partial': 'ここまでの結果で記録を保存しますか？',
      'empty_error': '保存するデータがありません',
      'onboarding_1_title': '正確な記録',
      'onboarding_1_desc': 'タップひとつで、日々の取り切り結果を簡単に記録できます。',
      'onboarding_2_title': '傾向を分析',
      'onboarding_2_desc': '日・月・年単位のグラフで、自分の成長を視覚的に把握。',
      'onboarding_3_title': 'スキルアップ',
      'onboarding_3_desc': '種目ごとの成功率を高め、確かな実力を身につけましょう。',
      'onboarding_4_title': '基本ルール',
      'onboarding_4_desc': 'ブレイク後、手玉は「ボールインハンド（自由位置）」で始めてください。',
      'next': '次へ',
      'get_started': 'はじめる',
      'tutorial_input_title': '記録のしかた',
      'tutorial_tab_title': '種目を選ぼう',
      'tutorial_tab_desc': 'まずは練習するボールの数（種目）を上のタブから選びます。',
      'tutorial_input_desc': '丸をタップして結果（○/×）を入力します。',
      'tutorial_reset_desc': '最後に「記録を保存」ボタンを押して、練習データを保存しましょう！',
      'sector_trend': 'ブロック推移',
      'seq_trend': '日別推移',
    },
  };

  static String s(WidgetRef ref, String key) {
    final lang = ref.watch(languageProvider);
    return _strings[lang]?[key] ?? key;
  }
}
