/// アプリの基本情報。設定 > 情報 とプライバシーポリシー画面が参照する単一の定義。
///
/// [version] は `pubspec.yaml` の `version`（ビルド番号を除く）および
/// `core/utils/app_version.dart` の `kAppVersion` と一致させること
/// （[Docs/08_platform_setup.md] §6、[Docs/11_release_quickref.md] C-4）。
class AppInfo {
  AppInfo._();

  static const String name = 'encello';

  /// サポート窓口。設定 > 情報 の表示と、ストア掲載のサポート連絡先・
  /// プライバシーポリシーの問い合わせ先を一致させる
  /// （[Docs/11_release_quickref.md] C-6）。
  static const String supportEmail = 'isaosia@gmail.com';
}
