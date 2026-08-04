import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/app_version.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../providers/providers.dart';
import '../widgets/soft_card.dart';
import 'profiles_screen.dart';
import 'wordbooks_screen.dart';

/// SCR-11 設定（[Docs/04_screens_and_flows.md] §4.10、[STYLE_GUIDE §5]）。
///
/// タブは 表示 / 学習 / マスタ / データ / 情報 の5つが最終形。中身がまだ無いタブは
/// 出さない（空のタブを置かない。[STYLE_GUIDE §0-4]）。学習・データは、それぞれの
/// 設定が実際に効く機能が入った時点で足す。
///
/// 表示タブの設定はすべて**現在の学習者のもの**。切り替えると別の値になる。
class SettingsScreen extends StatelessWidget {
  /// 現在の学習者。表示タブの各設定はこの人のものを読み書きする。
  final Profile profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: spacing.screenPadding.copyWith(bottom: 0),
            child: Text('設定', style: AppText.title()),
          ),
          TabBar(
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.ink3,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: '表示'),
              Tab(text: '学習'),
              Tab(text: 'マスタ'),
              Tab(text: '情報'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DisplayTab(profile: profile),
                _StudyTab(profile: profile),
                _MasterTab(profile: profile),
                const _InfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 表示タブ。値は現在の学習者の `profiles` の列に保存する。
class _DisplayTab extends StatelessWidget {
  final Profile profile;

  const _DisplayTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding,
      children: [
        _ThemeColorCard(profile: profile),
        SizedBox(height: spacing.gap),
        _TextSizeCard(profile: profile),
        SizedBox(height: spacing.gap),
        _DensityCard(profile: profile),
      ],
    );
  }
}

/// 学習者の設定を1項目書き換え、画面に出ている値を読み直す。
Future<void> _patchProfile(
  WidgetRef ref,
  int profileId,
  ProfilesCompanion patch,
) async {
  await ref.read(profileRepositoryProvider).updateSettings(profileId, patch);
  await ref.read(activeProfileProvider.notifier).reload();
}

/// 学習タブ。フラッシュカード・4択・スピード・音声・リマインダーの設定は、
/// それぞれの機能が入った時点で足す。
class _StudyTab extends StatelessWidget {
  final Profile profile;

  const _StudyTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding,
      children: [
        _DailyGoalCard(profile: profile),
        SizedBox(height: spacing.gap),
        _SessionSizeCard(profile: profile),
        SizedBox(height: spacing.gap),
        _KeyboardLayoutCard(profile: profile),
        SizedBox(height: spacing.gap),
        _AutoNextCard(profile: profile),
      ],
    );
  }
}

/// 1日に解く問題数の目標（FR-40）。
class _DailyGoalCard extends ConsumerWidget {
  final Profile profile;

  const _DailyGoalCard({required this.profile});

  static const _choices = [10, 20, 30, 50, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('デイリー目標', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('1日にこの問数を解くと、その日を達成にして連続日数が伸びます。', style: AppText.caption()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final n in _choices)
                ChoiceChip(
                  label: Text('$n問'),
                  selected: profile.dailyGoal == n,
                  onSelected: (_) => _patchProfile(
                    ref,
                    profile.id,
                    ProfilesCompanion(dailyGoal: Value(n)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 1セッションの問題数（FR-10）。モード選択シートの初期値になる。
class _SessionSizeCard extends ConsumerWidget {
  final Profile profile;

  const _SessionSizeCard({required this.profile});

  static const _choices = [10, 20, 50];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1セッションの問題数', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('学習をはじめるときの初期値です。開始前に変えられます。', style: AppText.caption()),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final n in _choices)
                ButtonSegment(value: n, label: Text('$n問')),
            ],
            selected: {
              _choices.contains(profile.sessionSize) ? profile.sessionSize : 20,
            },
            onSelectionChanged: (s) => _patchProfile(
              ref,
              profile.id,
              ProfilesCompanion(sessionSize: Value(s.first)),
            ),
          ),
        ],
      ),
    );
  }
}

/// アプリ内英字キーボードの配列（FR-17）。
class _KeyboardLayoutCard extends ConsumerWidget {
  final Profile profile;

  const _KeyboardLayoutCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = KeyboardLayout.fromValue(profile.keyboardLayout);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('キーボードの配列', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('綴りを入力するときのキーの並びです。ABC順はキーボードに慣れていないうちに向きます。', style: AppText.caption()),
          const SizedBox(height: 12),
          SegmentedButton<KeyboardLayout>(
            showSelectedIcon: false,
            segments: [
              for (final o in KeyboardLayout.values)
                ButtonSegment(value: o, label: Text(o.label)),
            ],
            selected: {current},
            onSelectionChanged: (s) => _patchProfile(
              ref,
              profile.id,
              ProfilesCompanion(keyboardLayout: Value(s.first.value)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 正解したら自動で次へ（既定 OFF）。
class _AutoNextCard extends ConsumerWidget {
  final Profile profile;

  const _AutoNextCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('正解したら自動で次へ', style: AppText.sectionTitle()),
              ),
              Switch(
                value: profile.autoNextOnCorrect,
                activeThumbColor: AppColors.accent,
                onChanged: (v) => _patchProfile(
                  ref,
                  profile.id,
                  ProfilesCompanion(autoNextOnCorrect: Value(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '正解のときだけ 1.2 秒後に次の問題へ進みます。'
            '間違えたときは、この設定に関わらず必ずタップで進みます。',
            style: AppText.caption(),
          ),
        ],
      ),
    );
  }
}

/// テーマの色（[STYLE_GUIDE §1.2]）。マスタ編集シートの色選択と同じ 36px 色玉
/// （選択中 = ink 枠3px＋白チェック）＋配色名で選ぶ。
/// SegmentedButton は色玉付き CJK ラベルで見切れるため使わない。
class _ThemeColorCard extends ConsumerWidget {
  final Profile profile;

  const _ThemeColorCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = profile.palette;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('テーマの色', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('アプリ全体の配色を変えられます。学習者ごとに選べます。', style: AppText.caption()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in appPalettes)
                _PaletteChoice(
                  palette: p,
                  selected: p.id == current,
                  onTap: () => _patchProfile(
                    ref,
                    profile.id,
                    ProfilesCompanion(palette: Value(p.id)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaletteChoice extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteChoice({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.ink : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                palette.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextSizeCard extends ConsumerWidget {
  final Profile profile;

  const _TextSizeCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = TextSizeOption.fromValue(profile.textScale);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('文字サイズ', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('端末の文字サイズ設定に、この倍率をかけて表示します。', style: AppText.caption()),
          const SizedBox(height: 12),
          SegmentedButton<TextSizeOption>(
            showSelectedIcon: false,
            segments: [
              for (final o in TextSizeOption.values)
                ButtonSegment(value: o, label: Text(o.label)),
            ],
            selected: {current},
            onSelectionChanged: (s) => _patchProfile(
              ref,
              profile.id,
              ProfilesCompanion(textScale: Value(s.first.value)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DensityCard extends ConsumerWidget {
  final Profile profile;

  const _DensityCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = UiDensity.fromValue(profile.density);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('余白', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text('コンパクトにすると余白が詰まり、一画面に入る情報が増えます。', style: AppText.caption()),
          const SizedBox(height: 12),
          SegmentedButton<UiDensity>(
            showSelectedIcon: false,
            segments: [
              for (final o in UiDensity.values)
                ButtonSegment(value: o, label: Text(o.label)),
            ],
            selected: {current},
            onSelectionChanged: (s) => _patchProfile(
              ref,
              profile.id,
              ProfilesCompanion(density: Value(s.first.value)),
            ),
          ),
        ],
      ),
    );
  }
}

/// マスタタブ。マイ単語・音声パック・実績のタイルは、それぞれの機能が入った時点で足す。
class _MasterTab extends StatelessWidget {
  final Profile profile;

  const _MasterTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding,
      children: [
        _NavTile(
          icon: Icons.group_outlined,
          label: '学習者管理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ProfilesScreen()),
          ),
        ),
        SizedBox(height: spacing.gap),
        _NavTile(
          icon: Icons.library_books_outlined,
          label: '単語帳管理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WordbooksScreen(profile: profile),
            ),
          ),
        ),
      ],
    );
  }
}

/// 遷移タイル（[STYLE_GUIDE §5]）。
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(),
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.ink3),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: spacing.screenPadding,
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('encello', style: AppText.sectionTitle()),
              const SizedBox(height: 4),
              Text('バージョン $kAppVersion', style: AppText.caption()),
              const SizedBox(height: 8),
              Text(
                '綴る・聴く・見分けるの3方向で英単語を反復し、忘却曲線に沿って再出題する英単語学習アプリです。',
                style: AppText.body(),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.gap),
        _NavTile(
          icon: Icons.description_outlined,
          label: 'オープンソースライセンス',
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'encello',
            applicationVersion: kAppVersion,
          ),
        ),
      ],
    );
  }
}
