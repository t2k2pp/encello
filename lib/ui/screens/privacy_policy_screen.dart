import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../widgets/centered_content.dart';

/// プライバシーポリシー（設定 > 情報 から開く）。
///
/// 原本はリポジトリ直下の `PRIVACY_POLICY.md`。改定時は原本・本画面・公開URLの
/// 3点を同時に更新し、[_established] に改定日を追記すること
/// （[Docs/11_release_quickref.md] C-1）。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _established = '制定日: 2026年8月10日';

  static const List<({String title, String body})> _sections = [
    (
      title: '基本方針',
      body:
          '${AppInfo.name}（以下「本アプリ」）は、記録したデータをすべてお使いの端末内にのみ保存します。'
          '開発者がユーザーの個人情報や学習記録を収集・送信・閲覧することはありません。'
          'アカウント登録も不要です。\n'
          '\n'
          '本アプリはインターネット通信を行いません。'
          'Android 版はネットワーク権限（INTERNET）自体を宣言していません。',
    ),
    (
      title: '端末内で利用する情報',
      body:
          '本アプリは次の機能のために端末の情報へアクセスします。いずれも端末内での処理・保存にのみ使われ、'
          '外部へ送信されることはありません。権限を許可しない場合も、該当機能以外はそのまま利用できます。\n'
          '\n'
          '・通知: 学習リマインダーの表示。設定でリマインダーを ON にしようとしたときに'
          '初めて許可を求めます（起動時には求めません）\n'
          '・他アプリからの共有: ブラウザや電子書籍アプリから共有されたテキストを、'
          'マイ単語のクイック登録に取り込みます\n'
          '・ファイルの読み書き: バックアップ（JSON）・単語帳（CSV）・音声パック（ZIP）の'
          '書き出しと取り込み。ユーザーが選んだファイルだけを読みます\n'
          '\n'
          'カメラ・位置情報・連絡先・写真ライブラリにはアクセスしません。',
    ),
    (
      title: '読み上げ（音声合成）',
      body:
          '単語の読み上げには、端末に入っている音声合成エンジン（OS の機能）を使います。'
          '本アプリは読み上げる文字列（見出し語・和訳）をそのエンジンへ渡すだけで、'
          '外部のサーバーへ送信することはありません。\n'
          '\n'
          '音声合成エンジンは本アプリとは別のソフトウェアです。エンジン自体の動作には、'
          'その提供元の条件が適用されます。音声データが端末に入っていない場合の追加ダウンロードは、'
          'OS の設定から行うものであり、本アプリは関与しません。\n'
          '\n'
          '音声パックを取り込んだ語は、パック内の録音ファイルを端末内で再生します。',
    ),
    (
      title: '生成AI に単語帳を作ってもらう機能',
      body:
          '本アプリは、生成AI に渡すための定型文を組み立ててクリップボードへコピーする機能と、'
          '返ってきた内容を貼り付けて取り込む機能を持ちます。\n'
          '\n'
          '本アプリ自身が生成AI サービスと通信することはありません。'
          '定型文をどのサービスに貼り付けるかはユーザーが選びます。'
          '貼り付けた内容の取り扱いには、そのサービスのプライバシーポリシーが適用されます。',
    ),
    (
      title: '広告・アクセス解析',
      body:
          '本アプリは広告を表示しません。アクセス解析や行動追跡も行いません。'
          'クラッシュレポートの外部送信も行いません。',
    ),
    (
      title: 'データの共有',
      body:
          'エクスポート（JSON / CSV）や共有シートによってデータが端末の外へ出るのは、'
          'ユーザー自身がその操作を行ったときだけです。'
          '共有したデータの取り扱いはユーザーの管理となります。',
    ),
    (
      title: '学習者ごとのデータ',
      body:
          '本アプリは1台の端末を複数人（家族など）で使えるように、学習者を分けて記録します。'
          'どの学習者のデータも同じ端末内に保存され、外部へ送信されません。'
          '学習者を削除すると、その学習者の学習記録とマイ単語も一緒に削除されます。',
    ),
    (
      title: 'データの削除',
      body:
          '記録データはアプリ内の削除操作（学習者の削除・学習状態のリセット）、または'
          'アプリのアンインストールで削除できます。開発者側にデータの複製は存在しません'
          '（バックアップはユーザー自身のエクスポートのみです）。',
    ),
    (
      title: '子どものプライバシー',
      body:
          '本アプリは中学生・高校生の利用を想定していますが、個人情報を一切収集しないため、'
          '年齢による取り扱いの違いはありません。'
          'アカウント登録も、保護者の同意を要する情報の収集もありません。',
    ),
    (
      title: '本ポリシーの変更',
      body: '内容を変更する場合は、アプリの更新情報およびアプリ内でお知らせします。',
    ),
    (
      title: 'お問い合わせ',
      body: '本ポリシーに関するお問い合わせは ${AppInfo.supportEmail} までお寄せください。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.of(context).screenPadding;
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシーポリシー')),
      body: CenteredContent(
        child: ListView(
          padding: padding,
          children: [
            Text('${AppInfo.name} プライバシーポリシー', style: AppText.sectionTitle()),
            const SizedBox(height: 4),
            Text(_established, style: AppText.caption()),
            const SizedBox(height: 16),
            for (final s in _sections) ...[
              Text(s.title, style: AppText.sectionTitle()),
              const SizedBox(height: 6),
              Text(s.body, style: AppText.body()),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
