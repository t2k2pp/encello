import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/tts_service.dart';
import '../../providers/audio.dart';
import '../../providers/providers.dart';
import 'soft_card.dart';
import 'soft_dropdown.dart';

/// 設定 > 学習 の音声カード（[Docs/06_features/pronunciation.md] §7）。
///
/// 音声パックも合成音声も無い端末では、カードごと出さず1行に置き換える。
/// 選ぶ意味のない設定を並べない。
class AudioSettingsCard extends ConsumerWidget {
  final Profile profile;

  const AudioSettingsCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capability = ref.watch(ttsCapabilityProvider).value;
    final packs = ref.watch(audioPacksProvider).value ?? const [];
    // voice の列挙が終わるまでは何も出さない（先に空のカードを見せない）。
    if (capability == null) return const SizedBox.shrink();

    if (!capability.hasAny && packs.isEmpty) {
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('音声', style: AppText.sectionTitle()),
            const SizedBox(height: 4),
            Text(
              'この端末では音声を再生できません。'
              '端末の設定 > 言語と入力 > 読み上げ から音声データを追加できることがあります。',
              style: AppText.caption(),
            ),
          ],
        ),
      );
    }

    final missing = ref.watch(missingVoicesProvider(profile));
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('音声', style: AppText.sectionTitle()),
          const SizedBox(height: 4),
          Text(
            '単語の読み上げに使う音源を選べます。例文は常に合成音声で読み上げます。',
            style: AppText.caption(),
          ),
          // 音声パックが1つも無いときは「音源」を選ぶ意味がないので出さない。
          if (packs.isNotEmpty) ...[
            const SizedBox(height: 12),
            SoftDropdown<AudioSourcePreference>(
              value: AudioSourcePreference.fromValue(profile.audioSource),
              hint: '音源',
              items: [
                for (final o in AudioSourcePreference.values)
                  (value: o, label: o.label),
              ],
              onChanged: (o) => _patch(
                ref,
                ProfilesCompanion(audioSource: Value(o.value)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text('音声パックを追加すると、録音された発音で学習できます。', style: AppText.caption()),
          ],
          if (capability.hasAny) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.line),
            const SizedBox(height: 4),
            Text('合成音声', style: AppText.caption()),
            for (final lang in SpeechLang.values)
              if (capability.has(lang)) ...[
                const SizedBox(height: 8),
                _VoiceRow(
                  profile: profile,
                  lang: lang,
                  voices: capability.voicesFor(lang),
                  missing: missing.contains(lang),
                ),
              ],
            const SizedBox(height: 12),
            _SliderRow(
              label: '速さ',
              value: profile.ttsRate,
              min: 0.3,
              max: 0.7,
              onChanged: (v) =>
                  _patch(ref, ProfilesCompanion(ttsRate: Value(v))),
            ),
            _SliderRow(
              label: '高さ',
              value: profile.ttsPitch,
              min: 0.8,
              max: 1.2,
              onChanged: (v) =>
                  _patch(ref, ProfilesCompanion(ttsPitch: Value(v))),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _preview(context, ref, capability),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('試聴'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _patch(WidgetRef ref, ProfilesCompanion patch) async {
    await ref
        .read(profileRepositoryProvider)
        .updateSettings(profile.id, patch);
    await ref.read(activeProfileProvider.notifier).reload();
  }

  Future<void> _preview(
    BuildContext context,
    WidgetRef ref,
    TtsCapability capability,
  ) async {
    final service = await ref.read(pronunciationProvider(profile).future);
    final lang = capability.hasEn ? SpeechLang.en : SpeechLang.ja;
    try {
      await service.speakText(
        lang == SpeechLang.en ? 'This is a sample.' : 'これはサンプルです。',
        lang,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

/// 言語ごとの voice 選択。**端末に実在する voice だけ**を並べる（FR-49）。
class _VoiceRow extends ConsumerWidget {
  final Profile profile;
  final SpeechLang lang;
  final List<TtsVoice> voices;

  /// 保存済みの voice が端末から消えているか。勝手に別の voice へ切り替えず警告する。
  final bool missing;

  const _VoiceRow({
    required this.profile,
    required this.lang,
    required this.voices,
    required this.missing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = lang == SpeechLang.en
        ? profile.ttsEnVoice
        : profile.ttsJaVoice;
    final label = lang == SpeechLang.en ? '英語の音声' : '日本語の音声';
    final selected = voices.any((v) => v.name == saved) ? saved : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption()),
        const SizedBox(height: 4),
        SoftDropdown<String>(
          value: selected,
          hint: label,
          items: [
            (value: '', label: '端末の既定'),
            for (final v in voices) (value: v.name, label: v.name),
          ],
          onChanged: (name) async {
            await ref
                .read(profileRepositoryProvider)
                .updateSettings(
                  profile.id,
                  lang == SpeechLang.en
                      ? ProfilesCompanion(ttsEnVoice: Value(name))
                      : ProfilesCompanion(ttsJaVoice: Value(name)),
                );
            await ref.read(activeProfileProvider.notifier).reload();
          },
        ),
        if (missing)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '選択中の音声が見つかりません。選び直してください。',
              style: AppText.caption(color: AppColors.accentDeep),
            ),
          ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: 8,
            activeColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
