import 'dart:convert';
import 'dart:typed_data';

import 'package:encello/domain/services/file_exchange_service.dart';

/// 実機のファイルダイアログを出さないフェイク（[Docs/07_testing_strategy.md] §4）。
///
/// 書き出した内容と、読み込ませるファイルをテストから直接扱う。
class FakeFileExchangeService implements FileExchangeService {
  FakeFileExchangeService({this.picked, this.cancelSave = false});

  /// [pick] が返すファイル。null なら「選ばずに閉じた」。
  PickedFile? picked;

  /// [save] で保存先を選ばずに閉じたことにするか。
  bool cancelSave;

  /// 書き出した内容（呼ばれた順）。
  final saved = <({String name, String contents})>[];

  /// 共有した回数。
  int shareCount = 0;

  /// テキストから読み込ませるファイルを作る。
  static PickedFile fileOf(String name, String contents) =>
      PickedFile(name: name, bytes: Uint8List.fromList(utf8.encode(contents)));

  @override
  Future<String?> save({
    required String suggestedName,
    required String contents,
  }) async {
    if (cancelSave) return null;
    saved.add((name: suggestedName, contents: contents));
    return '/tmp/$suggestedName';
  }

  @override
  Future<PickedFile?> pick({required List<String> extensions}) async => picked;

  @override
  Future<void> share({required String path, required String subject}) async {
    shareCount++;
  }
}
