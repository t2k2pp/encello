import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/app_data_dir.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/services/audio_library.dart';
import '../../data/services/audio_pack_importer.dart';
import '../../data/repositories/wordbook_repository.dart'
    show decodeIdList, encodeIdList;
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import '../dialogs/confirm_dialog.dart';
import '../widgets/centered_content.dart';
import '../widgets/empty_state.dart';
import '../widgets/soft_card.dart';

/// SCR-23 音声パック管理（[Docs/06_features/pronunciation.md] §8）。
///
/// 使用の ON/OFF と優先順位（同じ語が複数のパックにあれば上のものを使う）を、
/// **学習者ごと**に持つ（`profiles.audioPackIds`）。パックそのものは全員で共有する。
class AudioPacksScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const AudioPacksScreen({super.key, required this.profile});

  @override
  ConsumerState<AudioPacksScreen> createState() => _AudioPacksScreenState();
}

class _AudioPacksScreenState extends ConsumerState<AudioPacksScreen> {
  bool _importing = false;

  Profile get _profile => ref.watch(activeProfileProvider) ?? widget.profile;

  Future<void> _import() async {
    if (_importing) return;
    final picked = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: '音声パック', extensions: ['zip']),
      ],
    );
    if (picked == null || !mounted) return;

    setState(() => _importing = true);
    try {
      final dir = await appDataDirectory();
      final importer = AudioPackImporter(ref.read(databaseProvider), dir);
      var result = await _runImport(importer, File(picked.path));
      if (result == null || !mounted) return;

      // 取り込んだパックは、その場で使えるように学習者の使用リストへ足す。
      await _setEnabled(result.packId, true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.unmatchedCount == 0
                ? '「${result.name}」から ${result.importedCount}件を取り込みました'
                : '「${result.name}」から ${result.importedCount}件を取り込みました。'
                      '${result.unmatchedCount}件は該当する単語がありませんでした',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  /// 同じパックがすでにあるときだけ置換の確認を挟む。
  Future<AudioPackImportResult?> _runImport(
    AudioPackImporter importer,
    File file,
  ) async {
    try {
      return await importer.importZip(file);
    } on AudioPackImportException catch (e) {
      if (!mounted) return null;
      if (e.message.contains('すでに入っています')) {
        final ok = await confirmDestructive(
          context,
          title: '音声パックを置き換えますか',
          message: '${e.message}\n\n置き換えると、古い音声ファイルは削除されます。',
          confirmLabel: '置き換える',
        );
        if (!ok || !mounted) return null;
        return _runImport2(importer, file);
      }
      _showFailure(e);
      return null;
    }
  }

  Future<AudioPackImportResult?> _runImport2(
    AudioPackImporter importer,
    File file,
  ) async {
    try {
      return await importer.importZip(file, replaceExisting: true);
    } on AudioPackImportException catch (e) {
      _showFailure(e);
      return null;
    }
  }

  void _showFailure(AudioPackImportException e) {
    if (!mounted) return;
    // 失敗の理由を握りつぶさない。詳細があれば一覧で見せる。
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('音声パックを取り込めません'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.message, style: AppText.body()),
              if (e.details.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final line in e.details)
                  Text(line, style: AppText.caption()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> _setEnabled(String packId, bool enabled) async {
    final db = ref.read(databaseProvider);
    final pack = await (db.select(db.audioPacks)
          ..where((t) => t.packId.equals(packId)))
        .getSingleOrNull();
    if (pack == null) return;
    await _updateEnabledIds((ids) {
      final next = [...ids]..remove(pack.id);
      if (enabled) next.add(pack.id);
      return next;
    });
  }

  Future<void> _updateEnabledIds(
    List<int> Function(List<int> current) transform,
  ) async {
    final profile = _profile;
    final next = transform(decodeIdList(profile.audioPackIds));
    await ref
        .read(profileRepositoryProvider)
        .updateSettings(
          profile.id,
          ProfilesCompanion(audioPackIds: Value(encodeIdList(next))),
        );
    await ref.read(activeProfileProvider.notifier).reload();
  }

  Future<void> _delete(AudioPack pack) async {
    final ok = await confirmDestructive(
      context,
      title: '音声パックを削除',
      message:
          '「${pack.name}」を削除します。展開済みの音声ファイルも一緒に消えます。'
          'この端末のすべての学習者から使えなくなります。',
    );
    if (!ok || !mounted) return;

    final db = ref.read(databaseProvider);
    try {
      final dir = await appDataDirectory();
      final packDir = Directory(
        '${dir.path}/$kAudioPackDirName/${pack.packId}',
      );
      if (packDir.existsSync()) packDir.deleteSync(recursive: true);
      // word_audios は cascade で消える。
      await (db.delete(db.audioPacks)..where((t) => t.id.equals(pack.id))).go();
      await _updateEnabledIds((ids) => [...ids]..remove(pack.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
    }
  }

  /// 優先順位を1つ上げる。使用中のパックの中での並びを入れ替える。
  Future<void> _moveUp(int packId) async {
    await _updateEnabledIds((ids) {
      final next = [...ids];
      final index = next.indexOf(packId);
      if (index <= 0) return next;
      next
        ..removeAt(index)
        ..insert(index - 1, packId);
      return next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final packsAsync = ref.watch(audioPacksProvider);
    final enabled = decodeIdList(_profile.audioPackIds);

    return Scaffold(
      appBar: AppBar(title: const Text('音声パック')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: _importing ? null : _import,
        icon: _importing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: const Text('音声パックを取り込む'),
      ),
      body: CenteredContent(
        child: packsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => EmptyState(
            emoji: '⚠️',
            message: '音声パックを読み込めませんでした',
            subMessage: '$e',
          ),
          data: (packs) {
            if (packs.isEmpty) {
              return const EmptyState(
                emoji: '🎙',
                message: '音声パックがありません',
                subMessage: '録音された発音のファイルを取り込むと、その語は録音で読み上げます。'
                    '入れていない語は合成音声で読み上げます。',
              );
            }
            // 使用中のものを優先順位の順に上へ、未使用をその下へ。
            final ordered = [
              for (final id in enabled)
                ...packs.where((p) => p.id == id),
              ...packs.where((p) => !enabled.contains(p.id)),
            ];
            return ListView.separated(
              padding: spacing.screenPadding.copyWith(bottom: 96),
              itemCount: ordered.length,
              separatorBuilder: (_, _) => SizedBox(height: spacing.gap),
              itemBuilder: (_, i) {
                final pack = ordered[i];
                final isEnabled = enabled.contains(pack.id);
                return _PackRow(
                  pack: pack,
                  enabled: isEnabled,
                  // 使用中の先頭は上げられない。
                  canMoveUp: isEnabled && enabled.indexOf(pack.id) > 0,
                  onToggle: (v) => _setEnabled(pack.packId, v),
                  onMoveUp: () => _moveUp(pack.id),
                  onDelete: () => _delete(pack),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PackRow extends StatelessWidget {
  final AudioPack pack;
  final bool enabled;
  final bool canMoveUp;
  final ValueChanged<bool> onToggle;
  final VoidCallback onMoveUp;
  final VoidCallback onDelete;

  const _PackRow({
    required this.pack,
    required this.enabled,
    required this.canMoveUp,
    required this.onToggle,
    required this.onMoveUp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = SpeechLang.fromValue(pack.lang);
    final bundled =
        AudioPackSource.fromValue(pack.source) == AudioPackSource.bundled;
    return SoftCard(
      child: Row(
        children: [
          Text(
            '🎙',
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(),
                ),
                Text(
                  '${lang == SpeechLang.en ? '英語' : '日本語'} ・ ${pack.entryCount}語',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(),
                ),
              ],
            ),
          ),
          if (canMoveUp)
            IconButton(
              icon: Icon(Icons.arrow_upward, color: AppColors.ink3),
              tooltip: '優先順位を上げる',
              onPressed: onMoveUp,
            ),
          Tooltip(
            message: enabled ? '使わない' : '使う',
            child: Switch(
              value: enabled,
              activeThumbColor: AppColors.accent,
              onChanged: onToggle,
            ),
          ),
          // 同梱パックは削除できない（使用の ON/OFF だけできる）。
          if (!bundled)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.ink3),
              tooltip: '音声パックを削除',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
