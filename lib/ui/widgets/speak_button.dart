import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/enums.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/pronunciation_service.dart';
import '../../providers/audio.dart';

/// 読み上げボタン（[Docs/04_screens_and_flows.md] §4.18）。
///
/// **鳴らせない語ではボタンごと出さない**（無効化してグレーにしない）。
/// 右下に音源バッジ（🎙 音声ファイル / 🔉 合成音声）を重ね、長押しで音源名を出す。
/// 音声パックが1つも入っていない端末では全部が 🔉 になり情報にならないため、
/// バッジを出さない。
class SpeakWordButton extends ConsumerStatefulWidget {
  final Profile profile;
  final Word word;
  final SpeechLang lang;
  final double size;

  const SpeakWordButton({
    super.key,
    required this.profile,
    required this.word,
    required this.lang,
    this.size = 40,
  });

  @override
  ConsumerState<SpeakWordButton> createState() => _SpeakWordButtonState();
}

class _SpeakWordButtonState extends ConsumerState<SpeakWordButton> {
  bool _busy = false;

  Future<void> _speak(PronunciationService service) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await service.speakWord(
        wordId: widget.word.id,
        headword: widget.word.headword,
        lang: widget.lang,
      );
    } catch (e) {
      // 無音のまま成功したように見せない。
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // voice の列挙が終わるまではボタンを出さない（押しても鳴らない状態を作らない）。
    final service = ref.watch(pronunciationProvider(widget.profile)).value;
    if (service == null) return const SizedBox.shrink();

    final kind = service.resolve(widget.word.id, widget.lang);
    if (kind == null) return const SizedBox.shrink();

    final sourceName = service.sourceNameOf(widget.word.id, widget.lang) ?? '';
    final label = widget.lang == SpeechLang.en ? '英語で読み上げる' : '日本語で読み上げる';

    return Tooltip(
      message: '$label（$sourceName）',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            iconSize: widget.size * 0.55,
            constraints: BoxConstraints.tightFor(
              width: widget.size,
              height: widget.size,
            ),
            padding: EdgeInsets.zero,
            tooltip: label,
            color: AppColors.accent,
            onPressed: _busy ? null : () => _speak(service),
            icon: const Icon(Icons.volume_up),
          ),
          if (service.hasAnyAudioPack)
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                kind.badge,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

/// 例文などの任意テキストを読み上げるボタン。常に合成音声で読む。
class SpeakTextButton extends ConsumerStatefulWidget {
  final Profile profile;
  final String text;
  final SpeechLang lang;

  const SpeakTextButton({
    super.key,
    required this.profile,
    required this.text,
    required this.lang,
  });

  @override
  ConsumerState<SpeakTextButton> createState() => _SpeakTextButtonState();
}

class _SpeakTextButtonState extends ConsumerState<SpeakTextButton> {
  bool _busy = false;

  Future<void> _speak(PronunciationService service) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await service.speakText(widget.text, widget.lang);
    } catch (e) {
      // 無音のまま成功したように見せない。
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(pronunciationProvider(widget.profile)).value;
    final capability = ref.watch(ttsCapabilityProvider).value;
    // 例文は常に合成音声なので、その言語の voice が無ければボタンを出さない。
    if (service == null || capability == null || !capability.has(widget.lang)) {
      return const SizedBox.shrink();
    }

    return IconButton(
      iconSize: 20,
      tooltip: '読み上げる',
      color: AppColors.accent,
      onPressed: _busy ? null : () => _speak(service),
      icon: const Icon(Icons.volume_up_outlined),
    );
  }
}
