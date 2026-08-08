// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🙂'),
  );
  static const VerificationMeta _colorSeedMeta = const VerificationMeta(
    'colorSeed',
  );
  @override
  late final GeneratedColumn<int> colorSeed = GeneratedColumn<int>(
    'color_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paletteMeta = const VerificationMeta(
    'palette',
  );
  @override
  late final GeneratedColumn<String> palette = GeneratedColumn<String>(
    'palette',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pink'),
  );
  static const VerificationMeta _textScaleMeta = const VerificationMeta(
    'textScale',
  );
  @override
  late final GeneratedColumn<String> textScale = GeneratedColumn<String>(
    'text_scale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _densityMeta = const VerificationMeta(
    'density',
  );
  @override
  late final GeneratedColumn<String> density = GeneratedColumn<String>(
    'density',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _dictViewModeMeta = const VerificationMeta(
    'dictViewMode',
  );
  @override
  late final GeneratedColumn<String> dictViewMode = GeneratedColumn<String>(
    'dict_view_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('list'),
  );
  static const VerificationMeta _dictGridColumnsMeta = const VerificationMeta(
    'dictGridColumns',
  );
  @override
  late final GeneratedColumn<String> dictGridColumns = GeneratedColumn<String>(
    'dict_grid_columns',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _searchExamplesMeta = const VerificationMeta(
    'searchExamples',
  );
  @override
  late final GeneratedColumn<bool> searchExamples = GeneratedColumn<bool>(
    'search_examples',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("search_examples" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyGoalMeta = const VerificationMeta(
    'dailyGoal',
  );
  @override
  late final GeneratedColumn<int> dailyGoal = GeneratedColumn<int>(
    'daily_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _sessionSizeMeta = const VerificationMeta(
    'sessionSize',
  );
  @override
  late final GeneratedColumn<int> sessionSize = GeneratedColumn<int>(
    'session_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _keyboardLayoutMeta = const VerificationMeta(
    'keyboardLayout',
  );
  @override
  late final GeneratedColumn<String> keyboardLayout = GeneratedColumn<String>(
    'keyboard_layout',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('qwerty'),
  );
  static const VerificationMeta _autoNextOnCorrectMeta = const VerificationMeta(
    'autoNextOnCorrect',
  );
  @override
  late final GeneratedColumn<bool> autoNextOnCorrect = GeneratedColumn<bool>(
    'auto_next_on_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_next_on_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _flashcardModeMeta = const VerificationMeta(
    'flashcardMode',
  );
  @override
  late final GeneratedColumn<String> flashcardMode = GeneratedColumn<String>(
    'flashcard_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('silentAuto'),
  );
  static const VerificationMeta _flashcardSecondsMeta = const VerificationMeta(
    'flashcardSeconds',
  );
  @override
  late final GeneratedColumn<int> flashcardSeconds = GeneratedColumn<int>(
    'flashcard_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _choiceDirectionMeta = const VerificationMeta(
    'choiceDirection',
  );
  @override
  late final GeneratedColumn<String> choiceDirection = GeneratedColumn<String>(
    'choice_direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('random'),
  );
  static const VerificationMeta _speedLimitMsMeta = const VerificationMeta(
    'speedLimitMs',
  );
  @override
  late final GeneratedColumn<int> speedLimitMs = GeneratedColumn<int>(
    'speed_limit_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3000),
  );
  static const VerificationMeta _selectedWordbookIdsMeta =
      const VerificationMeta('selectedWordbookIds');
  @override
  late final GeneratedColumn<String> selectedWordbookIds =
      GeneratedColumn<String>(
        'selected_wordbook_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _audioSourceMeta = const VerificationMeta(
    'audioSource',
  );
  @override
  late final GeneratedColumn<String> audioSource = GeneratedColumn<String>(
    'audio_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('fileFirst'),
  );
  static const VerificationMeta _audioPackIdsMeta = const VerificationMeta(
    'audioPackIds',
  );
  @override
  late final GeneratedColumn<String> audioPackIds = GeneratedColumn<String>(
    'audio_pack_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _ttsEnVoiceMeta = const VerificationMeta(
    'ttsEnVoice',
  );
  @override
  late final GeneratedColumn<String> ttsEnVoice = GeneratedColumn<String>(
    'tts_en_voice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ttsJaVoiceMeta = const VerificationMeta(
    'ttsJaVoice',
  );
  @override
  late final GeneratedColumn<String> ttsJaVoice = GeneratedColumn<String>(
    'tts_ja_voice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ttsRateMeta = const VerificationMeta(
    'ttsRate',
  );
  @override
  late final GeneratedColumn<double> ttsRate = GeneratedColumn<double>(
    'tts_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _ttsPitchMeta = const VerificationMeta(
    'ttsPitch',
  );
  @override
  late final GeneratedColumn<double> ttsPitch = GeneratedColumn<double>(
    'tts_pitch',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(19),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    colorSeed,
    palette,
    textScale,
    density,
    dictViewMode,
    dictGridColumns,
    searchExamples,
    dailyGoal,
    sessionSize,
    keyboardLayout,
    autoNextOnCorrect,
    flashcardMode,
    flashcardSeconds,
    choiceDirection,
    speedLimitMs,
    selectedWordbookIds,
    audioSource,
    audioPackIds,
    ttsEnVoice,
    ttsJaVoice,
    ttsRate,
    ttsPitch,
    reminderEnabled,
    reminderHour,
    reminderMinute,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('color_seed')) {
      context.handle(
        _colorSeedMeta,
        colorSeed.isAcceptableOrUnknown(data['color_seed']!, _colorSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_colorSeedMeta);
    }
    if (data.containsKey('palette')) {
      context.handle(
        _paletteMeta,
        palette.isAcceptableOrUnknown(data['palette']!, _paletteMeta),
      );
    }
    if (data.containsKey('text_scale')) {
      context.handle(
        _textScaleMeta,
        textScale.isAcceptableOrUnknown(data['text_scale']!, _textScaleMeta),
      );
    }
    if (data.containsKey('density')) {
      context.handle(
        _densityMeta,
        density.isAcceptableOrUnknown(data['density']!, _densityMeta),
      );
    }
    if (data.containsKey('dict_view_mode')) {
      context.handle(
        _dictViewModeMeta,
        dictViewMode.isAcceptableOrUnknown(
          data['dict_view_mode']!,
          _dictViewModeMeta,
        ),
      );
    }
    if (data.containsKey('dict_grid_columns')) {
      context.handle(
        _dictGridColumnsMeta,
        dictGridColumns.isAcceptableOrUnknown(
          data['dict_grid_columns']!,
          _dictGridColumnsMeta,
        ),
      );
    }
    if (data.containsKey('search_examples')) {
      context.handle(
        _searchExamplesMeta,
        searchExamples.isAcceptableOrUnknown(
          data['search_examples']!,
          _searchExamplesMeta,
        ),
      );
    }
    if (data.containsKey('daily_goal')) {
      context.handle(
        _dailyGoalMeta,
        dailyGoal.isAcceptableOrUnknown(data['daily_goal']!, _dailyGoalMeta),
      );
    }
    if (data.containsKey('session_size')) {
      context.handle(
        _sessionSizeMeta,
        sessionSize.isAcceptableOrUnknown(
          data['session_size']!,
          _sessionSizeMeta,
        ),
      );
    }
    if (data.containsKey('keyboard_layout')) {
      context.handle(
        _keyboardLayoutMeta,
        keyboardLayout.isAcceptableOrUnknown(
          data['keyboard_layout']!,
          _keyboardLayoutMeta,
        ),
      );
    }
    if (data.containsKey('auto_next_on_correct')) {
      context.handle(
        _autoNextOnCorrectMeta,
        autoNextOnCorrect.isAcceptableOrUnknown(
          data['auto_next_on_correct']!,
          _autoNextOnCorrectMeta,
        ),
      );
    }
    if (data.containsKey('flashcard_mode')) {
      context.handle(
        _flashcardModeMeta,
        flashcardMode.isAcceptableOrUnknown(
          data['flashcard_mode']!,
          _flashcardModeMeta,
        ),
      );
    }
    if (data.containsKey('flashcard_seconds')) {
      context.handle(
        _flashcardSecondsMeta,
        flashcardSeconds.isAcceptableOrUnknown(
          data['flashcard_seconds']!,
          _flashcardSecondsMeta,
        ),
      );
    }
    if (data.containsKey('choice_direction')) {
      context.handle(
        _choiceDirectionMeta,
        choiceDirection.isAcceptableOrUnknown(
          data['choice_direction']!,
          _choiceDirectionMeta,
        ),
      );
    }
    if (data.containsKey('speed_limit_ms')) {
      context.handle(
        _speedLimitMsMeta,
        speedLimitMs.isAcceptableOrUnknown(
          data['speed_limit_ms']!,
          _speedLimitMsMeta,
        ),
      );
    }
    if (data.containsKey('selected_wordbook_ids')) {
      context.handle(
        _selectedWordbookIdsMeta,
        selectedWordbookIds.isAcceptableOrUnknown(
          data['selected_wordbook_ids']!,
          _selectedWordbookIdsMeta,
        ),
      );
    }
    if (data.containsKey('audio_source')) {
      context.handle(
        _audioSourceMeta,
        audioSource.isAcceptableOrUnknown(
          data['audio_source']!,
          _audioSourceMeta,
        ),
      );
    }
    if (data.containsKey('audio_pack_ids')) {
      context.handle(
        _audioPackIdsMeta,
        audioPackIds.isAcceptableOrUnknown(
          data['audio_pack_ids']!,
          _audioPackIdsMeta,
        ),
      );
    }
    if (data.containsKey('tts_en_voice')) {
      context.handle(
        _ttsEnVoiceMeta,
        ttsEnVoice.isAcceptableOrUnknown(
          data['tts_en_voice']!,
          _ttsEnVoiceMeta,
        ),
      );
    }
    if (data.containsKey('tts_ja_voice')) {
      context.handle(
        _ttsJaVoiceMeta,
        ttsJaVoice.isAcceptableOrUnknown(
          data['tts_ja_voice']!,
          _ttsJaVoiceMeta,
        ),
      );
    }
    if (data.containsKey('tts_rate')) {
      context.handle(
        _ttsRateMeta,
        ttsRate.isAcceptableOrUnknown(data['tts_rate']!, _ttsRateMeta),
      );
    }
    if (data.containsKey('tts_pitch')) {
      context.handle(
        _ttsPitchMeta,
        ttsPitch.isAcceptableOrUnknown(data['tts_pitch']!, _ttsPitchMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      colorSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_seed'],
      )!,
      palette: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}palette'],
      )!,
      textScale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_scale'],
      )!,
      density: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}density'],
      )!,
      dictViewMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dict_view_mode'],
      )!,
      dictGridColumns: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dict_grid_columns'],
      )!,
      searchExamples: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}search_examples'],
      )!,
      dailyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_goal'],
      )!,
      sessionSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_size'],
      )!,
      keyboardLayout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyboard_layout'],
      )!,
      autoNextOnCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_next_on_correct'],
      )!,
      flashcardMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_mode'],
      )!,
      flashcardSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flashcard_seconds'],
      )!,
      choiceDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choice_direction'],
      )!,
      speedLimitMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}speed_limit_ms'],
      )!,
      selectedWordbookIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_wordbook_ids'],
      )!,
      audioSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_source'],
      )!,
      audioPackIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_pack_ids'],
      )!,
      ttsEnVoice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_en_voice'],
      )!,
      ttsJaVoice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tts_ja_voice'],
      )!,
      ttsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tts_rate'],
      )!,
      ttsPitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tts_pitch'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final String emoji;

  /// 識別色の割当シード（`AppColors.seedColor(colorSeed)`）。
  final int colorSeed;

  /// テーマ配色 id（`AppPalette.id`）。人ごとに変えられる。
  final String palette;
  final String textScale;
  final String density;
  final String dictViewMode;

  /// 辞書グリッドの列数。`auto` または `2` / `3` / `4`。
  final String dictGridColumns;

  /// 辞書の検索対象に例文を含めるか。
  final bool searchExamples;
  final int dailyGoal;
  final int sessionSize;
  final String keyboardLayout;
  final bool autoNextOnCorrect;
  final String flashcardMode;
  final int flashcardSeconds;
  final String choiceDirection;

  /// スピードモードの制限時間（ミリ秒）。
  final int speedLimitMs;

  /// 学習対象の単語帳 id（JSON 配列）。
  final String selectedWordbookIds;

  /// 音源の優先順位（`AudioSourcePreference`）。
  final String audioSource;

  /// 使用する音声パック id（JSON 配列。優先順）。
  final String audioPackIds;
  final String ttsEnVoice;
  final String ttsJaVoice;
  final double ttsRate;
  final double ttsPitch;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorSeed,
    required this.palette,
    required this.textScale,
    required this.density,
    required this.dictViewMode,
    required this.dictGridColumns,
    required this.searchExamples,
    required this.dailyGoal,
    required this.sessionSize,
    required this.keyboardLayout,
    required this.autoNextOnCorrect,
    required this.flashcardMode,
    required this.flashcardSeconds,
    required this.choiceDirection,
    required this.speedLimitMs,
    required this.selectedWordbookIds,
    required this.audioSource,
    required this.audioPackIds,
    required this.ttsEnVoice,
    required this.ttsJaVoice,
    required this.ttsRate,
    required this.ttsPitch,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color_seed'] = Variable<int>(colorSeed);
    map['palette'] = Variable<String>(palette);
    map['text_scale'] = Variable<String>(textScale);
    map['density'] = Variable<String>(density);
    map['dict_view_mode'] = Variable<String>(dictViewMode);
    map['dict_grid_columns'] = Variable<String>(dictGridColumns);
    map['search_examples'] = Variable<bool>(searchExamples);
    map['daily_goal'] = Variable<int>(dailyGoal);
    map['session_size'] = Variable<int>(sessionSize);
    map['keyboard_layout'] = Variable<String>(keyboardLayout);
    map['auto_next_on_correct'] = Variable<bool>(autoNextOnCorrect);
    map['flashcard_mode'] = Variable<String>(flashcardMode);
    map['flashcard_seconds'] = Variable<int>(flashcardSeconds);
    map['choice_direction'] = Variable<String>(choiceDirection);
    map['speed_limit_ms'] = Variable<int>(speedLimitMs);
    map['selected_wordbook_ids'] = Variable<String>(selectedWordbookIds);
    map['audio_source'] = Variable<String>(audioSource);
    map['audio_pack_ids'] = Variable<String>(audioPackIds);
    map['tts_en_voice'] = Variable<String>(ttsEnVoice);
    map['tts_ja_voice'] = Variable<String>(ttsJaVoice);
    map['tts_rate'] = Variable<double>(ttsRate);
    map['tts_pitch'] = Variable<double>(ttsPitch);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      colorSeed: Value(colorSeed),
      palette: Value(palette),
      textScale: Value(textScale),
      density: Value(density),
      dictViewMode: Value(dictViewMode),
      dictGridColumns: Value(dictGridColumns),
      searchExamples: Value(searchExamples),
      dailyGoal: Value(dailyGoal),
      sessionSize: Value(sessionSize),
      keyboardLayout: Value(keyboardLayout),
      autoNextOnCorrect: Value(autoNextOnCorrect),
      flashcardMode: Value(flashcardMode),
      flashcardSeconds: Value(flashcardSeconds),
      choiceDirection: Value(choiceDirection),
      speedLimitMs: Value(speedLimitMs),
      selectedWordbookIds: Value(selectedWordbookIds),
      audioSource: Value(audioSource),
      audioPackIds: Value(audioPackIds),
      ttsEnVoice: Value(ttsEnVoice),
      ttsJaVoice: Value(ttsJaVoice),
      ttsRate: Value(ttsRate),
      ttsPitch: Value(ttsPitch),
      reminderEnabled: Value(reminderEnabled),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorSeed: serializer.fromJson<int>(json['colorSeed']),
      palette: serializer.fromJson<String>(json['palette']),
      textScale: serializer.fromJson<String>(json['textScale']),
      density: serializer.fromJson<String>(json['density']),
      dictViewMode: serializer.fromJson<String>(json['dictViewMode']),
      dictGridColumns: serializer.fromJson<String>(json['dictGridColumns']),
      searchExamples: serializer.fromJson<bool>(json['searchExamples']),
      dailyGoal: serializer.fromJson<int>(json['dailyGoal']),
      sessionSize: serializer.fromJson<int>(json['sessionSize']),
      keyboardLayout: serializer.fromJson<String>(json['keyboardLayout']),
      autoNextOnCorrect: serializer.fromJson<bool>(json['autoNextOnCorrect']),
      flashcardMode: serializer.fromJson<String>(json['flashcardMode']),
      flashcardSeconds: serializer.fromJson<int>(json['flashcardSeconds']),
      choiceDirection: serializer.fromJson<String>(json['choiceDirection']),
      speedLimitMs: serializer.fromJson<int>(json['speedLimitMs']),
      selectedWordbookIds: serializer.fromJson<String>(
        json['selectedWordbookIds'],
      ),
      audioSource: serializer.fromJson<String>(json['audioSource']),
      audioPackIds: serializer.fromJson<String>(json['audioPackIds']),
      ttsEnVoice: serializer.fromJson<String>(json['ttsEnVoice']),
      ttsJaVoice: serializer.fromJson<String>(json['ttsJaVoice']),
      ttsRate: serializer.fromJson<double>(json['ttsRate']),
      ttsPitch: serializer.fromJson<double>(json['ttsPitch']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'colorSeed': serializer.toJson<int>(colorSeed),
      'palette': serializer.toJson<String>(palette),
      'textScale': serializer.toJson<String>(textScale),
      'density': serializer.toJson<String>(density),
      'dictViewMode': serializer.toJson<String>(dictViewMode),
      'dictGridColumns': serializer.toJson<String>(dictGridColumns),
      'searchExamples': serializer.toJson<bool>(searchExamples),
      'dailyGoal': serializer.toJson<int>(dailyGoal),
      'sessionSize': serializer.toJson<int>(sessionSize),
      'keyboardLayout': serializer.toJson<String>(keyboardLayout),
      'autoNextOnCorrect': serializer.toJson<bool>(autoNextOnCorrect),
      'flashcardMode': serializer.toJson<String>(flashcardMode),
      'flashcardSeconds': serializer.toJson<int>(flashcardSeconds),
      'choiceDirection': serializer.toJson<String>(choiceDirection),
      'speedLimitMs': serializer.toJson<int>(speedLimitMs),
      'selectedWordbookIds': serializer.toJson<String>(selectedWordbookIds),
      'audioSource': serializer.toJson<String>(audioSource),
      'audioPackIds': serializer.toJson<String>(audioPackIds),
      'ttsEnVoice': serializer.toJson<String>(ttsEnVoice),
      'ttsJaVoice': serializer.toJson<String>(ttsJaVoice),
      'ttsRate': serializer.toJson<double>(ttsRate),
      'ttsPitch': serializer.toJson<double>(ttsPitch),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    String? emoji,
    int? colorSeed,
    String? palette,
    String? textScale,
    String? density,
    String? dictViewMode,
    String? dictGridColumns,
    bool? searchExamples,
    int? dailyGoal,
    int? sessionSize,
    String? keyboardLayout,
    bool? autoNextOnCorrect,
    String? flashcardMode,
    int? flashcardSeconds,
    String? choiceDirection,
    int? speedLimitMs,
    String? selectedWordbookIds,
    String? audioSource,
    String? audioPackIds,
    String? ttsEnVoice,
    String? ttsJaVoice,
    double? ttsRate,
    double? ttsPitch,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    colorSeed: colorSeed ?? this.colorSeed,
    palette: palette ?? this.palette,
    textScale: textScale ?? this.textScale,
    density: density ?? this.density,
    dictViewMode: dictViewMode ?? this.dictViewMode,
    dictGridColumns: dictGridColumns ?? this.dictGridColumns,
    searchExamples: searchExamples ?? this.searchExamples,
    dailyGoal: dailyGoal ?? this.dailyGoal,
    sessionSize: sessionSize ?? this.sessionSize,
    keyboardLayout: keyboardLayout ?? this.keyboardLayout,
    autoNextOnCorrect: autoNextOnCorrect ?? this.autoNextOnCorrect,
    flashcardMode: flashcardMode ?? this.flashcardMode,
    flashcardSeconds: flashcardSeconds ?? this.flashcardSeconds,
    choiceDirection: choiceDirection ?? this.choiceDirection,
    speedLimitMs: speedLimitMs ?? this.speedLimitMs,
    selectedWordbookIds: selectedWordbookIds ?? this.selectedWordbookIds,
    audioSource: audioSource ?? this.audioSource,
    audioPackIds: audioPackIds ?? this.audioPackIds,
    ttsEnVoice: ttsEnVoice ?? this.ttsEnVoice,
    ttsJaVoice: ttsJaVoice ?? this.ttsJaVoice,
    ttsRate: ttsRate ?? this.ttsRate,
    ttsPitch: ttsPitch ?? this.ttsPitch,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorSeed: data.colorSeed.present ? data.colorSeed.value : this.colorSeed,
      palette: data.palette.present ? data.palette.value : this.palette,
      textScale: data.textScale.present ? data.textScale.value : this.textScale,
      density: data.density.present ? data.density.value : this.density,
      dictViewMode: data.dictViewMode.present
          ? data.dictViewMode.value
          : this.dictViewMode,
      dictGridColumns: data.dictGridColumns.present
          ? data.dictGridColumns.value
          : this.dictGridColumns,
      searchExamples: data.searchExamples.present
          ? data.searchExamples.value
          : this.searchExamples,
      dailyGoal: data.dailyGoal.present ? data.dailyGoal.value : this.dailyGoal,
      sessionSize: data.sessionSize.present
          ? data.sessionSize.value
          : this.sessionSize,
      keyboardLayout: data.keyboardLayout.present
          ? data.keyboardLayout.value
          : this.keyboardLayout,
      autoNextOnCorrect: data.autoNextOnCorrect.present
          ? data.autoNextOnCorrect.value
          : this.autoNextOnCorrect,
      flashcardMode: data.flashcardMode.present
          ? data.flashcardMode.value
          : this.flashcardMode,
      flashcardSeconds: data.flashcardSeconds.present
          ? data.flashcardSeconds.value
          : this.flashcardSeconds,
      choiceDirection: data.choiceDirection.present
          ? data.choiceDirection.value
          : this.choiceDirection,
      speedLimitMs: data.speedLimitMs.present
          ? data.speedLimitMs.value
          : this.speedLimitMs,
      selectedWordbookIds: data.selectedWordbookIds.present
          ? data.selectedWordbookIds.value
          : this.selectedWordbookIds,
      audioSource: data.audioSource.present
          ? data.audioSource.value
          : this.audioSource,
      audioPackIds: data.audioPackIds.present
          ? data.audioPackIds.value
          : this.audioPackIds,
      ttsEnVoice: data.ttsEnVoice.present
          ? data.ttsEnVoice.value
          : this.ttsEnVoice,
      ttsJaVoice: data.ttsJaVoice.present
          ? data.ttsJaVoice.value
          : this.ttsJaVoice,
      ttsRate: data.ttsRate.present ? data.ttsRate.value : this.ttsRate,
      ttsPitch: data.ttsPitch.present ? data.ttsPitch.value : this.ttsPitch,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('palette: $palette, ')
          ..write('textScale: $textScale, ')
          ..write('density: $density, ')
          ..write('dictViewMode: $dictViewMode, ')
          ..write('dictGridColumns: $dictGridColumns, ')
          ..write('searchExamples: $searchExamples, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('sessionSize: $sessionSize, ')
          ..write('keyboardLayout: $keyboardLayout, ')
          ..write('autoNextOnCorrect: $autoNextOnCorrect, ')
          ..write('flashcardMode: $flashcardMode, ')
          ..write('flashcardSeconds: $flashcardSeconds, ')
          ..write('choiceDirection: $choiceDirection, ')
          ..write('speedLimitMs: $speedLimitMs, ')
          ..write('selectedWordbookIds: $selectedWordbookIds, ')
          ..write('audioSource: $audioSource, ')
          ..write('audioPackIds: $audioPackIds, ')
          ..write('ttsEnVoice: $ttsEnVoice, ')
          ..write('ttsJaVoice: $ttsJaVoice, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    emoji,
    colorSeed,
    palette,
    textScale,
    density,
    dictViewMode,
    dictGridColumns,
    searchExamples,
    dailyGoal,
    sessionSize,
    keyboardLayout,
    autoNextOnCorrect,
    flashcardMode,
    flashcardSeconds,
    choiceDirection,
    speedLimitMs,
    selectedWordbookIds,
    audioSource,
    audioPackIds,
    ttsEnVoice,
    ttsJaVoice,
    ttsRate,
    ttsPitch,
    reminderEnabled,
    reminderHour,
    reminderMinute,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.colorSeed == this.colorSeed &&
          other.palette == this.palette &&
          other.textScale == this.textScale &&
          other.density == this.density &&
          other.dictViewMode == this.dictViewMode &&
          other.dictGridColumns == this.dictGridColumns &&
          other.searchExamples == this.searchExamples &&
          other.dailyGoal == this.dailyGoal &&
          other.sessionSize == this.sessionSize &&
          other.keyboardLayout == this.keyboardLayout &&
          other.autoNextOnCorrect == this.autoNextOnCorrect &&
          other.flashcardMode == this.flashcardMode &&
          other.flashcardSeconds == this.flashcardSeconds &&
          other.choiceDirection == this.choiceDirection &&
          other.speedLimitMs == this.speedLimitMs &&
          other.selectedWordbookIds == this.selectedWordbookIds &&
          other.audioSource == this.audioSource &&
          other.audioPackIds == this.audioPackIds &&
          other.ttsEnVoice == this.ttsEnVoice &&
          other.ttsJaVoice == this.ttsJaVoice &&
          other.ttsRate == this.ttsRate &&
          other.ttsPitch == this.ttsPitch &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> colorSeed;
  final Value<String> palette;
  final Value<String> textScale;
  final Value<String> density;
  final Value<String> dictViewMode;
  final Value<String> dictGridColumns;
  final Value<bool> searchExamples;
  final Value<int> dailyGoal;
  final Value<int> sessionSize;
  final Value<String> keyboardLayout;
  final Value<bool> autoNextOnCorrect;
  final Value<String> flashcardMode;
  final Value<int> flashcardSeconds;
  final Value<String> choiceDirection;
  final Value<int> speedLimitMs;
  final Value<String> selectedWordbookIds;
  final Value<String> audioSource;
  final Value<String> audioPackIds;
  final Value<String> ttsEnVoice;
  final Value<String> ttsJaVoice;
  final Value<double> ttsRate;
  final Value<double> ttsPitch;
  final Value<bool> reminderEnabled;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorSeed = const Value.absent(),
    this.palette = const Value.absent(),
    this.textScale = const Value.absent(),
    this.density = const Value.absent(),
    this.dictViewMode = const Value.absent(),
    this.dictGridColumns = const Value.absent(),
    this.searchExamples = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.sessionSize = const Value.absent(),
    this.keyboardLayout = const Value.absent(),
    this.autoNextOnCorrect = const Value.absent(),
    this.flashcardMode = const Value.absent(),
    this.flashcardSeconds = const Value.absent(),
    this.choiceDirection = const Value.absent(),
    this.speedLimitMs = const Value.absent(),
    this.selectedWordbookIds = const Value.absent(),
    this.audioSource = const Value.absent(),
    this.audioPackIds = const Value.absent(),
    this.ttsEnVoice = const Value.absent(),
    this.ttsJaVoice = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    required int colorSeed,
    this.palette = const Value.absent(),
    this.textScale = const Value.absent(),
    this.density = const Value.absent(),
    this.dictViewMode = const Value.absent(),
    this.dictGridColumns = const Value.absent(),
    this.searchExamples = const Value.absent(),
    this.dailyGoal = const Value.absent(),
    this.sessionSize = const Value.absent(),
    this.keyboardLayout = const Value.absent(),
    this.autoNextOnCorrect = const Value.absent(),
    this.flashcardMode = const Value.absent(),
    this.flashcardSeconds = const Value.absent(),
    this.choiceDirection = const Value.absent(),
    this.speedLimitMs = const Value.absent(),
    this.selectedWordbookIds = const Value.absent(),
    this.audioSource = const Value.absent(),
    this.audioPackIds = const Value.absent(),
    this.ttsEnVoice = const Value.absent(),
    this.ttsJaVoice = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsPitch = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       colorSeed = Value(colorSeed);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? colorSeed,
    Expression<String>? palette,
    Expression<String>? textScale,
    Expression<String>? density,
    Expression<String>? dictViewMode,
    Expression<String>? dictGridColumns,
    Expression<bool>? searchExamples,
    Expression<int>? dailyGoal,
    Expression<int>? sessionSize,
    Expression<String>? keyboardLayout,
    Expression<bool>? autoNextOnCorrect,
    Expression<String>? flashcardMode,
    Expression<int>? flashcardSeconds,
    Expression<String>? choiceDirection,
    Expression<int>? speedLimitMs,
    Expression<String>? selectedWordbookIds,
    Expression<String>? audioSource,
    Expression<String>? audioPackIds,
    Expression<String>? ttsEnVoice,
    Expression<String>? ttsJaVoice,
    Expression<double>? ttsRate,
    Expression<double>? ttsPitch,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (colorSeed != null) 'color_seed': colorSeed,
      if (palette != null) 'palette': palette,
      if (textScale != null) 'text_scale': textScale,
      if (density != null) 'density': density,
      if (dictViewMode != null) 'dict_view_mode': dictViewMode,
      if (dictGridColumns != null) 'dict_grid_columns': dictGridColumns,
      if (searchExamples != null) 'search_examples': searchExamples,
      if (dailyGoal != null) 'daily_goal': dailyGoal,
      if (sessionSize != null) 'session_size': sessionSize,
      if (keyboardLayout != null) 'keyboard_layout': keyboardLayout,
      if (autoNextOnCorrect != null) 'auto_next_on_correct': autoNextOnCorrect,
      if (flashcardMode != null) 'flashcard_mode': flashcardMode,
      if (flashcardSeconds != null) 'flashcard_seconds': flashcardSeconds,
      if (choiceDirection != null) 'choice_direction': choiceDirection,
      if (speedLimitMs != null) 'speed_limit_ms': speedLimitMs,
      if (selectedWordbookIds != null)
        'selected_wordbook_ids': selectedWordbookIds,
      if (audioSource != null) 'audio_source': audioSource,
      if (audioPackIds != null) 'audio_pack_ids': audioPackIds,
      if (ttsEnVoice != null) 'tts_en_voice': ttsEnVoice,
      if (ttsJaVoice != null) 'tts_ja_voice': ttsJaVoice,
      if (ttsRate != null) 'tts_rate': ttsRate,
      if (ttsPitch != null) 'tts_pitch': ttsPitch,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? colorSeed,
    Value<String>? palette,
    Value<String>? textScale,
    Value<String>? density,
    Value<String>? dictViewMode,
    Value<String>? dictGridColumns,
    Value<bool>? searchExamples,
    Value<int>? dailyGoal,
    Value<int>? sessionSize,
    Value<String>? keyboardLayout,
    Value<bool>? autoNextOnCorrect,
    Value<String>? flashcardMode,
    Value<int>? flashcardSeconds,
    Value<String>? choiceDirection,
    Value<int>? speedLimitMs,
    Value<String>? selectedWordbookIds,
    Value<String>? audioSource,
    Value<String>? audioPackIds,
    Value<String>? ttsEnVoice,
    Value<String>? ttsJaVoice,
    Value<double>? ttsRate,
    Value<double>? ttsPitch,
    Value<bool>? reminderEnabled,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorSeed: colorSeed ?? this.colorSeed,
      palette: palette ?? this.palette,
      textScale: textScale ?? this.textScale,
      density: density ?? this.density,
      dictViewMode: dictViewMode ?? this.dictViewMode,
      dictGridColumns: dictGridColumns ?? this.dictGridColumns,
      searchExamples: searchExamples ?? this.searchExamples,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      sessionSize: sessionSize ?? this.sessionSize,
      keyboardLayout: keyboardLayout ?? this.keyboardLayout,
      autoNextOnCorrect: autoNextOnCorrect ?? this.autoNextOnCorrect,
      flashcardMode: flashcardMode ?? this.flashcardMode,
      flashcardSeconds: flashcardSeconds ?? this.flashcardSeconds,
      choiceDirection: choiceDirection ?? this.choiceDirection,
      speedLimitMs: speedLimitMs ?? this.speedLimitMs,
      selectedWordbookIds: selectedWordbookIds ?? this.selectedWordbookIds,
      audioSource: audioSource ?? this.audioSource,
      audioPackIds: audioPackIds ?? this.audioPackIds,
      ttsEnVoice: ttsEnVoice ?? this.ttsEnVoice,
      ttsJaVoice: ttsJaVoice ?? this.ttsJaVoice,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorSeed.present) {
      map['color_seed'] = Variable<int>(colorSeed.value);
    }
    if (palette.present) {
      map['palette'] = Variable<String>(palette.value);
    }
    if (textScale.present) {
      map['text_scale'] = Variable<String>(textScale.value);
    }
    if (density.present) {
      map['density'] = Variable<String>(density.value);
    }
    if (dictViewMode.present) {
      map['dict_view_mode'] = Variable<String>(dictViewMode.value);
    }
    if (dictGridColumns.present) {
      map['dict_grid_columns'] = Variable<String>(dictGridColumns.value);
    }
    if (searchExamples.present) {
      map['search_examples'] = Variable<bool>(searchExamples.value);
    }
    if (dailyGoal.present) {
      map['daily_goal'] = Variable<int>(dailyGoal.value);
    }
    if (sessionSize.present) {
      map['session_size'] = Variable<int>(sessionSize.value);
    }
    if (keyboardLayout.present) {
      map['keyboard_layout'] = Variable<String>(keyboardLayout.value);
    }
    if (autoNextOnCorrect.present) {
      map['auto_next_on_correct'] = Variable<bool>(autoNextOnCorrect.value);
    }
    if (flashcardMode.present) {
      map['flashcard_mode'] = Variable<String>(flashcardMode.value);
    }
    if (flashcardSeconds.present) {
      map['flashcard_seconds'] = Variable<int>(flashcardSeconds.value);
    }
    if (choiceDirection.present) {
      map['choice_direction'] = Variable<String>(choiceDirection.value);
    }
    if (speedLimitMs.present) {
      map['speed_limit_ms'] = Variable<int>(speedLimitMs.value);
    }
    if (selectedWordbookIds.present) {
      map['selected_wordbook_ids'] = Variable<String>(
        selectedWordbookIds.value,
      );
    }
    if (audioSource.present) {
      map['audio_source'] = Variable<String>(audioSource.value);
    }
    if (audioPackIds.present) {
      map['audio_pack_ids'] = Variable<String>(audioPackIds.value);
    }
    if (ttsEnVoice.present) {
      map['tts_en_voice'] = Variable<String>(ttsEnVoice.value);
    }
    if (ttsJaVoice.present) {
      map['tts_ja_voice'] = Variable<String>(ttsJaVoice.value);
    }
    if (ttsRate.present) {
      map['tts_rate'] = Variable<double>(ttsRate.value);
    }
    if (ttsPitch.present) {
      map['tts_pitch'] = Variable<double>(ttsPitch.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('palette: $palette, ')
          ..write('textScale: $textScale, ')
          ..write('density: $density, ')
          ..write('dictViewMode: $dictViewMode, ')
          ..write('dictGridColumns: $dictGridColumns, ')
          ..write('searchExamples: $searchExamples, ')
          ..write('dailyGoal: $dailyGoal, ')
          ..write('sessionSize: $sessionSize, ')
          ..write('keyboardLayout: $keyboardLayout, ')
          ..write('autoNextOnCorrect: $autoNextOnCorrect, ')
          ..write('flashcardMode: $flashcardMode, ')
          ..write('flashcardSeconds: $flashcardSeconds, ')
          ..write('choiceDirection: $choiceDirection, ')
          ..write('speedLimitMs: $speedLimitMs, ')
          ..write('selectedWordbookIds: $selectedWordbookIds, ')
          ..write('audioSource: $audioSource, ')
          ..write('audioPackIds: $audioPackIds, ')
          ..write('ttsEnVoice: $ttsEnVoice, ')
          ..write('ttsJaVoice: $ttsJaVoice, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsPitch: $ttsPitch, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WordFamiliesTable extends WordFamilies
    with TableInfo<$WordFamiliesTable, WordFamily> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordFamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _baseFormMeta = const VerificationMeta(
    'baseForm',
  );
  @override
  late final GeneratedColumn<String> baseForm = GeneratedColumn<String>(
    'base_form',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, baseForm, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_families';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordFamily> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_form')) {
      context.handle(
        _baseFormMeta,
        baseForm.isAcceptableOrUnknown(data['base_form']!, _baseFormMeta),
      );
    } else if (isInserting) {
      context.missing(_baseFormMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordFamily map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordFamily(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      baseForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_form'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WordFamiliesTable createAlias(String alias) {
    return $WordFamiliesTable(attachedDatabase, alias);
  }
}

class WordFamily extends DataClass implements Insertable<WordFamily> {
  final int id;

  /// 語族の代表形（例 `decide`）。
  final String baseForm;
  final String? note;
  const WordFamily({required this.id, required this.baseForm, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_form'] = Variable<String>(baseForm);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WordFamiliesCompanion toCompanion(bool nullToAbsent) {
    return WordFamiliesCompanion(
      id: Value(id),
      baseForm: Value(baseForm),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WordFamily.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordFamily(
      id: serializer.fromJson<int>(json['id']),
      baseForm: serializer.fromJson<String>(json['baseForm']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseForm': serializer.toJson<String>(baseForm),
      'note': serializer.toJson<String?>(note),
    };
  }

  WordFamily copyWith({
    int? id,
    String? baseForm,
    Value<String?> note = const Value.absent(),
  }) => WordFamily(
    id: id ?? this.id,
    baseForm: baseForm ?? this.baseForm,
    note: note.present ? note.value : this.note,
  );
  WordFamily copyWithCompanion(WordFamiliesCompanion data) {
    return WordFamily(
      id: data.id.present ? data.id.value : this.id,
      baseForm: data.baseForm.present ? data.baseForm.value : this.baseForm,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordFamily(')
          ..write('id: $id, ')
          ..write('baseForm: $baseForm, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, baseForm, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordFamily &&
          other.id == this.id &&
          other.baseForm == this.baseForm &&
          other.note == this.note);
}

class WordFamiliesCompanion extends UpdateCompanion<WordFamily> {
  final Value<int> id;
  final Value<String> baseForm;
  final Value<String?> note;
  const WordFamiliesCompanion({
    this.id = const Value.absent(),
    this.baseForm = const Value.absent(),
    this.note = const Value.absent(),
  });
  WordFamiliesCompanion.insert({
    this.id = const Value.absent(),
    required String baseForm,
    this.note = const Value.absent(),
  }) : baseForm = Value(baseForm);
  static Insertable<WordFamily> custom({
    Expression<int>? id,
    Expression<String>? baseForm,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseForm != null) 'base_form': baseForm,
      if (note != null) 'note': note,
    });
  }

  WordFamiliesCompanion copyWith({
    Value<int>? id,
    Value<String>? baseForm,
    Value<String?>? note,
  }) {
    return WordFamiliesCompanion(
      id: id ?? this.id,
      baseForm: baseForm ?? this.baseForm,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseForm.present) {
      map['base_form'] = Variable<String>(baseForm.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordFamiliesCompanion(')
          ..write('id: $id, ')
          ..write('baseForm: $baseForm, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _headwordMeta = const VerificationMeta(
    'headword',
  );
  @override
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
    'headword',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  @override
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partsNoteMeta = const VerificationMeta(
    'partsNote',
  );
  @override
  late final GeneratedColumn<String> partsNote = GeneratedColumn<String>(
    'parts_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confusionNoteMeta = const VerificationMeta(
    'confusionNote',
  );
  @override
  late final GeneratedColumn<String> confusionNote = GeneratedColumn<String>(
    'confusion_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<int> familyId = GeneratedColumn<int>(
    'family_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_families (id)',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _frequencyRankMeta = const VerificationMeta(
    'frequencyRank',
  );
  @override
  late final GeneratedColumn<int> frequencyRank = GeneratedColumn<int>(
    'frequency_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerProfileIdMeta = const VerificationMeta(
    'ownerProfileId',
  );
  @override
  late final GeneratedColumn<int> ownerProfileId = GeneratedColumn<int>(
    'owner_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isDraftMeta = const VerificationMeta(
    'isDraft',
  );
  @override
  late final GeneratedColumn<bool> isDraft = GeneratedColumn<bool>(
    'is_draft',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_draft" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isEditedMeta = const VerificationMeta(
    'isEdited',
  );
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
    'is_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isExcludedMeta = const VerificationMeta(
    'isExcluded',
  );
  @override
  late final GeneratedColumn<bool> isExcluded = GeneratedColumn<bool>(
    'is_excluded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_excluded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    headword,
    partOfSpeech,
    phonetic,
    meaning,
    partsNote,
    confusionNote,
    familyId,
    level,
    frequencyRank,
    presetId,
    ownerProfileId,
    isDraft,
    isEdited,
    isExcluded,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('headword')) {
      context.handle(
        _headwordMeta,
        headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta),
      );
    } else if (isInserting) {
      context.missing(_headwordMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partOfSpeechMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('parts_note')) {
      context.handle(
        _partsNoteMeta,
        partsNote.isAcceptableOrUnknown(data['parts_note']!, _partsNoteMeta),
      );
    }
    if (data.containsKey('confusion_note')) {
      context.handle(
        _confusionNoteMeta,
        confusionNote.isAcceptableOrUnknown(
          data['confusion_note']!,
          _confusionNoteMeta,
        ),
      );
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('frequency_rank')) {
      context.handle(
        _frequencyRankMeta,
        frequencyRank.isAcceptableOrUnknown(
          data['frequency_rank']!,
          _frequencyRankMeta,
        ),
      );
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    if (data.containsKey('owner_profile_id')) {
      context.handle(
        _ownerProfileIdMeta,
        ownerProfileId.isAcceptableOrUnknown(
          data['owner_profile_id']!,
          _ownerProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('is_draft')) {
      context.handle(
        _isDraftMeta,
        isDraft.isAcceptableOrUnknown(data['is_draft']!, _isDraftMeta),
      );
    }
    if (data.containsKey('is_edited')) {
      context.handle(
        _isEditedMeta,
        isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta),
      );
    }
    if (data.containsKey('is_excluded')) {
      context.handle(
        _isExcludedMeta,
        isExcluded.isAcceptableOrUnknown(data['is_excluded']!, _isExcludedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      headword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headword'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      partsNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parts_note'],
      ),
      confusionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confusion_note'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}family_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      frequencyRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_rank'],
      ),
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      ),
      ownerProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_profile_id'],
      ),
      isDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_draft'],
      )!,
      isEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_edited'],
      )!,
      isExcluded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_excluded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;

  /// 見出し語。**小文字で正規化して保存する**。
  final String headword;

  /// 品詞（`PartOfSpeech`）。
  final String partOfSpeech;
  final String? phonetic;

  /// 日本語訳。`isDraft = true` のときだけ空文字を許す。
  final String meaning;

  /// 語のつくりの説明1行（[Docs/06_features/word_parts.md] §3.1）。
  final String? partsNote;

  /// 取り違えやすい語との区別の覚え方。
  final String? confusionNote;
  final int? familyId;

  /// 難易度 1〜5。
  final int level;

  /// 頻度順位。ライセンス条件を確認できた頻度リストを持つ語にだけ入れる
  /// （[Docs/03_data_model.md] §7）。値が無い間は「頻度順」のソート項目を出さない。
  final int? frequencyRank;

  /// プリセット由来ならアセット内の識別子。編集前の値を DB に二重に持たず、
  /// これでアセットを引き直して「元に戻す」を実現する（FR-06）。
  final String? presetId;

  /// マイ単語の持ち主。共有の語は null。
  final int? ownerProfileId;

  /// 訳が未入力のマイ単語（出題されない）。
  final bool isDraft;

  /// プリセット語をユーザーが編集した。
  final bool isEdited;

  /// 出題から除外する。
  final bool isExcluded;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Word({
    required this.id,
    required this.headword,
    required this.partOfSpeech,
    this.phonetic,
    required this.meaning,
    this.partsNote,
    this.confusionNote,
    this.familyId,
    required this.level,
    this.frequencyRank,
    this.presetId,
    this.ownerProfileId,
    required this.isDraft,
    required this.isEdited,
    required this.isExcluded,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['headword'] = Variable<String>(headword);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || partsNote != null) {
      map['parts_note'] = Variable<String>(partsNote);
    }
    if (!nullToAbsent || confusionNote != null) {
      map['confusion_note'] = Variable<String>(confusionNote);
    }
    if (!nullToAbsent || familyId != null) {
      map['family_id'] = Variable<int>(familyId);
    }
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || frequencyRank != null) {
      map['frequency_rank'] = Variable<int>(frequencyRank);
    }
    if (!nullToAbsent || presetId != null) {
      map['preset_id'] = Variable<String>(presetId);
    }
    if (!nullToAbsent || ownerProfileId != null) {
      map['owner_profile_id'] = Variable<int>(ownerProfileId);
    }
    map['is_draft'] = Variable<bool>(isDraft);
    map['is_edited'] = Variable<bool>(isEdited);
    map['is_excluded'] = Variable<bool>(isExcluded);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      headword: Value(headword),
      partOfSpeech: Value(partOfSpeech),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      meaning: Value(meaning),
      partsNote: partsNote == null && nullToAbsent
          ? const Value.absent()
          : Value(partsNote),
      confusionNote: confusionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(confusionNote),
      familyId: familyId == null && nullToAbsent
          ? const Value.absent()
          : Value(familyId),
      level: Value(level),
      frequencyRank: frequencyRank == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyRank),
      presetId: presetId == null && nullToAbsent
          ? const Value.absent()
          : Value(presetId),
      ownerProfileId: ownerProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerProfileId),
      isDraft: Value(isDraft),
      isEdited: Value(isEdited),
      isExcluded: Value(isExcluded),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      headword: serializer.fromJson<String>(json['headword']),
      partOfSpeech: serializer.fromJson<String>(json['partOfSpeech']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      meaning: serializer.fromJson<String>(json['meaning']),
      partsNote: serializer.fromJson<String?>(json['partsNote']),
      confusionNote: serializer.fromJson<String?>(json['confusionNote']),
      familyId: serializer.fromJson<int?>(json['familyId']),
      level: serializer.fromJson<int>(json['level']),
      frequencyRank: serializer.fromJson<int?>(json['frequencyRank']),
      presetId: serializer.fromJson<String?>(json['presetId']),
      ownerProfileId: serializer.fromJson<int?>(json['ownerProfileId']),
      isDraft: serializer.fromJson<bool>(json['isDraft']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      isExcluded: serializer.fromJson<bool>(json['isExcluded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'headword': serializer.toJson<String>(headword),
      'partOfSpeech': serializer.toJson<String>(partOfSpeech),
      'phonetic': serializer.toJson<String?>(phonetic),
      'meaning': serializer.toJson<String>(meaning),
      'partsNote': serializer.toJson<String?>(partsNote),
      'confusionNote': serializer.toJson<String?>(confusionNote),
      'familyId': serializer.toJson<int?>(familyId),
      'level': serializer.toJson<int>(level),
      'frequencyRank': serializer.toJson<int?>(frequencyRank),
      'presetId': serializer.toJson<String?>(presetId),
      'ownerProfileId': serializer.toJson<int?>(ownerProfileId),
      'isDraft': serializer.toJson<bool>(isDraft),
      'isEdited': serializer.toJson<bool>(isEdited),
      'isExcluded': serializer.toJson<bool>(isExcluded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Word copyWith({
    int? id,
    String? headword,
    String? partOfSpeech,
    Value<String?> phonetic = const Value.absent(),
    String? meaning,
    Value<String?> partsNote = const Value.absent(),
    Value<String?> confusionNote = const Value.absent(),
    Value<int?> familyId = const Value.absent(),
    int? level,
    Value<int?> frequencyRank = const Value.absent(),
    Value<String?> presetId = const Value.absent(),
    Value<int?> ownerProfileId = const Value.absent(),
    bool? isDraft,
    bool? isEdited,
    bool? isExcluded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Word(
    id: id ?? this.id,
    headword: headword ?? this.headword,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    meaning: meaning ?? this.meaning,
    partsNote: partsNote.present ? partsNote.value : this.partsNote,
    confusionNote: confusionNote.present
        ? confusionNote.value
        : this.confusionNote,
    familyId: familyId.present ? familyId.value : this.familyId,
    level: level ?? this.level,
    frequencyRank: frequencyRank.present
        ? frequencyRank.value
        : this.frequencyRank,
    presetId: presetId.present ? presetId.value : this.presetId,
    ownerProfileId: ownerProfileId.present
        ? ownerProfileId.value
        : this.ownerProfileId,
    isDraft: isDraft ?? this.isDraft,
    isEdited: isEdited ?? this.isEdited,
    isExcluded: isExcluded ?? this.isExcluded,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      headword: data.headword.present ? data.headword.value : this.headword,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      partsNote: data.partsNote.present ? data.partsNote.value : this.partsNote,
      confusionNote: data.confusionNote.present
          ? data.confusionNote.value
          : this.confusionNote,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      level: data.level.present ? data.level.value : this.level,
      frequencyRank: data.frequencyRank.present
          ? data.frequencyRank.value
          : this.frequencyRank,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      ownerProfileId: data.ownerProfileId.present
          ? data.ownerProfileId.value
          : this.ownerProfileId,
      isDraft: data.isDraft.present ? data.isDraft.value : this.isDraft,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      isExcluded: data.isExcluded.present
          ? data.isExcluded.value
          : this.isExcluded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('phonetic: $phonetic, ')
          ..write('meaning: $meaning, ')
          ..write('partsNote: $partsNote, ')
          ..write('confusionNote: $confusionNote, ')
          ..write('familyId: $familyId, ')
          ..write('level: $level, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('presetId: $presetId, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('isDraft: $isDraft, ')
          ..write('isEdited: $isEdited, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    headword,
    partOfSpeech,
    phonetic,
    meaning,
    partsNote,
    confusionNote,
    familyId,
    level,
    frequencyRank,
    presetId,
    ownerProfileId,
    isDraft,
    isEdited,
    isExcluded,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.headword == this.headword &&
          other.partOfSpeech == this.partOfSpeech &&
          other.phonetic == this.phonetic &&
          other.meaning == this.meaning &&
          other.partsNote == this.partsNote &&
          other.confusionNote == this.confusionNote &&
          other.familyId == this.familyId &&
          other.level == this.level &&
          other.frequencyRank == this.frequencyRank &&
          other.presetId == this.presetId &&
          other.ownerProfileId == this.ownerProfileId &&
          other.isDraft == this.isDraft &&
          other.isEdited == this.isEdited &&
          other.isExcluded == this.isExcluded &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> headword;
  final Value<String> partOfSpeech;
  final Value<String?> phonetic;
  final Value<String> meaning;
  final Value<String?> partsNote;
  final Value<String?> confusionNote;
  final Value<int?> familyId;
  final Value<int> level;
  final Value<int?> frequencyRank;
  final Value<String?> presetId;
  final Value<int?> ownerProfileId;
  final Value<bool> isDraft;
  final Value<bool> isEdited;
  final Value<bool> isExcluded;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.headword = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.meaning = const Value.absent(),
    this.partsNote = const Value.absent(),
    this.confusionNote = const Value.absent(),
    this.familyId = const Value.absent(),
    this.level = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    this.presetId = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String headword,
    required String partOfSpeech,
    this.phonetic = const Value.absent(),
    required String meaning,
    this.partsNote = const Value.absent(),
    this.confusionNote = const Value.absent(),
    this.familyId = const Value.absent(),
    this.level = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    this.presetId = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.isDraft = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.isExcluded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : headword = Value(headword),
       partOfSpeech = Value(partOfSpeech),
       meaning = Value(meaning);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? headword,
    Expression<String>? partOfSpeech,
    Expression<String>? phonetic,
    Expression<String>? meaning,
    Expression<String>? partsNote,
    Expression<String>? confusionNote,
    Expression<int>? familyId,
    Expression<int>? level,
    Expression<int>? frequencyRank,
    Expression<String>? presetId,
    Expression<int>? ownerProfileId,
    Expression<bool>? isDraft,
    Expression<bool>? isEdited,
    Expression<bool>? isExcluded,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (headword != null) 'headword': headword,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (phonetic != null) 'phonetic': phonetic,
      if (meaning != null) 'meaning': meaning,
      if (partsNote != null) 'parts_note': partsNote,
      if (confusionNote != null) 'confusion_note': confusionNote,
      if (familyId != null) 'family_id': familyId,
      if (level != null) 'level': level,
      if (frequencyRank != null) 'frequency_rank': frequencyRank,
      if (presetId != null) 'preset_id': presetId,
      if (ownerProfileId != null) 'owner_profile_id': ownerProfileId,
      if (isDraft != null) 'is_draft': isDraft,
      if (isEdited != null) 'is_edited': isEdited,
      if (isExcluded != null) 'is_excluded': isExcluded,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? headword,
    Value<String>? partOfSpeech,
    Value<String?>? phonetic,
    Value<String>? meaning,
    Value<String?>? partsNote,
    Value<String?>? confusionNote,
    Value<int?>? familyId,
    Value<int>? level,
    Value<int?>? frequencyRank,
    Value<String?>? presetId,
    Value<int?>? ownerProfileId,
    Value<bool>? isDraft,
    Value<bool>? isEdited,
    Value<bool>? isExcluded,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      headword: headword ?? this.headword,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning,
      partsNote: partsNote ?? this.partsNote,
      confusionNote: confusionNote ?? this.confusionNote,
      familyId: familyId ?? this.familyId,
      level: level ?? this.level,
      frequencyRank: frequencyRank ?? this.frequencyRank,
      presetId: presetId ?? this.presetId,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      isDraft: isDraft ?? this.isDraft,
      isEdited: isEdited ?? this.isEdited,
      isExcluded: isExcluded ?? this.isExcluded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (partsNote.present) {
      map['parts_note'] = Variable<String>(partsNote.value);
    }
    if (confusionNote.present) {
      map['confusion_note'] = Variable<String>(confusionNote.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<int>(familyId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (frequencyRank.present) {
      map['frequency_rank'] = Variable<int>(frequencyRank.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (ownerProfileId.present) {
      map['owner_profile_id'] = Variable<int>(ownerProfileId.value);
    }
    if (isDraft.present) {
      map['is_draft'] = Variable<bool>(isDraft.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (isExcluded.present) {
      map['is_excluded'] = Variable<bool>(isExcluded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('phonetic: $phonetic, ')
          ..write('meaning: $meaning, ')
          ..write('partsNote: $partsNote, ')
          ..write('confusionNote: $confusionNote, ')
          ..write('familyId: $familyId, ')
          ..write('level: $level, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('presetId: $presetId, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('isDraft: $isDraft, ')
          ..write('isEdited: $isEdited, ')
          ..write('isExcluded: $isExcluded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WordExamplesTable extends WordExamples
    with TableInfo<$WordExamplesTable, WordExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordExamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exampleEnMeta = const VerificationMeta(
    'exampleEn',
  );
  @override
  late final GeneratedColumn<String> exampleEn = GeneratedColumn<String>(
    'example_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleJaMeta = const VerificationMeta(
    'exampleJa',
  );
  @override
  late final GeneratedColumn<String> exampleJa = GeneratedColumn<String>(
    'example_ja',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourcePresetIdMeta = const VerificationMeta(
    'sourcePresetId',
  );
  @override
  late final GeneratedColumn<String> sourcePresetId = GeneratedColumn<String>(
    'source_preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wordId,
    exampleEn,
    exampleJa,
    sourcePresetId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_examples';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordExample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('example_en')) {
      context.handle(
        _exampleEnMeta,
        exampleEn.isAcceptableOrUnknown(data['example_en']!, _exampleEnMeta),
      );
    } else if (isInserting) {
      context.missing(_exampleEnMeta);
    }
    if (data.containsKey('example_ja')) {
      context.handle(
        _exampleJaMeta,
        exampleJa.isAcceptableOrUnknown(data['example_ja']!, _exampleJaMeta),
      );
    }
    if (data.containsKey('source_preset_id')) {
      context.handle(
        _sourcePresetIdMeta,
        sourcePresetId.isAcceptableOrUnknown(
          data['source_preset_id']!,
          _sourcePresetIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordExample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      exampleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_en'],
      )!,
      exampleJa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_ja'],
      ),
      sourcePresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_preset_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WordExamplesTable createAlias(String alias) {
    return $WordExamplesTable(attachedDatabase, alias);
  }
}

class WordExample extends DataClass implements Insertable<WordExample> {
  final int id;
  final int wordId;

  /// 英語例文（マイ単語では「見つけた文」）。
  final String exampleEn;

  /// 例文の和訳。要否は出どころで変わる（[Docs/03_data_model.md] §2.4）。
  /// [sourcePresetId] があるなら必須（片方だけの例文はアセットに入れない）。
  /// ユーザーが書いた文（[sourcePresetId] が null）では任意で、
  /// 無いときは **null**（空文字を入れない）。
  final String? exampleJa;

  /// どの単語帳由来か（`toeic_basic_v1` など）。ユーザーが書いた文は null。
  final String? sourcePresetId;

  /// 表示順。ユーザーが書いた文は 0、プリセット由来は `wordbooks.sortOrder`。
  final int sortOrder;
  const WordExample({
    required this.id,
    required this.wordId,
    required this.exampleEn,
    this.exampleJa,
    this.sourcePresetId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['example_en'] = Variable<String>(exampleEn);
    if (!nullToAbsent || exampleJa != null) {
      map['example_ja'] = Variable<String>(exampleJa);
    }
    if (!nullToAbsent || sourcePresetId != null) {
      map['source_preset_id'] = Variable<String>(sourcePresetId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WordExamplesCompanion toCompanion(bool nullToAbsent) {
    return WordExamplesCompanion(
      id: Value(id),
      wordId: Value(wordId),
      exampleEn: Value(exampleEn),
      exampleJa: exampleJa == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleJa),
      sourcePresetId: sourcePresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePresetId),
      sortOrder: Value(sortOrder),
    );
  }

  factory WordExample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordExample(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      exampleEn: serializer.fromJson<String>(json['exampleEn']),
      exampleJa: serializer.fromJson<String?>(json['exampleJa']),
      sourcePresetId: serializer.fromJson<String?>(json['sourcePresetId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'exampleEn': serializer.toJson<String>(exampleEn),
      'exampleJa': serializer.toJson<String?>(exampleJa),
      'sourcePresetId': serializer.toJson<String?>(sourcePresetId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WordExample copyWith({
    int? id,
    int? wordId,
    String? exampleEn,
    Value<String?> exampleJa = const Value.absent(),
    Value<String?> sourcePresetId = const Value.absent(),
    int? sortOrder,
  }) => WordExample(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    exampleEn: exampleEn ?? this.exampleEn,
    exampleJa: exampleJa.present ? exampleJa.value : this.exampleJa,
    sourcePresetId: sourcePresetId.present
        ? sourcePresetId.value
        : this.sourcePresetId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WordExample copyWithCompanion(WordExamplesCompanion data) {
    return WordExample(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      exampleEn: data.exampleEn.present ? data.exampleEn.value : this.exampleEn,
      exampleJa: data.exampleJa.present ? data.exampleJa.value : this.exampleJa,
      sourcePresetId: data.sourcePresetId.present
          ? data.sourcePresetId.value
          : this.sourcePresetId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordExample(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('exampleJa: $exampleJa, ')
          ..write('sourcePresetId: $sourcePresetId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordId, exampleEn, exampleJa, sourcePresetId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordExample &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.exampleEn == this.exampleEn &&
          other.exampleJa == this.exampleJa &&
          other.sourcePresetId == this.sourcePresetId &&
          other.sortOrder == this.sortOrder);
}

class WordExamplesCompanion extends UpdateCompanion<WordExample> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<String> exampleEn;
  final Value<String?> exampleJa;
  final Value<String?> sourcePresetId;
  final Value<int> sortOrder;
  const WordExamplesCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.exampleJa = const Value.absent(),
    this.sourcePresetId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WordExamplesCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required String exampleEn,
    this.exampleJa = const Value.absent(),
    this.sourcePresetId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : wordId = Value(wordId),
       exampleEn = Value(exampleEn);
  static Insertable<WordExample> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<String>? exampleEn,
    Expression<String>? exampleJa,
    Expression<String>? sourcePresetId,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (exampleEn != null) 'example_en': exampleEn,
      if (exampleJa != null) 'example_ja': exampleJa,
      if (sourcePresetId != null) 'source_preset_id': sourcePresetId,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WordExamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<String>? exampleEn,
    Value<String?>? exampleJa,
    Value<String?>? sourcePresetId,
    Value<int>? sortOrder,
  }) {
    return WordExamplesCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      exampleEn: exampleEn ?? this.exampleEn,
      exampleJa: exampleJa ?? this.exampleJa,
      sourcePresetId: sourcePresetId ?? this.sourcePresetId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (exampleEn.present) {
      map['example_en'] = Variable<String>(exampleEn.value);
    }
    if (exampleJa.present) {
      map['example_ja'] = Variable<String>(exampleJa.value);
    }
    if (sourcePresetId.present) {
      map['source_preset_id'] = Variable<String>(sourcePresetId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordExamplesCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('exampleJa: $exampleJa, ')
          ..write('sourcePresetId: $sourcePresetId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WordbooksTable extends Wordbooks
    with TableInfo<$WordbooksTable, Wordbook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordbooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorSeedMeta = const VerificationMeta(
    'colorSeed',
  );
  @override
  late final GeneratedColumn<int> colorSeed = GeneratedColumn<int>(
    'color_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerProfileIdMeta = const VerificationMeta(
    'ownerProfileId',
  );
  @override
  late final GeneratedColumn<int> ownerProfileId = GeneratedColumn<int>(
    'owner_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seedVersionMeta = const VerificationMeta(
    'seedVersion',
  );
  @override
  late final GeneratedColumn<int> seedVersion = GeneratedColumn<int>(
    'seed_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bandSizeMeta = const VerificationMeta(
    'bandSize',
  );
  @override
  late final GeneratedColumn<int> bandSize = GeneratedColumn<int>(
    'band_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    colorSeed,
    category,
    source,
    presetId,
    ownerProfileId,
    seedVersion,
    bandSize,
    note,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wordbooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wordbook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color_seed')) {
      context.handle(
        _colorSeedMeta,
        colorSeed.isAcceptableOrUnknown(data['color_seed']!, _colorSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_colorSeedMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    if (data.containsKey('owner_profile_id')) {
      context.handle(
        _ownerProfileIdMeta,
        ownerProfileId.isAcceptableOrUnknown(
          data['owner_profile_id']!,
          _ownerProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('seed_version')) {
      context.handle(
        _seedVersionMeta,
        seedVersion.isAcceptableOrUnknown(
          data['seed_version']!,
          _seedVersionMeta,
        ),
      );
    }
    if (data.containsKey('band_size')) {
      context.handle(
        _bandSizeMeta,
        bandSize.isAcceptableOrUnknown(data['band_size']!, _bandSizeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Wordbook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wordbook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      colorSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_seed'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      ),
      ownerProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}owner_profile_id'],
      ),
      seedVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_version'],
      )!,
      bandSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}band_size'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WordbooksTable createAlias(String alias) {
    return $WordbooksTable(attachedDatabase, alias);
  }
}

class Wordbook extends DataClass implements Insertable<Wordbook> {
  final int id;
  final String name;
  final String emoji;

  /// 識別色の割当シード（`AppColors.seedColor(colorSeed)`）。
  final int colorSeed;

  /// 区分（`WordbookCategory`）。
  final String category;

  /// 由来（`WordbookSource`）。
  final String source;

  /// `source = preset` のときアセット側の識別子（例 `jhs_v1`）。
  final String? presetId;

  /// マイ単語帳の持ち主。それ以外は null。
  final int? ownerProfileId;

  /// 投入済みプリセットの版（[Docs/06_features/wordbooks.md] §3）。
  final int seedVersion;

  /// 語彙力測定で帯として使うときの語数（[Docs/06_features/vocab_size_test.md] §3）。
  final int? bandSize;
  final String? note;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Wordbook({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorSeed,
    required this.category,
    required this.source,
    this.presetId,
    this.ownerProfileId,
    required this.seedVersion,
    this.bandSize,
    this.note,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color_seed'] = Variable<int>(colorSeed);
    map['category'] = Variable<String>(category);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || presetId != null) {
      map['preset_id'] = Variable<String>(presetId);
    }
    if (!nullToAbsent || ownerProfileId != null) {
      map['owner_profile_id'] = Variable<int>(ownerProfileId);
    }
    map['seed_version'] = Variable<int>(seedVersion);
    if (!nullToAbsent || bandSize != null) {
      map['band_size'] = Variable<int>(bandSize);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WordbooksCompanion toCompanion(bool nullToAbsent) {
    return WordbooksCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      colorSeed: Value(colorSeed),
      category: Value(category),
      source: Value(source),
      presetId: presetId == null && nullToAbsent
          ? const Value.absent()
          : Value(presetId),
      ownerProfileId: ownerProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerProfileId),
      seedVersion: Value(seedVersion),
      bandSize: bandSize == null && nullToAbsent
          ? const Value.absent()
          : Value(bandSize),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Wordbook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wordbook(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorSeed: serializer.fromJson<int>(json['colorSeed']),
      category: serializer.fromJson<String>(json['category']),
      source: serializer.fromJson<String>(json['source']),
      presetId: serializer.fromJson<String?>(json['presetId']),
      ownerProfileId: serializer.fromJson<int?>(json['ownerProfileId']),
      seedVersion: serializer.fromJson<int>(json['seedVersion']),
      bandSize: serializer.fromJson<int?>(json['bandSize']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'colorSeed': serializer.toJson<int>(colorSeed),
      'category': serializer.toJson<String>(category),
      'source': serializer.toJson<String>(source),
      'presetId': serializer.toJson<String?>(presetId),
      'ownerProfileId': serializer.toJson<int?>(ownerProfileId),
      'seedVersion': serializer.toJson<int>(seedVersion),
      'bandSize': serializer.toJson<int?>(bandSize),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Wordbook copyWith({
    int? id,
    String? name,
    String? emoji,
    int? colorSeed,
    String? category,
    String? source,
    Value<String?> presetId = const Value.absent(),
    Value<int?> ownerProfileId = const Value.absent(),
    int? seedVersion,
    Value<int?> bandSize = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Wordbook(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    colorSeed: colorSeed ?? this.colorSeed,
    category: category ?? this.category,
    source: source ?? this.source,
    presetId: presetId.present ? presetId.value : this.presetId,
    ownerProfileId: ownerProfileId.present
        ? ownerProfileId.value
        : this.ownerProfileId,
    seedVersion: seedVersion ?? this.seedVersion,
    bandSize: bandSize.present ? bandSize.value : this.bandSize,
    note: note.present ? note.value : this.note,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Wordbook copyWithCompanion(WordbooksCompanion data) {
    return Wordbook(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorSeed: data.colorSeed.present ? data.colorSeed.value : this.colorSeed,
      category: data.category.present ? data.category.value : this.category,
      source: data.source.present ? data.source.value : this.source,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      ownerProfileId: data.ownerProfileId.present
          ? data.ownerProfileId.value
          : this.ownerProfileId,
      seedVersion: data.seedVersion.present
          ? data.seedVersion.value
          : this.seedVersion,
      bandSize: data.bandSize.present ? data.bandSize.value : this.bandSize,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wordbook(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('presetId: $presetId, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('seedVersion: $seedVersion, ')
          ..write('bandSize: $bandSize, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    colorSeed,
    category,
    source,
    presetId,
    ownerProfileId,
    seedVersion,
    bandSize,
    note,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wordbook &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.colorSeed == this.colorSeed &&
          other.category == this.category &&
          other.source == this.source &&
          other.presetId == this.presetId &&
          other.ownerProfileId == this.ownerProfileId &&
          other.seedVersion == this.seedVersion &&
          other.bandSize == this.bandSize &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WordbooksCompanion extends UpdateCompanion<Wordbook> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> colorSeed;
  final Value<String> category;
  final Value<String> source;
  final Value<String?> presetId;
  final Value<int?> ownerProfileId;
  final Value<int> seedVersion;
  final Value<int?> bandSize;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WordbooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorSeed = const Value.absent(),
    this.category = const Value.absent(),
    this.source = const Value.absent(),
    this.presetId = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.seedVersion = const Value.absent(),
    this.bandSize = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WordbooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String emoji,
    required int colorSeed,
    required String category,
    required String source,
    this.presetId = const Value.absent(),
    this.ownerProfileId = const Value.absent(),
    this.seedVersion = const Value.absent(),
    this.bandSize = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       emoji = Value(emoji),
       colorSeed = Value(colorSeed),
       category = Value(category),
       source = Value(source);
  static Insertable<Wordbook> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? colorSeed,
    Expression<String>? category,
    Expression<String>? source,
    Expression<String>? presetId,
    Expression<int>? ownerProfileId,
    Expression<int>? seedVersion,
    Expression<int>? bandSize,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (colorSeed != null) 'color_seed': colorSeed,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (presetId != null) 'preset_id': presetId,
      if (ownerProfileId != null) 'owner_profile_id': ownerProfileId,
      if (seedVersion != null) 'seed_version': seedVersion,
      if (bandSize != null) 'band_size': bandSize,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WordbooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? colorSeed,
    Value<String>? category,
    Value<String>? source,
    Value<String?>? presetId,
    Value<int?>? ownerProfileId,
    Value<int>? seedVersion,
    Value<int?>? bandSize,
    Value<String?>? note,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WordbooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorSeed: colorSeed ?? this.colorSeed,
      category: category ?? this.category,
      source: source ?? this.source,
      presetId: presetId ?? this.presetId,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      seedVersion: seedVersion ?? this.seedVersion,
      bandSize: bandSize ?? this.bandSize,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorSeed.present) {
      map['color_seed'] = Variable<int>(colorSeed.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (ownerProfileId.present) {
      map['owner_profile_id'] = Variable<int>(ownerProfileId.value);
    }
    if (seedVersion.present) {
      map['seed_version'] = Variable<int>(seedVersion.value);
    }
    if (bandSize.present) {
      map['band_size'] = Variable<int>(bandSize.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordbooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('presetId: $presetId, ')
          ..write('ownerProfileId: $ownerProfileId, ')
          ..write('seedVersion: $seedVersion, ')
          ..write('bandSize: $bandSize, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WordbookEntriesTable extends WordbookEntries
    with TableInfo<$WordbookEntriesTable, WordbookEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordbookEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordbookIdMeta = const VerificationMeta(
    'wordbookId',
  );
  @override
  late final GeneratedColumn<int> wordbookId = GeneratedColumn<int>(
    'wordbook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wordbooks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [wordbookId, wordId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wordbook_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordbookEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wordbook_id')) {
      context.handle(
        _wordbookIdMeta,
        wordbookId.isAcceptableOrUnknown(data['wordbook_id']!, _wordbookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordbookIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordbookId, wordId};
  @override
  WordbookEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordbookEntry(
      wordbookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wordbook_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WordbookEntriesTable createAlias(String alias) {
    return $WordbookEntriesTable(attachedDatabase, alias);
  }
}

class WordbookEntry extends DataClass implements Insertable<WordbookEntry> {
  final int wordbookId;
  final int wordId;

  /// 単語帳内の並び。
  final int sortOrder;
  const WordbookEntry({
    required this.wordbookId,
    required this.wordId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wordbook_id'] = Variable<int>(wordbookId);
    map['word_id'] = Variable<int>(wordId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WordbookEntriesCompanion toCompanion(bool nullToAbsent) {
    return WordbookEntriesCompanion(
      wordbookId: Value(wordbookId),
      wordId: Value(wordId),
      sortOrder: Value(sortOrder),
    );
  }

  factory WordbookEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordbookEntry(
      wordbookId: serializer.fromJson<int>(json['wordbookId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordbookId': serializer.toJson<int>(wordbookId),
      'wordId': serializer.toJson<int>(wordId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WordbookEntry copyWith({int? wordbookId, int? wordId, int? sortOrder}) =>
      WordbookEntry(
        wordbookId: wordbookId ?? this.wordbookId,
        wordId: wordId ?? this.wordId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WordbookEntry copyWithCompanion(WordbookEntriesCompanion data) {
    return WordbookEntry(
      wordbookId: data.wordbookId.present
          ? data.wordbookId.value
          : this.wordbookId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordbookEntry(')
          ..write('wordbookId: $wordbookId, ')
          ..write('wordId: $wordId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordbookId, wordId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordbookEntry &&
          other.wordbookId == this.wordbookId &&
          other.wordId == this.wordId &&
          other.sortOrder == this.sortOrder);
}

class WordbookEntriesCompanion extends UpdateCompanion<WordbookEntry> {
  final Value<int> wordbookId;
  final Value<int> wordId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WordbookEntriesCompanion({
    this.wordbookId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordbookEntriesCompanion.insert({
    required int wordbookId,
    required int wordId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : wordbookId = Value(wordbookId),
       wordId = Value(wordId);
  static Insertable<WordbookEntry> custom({
    Expression<int>? wordbookId,
    Expression<int>? wordId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordbookId != null) 'wordbook_id': wordbookId,
      if (wordId != null) 'word_id': wordId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordbookEntriesCompanion copyWith({
    Value<int>? wordbookId,
    Value<int>? wordId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return WordbookEntriesCompanion(
      wordbookId: wordbookId ?? this.wordbookId,
      wordId: wordId ?? this.wordId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordbookId.present) {
      map['wordbook_id'] = Variable<int>(wordbookId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordbookEntriesCompanion(')
          ..write('wordbookId: $wordbookId, ')
          ..write('wordId: $wordId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordPartsTable extends WordParts
    with TableInfo<$WordPartsTable, WordPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordPartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    form,
    type,
    meaning,
    origin,
    note,
    level,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordPart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    } else if (isInserting) {
      context.missing(_formMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordPart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $WordPartsTable createAlias(String alias) {
    return $WordPartsTable(attachedDatabase, alias);
  }
}

class WordPart extends DataClass implements Insertable<WordPart> {
  final int id;

  /// 表記（例 `port`）。
  final String form;

  /// 種別（`WordPartType`: prefix / root / suffix）。
  final String type;

  /// 意味（例「運ぶ」）。
  final String meaning;

  /// 語源（例「ラテン語 portare」）。
  final String? origin;
  final String? note;

  /// 難易度 1〜5。
  final int level;
  const WordPart({
    required this.id,
    required this.form,
    required this.type,
    required this.meaning,
    this.origin,
    this.note,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['form'] = Variable<String>(form);
    map['type'] = Variable<String>(type);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['level'] = Variable<int>(level);
    return map;
  }

  WordPartsCompanion toCompanion(bool nullToAbsent) {
    return WordPartsCompanion(
      id: Value(id),
      form: Value(form),
      type: Value(type),
      meaning: Value(meaning),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      level: Value(level),
    );
  }

  factory WordPart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordPart(
      id: serializer.fromJson<int>(json['id']),
      form: serializer.fromJson<String>(json['form']),
      type: serializer.fromJson<String>(json['type']),
      meaning: serializer.fromJson<String>(json['meaning']),
      origin: serializer.fromJson<String?>(json['origin']),
      note: serializer.fromJson<String?>(json['note']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'form': serializer.toJson<String>(form),
      'type': serializer.toJson<String>(type),
      'meaning': serializer.toJson<String>(meaning),
      'origin': serializer.toJson<String?>(origin),
      'note': serializer.toJson<String?>(note),
      'level': serializer.toJson<int>(level),
    };
  }

  WordPart copyWith({
    int? id,
    String? form,
    String? type,
    String? meaning,
    Value<String?> origin = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? level,
  }) => WordPart(
    id: id ?? this.id,
    form: form ?? this.form,
    type: type ?? this.type,
    meaning: meaning ?? this.meaning,
    origin: origin.present ? origin.value : this.origin,
    note: note.present ? note.value : this.note,
    level: level ?? this.level,
  );
  WordPart copyWithCompanion(WordPartsCompanion data) {
    return WordPart(
      id: data.id.present ? data.id.value : this.id,
      form: data.form.present ? data.form.value : this.form,
      type: data.type.present ? data.type.value : this.type,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      origin: data.origin.present ? data.origin.value : this.origin,
      note: data.note.present ? data.note.value : this.note,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordPart(')
          ..write('id: $id, ')
          ..write('form: $form, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('origin: $origin, ')
          ..write('note: $note, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, form, type, meaning, origin, note, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordPart &&
          other.id == this.id &&
          other.form == this.form &&
          other.type == this.type &&
          other.meaning == this.meaning &&
          other.origin == this.origin &&
          other.note == this.note &&
          other.level == this.level);
}

class WordPartsCompanion extends UpdateCompanion<WordPart> {
  final Value<int> id;
  final Value<String> form;
  final Value<String> type;
  final Value<String> meaning;
  final Value<String?> origin;
  final Value<String?> note;
  final Value<int> level;
  const WordPartsCompanion({
    this.id = const Value.absent(),
    this.form = const Value.absent(),
    this.type = const Value.absent(),
    this.meaning = const Value.absent(),
    this.origin = const Value.absent(),
    this.note = const Value.absent(),
    this.level = const Value.absent(),
  });
  WordPartsCompanion.insert({
    this.id = const Value.absent(),
    required String form,
    required String type,
    required String meaning,
    this.origin = const Value.absent(),
    this.note = const Value.absent(),
    this.level = const Value.absent(),
  }) : form = Value(form),
       type = Value(type),
       meaning = Value(meaning);
  static Insertable<WordPart> custom({
    Expression<int>? id,
    Expression<String>? form,
    Expression<String>? type,
    Expression<String>? meaning,
    Expression<String>? origin,
    Expression<String>? note,
    Expression<int>? level,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (form != null) 'form': form,
      if (type != null) 'type': type,
      if (meaning != null) 'meaning': meaning,
      if (origin != null) 'origin': origin,
      if (note != null) 'note': note,
      if (level != null) 'level': level,
    });
  }

  WordPartsCompanion copyWith({
    Value<int>? id,
    Value<String>? form,
    Value<String>? type,
    Value<String>? meaning,
    Value<String?>? origin,
    Value<String?>? note,
    Value<int>? level,
  }) {
    return WordPartsCompanion(
      id: id ?? this.id,
      form: form ?? this.form,
      type: type ?? this.type,
      meaning: meaning ?? this.meaning,
      origin: origin ?? this.origin,
      note: note ?? this.note,
      level: level ?? this.level,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordPartsCompanion(')
          ..write('id: $id, ')
          ..write('form: $form, ')
          ..write('type: $type, ')
          ..write('meaning: $meaning, ')
          ..write('origin: $origin, ')
          ..write('note: $note, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }
}

class $WordPartLinksTable extends WordPartLinks
    with TableInfo<$WordPartLinksTable, WordPartLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordPartLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_parts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [wordId, partId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_part_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordPartLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, partId};
  @override
  WordPartLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordPartLink(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $WordPartLinksTable createAlias(String alias) {
    return $WordPartLinksTable(attachedDatabase, alias);
  }
}

class WordPartLink extends DataClass implements Insertable<WordPartLink> {
  final int wordId;
  final int partId;

  /// 語の中での並び（接頭辞→語根→接尾辞）。
  final int position;
  const WordPartLink({
    required this.wordId,
    required this.partId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['part_id'] = Variable<int>(partId);
    map['position'] = Variable<int>(position);
    return map;
  }

  WordPartLinksCompanion toCompanion(bool nullToAbsent) {
    return WordPartLinksCompanion(
      wordId: Value(wordId),
      partId: Value(partId),
      position: Value(position),
    );
  }

  factory WordPartLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordPartLink(
      wordId: serializer.fromJson<int>(json['wordId']),
      partId: serializer.fromJson<int>(json['partId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'partId': serializer.toJson<int>(partId),
      'position': serializer.toJson<int>(position),
    };
  }

  WordPartLink copyWith({int? wordId, int? partId, int? position}) =>
      WordPartLink(
        wordId: wordId ?? this.wordId,
        partId: partId ?? this.partId,
        position: position ?? this.position,
      );
  WordPartLink copyWithCompanion(WordPartLinksCompanion data) {
    return WordPartLink(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      partId: data.partId.present ? data.partId.value : this.partId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordPartLink(')
          ..write('wordId: $wordId, ')
          ..write('partId: $partId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, partId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordPartLink &&
          other.wordId == this.wordId &&
          other.partId == this.partId &&
          other.position == this.position);
}

class WordPartLinksCompanion extends UpdateCompanion<WordPartLink> {
  final Value<int> wordId;
  final Value<int> partId;
  final Value<int> position;
  final Value<int> rowid;
  const WordPartLinksCompanion({
    this.wordId = const Value.absent(),
    this.partId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordPartLinksCompanion.insert({
    required int wordId,
    required int partId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       partId = Value(partId);
  static Insertable<WordPartLink> custom({
    Expression<int>? wordId,
    Expression<int>? partId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (partId != null) 'part_id': partId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordPartLinksCompanion copyWith({
    Value<int>? wordId,
    Value<int>? partId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return WordPartLinksCompanion(
      wordId: wordId ?? this.wordId,
      partId: partId ?? this.partId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordPartLinksCompanion(')
          ..write('wordId: $wordId, ')
          ..write('partId: $partId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordReviewsTable extends WordReviews
    with TableInfo<$WordReviewsTable, WordReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _repetitionMeta = const VerificationMeta(
    'repetition',
  );
  @override
  late final GeneratedColumn<int> repetition = GeneratedColumn<int>(
    'repetition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<double> intervalDays = GeneratedColumn<double>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _firstLearnedAtMeta = const VerificationMeta(
    'firstLearnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLearnedAt =
      GeneratedColumn<DateTime>(
        'first_learned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctStreakMeta = const VerificationMeta(
    'correctStreak',
  );
  @override
  late final GeneratedColumn<int> correctStreak = GeneratedColumn<int>(
    'correct_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCorrectMeta = const VerificationMeta(
    'totalCorrect',
  );
  @override
  late final GeneratedColumn<int> totalCorrect = GeneratedColumn<int>(
    'total_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalIncorrectMeta = const VerificationMeta(
    'totalIncorrect',
  );
  @override
  late final GeneratedColumn<int> totalIncorrect = GeneratedColumn<int>(
    'total_incorrect',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _masteryLevelMeta = const VerificationMeta(
    'masteryLevel',
  );
  @override
  late final GeneratedColumn<int> masteryLevel = GeneratedColumn<int>(
    'mastery_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    wordId,
    repetition,
    intervalDays,
    easeFactor,
    dueAt,
    lastReviewedAt,
    firstLearnedAt,
    lapses,
    correctStreak,
    totalCorrect,
    totalIncorrect,
    masteryLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('repetition')) {
      context.handle(
        _repetitionMeta,
        repetition.isAcceptableOrUnknown(data['repetition']!, _repetitionMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('first_learned_at')) {
      context.handle(
        _firstLearnedAtMeta,
        firstLearnedAt.isAcceptableOrUnknown(
          data['first_learned_at']!,
          _firstLearnedAtMeta,
        ),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('correct_streak')) {
      context.handle(
        _correctStreakMeta,
        correctStreak.isAcceptableOrUnknown(
          data['correct_streak']!,
          _correctStreakMeta,
        ),
      );
    }
    if (data.containsKey('total_correct')) {
      context.handle(
        _totalCorrectMeta,
        totalCorrect.isAcceptableOrUnknown(
          data['total_correct']!,
          _totalCorrectMeta,
        ),
      );
    }
    if (data.containsKey('total_incorrect')) {
      context.handle(
        _totalIncorrectMeta,
        totalIncorrect.isAcceptableOrUnknown(
          data['total_incorrect']!,
          _totalIncorrectMeta,
        ),
      );
    }
    if (data.containsKey('mastery_level')) {
      context.handle(
        _masteryLevelMeta,
        masteryLevel.isAcceptableOrUnknown(
          data['mastery_level']!,
          _masteryLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, wordId};
  @override
  WordReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordReview(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      repetition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetition'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      firstLearnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_learned_at'],
      ),
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      correctStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_streak'],
      )!,
      totalCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_correct'],
      )!,
      totalIncorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_incorrect'],
      )!,
      masteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastery_level'],
      )!,
    );
  }

  @override
  $WordReviewsTable createAlias(String alias) {
    return $WordReviewsTable(attachedDatabase, alias);
  }
}

class WordReview extends DataClass implements Insertable<WordReview> {
  final int profileId;
  final int wordId;

  /// 連続正解回数（SM-2 の n）。
  final int repetition;

  /// 現在の出題間隔（日）。
  final double intervalDays;

  /// 容易度係数。下限 1.3。
  final double easeFactor;

  /// 次回出題日時。
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  final DateTime? firstLearnedAt;
  final int lapses;
  final int correctStreak;
  final int totalCorrect;
  final int totalIncorrect;

  /// 導出値（`Mastery.from`）。絞り込み・並べ替えにインデックスが要るため列に持つ。
  final int masteryLevel;
  const WordReview({
    required this.profileId,
    required this.wordId,
    required this.repetition,
    required this.intervalDays,
    required this.easeFactor,
    required this.dueAt,
    this.lastReviewedAt,
    this.firstLearnedAt,
    required this.lapses,
    required this.correctStreak,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.masteryLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['word_id'] = Variable<int>(wordId);
    map['repetition'] = Variable<int>(repetition);
    map['interval_days'] = Variable<double>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || firstLearnedAt != null) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt);
    }
    map['lapses'] = Variable<int>(lapses);
    map['correct_streak'] = Variable<int>(correctStreak);
    map['total_correct'] = Variable<int>(totalCorrect);
    map['total_incorrect'] = Variable<int>(totalIncorrect);
    map['mastery_level'] = Variable<int>(masteryLevel);
    return map;
  }

  WordReviewsCompanion toCompanion(bool nullToAbsent) {
    return WordReviewsCompanion(
      profileId: Value(profileId),
      wordId: Value(wordId),
      repetition: Value(repetition),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      dueAt: Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      firstLearnedAt: firstLearnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLearnedAt),
      lapses: Value(lapses),
      correctStreak: Value(correctStreak),
      totalCorrect: Value(totalCorrect),
      totalIncorrect: Value(totalIncorrect),
      masteryLevel: Value(masteryLevel),
    );
  }

  factory WordReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordReview(
      profileId: serializer.fromJson<int>(json['profileId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      repetition: serializer.fromJson<int>(json['repetition']),
      intervalDays: serializer.fromJson<double>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      firstLearnedAt: serializer.fromJson<DateTime?>(json['firstLearnedAt']),
      lapses: serializer.fromJson<int>(json['lapses']),
      correctStreak: serializer.fromJson<int>(json['correctStreak']),
      totalCorrect: serializer.fromJson<int>(json['totalCorrect']),
      totalIncorrect: serializer.fromJson<int>(json['totalIncorrect']),
      masteryLevel: serializer.fromJson<int>(json['masteryLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'wordId': serializer.toJson<int>(wordId),
      'repetition': serializer.toJson<int>(repetition),
      'intervalDays': serializer.toJson<double>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'firstLearnedAt': serializer.toJson<DateTime?>(firstLearnedAt),
      'lapses': serializer.toJson<int>(lapses),
      'correctStreak': serializer.toJson<int>(correctStreak),
      'totalCorrect': serializer.toJson<int>(totalCorrect),
      'totalIncorrect': serializer.toJson<int>(totalIncorrect),
      'masteryLevel': serializer.toJson<int>(masteryLevel),
    };
  }

  WordReview copyWith({
    int? profileId,
    int? wordId,
    int? repetition,
    double? intervalDays,
    double? easeFactor,
    DateTime? dueAt,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<DateTime?> firstLearnedAt = const Value.absent(),
    int? lapses,
    int? correctStreak,
    int? totalCorrect,
    int? totalIncorrect,
    int? masteryLevel,
  }) => WordReview(
    profileId: profileId ?? this.profileId,
    wordId: wordId ?? this.wordId,
    repetition: repetition ?? this.repetition,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    dueAt: dueAt ?? this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    firstLearnedAt: firstLearnedAt.present
        ? firstLearnedAt.value
        : this.firstLearnedAt,
    lapses: lapses ?? this.lapses,
    correctStreak: correctStreak ?? this.correctStreak,
    totalCorrect: totalCorrect ?? this.totalCorrect,
    totalIncorrect: totalIncorrect ?? this.totalIncorrect,
    masteryLevel: masteryLevel ?? this.masteryLevel,
  );
  WordReview copyWithCompanion(WordReviewsCompanion data) {
    return WordReview(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      repetition: data.repetition.present
          ? data.repetition.value
          : this.repetition,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      firstLearnedAt: data.firstLearnedAt.present
          ? data.firstLearnedAt.value
          : this.firstLearnedAt,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      correctStreak: data.correctStreak.present
          ? data.correctStreak.value
          : this.correctStreak,
      totalCorrect: data.totalCorrect.present
          ? data.totalCorrect.value
          : this.totalCorrect,
      totalIncorrect: data.totalIncorrect.present
          ? data.totalIncorrect.value
          : this.totalIncorrect,
      masteryLevel: data.masteryLevel.present
          ? data.masteryLevel.value
          : this.masteryLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordReview(')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('repetition: $repetition, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('lapses: $lapses, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalIncorrect: $totalIncorrect, ')
          ..write('masteryLevel: $masteryLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    wordId,
    repetition,
    intervalDays,
    easeFactor,
    dueAt,
    lastReviewedAt,
    firstLearnedAt,
    lapses,
    correctStreak,
    totalCorrect,
    totalIncorrect,
    masteryLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordReview &&
          other.profileId == this.profileId &&
          other.wordId == this.wordId &&
          other.repetition == this.repetition &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.firstLearnedAt == this.firstLearnedAt &&
          other.lapses == this.lapses &&
          other.correctStreak == this.correctStreak &&
          other.totalCorrect == this.totalCorrect &&
          other.totalIncorrect == this.totalIncorrect &&
          other.masteryLevel == this.masteryLevel);
}

class WordReviewsCompanion extends UpdateCompanion<WordReview> {
  final Value<int> profileId;
  final Value<int> wordId;
  final Value<int> repetition;
  final Value<double> intervalDays;
  final Value<double> easeFactor;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> firstLearnedAt;
  final Value<int> lapses;
  final Value<int> correctStreak;
  final Value<int> totalCorrect;
  final Value<int> totalIncorrect;
  final Value<int> masteryLevel;
  final Value<int> rowid;
  const WordReviewsCompanion({
    this.profileId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.repetition = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.lapses = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalIncorrect = const Value.absent(),
    this.masteryLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordReviewsCompanion.insert({
    required int profileId,
    required int wordId,
    this.repetition = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    required DateTime dueAt,
    this.lastReviewedAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.lapses = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalIncorrect = const Value.absent(),
    this.masteryLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       wordId = Value(wordId),
       dueAt = Value(dueAt);
  static Insertable<WordReview> custom({
    Expression<int>? profileId,
    Expression<int>? wordId,
    Expression<int>? repetition,
    Expression<double>? intervalDays,
    Expression<double>? easeFactor,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? firstLearnedAt,
    Expression<int>? lapses,
    Expression<int>? correctStreak,
    Expression<int>? totalCorrect,
    Expression<int>? totalIncorrect,
    Expression<int>? masteryLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (wordId != null) 'word_id': wordId,
      if (repetition != null) 'repetition': repetition,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (firstLearnedAt != null) 'first_learned_at': firstLearnedAt,
      if (lapses != null) 'lapses': lapses,
      if (correctStreak != null) 'correct_streak': correctStreak,
      if (totalCorrect != null) 'total_correct': totalCorrect,
      if (totalIncorrect != null) 'total_incorrect': totalIncorrect,
      if (masteryLevel != null) 'mastery_level': masteryLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordReviewsCompanion copyWith({
    Value<int>? profileId,
    Value<int>? wordId,
    Value<int>? repetition,
    Value<double>? intervalDays,
    Value<double>? easeFactor,
    Value<DateTime>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? firstLearnedAt,
    Value<int>? lapses,
    Value<int>? correctStreak,
    Value<int>? totalCorrect,
    Value<int>? totalIncorrect,
    Value<int>? masteryLevel,
    Value<int>? rowid,
  }) {
    return WordReviewsCompanion(
      profileId: profileId ?? this.profileId,
      wordId: wordId ?? this.wordId,
      repetition: repetition ?? this.repetition,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      lapses: lapses ?? this.lapses,
      correctStreak: correctStreak ?? this.correctStreak,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (repetition.present) {
      map['repetition'] = Variable<int>(repetition.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<double>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (firstLearnedAt.present) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (correctStreak.present) {
      map['correct_streak'] = Variable<int>(correctStreak.value);
    }
    if (totalCorrect.present) {
      map['total_correct'] = Variable<int>(totalCorrect.value);
    }
    if (totalIncorrect.present) {
      map['total_incorrect'] = Variable<int>(totalIncorrect.value);
    }
    if (masteryLevel.present) {
      map['mastery_level'] = Variable<int>(masteryLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordReviewsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('repetition: $repetition, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('lapses: $lapses, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalIncorrect: $totalIncorrect, ')
          ..write('masteryLevel: $masteryLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartReviewsTable extends PartReviews
    with TableInfo<$PartReviewsTable, PartReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartReviewsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_parts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _repetitionMeta = const VerificationMeta(
    'repetition',
  );
  @override
  late final GeneratedColumn<int> repetition = GeneratedColumn<int>(
    'repetition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<double> intervalDays = GeneratedColumn<double>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _firstLearnedAtMeta = const VerificationMeta(
    'firstLearnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLearnedAt =
      GeneratedColumn<DateTime>(
        'first_learned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctStreakMeta = const VerificationMeta(
    'correctStreak',
  );
  @override
  late final GeneratedColumn<int> correctStreak = GeneratedColumn<int>(
    'correct_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCorrectMeta = const VerificationMeta(
    'totalCorrect',
  );
  @override
  late final GeneratedColumn<int> totalCorrect = GeneratedColumn<int>(
    'total_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalIncorrectMeta = const VerificationMeta(
    'totalIncorrect',
  );
  @override
  late final GeneratedColumn<int> totalIncorrect = GeneratedColumn<int>(
    'total_incorrect',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _masteryLevelMeta = const VerificationMeta(
    'masteryLevel',
  );
  @override
  late final GeneratedColumn<int> masteryLevel = GeneratedColumn<int>(
    'mastery_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    partId,
    repetition,
    intervalDays,
    easeFactor,
    dueAt,
    lastReviewedAt,
    firstLearnedAt,
    lapses,
    correctStreak,
    totalCorrect,
    totalIncorrect,
    masteryLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('repetition')) {
      context.handle(
        _repetitionMeta,
        repetition.isAcceptableOrUnknown(data['repetition']!, _repetitionMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('first_learned_at')) {
      context.handle(
        _firstLearnedAtMeta,
        firstLearnedAt.isAcceptableOrUnknown(
          data['first_learned_at']!,
          _firstLearnedAtMeta,
        ),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('correct_streak')) {
      context.handle(
        _correctStreakMeta,
        correctStreak.isAcceptableOrUnknown(
          data['correct_streak']!,
          _correctStreakMeta,
        ),
      );
    }
    if (data.containsKey('total_correct')) {
      context.handle(
        _totalCorrectMeta,
        totalCorrect.isAcceptableOrUnknown(
          data['total_correct']!,
          _totalCorrectMeta,
        ),
      );
    }
    if (data.containsKey('total_incorrect')) {
      context.handle(
        _totalIncorrectMeta,
        totalIncorrect.isAcceptableOrUnknown(
          data['total_incorrect']!,
          _totalIncorrectMeta,
        ),
      );
    }
    if (data.containsKey('mastery_level')) {
      context.handle(
        _masteryLevelMeta,
        masteryLevel.isAcceptableOrUnknown(
          data['mastery_level']!,
          _masteryLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, partId};
  @override
  PartReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartReview(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_id'],
      )!,
      repetition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetition'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      firstLearnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_learned_at'],
      ),
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      correctStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_streak'],
      )!,
      totalCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_correct'],
      )!,
      totalIncorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_incorrect'],
      )!,
      masteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastery_level'],
      )!,
    );
  }

  @override
  $PartReviewsTable createAlias(String alias) {
    return $PartReviewsTable(attachedDatabase, alias);
  }
}

class PartReview extends DataClass implements Insertable<PartReview> {
  final int profileId;
  final int partId;
  final int repetition;
  final double intervalDays;
  final double easeFactor;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  final DateTime? firstLearnedAt;
  final int lapses;
  final int correctStreak;
  final int totalCorrect;
  final int totalIncorrect;
  final int masteryLevel;
  const PartReview({
    required this.profileId,
    required this.partId,
    required this.repetition,
    required this.intervalDays,
    required this.easeFactor,
    required this.dueAt,
    this.lastReviewedAt,
    this.firstLearnedAt,
    required this.lapses,
    required this.correctStreak,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.masteryLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['part_id'] = Variable<int>(partId);
    map['repetition'] = Variable<int>(repetition);
    map['interval_days'] = Variable<double>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    if (!nullToAbsent || firstLearnedAt != null) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt);
    }
    map['lapses'] = Variable<int>(lapses);
    map['correct_streak'] = Variable<int>(correctStreak);
    map['total_correct'] = Variable<int>(totalCorrect);
    map['total_incorrect'] = Variable<int>(totalIncorrect);
    map['mastery_level'] = Variable<int>(masteryLevel);
    return map;
  }

  PartReviewsCompanion toCompanion(bool nullToAbsent) {
    return PartReviewsCompanion(
      profileId: Value(profileId),
      partId: Value(partId),
      repetition: Value(repetition),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      dueAt: Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      firstLearnedAt: firstLearnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLearnedAt),
      lapses: Value(lapses),
      correctStreak: Value(correctStreak),
      totalCorrect: Value(totalCorrect),
      totalIncorrect: Value(totalIncorrect),
      masteryLevel: Value(masteryLevel),
    );
  }

  factory PartReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartReview(
      profileId: serializer.fromJson<int>(json['profileId']),
      partId: serializer.fromJson<int>(json['partId']),
      repetition: serializer.fromJson<int>(json['repetition']),
      intervalDays: serializer.fromJson<double>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      firstLearnedAt: serializer.fromJson<DateTime?>(json['firstLearnedAt']),
      lapses: serializer.fromJson<int>(json['lapses']),
      correctStreak: serializer.fromJson<int>(json['correctStreak']),
      totalCorrect: serializer.fromJson<int>(json['totalCorrect']),
      totalIncorrect: serializer.fromJson<int>(json['totalIncorrect']),
      masteryLevel: serializer.fromJson<int>(json['masteryLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'partId': serializer.toJson<int>(partId),
      'repetition': serializer.toJson<int>(repetition),
      'intervalDays': serializer.toJson<double>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'firstLearnedAt': serializer.toJson<DateTime?>(firstLearnedAt),
      'lapses': serializer.toJson<int>(lapses),
      'correctStreak': serializer.toJson<int>(correctStreak),
      'totalCorrect': serializer.toJson<int>(totalCorrect),
      'totalIncorrect': serializer.toJson<int>(totalIncorrect),
      'masteryLevel': serializer.toJson<int>(masteryLevel),
    };
  }

  PartReview copyWith({
    int? profileId,
    int? partId,
    int? repetition,
    double? intervalDays,
    double? easeFactor,
    DateTime? dueAt,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    Value<DateTime?> firstLearnedAt = const Value.absent(),
    int? lapses,
    int? correctStreak,
    int? totalCorrect,
    int? totalIncorrect,
    int? masteryLevel,
  }) => PartReview(
    profileId: profileId ?? this.profileId,
    partId: partId ?? this.partId,
    repetition: repetition ?? this.repetition,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    dueAt: dueAt ?? this.dueAt,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    firstLearnedAt: firstLearnedAt.present
        ? firstLearnedAt.value
        : this.firstLearnedAt,
    lapses: lapses ?? this.lapses,
    correctStreak: correctStreak ?? this.correctStreak,
    totalCorrect: totalCorrect ?? this.totalCorrect,
    totalIncorrect: totalIncorrect ?? this.totalIncorrect,
    masteryLevel: masteryLevel ?? this.masteryLevel,
  );
  PartReview copyWithCompanion(PartReviewsCompanion data) {
    return PartReview(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      partId: data.partId.present ? data.partId.value : this.partId,
      repetition: data.repetition.present
          ? data.repetition.value
          : this.repetition,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      firstLearnedAt: data.firstLearnedAt.present
          ? data.firstLearnedAt.value
          : this.firstLearnedAt,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      correctStreak: data.correctStreak.present
          ? data.correctStreak.value
          : this.correctStreak,
      totalCorrect: data.totalCorrect.present
          ? data.totalCorrect.value
          : this.totalCorrect,
      totalIncorrect: data.totalIncorrect.present
          ? data.totalIncorrect.value
          : this.totalIncorrect,
      masteryLevel: data.masteryLevel.present
          ? data.masteryLevel.value
          : this.masteryLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartReview(')
          ..write('profileId: $profileId, ')
          ..write('partId: $partId, ')
          ..write('repetition: $repetition, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('lapses: $lapses, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalIncorrect: $totalIncorrect, ')
          ..write('masteryLevel: $masteryLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    partId,
    repetition,
    intervalDays,
    easeFactor,
    dueAt,
    lastReviewedAt,
    firstLearnedAt,
    lapses,
    correctStreak,
    totalCorrect,
    totalIncorrect,
    masteryLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartReview &&
          other.profileId == this.profileId &&
          other.partId == this.partId &&
          other.repetition == this.repetition &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.firstLearnedAt == this.firstLearnedAt &&
          other.lapses == this.lapses &&
          other.correctStreak == this.correctStreak &&
          other.totalCorrect == this.totalCorrect &&
          other.totalIncorrect == this.totalIncorrect &&
          other.masteryLevel == this.masteryLevel);
}

class PartReviewsCompanion extends UpdateCompanion<PartReview> {
  final Value<int> profileId;
  final Value<int> partId;
  final Value<int> repetition;
  final Value<double> intervalDays;
  final Value<double> easeFactor;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime?> firstLearnedAt;
  final Value<int> lapses;
  final Value<int> correctStreak;
  final Value<int> totalCorrect;
  final Value<int> totalIncorrect;
  final Value<int> masteryLevel;
  final Value<int> rowid;
  const PartReviewsCompanion({
    this.profileId = const Value.absent(),
    this.partId = const Value.absent(),
    this.repetition = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.lapses = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalIncorrect = const Value.absent(),
    this.masteryLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartReviewsCompanion.insert({
    required int profileId,
    required int partId,
    this.repetition = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    required DateTime dueAt,
    this.lastReviewedAt = const Value.absent(),
    this.firstLearnedAt = const Value.absent(),
    this.lapses = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalIncorrect = const Value.absent(),
    this.masteryLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       partId = Value(partId),
       dueAt = Value(dueAt);
  static Insertable<PartReview> custom({
    Expression<int>? profileId,
    Expression<int>? partId,
    Expression<int>? repetition,
    Expression<double>? intervalDays,
    Expression<double>? easeFactor,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? firstLearnedAt,
    Expression<int>? lapses,
    Expression<int>? correctStreak,
    Expression<int>? totalCorrect,
    Expression<int>? totalIncorrect,
    Expression<int>? masteryLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (partId != null) 'part_id': partId,
      if (repetition != null) 'repetition': repetition,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (firstLearnedAt != null) 'first_learned_at': firstLearnedAt,
      if (lapses != null) 'lapses': lapses,
      if (correctStreak != null) 'correct_streak': correctStreak,
      if (totalCorrect != null) 'total_correct': totalCorrect,
      if (totalIncorrect != null) 'total_incorrect': totalIncorrect,
      if (masteryLevel != null) 'mastery_level': masteryLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartReviewsCompanion copyWith({
    Value<int>? profileId,
    Value<int>? partId,
    Value<int>? repetition,
    Value<double>? intervalDays,
    Value<double>? easeFactor,
    Value<DateTime>? dueAt,
    Value<DateTime?>? lastReviewedAt,
    Value<DateTime?>? firstLearnedAt,
    Value<int>? lapses,
    Value<int>? correctStreak,
    Value<int>? totalCorrect,
    Value<int>? totalIncorrect,
    Value<int>? masteryLevel,
    Value<int>? rowid,
  }) {
    return PartReviewsCompanion(
      profileId: profileId ?? this.profileId,
      partId: partId ?? this.partId,
      repetition: repetition ?? this.repetition,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      firstLearnedAt: firstLearnedAt ?? this.firstLearnedAt,
      lapses: lapses ?? this.lapses,
      correctStreak: correctStreak ?? this.correctStreak,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalIncorrect: totalIncorrect ?? this.totalIncorrect,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (repetition.present) {
      map['repetition'] = Variable<int>(repetition.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<double>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (firstLearnedAt.present) {
      map['first_learned_at'] = Variable<DateTime>(firstLearnedAt.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (correctStreak.present) {
      map['correct_streak'] = Variable<int>(correctStreak.value);
    }
    if (totalCorrect.present) {
      map['total_correct'] = Variable<int>(totalCorrect.value);
    }
    if (totalIncorrect.present) {
      map['total_incorrect'] = Variable<int>(totalIncorrect.value);
    }
    if (masteryLevel.present) {
      map['mastery_level'] = Variable<int>(masteryLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartReviewsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('partId: $partId, ')
          ..write('repetition: $repetition, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('firstLearnedAt: $firstLearnedAt, ')
          ..write('lapses: $lapses, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalIncorrect: $totalIncorrect, ')
          ..write('masteryLevel: $masteryLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResolvedConfusionsTable extends ResolvedConfusions
    with TableInfo<$ResolvedConfusionsTable, ResolvedConfusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResolvedConfusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdAMeta = const VerificationMeta(
    'wordIdA',
  );
  @override
  late final GeneratedColumn<int> wordIdA = GeneratedColumn<int>(
    'word_id_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdBMeta = const VerificationMeta(
    'wordIdB',
  );
  @override
  late final GeneratedColumn<int> wordIdB = GeneratedColumn<int>(
    'word_id_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    wordIdA,
    wordIdB,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resolved_confusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResolvedConfusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id_a')) {
      context.handle(
        _wordIdAMeta,
        wordIdA.isAcceptableOrUnknown(data['word_id_a']!, _wordIdAMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdAMeta);
    }
    if (data.containsKey('word_id_b')) {
      context.handle(
        _wordIdBMeta,
        wordIdB.isAcceptableOrUnknown(data['word_id_b']!, _wordIdBMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdBMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, wordIdA, wordIdB};
  @override
  ResolvedConfusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResolvedConfusion(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      wordIdA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id_a'],
      )!,
      wordIdB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id_b'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      )!,
    );
  }

  @override
  $ResolvedConfusionsTable createAlias(String alias) {
    return $ResolvedConfusionsTable(attachedDatabase, alias);
  }
}

class ResolvedConfusion extends DataClass
    implements Insertable<ResolvedConfusion> {
  final int profileId;
  final int wordIdA;
  final int wordIdB;
  final DateTime resolvedAt;
  const ResolvedConfusion({
    required this.profileId,
    required this.wordIdA,
    required this.wordIdB,
    required this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['word_id_a'] = Variable<int>(wordIdA);
    map['word_id_b'] = Variable<int>(wordIdB);
    map['resolved_at'] = Variable<DateTime>(resolvedAt);
    return map;
  }

  ResolvedConfusionsCompanion toCompanion(bool nullToAbsent) {
    return ResolvedConfusionsCompanion(
      profileId: Value(profileId),
      wordIdA: Value(wordIdA),
      wordIdB: Value(wordIdB),
      resolvedAt: Value(resolvedAt),
    );
  }

  factory ResolvedConfusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResolvedConfusion(
      profileId: serializer.fromJson<int>(json['profileId']),
      wordIdA: serializer.fromJson<int>(json['wordIdA']),
      wordIdB: serializer.fromJson<int>(json['wordIdB']),
      resolvedAt: serializer.fromJson<DateTime>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'wordIdA': serializer.toJson<int>(wordIdA),
      'wordIdB': serializer.toJson<int>(wordIdB),
      'resolvedAt': serializer.toJson<DateTime>(resolvedAt),
    };
  }

  ResolvedConfusion copyWith({
    int? profileId,
    int? wordIdA,
    int? wordIdB,
    DateTime? resolvedAt,
  }) => ResolvedConfusion(
    profileId: profileId ?? this.profileId,
    wordIdA: wordIdA ?? this.wordIdA,
    wordIdB: wordIdB ?? this.wordIdB,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
  ResolvedConfusion copyWithCompanion(ResolvedConfusionsCompanion data) {
    return ResolvedConfusion(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordIdA: data.wordIdA.present ? data.wordIdA.value : this.wordIdA,
      wordIdB: data.wordIdB.present ? data.wordIdB.value : this.wordIdB,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResolvedConfusion(')
          ..write('profileId: $profileId, ')
          ..write('wordIdA: $wordIdA, ')
          ..write('wordIdB: $wordIdB, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, wordIdA, wordIdB, resolvedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResolvedConfusion &&
          other.profileId == this.profileId &&
          other.wordIdA == this.wordIdA &&
          other.wordIdB == this.wordIdB &&
          other.resolvedAt == this.resolvedAt);
}

class ResolvedConfusionsCompanion extends UpdateCompanion<ResolvedConfusion> {
  final Value<int> profileId;
  final Value<int> wordIdA;
  final Value<int> wordIdB;
  final Value<DateTime> resolvedAt;
  final Value<int> rowid;
  const ResolvedConfusionsCompanion({
    this.profileId = const Value.absent(),
    this.wordIdA = const Value.absent(),
    this.wordIdB = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResolvedConfusionsCompanion.insert({
    required int profileId,
    required int wordIdA,
    required int wordIdB,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       wordIdA = Value(wordIdA),
       wordIdB = Value(wordIdB);
  static Insertable<ResolvedConfusion> custom({
    Expression<int>? profileId,
    Expression<int>? wordIdA,
    Expression<int>? wordIdB,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (wordIdA != null) 'word_id_a': wordIdA,
      if (wordIdB != null) 'word_id_b': wordIdB,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResolvedConfusionsCompanion copyWith({
    Value<int>? profileId,
    Value<int>? wordIdA,
    Value<int>? wordIdB,
    Value<DateTime>? resolvedAt,
    Value<int>? rowid,
  }) {
    return ResolvedConfusionsCompanion(
      profileId: profileId ?? this.profileId,
      wordIdA: wordIdA ?? this.wordIdA,
      wordIdB: wordIdB ?? this.wordIdB,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordIdA.present) {
      map['word_id_a'] = Variable<int>(wordIdA.value);
    }
    if (wordIdB.present) {
      map['word_id_b'] = Variable<int>(wordIdB.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResolvedConfusionsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('wordIdA: $wordIdA, ')
          ..write('wordIdB: $wordIdB, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordbookIdsMeta = const VerificationMeta(
    'wordbookIds',
  );
  @override
  late final GeneratedColumn<String> wordbookIds = GeneratedColumn<String>(
    'wordbook_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedCountMeta = const VerificationMeta(
    'plannedCount',
  );
  @override
  late final GeneratedColumn<int> plannedCount = GeneratedColumn<int>(
    'planned_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredCountMeta = const VerificationMeta(
    'answeredCount',
  );
  @override
  late final GeneratedColumn<int> answeredCount = GeneratedColumn<int>(
    'answered_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpEarnedMeta = const VerificationMeta(
    'xpEarned',
  );
  @override
  late final GeneratedColumn<int> xpEarned = GeneratedColumn<int>(
    'xp_earned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgReactionMsMeta = const VerificationMeta(
    'avgReactionMs',
  );
  @override
  late final GeneratedColumn<int> avgReactionMs = GeneratedColumn<int>(
    'avg_reaction_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    mode,
    wordbookIds,
    startedAt,
    finishedAt,
    plannedCount,
    answeredCount,
    correctCount,
    xpEarned,
    avgReactionMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('wordbook_ids')) {
      context.handle(
        _wordbookIdsMeta,
        wordbookIds.isAcceptableOrUnknown(
          data['wordbook_ids']!,
          _wordbookIdsMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('planned_count')) {
      context.handle(
        _plannedCountMeta,
        plannedCount.isAcceptableOrUnknown(
          data['planned_count']!,
          _plannedCountMeta,
        ),
      );
    }
    if (data.containsKey('answered_count')) {
      context.handle(
        _answeredCountMeta,
        answeredCount.isAcceptableOrUnknown(
          data['answered_count']!,
          _answeredCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('xp_earned')) {
      context.handle(
        _xpEarnedMeta,
        xpEarned.isAcceptableOrUnknown(data['xp_earned']!, _xpEarnedMeta),
      );
    }
    if (data.containsKey('avg_reaction_ms')) {
      context.handle(
        _avgReactionMsMeta,
        avgReactionMs.isAcceptableOrUnknown(
          data['avg_reaction_ms']!,
          _avgReactionMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      wordbookIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wordbook_ids'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      plannedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_count'],
      )!,
      answeredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      xpEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_earned'],
      )!,
      avgReactionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_reaction_ms'],
      ),
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  /// UUID v4。
  final String id;
  final int profileId;

  /// 学習モード（`StudyMode`）。
  final String mode;

  /// 対象単語帳の id を JSON 配列で持つ（履歴の再現用）。
  final String wordbookIds;
  final DateTime startedAt;

  /// null = 中断のまま終わった。
  final DateTime? finishedAt;
  final int plannedCount;
  final int answeredCount;
  final int correctCount;
  final int xpEarned;

  /// スピードモードでのみ。時間内正解のみの平均反応時間（ミリ秒）。
  final int? avgReactionMs;
  const StudySession({
    required this.id,
    required this.profileId,
    required this.mode,
    required this.wordbookIds,
    required this.startedAt,
    this.finishedAt,
    required this.plannedCount,
    required this.answeredCount,
    required this.correctCount,
    required this.xpEarned,
    this.avgReactionMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['mode'] = Variable<String>(mode);
    map['wordbook_ids'] = Variable<String>(wordbookIds);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['planned_count'] = Variable<int>(plannedCount);
    map['answered_count'] = Variable<int>(answeredCount);
    map['correct_count'] = Variable<int>(correctCount);
    map['xp_earned'] = Variable<int>(xpEarned);
    if (!nullToAbsent || avgReactionMs != null) {
      map['avg_reaction_ms'] = Variable<int>(avgReactionMs);
    }
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      mode: Value(mode),
      wordbookIds: Value(wordbookIds),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      plannedCount: Value(plannedCount),
      answeredCount: Value(answeredCount),
      correctCount: Value(correctCount),
      xpEarned: Value(xpEarned),
      avgReactionMs: avgReactionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(avgReactionMs),
    );
  }

  factory StudySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      mode: serializer.fromJson<String>(json['mode']),
      wordbookIds: serializer.fromJson<String>(json['wordbookIds']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      plannedCount: serializer.fromJson<int>(json['plannedCount']),
      answeredCount: serializer.fromJson<int>(json['answeredCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      xpEarned: serializer.fromJson<int>(json['xpEarned']),
      avgReactionMs: serializer.fromJson<int?>(json['avgReactionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<int>(profileId),
      'mode': serializer.toJson<String>(mode),
      'wordbookIds': serializer.toJson<String>(wordbookIds),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'plannedCount': serializer.toJson<int>(plannedCount),
      'answeredCount': serializer.toJson<int>(answeredCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'xpEarned': serializer.toJson<int>(xpEarned),
      'avgReactionMs': serializer.toJson<int?>(avgReactionMs),
    };
  }

  StudySession copyWith({
    String? id,
    int? profileId,
    String? mode,
    String? wordbookIds,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? plannedCount,
    int? answeredCount,
    int? correctCount,
    int? xpEarned,
    Value<int?> avgReactionMs = const Value.absent(),
  }) => StudySession(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    mode: mode ?? this.mode,
    wordbookIds: wordbookIds ?? this.wordbookIds,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    plannedCount: plannedCount ?? this.plannedCount,
    answeredCount: answeredCount ?? this.answeredCount,
    correctCount: correctCount ?? this.correctCount,
    xpEarned: xpEarned ?? this.xpEarned,
    avgReactionMs: avgReactionMs.present
        ? avgReactionMs.value
        : this.avgReactionMs,
  );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      mode: data.mode.present ? data.mode.value : this.mode,
      wordbookIds: data.wordbookIds.present
          ? data.wordbookIds.value
          : this.wordbookIds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      plannedCount: data.plannedCount.present
          ? data.plannedCount.value
          : this.plannedCount,
      answeredCount: data.answeredCount.present
          ? data.answeredCount.value
          : this.answeredCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      xpEarned: data.xpEarned.present ? data.xpEarned.value : this.xpEarned,
      avgReactionMs: data.avgReactionMs.present
          ? data.avgReactionMs.value
          : this.avgReactionMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('mode: $mode, ')
          ..write('wordbookIds: $wordbookIds, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('plannedCount: $plannedCount, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('avgReactionMs: $avgReactionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    mode,
    wordbookIds,
    startedAt,
    finishedAt,
    plannedCount,
    answeredCount,
    correctCount,
    xpEarned,
    avgReactionMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.mode == this.mode &&
          other.wordbookIds == this.wordbookIds &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.plannedCount == this.plannedCount &&
          other.answeredCount == this.answeredCount &&
          other.correctCount == this.correctCount &&
          other.xpEarned == this.xpEarned &&
          other.avgReactionMs == this.avgReactionMs);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<int> profileId;
  final Value<String> mode;
  final Value<String> wordbookIds;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> plannedCount;
  final Value<int> answeredCount;
  final Value<int> correctCount;
  final Value<int> xpEarned;
  final Value<int?> avgReactionMs;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.mode = const Value.absent(),
    this.wordbookIds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.plannedCount = const Value.absent(),
    this.answeredCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.avgReactionMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required int profileId,
    required String mode,
    this.wordbookIds = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.plannedCount = const Value.absent(),
    this.answeredCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.xpEarned = const Value.absent(),
    this.avgReactionMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       mode = Value(mode),
       startedAt = Value(startedAt);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<int>? profileId,
    Expression<String>? mode,
    Expression<String>? wordbookIds,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? plannedCount,
    Expression<int>? answeredCount,
    Expression<int>? correctCount,
    Expression<int>? xpEarned,
    Expression<int>? avgReactionMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (mode != null) 'mode': mode,
      if (wordbookIds != null) 'wordbook_ids': wordbookIds,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (plannedCount != null) 'planned_count': plannedCount,
      if (answeredCount != null) 'answered_count': answeredCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (xpEarned != null) 'xp_earned': xpEarned,
      if (avgReactionMs != null) 'avg_reaction_ms': avgReactionMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith({
    Value<String>? id,
    Value<int>? profileId,
    Value<String>? mode,
    Value<String>? wordbookIds,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? plannedCount,
    Value<int>? answeredCount,
    Value<int>? correctCount,
    Value<int>? xpEarned,
    Value<int?>? avgReactionMs,
    Value<int>? rowid,
  }) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      mode: mode ?? this.mode,
      wordbookIds: wordbookIds ?? this.wordbookIds,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      plannedCount: plannedCount ?? this.plannedCount,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      xpEarned: xpEarned ?? this.xpEarned,
      avgReactionMs: avgReactionMs ?? this.avgReactionMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (wordbookIds.present) {
      map['wordbook_ids'] = Variable<String>(wordbookIds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (plannedCount.present) {
      map['planned_count'] = Variable<int>(plannedCount.value);
    }
    if (answeredCount.present) {
      map['answered_count'] = Variable<int>(answeredCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (xpEarned.present) {
      map['xp_earned'] = Variable<int>(xpEarned.value);
    }
    if (avgReactionMs.present) {
      map['avg_reaction_ms'] = Variable<int>(avgReactionMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('mode: $mode, ')
          ..write('wordbookIds: $wordbookIds, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('plannedCount: $plannedCount, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('xpEarned: $xpEarned, ')
          ..write('avgReactionMs: $avgReactionMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningLogsTable extends LearningLogs
    with TableInfo<$LearningLogsTable, LearningLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<int> partId = GeneratedColumn<int>(
    'part_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES word_parts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredTextMeta = const VerificationMeta(
    'answeredText',
  );
  @override
  late final GeneratedColumn<String> answeredText = GeneratedColumn<String>(
    'answered_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hintUsedMeta = const VerificationMeta(
    'hintUsed',
  );
  @override
  late final GeneratedColumn<int> hintUsed = GeneratedColumn<int>(
    'hint_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _replayCountMeta = const VerificationMeta(
    'replayCount',
  );
  @override
  late final GeneratedColumn<int> replayCount = GeneratedColumn<int>(
    'replay_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    sessionId,
    wordId,
    partId,
    mode,
    direction,
    isCorrect,
    grade,
    answeredText,
    hintUsed,
    replayCount,
    elapsedMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearningLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('answered_text')) {
      context.handle(
        _answeredTextMeta,
        answeredText.isAcceptableOrUnknown(
          data['answered_text']!,
          _answeredTextMeta,
        ),
      );
    }
    if (data.containsKey('hint_used')) {
      context.handle(
        _hintUsedMeta,
        hintUsed.isAcceptableOrUnknown(data['hint_used']!, _hintUsedMeta),
      );
    }
    if (data.containsKey('replay_count')) {
      context.handle(
        _replayCountMeta,
        replayCount.isAcceptableOrUnknown(
          data['replay_count']!,
          _replayCountMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      ),
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_id'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      )!,
      answeredText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answered_text'],
      ),
      hintUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hint_used'],
      )!,
      replayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replay_count'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $LearningLogsTable createAlias(String alias) {
    return $LearningLogsTable(attachedDatabase, alias);
  }
}

class LearningLog extends DataClass implements Insertable<LearningLog> {
  final int id;
  final int profileId;
  final String sessionId;

  /// 語のつくりモードでは null。
  final int? wordId;

  /// 語のつくりモードでのみ非 null。
  final int? partId;

  /// 学習モード（`StudyMode`）。
  final String mode;

  /// 出題方向（`StudyDirection`）。
  final String direction;
  final bool isCorrect;

  /// SM-2 に渡した grade（0〜5）。`-1` = 学習状態を更新しなかった（時間切れ等）。
  final int grade;

  /// 入力した文字列／選んだ選択肢。取り違え検出に使う。
  final String? answeredText;

  /// 開示したヒント文字数。
  final int hintUsed;

  /// 音声の再生回数。
  final int replayCount;

  /// 出題表示から解答確定までの時間（ミリ秒）。
  final int elapsedMs;
  final DateTime answeredAt;
  const LearningLog({
    required this.id,
    required this.profileId,
    required this.sessionId,
    this.wordId,
    this.partId,
    required this.mode,
    required this.direction,
    required this.isCorrect,
    required this.grade,
    this.answeredText,
    required this.hintUsed,
    required this.replayCount,
    required this.elapsedMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || wordId != null) {
      map['word_id'] = Variable<int>(wordId);
    }
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<int>(partId);
    }
    map['mode'] = Variable<String>(mode);
    map['direction'] = Variable<String>(direction);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['grade'] = Variable<int>(grade);
    if (!nullToAbsent || answeredText != null) {
      map['answered_text'] = Variable<String>(answeredText);
    }
    map['hint_used'] = Variable<int>(hintUsed);
    map['replay_count'] = Variable<int>(replayCount);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  LearningLogsCompanion toCompanion(bool nullToAbsent) {
    return LearningLogsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      sessionId: Value(sessionId),
      wordId: wordId == null && nullToAbsent
          ? const Value.absent()
          : Value(wordId),
      partId: partId == null && nullToAbsent
          ? const Value.absent()
          : Value(partId),
      mode: Value(mode),
      direction: Value(direction),
      isCorrect: Value(isCorrect),
      grade: Value(grade),
      answeredText: answeredText == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredText),
      hintUsed: Value(hintUsed),
      replayCount: Value(replayCount),
      elapsedMs: Value(elapsedMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory LearningLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningLog(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      wordId: serializer.fromJson<int?>(json['wordId']),
      partId: serializer.fromJson<int?>(json['partId']),
      mode: serializer.fromJson<String>(json['mode']),
      direction: serializer.fromJson<String>(json['direction']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      grade: serializer.fromJson<int>(json['grade']),
      answeredText: serializer.fromJson<String?>(json['answeredText']),
      hintUsed: serializer.fromJson<int>(json['hintUsed']),
      replayCount: serializer.fromJson<int>(json['replayCount']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'sessionId': serializer.toJson<String>(sessionId),
      'wordId': serializer.toJson<int?>(wordId),
      'partId': serializer.toJson<int?>(partId),
      'mode': serializer.toJson<String>(mode),
      'direction': serializer.toJson<String>(direction),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'grade': serializer.toJson<int>(grade),
      'answeredText': serializer.toJson<String?>(answeredText),
      'hintUsed': serializer.toJson<int>(hintUsed),
      'replayCount': serializer.toJson<int>(replayCount),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  LearningLog copyWith({
    int? id,
    int? profileId,
    String? sessionId,
    Value<int?> wordId = const Value.absent(),
    Value<int?> partId = const Value.absent(),
    String? mode,
    String? direction,
    bool? isCorrect,
    int? grade,
    Value<String?> answeredText = const Value.absent(),
    int? hintUsed,
    int? replayCount,
    int? elapsedMs,
    DateTime? answeredAt,
  }) => LearningLog(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    sessionId: sessionId ?? this.sessionId,
    wordId: wordId.present ? wordId.value : this.wordId,
    partId: partId.present ? partId.value : this.partId,
    mode: mode ?? this.mode,
    direction: direction ?? this.direction,
    isCorrect: isCorrect ?? this.isCorrect,
    grade: grade ?? this.grade,
    answeredText: answeredText.present ? answeredText.value : this.answeredText,
    hintUsed: hintUsed ?? this.hintUsed,
    replayCount: replayCount ?? this.replayCount,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  LearningLog copyWithCompanion(LearningLogsCompanion data) {
    return LearningLog(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      partId: data.partId.present ? data.partId.value : this.partId,
      mode: data.mode.present ? data.mode.value : this.mode,
      direction: data.direction.present ? data.direction.value : this.direction,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      grade: data.grade.present ? data.grade.value : this.grade,
      answeredText: data.answeredText.present
          ? data.answeredText.value
          : this.answeredText,
      hintUsed: data.hintUsed.present ? data.hintUsed.value : this.hintUsed,
      replayCount: data.replayCount.present
          ? data.replayCount.value
          : this.replayCount,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningLog(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('partId: $partId, ')
          ..write('mode: $mode, ')
          ..write('direction: $direction, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('grade: $grade, ')
          ..write('answeredText: $answeredText, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('replayCount: $replayCount, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    sessionId,
    wordId,
    partId,
    mode,
    direction,
    isCorrect,
    grade,
    answeredText,
    hintUsed,
    replayCount,
    elapsedMs,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningLog &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.sessionId == this.sessionId &&
          other.wordId == this.wordId &&
          other.partId == this.partId &&
          other.mode == this.mode &&
          other.direction == this.direction &&
          other.isCorrect == this.isCorrect &&
          other.grade == this.grade &&
          other.answeredText == this.answeredText &&
          other.hintUsed == this.hintUsed &&
          other.replayCount == this.replayCount &&
          other.elapsedMs == this.elapsedMs &&
          other.answeredAt == this.answeredAt);
}

class LearningLogsCompanion extends UpdateCompanion<LearningLog> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> sessionId;
  final Value<int?> wordId;
  final Value<int?> partId;
  final Value<String> mode;
  final Value<String> direction;
  final Value<bool> isCorrect;
  final Value<int> grade;
  final Value<String?> answeredText;
  final Value<int> hintUsed;
  final Value<int> replayCount;
  final Value<int> elapsedMs;
  final Value<DateTime> answeredAt;
  const LearningLogsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.partId = const Value.absent(),
    this.mode = const Value.absent(),
    this.direction = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.grade = const Value.absent(),
    this.answeredText = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.replayCount = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  LearningLogsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String sessionId,
    this.wordId = const Value.absent(),
    this.partId = const Value.absent(),
    required String mode,
    required String direction,
    required bool isCorrect,
    required int grade,
    this.answeredText = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.replayCount = const Value.absent(),
    required int elapsedMs,
    required DateTime answeredAt,
  }) : profileId = Value(profileId),
       sessionId = Value(sessionId),
       mode = Value(mode),
       direction = Value(direction),
       isCorrect = Value(isCorrect),
       grade = Value(grade),
       elapsedMs = Value(elapsedMs),
       answeredAt = Value(answeredAt);
  static Insertable<LearningLog> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? sessionId,
    Expression<int>? wordId,
    Expression<int>? partId,
    Expression<String>? mode,
    Expression<String>? direction,
    Expression<bool>? isCorrect,
    Expression<int>? grade,
    Expression<String>? answeredText,
    Expression<int>? hintUsed,
    Expression<int>? replayCount,
    Expression<int>? elapsedMs,
    Expression<DateTime>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (sessionId != null) 'session_id': sessionId,
      if (wordId != null) 'word_id': wordId,
      if (partId != null) 'part_id': partId,
      if (mode != null) 'mode': mode,
      if (direction != null) 'direction': direction,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (grade != null) 'grade': grade,
      if (answeredText != null) 'answered_text': answeredText,
      if (hintUsed != null) 'hint_used': hintUsed,
      if (replayCount != null) 'replay_count': replayCount,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  LearningLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<String>? sessionId,
    Value<int?>? wordId,
    Value<int?>? partId,
    Value<String>? mode,
    Value<String>? direction,
    Value<bool>? isCorrect,
    Value<int>? grade,
    Value<String?>? answeredText,
    Value<int>? hintUsed,
    Value<int>? replayCount,
    Value<int>? elapsedMs,
    Value<DateTime>? answeredAt,
  }) {
    return LearningLogsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      partId: partId ?? this.partId,
      mode: mode ?? this.mode,
      direction: direction ?? this.direction,
      isCorrect: isCorrect ?? this.isCorrect,
      grade: grade ?? this.grade,
      answeredText: answeredText ?? this.answeredText,
      hintUsed: hintUsed ?? this.hintUsed,
      replayCount: replayCount ?? this.replayCount,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<int>(partId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (answeredText.present) {
      map['answered_text'] = Variable<String>(answeredText.value);
    }
    if (hintUsed.present) {
      map['hint_used'] = Variable<int>(hintUsed.value);
    }
    if (replayCount.present) {
      map['replay_count'] = Variable<int>(replayCount.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningLogsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('partId: $partId, ')
          ..write('mode: $mode, ')
          ..write('direction: $direction, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('grade: $grade, ')
          ..write('answeredText: $answeredText, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('replayCount: $replayCount, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studyDateMeta = const VerificationMeta(
    'studyDate',
  );
  @override
  late final GeneratedColumn<String> studyDate = GeneratedColumn<String>(
    'study_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredCountMeta = const VerificationMeta(
    'answeredCount',
  );
  @override
  late final GeneratedColumn<int> answeredCount = GeneratedColumn<int>(
    'answered_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _studySecondsMeta = const VerificationMeta(
    'studySeconds',
  );
  @override
  late final GeneratedColumn<int> studySeconds = GeneratedColumn<int>(
    'study_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _goalCountMeta = const VerificationMeta(
    'goalCount',
  );
  @override
  late final GeneratedColumn<int> goalCount = GeneratedColumn<int>(
    'goal_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMetMeta = const VerificationMeta(
    'goalMet',
  );
  @override
  late final GeneratedColumn<bool> goalMet = GeneratedColumn<bool>(
    'goal_met',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_met" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    studyDate,
    answeredCount,
    correctCount,
    xp,
    studySeconds,
    goalCount,
    goalMet,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('study_date')) {
      context.handle(
        _studyDateMeta,
        studyDate.isAcceptableOrUnknown(data['study_date']!, _studyDateMeta),
      );
    } else if (isInserting) {
      context.missing(_studyDateMeta);
    }
    if (data.containsKey('answered_count')) {
      context.handle(
        _answeredCountMeta,
        answeredCount.isAcceptableOrUnknown(
          data['answered_count']!,
          _answeredCountMeta,
        ),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('study_seconds')) {
      context.handle(
        _studySecondsMeta,
        studySeconds.isAcceptableOrUnknown(
          data['study_seconds']!,
          _studySecondsMeta,
        ),
      );
    }
    if (data.containsKey('goal_count')) {
      context.handle(
        _goalCountMeta,
        goalCount.isAcceptableOrUnknown(data['goal_count']!, _goalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_goalCountMeta);
    }
    if (data.containsKey('goal_met')) {
      context.handle(
        _goalMetMeta,
        goalMet.isAcceptableOrUnknown(data['goal_met']!, _goalMetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, studyDate};
  @override
  DailyStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStat(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      studyDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_date'],
      )!,
      answeredCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_count'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      studySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_seconds'],
      )!,
      goalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_count'],
      )!,
      goalMet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_met'],
      )!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStat extends DataClass implements Insertable<DailyStat> {
  final int profileId;

  /// `YYYY-MM-DD`。学習日の境界（04:00）で決める（`studyDateOf`）。
  final String studyDate;
  final int answeredCount;
  final int correctCount;
  final int xp;
  final int studySeconds;

  /// その日に適用されていた目標（後から変えても過去を動かさない）。
  final int goalCount;

  /// 達成した時点で true。以後 false に戻さない。
  final bool goalMet;
  const DailyStat({
    required this.profileId,
    required this.studyDate,
    required this.answeredCount,
    required this.correctCount,
    required this.xp,
    required this.studySeconds,
    required this.goalCount,
    required this.goalMet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['study_date'] = Variable<String>(studyDate);
    map['answered_count'] = Variable<int>(answeredCount);
    map['correct_count'] = Variable<int>(correctCount);
    map['xp'] = Variable<int>(xp);
    map['study_seconds'] = Variable<int>(studySeconds);
    map['goal_count'] = Variable<int>(goalCount);
    map['goal_met'] = Variable<bool>(goalMet);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      profileId: Value(profileId),
      studyDate: Value(studyDate),
      answeredCount: Value(answeredCount),
      correctCount: Value(correctCount),
      xp: Value(xp),
      studySeconds: Value(studySeconds),
      goalCount: Value(goalCount),
      goalMet: Value(goalMet),
    );
  }

  factory DailyStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStat(
      profileId: serializer.fromJson<int>(json['profileId']),
      studyDate: serializer.fromJson<String>(json['studyDate']),
      answeredCount: serializer.fromJson<int>(json['answeredCount']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      xp: serializer.fromJson<int>(json['xp']),
      studySeconds: serializer.fromJson<int>(json['studySeconds']),
      goalCount: serializer.fromJson<int>(json['goalCount']),
      goalMet: serializer.fromJson<bool>(json['goalMet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'studyDate': serializer.toJson<String>(studyDate),
      'answeredCount': serializer.toJson<int>(answeredCount),
      'correctCount': serializer.toJson<int>(correctCount),
      'xp': serializer.toJson<int>(xp),
      'studySeconds': serializer.toJson<int>(studySeconds),
      'goalCount': serializer.toJson<int>(goalCount),
      'goalMet': serializer.toJson<bool>(goalMet),
    };
  }

  DailyStat copyWith({
    int? profileId,
    String? studyDate,
    int? answeredCount,
    int? correctCount,
    int? xp,
    int? studySeconds,
    int? goalCount,
    bool? goalMet,
  }) => DailyStat(
    profileId: profileId ?? this.profileId,
    studyDate: studyDate ?? this.studyDate,
    answeredCount: answeredCount ?? this.answeredCount,
    correctCount: correctCount ?? this.correctCount,
    xp: xp ?? this.xp,
    studySeconds: studySeconds ?? this.studySeconds,
    goalCount: goalCount ?? this.goalCount,
    goalMet: goalMet ?? this.goalMet,
  );
  DailyStat copyWithCompanion(DailyStatsCompanion data) {
    return DailyStat(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      studyDate: data.studyDate.present ? data.studyDate.value : this.studyDate,
      answeredCount: data.answeredCount.present
          ? data.answeredCount.value
          : this.answeredCount,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      xp: data.xp.present ? data.xp.value : this.xp,
      studySeconds: data.studySeconds.present
          ? data.studySeconds.value
          : this.studySeconds,
      goalCount: data.goalCount.present ? data.goalCount.value : this.goalCount,
      goalMet: data.goalMet.present ? data.goalMet.value : this.goalMet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStat(')
          ..write('profileId: $profileId, ')
          ..write('studyDate: $studyDate, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('xp: $xp, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('goalCount: $goalCount, ')
          ..write('goalMet: $goalMet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    studyDate,
    answeredCount,
    correctCount,
    xp,
    studySeconds,
    goalCount,
    goalMet,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStat &&
          other.profileId == this.profileId &&
          other.studyDate == this.studyDate &&
          other.answeredCount == this.answeredCount &&
          other.correctCount == this.correctCount &&
          other.xp == this.xp &&
          other.studySeconds == this.studySeconds &&
          other.goalCount == this.goalCount &&
          other.goalMet == this.goalMet);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStat> {
  final Value<int> profileId;
  final Value<String> studyDate;
  final Value<int> answeredCount;
  final Value<int> correctCount;
  final Value<int> xp;
  final Value<int> studySeconds;
  final Value<int> goalCount;
  final Value<bool> goalMet;
  final Value<int> rowid;
  const DailyStatsCompanion({
    this.profileId = const Value.absent(),
    this.studyDate = const Value.absent(),
    this.answeredCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.xp = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.goalCount = const Value.absent(),
    this.goalMet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    required int profileId,
    required String studyDate,
    this.answeredCount = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.xp = const Value.absent(),
    this.studySeconds = const Value.absent(),
    required int goalCount,
    this.goalMet = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       studyDate = Value(studyDate),
       goalCount = Value(goalCount);
  static Insertable<DailyStat> custom({
    Expression<int>? profileId,
    Expression<String>? studyDate,
    Expression<int>? answeredCount,
    Expression<int>? correctCount,
    Expression<int>? xp,
    Expression<int>? studySeconds,
    Expression<int>? goalCount,
    Expression<bool>? goalMet,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (studyDate != null) 'study_date': studyDate,
      if (answeredCount != null) 'answered_count': answeredCount,
      if (correctCount != null) 'correct_count': correctCount,
      if (xp != null) 'xp': xp,
      if (studySeconds != null) 'study_seconds': studySeconds,
      if (goalCount != null) 'goal_count': goalCount,
      if (goalMet != null) 'goal_met': goalMet,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStatsCompanion copyWith({
    Value<int>? profileId,
    Value<String>? studyDate,
    Value<int>? answeredCount,
    Value<int>? correctCount,
    Value<int>? xp,
    Value<int>? studySeconds,
    Value<int>? goalCount,
    Value<bool>? goalMet,
    Value<int>? rowid,
  }) {
    return DailyStatsCompanion(
      profileId: profileId ?? this.profileId,
      studyDate: studyDate ?? this.studyDate,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      xp: xp ?? this.xp,
      studySeconds: studySeconds ?? this.studySeconds,
      goalCount: goalCount ?? this.goalCount,
      goalMet: goalMet ?? this.goalMet,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (studyDate.present) {
      map['study_date'] = Variable<String>(studyDate.value);
    }
    if (answeredCount.present) {
      map['answered_count'] = Variable<int>(answeredCount.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (studySeconds.present) {
      map['study_seconds'] = Variable<int>(studySeconds.value);
    }
    if (goalCount.present) {
      map['goal_count'] = Variable<int>(goalCount.value);
    }
    if (goalMet.present) {
      map['goal_met'] = Variable<bool>(goalMet.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('studyDate: $studyDate, ')
          ..write('answeredCount: $answeredCount, ')
          ..write('correctCount: $correctCount, ')
          ..write('xp: $xp, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('goalCount: $goalCount, ')
          ..write('goalMet: $goalMet, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [profileId, code, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, code};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int profileId;

  /// 実績コード（例 `streak_7`、`mastered_100`）。
  final String code;
  final DateTime unlockedAt;
  const Achievement({
    required this.profileId,
    required this.code,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<int>(profileId);
    map['code'] = Variable<String>(code);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      profileId: Value(profileId),
      code: Value(code),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      profileId: serializer.fromJson<int>(json['profileId']),
      code: serializer.fromJson<String>(json['code']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<int>(profileId),
      'code': serializer.toJson<String>(code),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  Achievement copyWith({int? profileId, String? code, DateTime? unlockedAt}) =>
      Achievement(
        profileId: profileId ?? this.profileId,
        code: code ?? this.code,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      code: data.code.present ? data.code.value : this.code,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('profileId: $profileId, ')
          ..write('code: $code, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(profileId, code, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.profileId == this.profileId &&
          other.code == this.code &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> profileId;
  final Value<String> code;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.profileId = const Value.absent(),
    this.code = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required int profileId,
    required String code,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       code = Value(code),
       unlockedAt = Value(unlockedAt);
  static Insertable<Achievement> custom({
    Expression<int>? profileId,
    Expression<String>? code,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (code != null) 'code': code,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? profileId,
    Value<String>? code,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      profileId: profileId ?? this.profileId,
      code: code ?? this.code,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('code: $code, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocabSizeTestsTable extends VocabSizeTests
    with TableInfo<$VocabSizeTestsTable, VocabSizeTest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabSizeTestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedSizeMeta = const VerificationMeta(
    'estimatedSize',
  );
  @override
  late final GeneratedColumn<int> estimatedSize = GeneratedColumn<int>(
    'estimated_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _falseAlarmRateMeta = const VerificationMeta(
    'falseAlarmRate',
  );
  @override
  late final GeneratedColumn<double> falseAlarmRate = GeneratedColumn<double>(
    'false_alarm_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bandResultsMeta = const VerificationMeta(
    'bandResults',
  );
  @override
  late final GeneratedColumn<String> bandResults = GeneratedColumn<String>(
    'band_results',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _askedWordIdsMeta = const VerificationMeta(
    'askedWordIds',
  );
  @override
  late final GeneratedColumn<String> askedWordIds = GeneratedColumn<String>(
    'asked_word_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    takenAt,
    estimatedSize,
    falseAlarmRate,
    bandResults,
    askedWordIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocab_size_tests';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabSizeTest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('estimated_size')) {
      context.handle(
        _estimatedSizeMeta,
        estimatedSize.isAcceptableOrUnknown(
          data['estimated_size']!,
          _estimatedSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedSizeMeta);
    }
    if (data.containsKey('false_alarm_rate')) {
      context.handle(
        _falseAlarmRateMeta,
        falseAlarmRate.isAcceptableOrUnknown(
          data['false_alarm_rate']!,
          _falseAlarmRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_falseAlarmRateMeta);
    }
    if (data.containsKey('band_results')) {
      context.handle(
        _bandResultsMeta,
        bandResults.isAcceptableOrUnknown(
          data['band_results']!,
          _bandResultsMeta,
        ),
      );
    }
    if (data.containsKey('asked_word_ids')) {
      context.handle(
        _askedWordIdsMeta,
        askedWordIds.isAcceptableOrUnknown(
          data['asked_word_ids']!,
          _askedWordIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabSizeTest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabSizeTest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      estimatedSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_size'],
      )!,
      falseAlarmRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}false_alarm_rate'],
      )!,
      bandResults: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band_results'],
      )!,
      askedWordIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asked_word_ids'],
      )!,
    );
  }

  @override
  $VocabSizeTestsTable createAlias(String alias) {
    return $VocabSizeTestsTable(attachedDatabase, alias);
  }
}

class VocabSizeTest extends DataClass implements Insertable<VocabSizeTest> {
  final int id;
  final int profileId;
  final DateTime takenAt;

  /// 推定語彙数。
  final int estimatedSize;

  /// 擬似語に「わかる」と答えた率。
  final double falseAlarmRate;

  /// 帯ごとの補正済み正答率と出題数を JSON で。
  final String bandResults;

  /// 出題した実在語の id（次回の重複回避用）を JSON で。
  final String askedWordIds;
  const VocabSizeTest({
    required this.id,
    required this.profileId,
    required this.takenAt,
    required this.estimatedSize,
    required this.falseAlarmRate,
    required this.bandResults,
    required this.askedWordIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['estimated_size'] = Variable<int>(estimatedSize);
    map['false_alarm_rate'] = Variable<double>(falseAlarmRate);
    map['band_results'] = Variable<String>(bandResults);
    map['asked_word_ids'] = Variable<String>(askedWordIds);
    return map;
  }

  VocabSizeTestsCompanion toCompanion(bool nullToAbsent) {
    return VocabSizeTestsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      takenAt: Value(takenAt),
      estimatedSize: Value(estimatedSize),
      falseAlarmRate: Value(falseAlarmRate),
      bandResults: Value(bandResults),
      askedWordIds: Value(askedWordIds),
    );
  }

  factory VocabSizeTest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabSizeTest(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      estimatedSize: serializer.fromJson<int>(json['estimatedSize']),
      falseAlarmRate: serializer.fromJson<double>(json['falseAlarmRate']),
      bandResults: serializer.fromJson<String>(json['bandResults']),
      askedWordIds: serializer.fromJson<String>(json['askedWordIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'estimatedSize': serializer.toJson<int>(estimatedSize),
      'falseAlarmRate': serializer.toJson<double>(falseAlarmRate),
      'bandResults': serializer.toJson<String>(bandResults),
      'askedWordIds': serializer.toJson<String>(askedWordIds),
    };
  }

  VocabSizeTest copyWith({
    int? id,
    int? profileId,
    DateTime? takenAt,
    int? estimatedSize,
    double? falseAlarmRate,
    String? bandResults,
    String? askedWordIds,
  }) => VocabSizeTest(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    takenAt: takenAt ?? this.takenAt,
    estimatedSize: estimatedSize ?? this.estimatedSize,
    falseAlarmRate: falseAlarmRate ?? this.falseAlarmRate,
    bandResults: bandResults ?? this.bandResults,
    askedWordIds: askedWordIds ?? this.askedWordIds,
  );
  VocabSizeTest copyWithCompanion(VocabSizeTestsCompanion data) {
    return VocabSizeTest(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      estimatedSize: data.estimatedSize.present
          ? data.estimatedSize.value
          : this.estimatedSize,
      falseAlarmRate: data.falseAlarmRate.present
          ? data.falseAlarmRate.value
          : this.falseAlarmRate,
      bandResults: data.bandResults.present
          ? data.bandResults.value
          : this.bandResults,
      askedWordIds: data.askedWordIds.present
          ? data.askedWordIds.value
          : this.askedWordIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabSizeTest(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('takenAt: $takenAt, ')
          ..write('estimatedSize: $estimatedSize, ')
          ..write('falseAlarmRate: $falseAlarmRate, ')
          ..write('bandResults: $bandResults, ')
          ..write('askedWordIds: $askedWordIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    takenAt,
    estimatedSize,
    falseAlarmRate,
    bandResults,
    askedWordIds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabSizeTest &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.takenAt == this.takenAt &&
          other.estimatedSize == this.estimatedSize &&
          other.falseAlarmRate == this.falseAlarmRate &&
          other.bandResults == this.bandResults &&
          other.askedWordIds == this.askedWordIds);
}

class VocabSizeTestsCompanion extends UpdateCompanion<VocabSizeTest> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> takenAt;
  final Value<int> estimatedSize;
  final Value<double> falseAlarmRate;
  final Value<String> bandResults;
  final Value<String> askedWordIds;
  const VocabSizeTestsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.estimatedSize = const Value.absent(),
    this.falseAlarmRate = const Value.absent(),
    this.bandResults = const Value.absent(),
    this.askedWordIds = const Value.absent(),
  });
  VocabSizeTestsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime takenAt,
    required int estimatedSize,
    required double falseAlarmRate,
    this.bandResults = const Value.absent(),
    this.askedWordIds = const Value.absent(),
  }) : profileId = Value(profileId),
       takenAt = Value(takenAt),
       estimatedSize = Value(estimatedSize),
       falseAlarmRate = Value(falseAlarmRate);
  static Insertable<VocabSizeTest> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? takenAt,
    Expression<int>? estimatedSize,
    Expression<double>? falseAlarmRate,
    Expression<String>? bandResults,
    Expression<String>? askedWordIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (takenAt != null) 'taken_at': takenAt,
      if (estimatedSize != null) 'estimated_size': estimatedSize,
      if (falseAlarmRate != null) 'false_alarm_rate': falseAlarmRate,
      if (bandResults != null) 'band_results': bandResults,
      if (askedWordIds != null) 'asked_word_ids': askedWordIds,
    });
  }

  VocabSizeTestsCompanion copyWith({
    Value<int>? id,
    Value<int>? profileId,
    Value<DateTime>? takenAt,
    Value<int>? estimatedSize,
    Value<double>? falseAlarmRate,
    Value<String>? bandResults,
    Value<String>? askedWordIds,
  }) {
    return VocabSizeTestsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      takenAt: takenAt ?? this.takenAt,
      estimatedSize: estimatedSize ?? this.estimatedSize,
      falseAlarmRate: falseAlarmRate ?? this.falseAlarmRate,
      bandResults: bandResults ?? this.bandResults,
      askedWordIds: askedWordIds ?? this.askedWordIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (estimatedSize.present) {
      map['estimated_size'] = Variable<int>(estimatedSize.value);
    }
    if (falseAlarmRate.present) {
      map['false_alarm_rate'] = Variable<double>(falseAlarmRate.value);
    }
    if (bandResults.present) {
      map['band_results'] = Variable<String>(bandResults.value);
    }
    if (askedWordIds.present) {
      map['asked_word_ids'] = Variable<String>(askedWordIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabSizeTestsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('takenAt: $takenAt, ')
          ..write('estimatedSize: $estimatedSize, ')
          ..write('falseAlarmRate: $falseAlarmRate, ')
          ..write('bandResults: $bandResults, ')
          ..write('askedWordIds: $askedWordIds')
          ..write(')'))
        .toString();
  }
}

class $AudioPacksTable extends AudioPacks
    with TableInfo<$AudioPacksTable, AudioPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    name,
    source,
    lang,
    note,
    entryCount,
    installedAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioPack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      entryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_count'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AudioPacksTable createAlias(String alias) {
    return $AudioPacksTable(attachedDatabase, alias);
  }
}

class AudioPack extends DataClass implements Insertable<AudioPack> {
  final int id;

  /// 識別子（例 `jhs_en_us_v1`）。
  final String packId;
  final String name;

  /// 由来（`AudioPackSource`: bundled / imported）。
  final String source;

  /// 収録言語（`SpeechLang`: en / ja）。
  final String lang;
  final String? note;

  /// 収録音声数。
  final int entryCount;
  final DateTime installedAt;

  /// 優先順位（同じ語が複数パックにあるとき小さいものを使う）。
  final int sortOrder;
  const AudioPack({
    required this.id,
    required this.packId,
    required this.name,
    required this.source,
    required this.lang,
    this.note,
    required this.entryCount,
    required this.installedAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pack_id'] = Variable<String>(packId);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['lang'] = Variable<String>(lang);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['entry_count'] = Variable<int>(entryCount);
    map['installed_at'] = Variable<DateTime>(installedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AudioPacksCompanion toCompanion(bool nullToAbsent) {
    return AudioPacksCompanion(
      id: Value(id),
      packId: Value(packId),
      name: Value(name),
      source: Value(source),
      lang: Value(lang),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      entryCount: Value(entryCount),
      installedAt: Value(installedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory AudioPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioPack(
      id: serializer.fromJson<int>(json['id']),
      packId: serializer.fromJson<String>(json['packId']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      lang: serializer.fromJson<String>(json['lang']),
      note: serializer.fromJson<String?>(json['note']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packId': serializer.toJson<String>(packId),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'lang': serializer.toJson<String>(lang),
      'note': serializer.toJson<String?>(note),
      'entryCount': serializer.toJson<int>(entryCount),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AudioPack copyWith({
    int? id,
    String? packId,
    String? name,
    String? source,
    String? lang,
    Value<String?> note = const Value.absent(),
    int? entryCount,
    DateTime? installedAt,
    int? sortOrder,
  }) => AudioPack(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    name: name ?? this.name,
    source: source ?? this.source,
    lang: lang ?? this.lang,
    note: note.present ? note.value : this.note,
    entryCount: entryCount ?? this.entryCount,
    installedAt: installedAt ?? this.installedAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AudioPack copyWithCompanion(AudioPacksCompanion data) {
    return AudioPack(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      lang: data.lang.present ? data.lang.value : this.lang,
      note: data.note.present ? data.note.value : this.note,
      entryCount: data.entryCount.present
          ? data.entryCount.value
          : this.entryCount,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioPack(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('lang: $lang, ')
          ..write('note: $note, ')
          ..write('entryCount: $entryCount, ')
          ..write('installedAt: $installedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packId,
    name,
    source,
    lang,
    note,
    entryCount,
    installedAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioPack &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.name == this.name &&
          other.source == this.source &&
          other.lang == this.lang &&
          other.note == this.note &&
          other.entryCount == this.entryCount &&
          other.installedAt == this.installedAt &&
          other.sortOrder == this.sortOrder);
}

class AudioPacksCompanion extends UpdateCompanion<AudioPack> {
  final Value<int> id;
  final Value<String> packId;
  final Value<String> name;
  final Value<String> source;
  final Value<String> lang;
  final Value<String?> note;
  final Value<int> entryCount;
  final Value<DateTime> installedAt;
  final Value<int> sortOrder;
  const AudioPacksCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.lang = const Value.absent(),
    this.note = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  AudioPacksCompanion.insert({
    this.id = const Value.absent(),
    required String packId,
    required String name,
    required String source,
    required String lang,
    this.note = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : packId = Value(packId),
       name = Value(name),
       source = Value(source),
       lang = Value(lang);
  static Insertable<AudioPack> custom({
    Expression<int>? id,
    Expression<String>? packId,
    Expression<String>? name,
    Expression<String>? source,
    Expression<String>? lang,
    Expression<String>? note,
    Expression<int>? entryCount,
    Expression<DateTime>? installedAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (lang != null) 'lang': lang,
      if (note != null) 'note': note,
      if (entryCount != null) 'entry_count': entryCount,
      if (installedAt != null) 'installed_at': installedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  AudioPacksCompanion copyWith({
    Value<int>? id,
    Value<String>? packId,
    Value<String>? name,
    Value<String>? source,
    Value<String>? lang,
    Value<String?>? note,
    Value<int>? entryCount,
    Value<DateTime>? installedAt,
    Value<int>? sortOrder,
  }) {
    return AudioPacksCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      source: source ?? this.source,
      lang: lang ?? this.lang,
      note: note ?? this.note,
      entryCount: entryCount ?? this.entryCount,
      installedAt: installedAt ?? this.installedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioPacksCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('lang: $lang, ')
          ..write('note: $note, ')
          ..write('entryCount: $entryCount, ')
          ..write('installedAt: $installedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WordAudiosTable extends WordAudios
    with TableInfo<$WordAudiosTable, WordAudio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordAudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<int> packId = GeneratedColumn<int>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_packs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, wordId, packId, lang, filePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_audios';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordAudio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordAudio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordAudio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
    );
  }

  @override
  $WordAudiosTable createAlias(String alias) {
    return $WordAudiosTable(attachedDatabase, alias);
  }
}

class WordAudio extends DataClass implements Insertable<WordAudio> {
  final int id;
  final int wordId;
  final int packId;

  /// `SpeechLang`（en / ja）。
  final String lang;

  /// `source = bundled` はアセットパス、`imported` は保存先の相対パス。
  final String filePath;
  const WordAudio({
    required this.id,
    required this.wordId,
    required this.packId,
    required this.lang,
    required this.filePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word_id'] = Variable<int>(wordId);
    map['pack_id'] = Variable<int>(packId);
    map['lang'] = Variable<String>(lang);
    map['file_path'] = Variable<String>(filePath);
    return map;
  }

  WordAudiosCompanion toCompanion(bool nullToAbsent) {
    return WordAudiosCompanion(
      id: Value(id),
      wordId: Value(wordId),
      packId: Value(packId),
      lang: Value(lang),
      filePath: Value(filePath),
    );
  }

  factory WordAudio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordAudio(
      id: serializer.fromJson<int>(json['id']),
      wordId: serializer.fromJson<int>(json['wordId']),
      packId: serializer.fromJson<int>(json['packId']),
      lang: serializer.fromJson<String>(json['lang']),
      filePath: serializer.fromJson<String>(json['filePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wordId': serializer.toJson<int>(wordId),
      'packId': serializer.toJson<int>(packId),
      'lang': serializer.toJson<String>(lang),
      'filePath': serializer.toJson<String>(filePath),
    };
  }

  WordAudio copyWith({
    int? id,
    int? wordId,
    int? packId,
    String? lang,
    String? filePath,
  }) => WordAudio(
    id: id ?? this.id,
    wordId: wordId ?? this.wordId,
    packId: packId ?? this.packId,
    lang: lang ?? this.lang,
    filePath: filePath ?? this.filePath,
  );
  WordAudio copyWithCompanion(WordAudiosCompanion data) {
    return WordAudio(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      packId: data.packId.present ? data.packId.value : this.packId,
      lang: data.lang.present ? data.lang.value : this.lang,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordAudio(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('packId: $packId, ')
          ..write('lang: $lang, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, wordId, packId, lang, filePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordAudio &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.packId == this.packId &&
          other.lang == this.lang &&
          other.filePath == this.filePath);
}

class WordAudiosCompanion extends UpdateCompanion<WordAudio> {
  final Value<int> id;
  final Value<int> wordId;
  final Value<int> packId;
  final Value<String> lang;
  final Value<String> filePath;
  const WordAudiosCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.packId = const Value.absent(),
    this.lang = const Value.absent(),
    this.filePath = const Value.absent(),
  });
  WordAudiosCompanion.insert({
    this.id = const Value.absent(),
    required int wordId,
    required int packId,
    required String lang,
    required String filePath,
  }) : wordId = Value(wordId),
       packId = Value(packId),
       lang = Value(lang),
       filePath = Value(filePath);
  static Insertable<WordAudio> custom({
    Expression<int>? id,
    Expression<int>? wordId,
    Expression<int>? packId,
    Expression<String>? lang,
    Expression<String>? filePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (packId != null) 'pack_id': packId,
      if (lang != null) 'lang': lang,
      if (filePath != null) 'file_path': filePath,
    });
  }

  WordAudiosCompanion copyWith({
    Value<int>? id,
    Value<int>? wordId,
    Value<int>? packId,
    Value<String>? lang,
    Value<String>? filePath,
  }) {
    return WordAudiosCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      packId: packId ?? this.packId,
      lang: lang ?? this.lang,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<int>(packId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordAudiosCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('packId: $packId, ')
          ..write('lang: $lang, ')
          ..write('filePath: $filePath')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $WordFamiliesTable wordFamilies = $WordFamiliesTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordExamplesTable wordExamples = $WordExamplesTable(this);
  late final $WordbooksTable wordbooks = $WordbooksTable(this);
  late final $WordbookEntriesTable wordbookEntries = $WordbookEntriesTable(
    this,
  );
  late final $WordPartsTable wordParts = $WordPartsTable(this);
  late final $WordPartLinksTable wordPartLinks = $WordPartLinksTable(this);
  late final $WordReviewsTable wordReviews = $WordReviewsTable(this);
  late final $PartReviewsTable partReviews = $PartReviewsTable(this);
  late final $ResolvedConfusionsTable resolvedConfusions =
      $ResolvedConfusionsTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $LearningLogsTable learningLogs = $LearningLogsTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $VocabSizeTestsTable vocabSizeTests = $VocabSizeTestsTable(this);
  late final $AudioPacksTable audioPacks = $AudioPacksTable(this);
  late final $WordAudiosTable wordAudios = $WordAudiosTable(this);
  late final Index wordFamiliesBaseForm = Index(
    'word_families_base_form',
    'CREATE UNIQUE INDEX word_families_base_form ON word_families (base_form)',
  );
  late final Index wordsSharedUnique = Index(
    'words_shared_unique',
    'CREATE UNIQUE INDEX words_shared_unique ON words (headword, part_of_speech) WHERE owner_profile_id IS NULL',
  );
  late final Index wordsOwnedUnique = Index(
    'words_owned_unique',
    'CREATE UNIQUE INDEX words_owned_unique ON words (headword, part_of_speech, owner_profile_id) WHERE owner_profile_id IS NOT NULL',
  );
  late final Index wordsHeadword = Index(
    'words_headword',
    'CREATE INDEX words_headword ON words (headword)',
  );
  late final Index wordsOwnerProfileId = Index(
    'words_owner_profile_id',
    'CREATE INDEX words_owner_profile_id ON words (owner_profile_id)',
  );
  late final Index wordsFamilyId = Index(
    'words_family_id',
    'CREATE INDEX words_family_id ON words (family_id)',
  );
  late final Index wordsPresetId = Index(
    'words_preset_id',
    'CREATE INDEX words_preset_id ON words (preset_id)',
  );
  late final Index wordExamplesSourceUnique = Index(
    'word_examples_source_unique',
    'CREATE UNIQUE INDEX word_examples_source_unique ON word_examples (word_id, source_preset_id) WHERE source_preset_id IS NOT NULL',
  );
  late final Index wordExamplesUserUnique = Index(
    'word_examples_user_unique',
    'CREATE UNIQUE INDEX word_examples_user_unique ON word_examples (word_id) WHERE source_preset_id IS NULL',
  );
  late final Index wordExamplesWordId = Index(
    'word_examples_word_id',
    'CREATE INDEX word_examples_word_id ON word_examples (word_id)',
  );
  late final Index wordbooksPresetId = Index(
    'wordbooks_preset_id',
    'CREATE UNIQUE INDEX wordbooks_preset_id ON wordbooks (preset_id)',
  );
  late final Index wordbookEntriesWordId = Index(
    'wordbook_entries_word_id',
    'CREATE INDEX wordbook_entries_word_id ON wordbook_entries (word_id)',
  );
  late final Index wordPartsFormType = Index(
    'word_parts_form_type',
    'CREATE UNIQUE INDEX word_parts_form_type ON word_parts (form, type)',
  );
  late final Index wordPartLinksPartId = Index(
    'word_part_links_part_id',
    'CREATE INDEX word_part_links_part_id ON word_part_links (part_id)',
  );
  late final Index wordReviewsProfileDue = Index(
    'word_reviews_profile_due',
    'CREATE INDEX word_reviews_profile_due ON word_reviews (profile_id, due_at)',
  );
  late final Index wordReviewsProfileMastery = Index(
    'word_reviews_profile_mastery',
    'CREATE INDEX word_reviews_profile_mastery ON word_reviews (profile_id, mastery_level)',
  );
  late final Index partReviewsProfileDue = Index(
    'part_reviews_profile_due',
    'CREATE INDEX part_reviews_profile_due ON part_reviews (profile_id, due_at)',
  );
  late final Index studySessionsProfileStarted = Index(
    'study_sessions_profile_started',
    'CREATE INDEX study_sessions_profile_started ON study_sessions (profile_id, started_at)',
  );
  late final Index learningLogsProfileAnswered = Index(
    'learning_logs_profile_answered',
    'CREATE INDEX learning_logs_profile_answered ON learning_logs (profile_id, answered_at)',
  );
  late final Index learningLogsSessionId = Index(
    'learning_logs_session_id',
    'CREATE INDEX learning_logs_session_id ON learning_logs (session_id)',
  );
  late final Index learningLogsWordId = Index(
    'learning_logs_word_id',
    'CREATE INDEX learning_logs_word_id ON learning_logs (word_id)',
  );
  late final Index vocabSizeTestsProfileTaken = Index(
    'vocab_size_tests_profile_taken',
    'CREATE INDEX vocab_size_tests_profile_taken ON vocab_size_tests (profile_id, taken_at)',
  );
  late final Index audioPacksPackId = Index(
    'audio_packs_pack_id',
    'CREATE UNIQUE INDEX audio_packs_pack_id ON audio_packs (pack_id)',
  );
  late final Index wordAudiosWordLang = Index(
    'word_audios_word_lang',
    'CREATE INDEX word_audios_word_lang ON word_audios (word_id, lang)',
  );
  late final Index wordAudiosWordPackLang = Index(
    'word_audios_word_pack_lang',
    'CREATE UNIQUE INDEX word_audios_word_pack_lang ON word_audios (word_id, pack_id, lang)',
  );
  late final ProfileDao profileDao = ProfileDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    wordFamilies,
    words,
    wordExamples,
    wordbooks,
    wordbookEntries,
    wordParts,
    wordPartLinks,
    wordReviews,
    partReviews,
    resolvedConfusions,
    studySessions,
    learningLogs,
    dailyStats,
    achievements,
    vocabSizeTests,
    audioPacks,
    wordAudios,
    wordFamiliesBaseForm,
    wordsSharedUnique,
    wordsOwnedUnique,
    wordsHeadword,
    wordsOwnerProfileId,
    wordsFamilyId,
    wordsPresetId,
    wordExamplesSourceUnique,
    wordExamplesUserUnique,
    wordExamplesWordId,
    wordbooksPresetId,
    wordbookEntriesWordId,
    wordPartsFormType,
    wordPartLinksPartId,
    wordReviewsProfileDue,
    wordReviewsProfileMastery,
    partReviewsProfileDue,
    studySessionsProfileStarted,
    learningLogsProfileAnswered,
    learningLogsSessionId,
    learningLogsWordId,
    vocabSizeTestsProfileTaken,
    audioPacksPackId,
    wordAudiosWordLang,
    wordAudiosWordPackLang,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_examples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wordbooks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wordbooks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wordbook_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wordbook_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_part_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_part_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('part_reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('part_reviews', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resolved_confusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resolved_confusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('resolved_confusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'word_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('learning_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('daily_stats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('achievements', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'profiles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vocab_size_tests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_audios', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audio_packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_audios', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> emoji,
      required int colorSeed,
      Value<String> palette,
      Value<String> textScale,
      Value<String> density,
      Value<String> dictViewMode,
      Value<String> dictGridColumns,
      Value<bool> searchExamples,
      Value<int> dailyGoal,
      Value<int> sessionSize,
      Value<String> keyboardLayout,
      Value<bool> autoNextOnCorrect,
      Value<String> flashcardMode,
      Value<int> flashcardSeconds,
      Value<String> choiceDirection,
      Value<int> speedLimitMs,
      Value<String> selectedWordbookIds,
      Value<String> audioSource,
      Value<String> audioPackIds,
      Value<String> ttsEnVoice,
      Value<String> ttsJaVoice,
      Value<double> ttsRate,
      Value<double> ttsPitch,
      Value<bool> reminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> colorSeed,
      Value<String> palette,
      Value<String> textScale,
      Value<String> density,
      Value<String> dictViewMode,
      Value<String> dictGridColumns,
      Value<bool> searchExamples,
      Value<int> dailyGoal,
      Value<int> sessionSize,
      Value<String> keyboardLayout,
      Value<bool> autoNextOnCorrect,
      Value<String> flashcardMode,
      Value<int> flashcardSeconds,
      Value<String> choiceDirection,
      Value<int> speedLimitMs,
      Value<String> selectedWordbookIds,
      Value<String> audioSource,
      Value<String> audioPackIds,
      Value<String> ttsEnVoice,
      Value<String> ttsJaVoice,
      Value<double> ttsRate,
      Value<double> ttsPitch,
      Value<bool> reminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: 'profiles__id__words__owner_profile_id',
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.ownerProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordbooksTable, List<Wordbook>>
  _wordbooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordbooks,
    aliasName: 'profiles__id__wordbooks__owner_profile_id',
  );

  $$WordbooksTableProcessedTableManager get wordbooksRefs {
    final manager = $$WordbooksTableTableManager(
      $_db,
      $_db.wordbooks,
    ).filter((f) => f.ownerProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordbooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordReviewsTable, List<WordReview>>
  _wordReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordReviews,
    aliasName: 'profiles__id__word_reviews__profile_id',
  );

  $$WordReviewsTableProcessedTableManager get wordReviewsRefs {
    final manager = $$WordReviewsTableTableManager(
      $_db,
      $_db.wordReviews,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PartReviewsTable, List<PartReview>>
  _partReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partReviews,
    aliasName: 'profiles__id__part_reviews__profile_id',
  );

  $$PartReviewsTableProcessedTableManager get partReviewsRefs {
    final manager = $$PartReviewsTableTableManager(
      $_db,
      $_db.partReviews,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResolvedConfusionsTable, List<ResolvedConfusion>>
  _resolvedConfusionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resolvedConfusions,
        aliasName: 'profiles__id__resolved_confusions__profile_id',
      );

  $$ResolvedConfusionsTableProcessedTableManager get resolvedConfusionsRefs {
    final manager = $$ResolvedConfusionsTableTableManager(
      $_db,
      $_db.resolvedConfusions,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resolvedConfusionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudySessionsTable, List<StudySession>>
  _studySessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studySessions,
    aliasName: 'profiles__id__study_sessions__profile_id',
  );

  $$StudySessionsTableProcessedTableManager get studySessionsRefs {
    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_studySessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LearningLogsTable, List<LearningLog>>
  _learningLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.learningLogs,
    aliasName: 'profiles__id__learning_logs__profile_id',
  );

  $$LearningLogsTableProcessedTableManager get learningLogsRefs {
    final manager = $$LearningLogsTableTableManager(
      $_db,
      $_db.learningLogs,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_learningLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyStatsTable, List<DailyStat>>
  _dailyStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyStats,
    aliasName: 'profiles__id__daily_stats__profile_id',
  );

  $$DailyStatsTableProcessedTableManager get dailyStatsRefs {
    final manager = $$DailyStatsTableTableManager(
      $_db,
      $_db.dailyStats,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dailyStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AchievementsTable, List<Achievement>>
  _achievementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.achievements,
    aliasName: 'profiles__id__achievements__profile_id',
  );

  $$AchievementsTableProcessedTableManager get achievementsRefs {
    final manager = $$AchievementsTableTableManager(
      $_db,
      $_db.achievements,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_achievementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VocabSizeTestsTable, List<VocabSizeTest>>
  _vocabSizeTestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vocabSizeTests,
    aliasName: 'profiles__id__vocab_size_tests__profile_id',
  );

  $$VocabSizeTestsTableProcessedTableManager get vocabSizeTestsRefs {
    final manager = $$VocabSizeTestsTableTableManager(
      $_db,
      $_db.vocabSizeTests,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vocabSizeTestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get palette => $composableBuilder(
    column: $table.palette,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textScale => $composableBuilder(
    column: $table.textScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dictViewMode => $composableBuilder(
    column: $table.dictViewMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dictGridColumns => $composableBuilder(
    column: $table.dictGridColumns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get searchExamples => $composableBuilder(
    column: $table.searchExamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionSize => $composableBuilder(
    column: $table.sessionSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyboardLayout => $composableBuilder(
    column: $table.keyboardLayout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoNextOnCorrect => $composableBuilder(
    column: $table.autoNextOnCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flashcardMode => $composableBuilder(
    column: $table.flashcardMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flashcardSeconds => $composableBuilder(
    column: $table.flashcardSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choiceDirection => $composableBuilder(
    column: $table.choiceDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get speedLimitMs => $composableBuilder(
    column: $table.speedLimitMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedWordbookIds => $composableBuilder(
    column: $table.selectedWordbookIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSource => $composableBuilder(
    column: $table.audioSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPackIds => $composableBuilder(
    column: $table.audioPackIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsEnVoice => $composableBuilder(
    column: $table.ttsEnVoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ttsJaVoice => $composableBuilder(
    column: $table.ttsJaVoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ttsRate => $composableBuilder(
    column: $table.ttsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ttsPitch => $composableBuilder(
    column: $table.ttsPitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.ownerProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordbooksRefs(
    Expression<bool> Function($$WordbooksTableFilterComposer f) f,
  ) {
    final $$WordbooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbooks,
      getReferencedColumn: (t) => t.ownerProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbooksTableFilterComposer(
            $db: $db,
            $table: $db.wordbooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordReviewsRefs(
    Expression<bool> Function($$WordReviewsTableFilterComposer f) f,
  ) {
    final $$WordReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordReviews,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordReviewsTableFilterComposer(
            $db: $db,
            $table: $db.wordReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partReviewsRefs(
    Expression<bool> Function($$PartReviewsTableFilterComposer f) f,
  ) {
    final $$PartReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partReviews,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartReviewsTableFilterComposer(
            $db: $db,
            $table: $db.partReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resolvedConfusionsRefs(
    Expression<bool> Function($$ResolvedConfusionsTableFilterComposer f) f,
  ) {
    final $$ResolvedConfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resolvedConfusions,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResolvedConfusionsTableFilterComposer(
            $db: $db,
            $table: $db.resolvedConfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studySessionsRefs(
    Expression<bool> Function($$StudySessionsTableFilterComposer f) f,
  ) {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> learningLogsRefs(
    Expression<bool> Function($$LearningLogsTableFilterComposer f) f,
  ) {
    final $$LearningLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableFilterComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyStatsRefs(
    Expression<bool> Function($$DailyStatsTableFilterComposer f) f,
  ) {
    final $$DailyStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyStats,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyStatsTableFilterComposer(
            $db: $db,
            $table: $db.dailyStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> achievementsRefs(
    Expression<bool> Function($$AchievementsTableFilterComposer f) f,
  ) {
    final $$AchievementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableFilterComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vocabSizeTestsRefs(
    Expression<bool> Function($$VocabSizeTestsTableFilterComposer f) f,
  ) {
    final $$VocabSizeTestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vocabSizeTests,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabSizeTestsTableFilterComposer(
            $db: $db,
            $table: $db.vocabSizeTests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get palette => $composableBuilder(
    column: $table.palette,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textScale => $composableBuilder(
    column: $table.textScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get density => $composableBuilder(
    column: $table.density,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dictViewMode => $composableBuilder(
    column: $table.dictViewMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dictGridColumns => $composableBuilder(
    column: $table.dictGridColumns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get searchExamples => $composableBuilder(
    column: $table.searchExamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyGoal => $composableBuilder(
    column: $table.dailyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionSize => $composableBuilder(
    column: $table.sessionSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyboardLayout => $composableBuilder(
    column: $table.keyboardLayout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoNextOnCorrect => $composableBuilder(
    column: $table.autoNextOnCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flashcardMode => $composableBuilder(
    column: $table.flashcardMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flashcardSeconds => $composableBuilder(
    column: $table.flashcardSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choiceDirection => $composableBuilder(
    column: $table.choiceDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get speedLimitMs => $composableBuilder(
    column: $table.speedLimitMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedWordbookIds => $composableBuilder(
    column: $table.selectedWordbookIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSource => $composableBuilder(
    column: $table.audioSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPackIds => $composableBuilder(
    column: $table.audioPackIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsEnVoice => $composableBuilder(
    column: $table.ttsEnVoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ttsJaVoice => $composableBuilder(
    column: $table.ttsJaVoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ttsRate => $composableBuilder(
    column: $table.ttsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ttsPitch => $composableBuilder(
    column: $table.ttsPitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get colorSeed =>
      $composableBuilder(column: $table.colorSeed, builder: (column) => column);

  GeneratedColumn<String> get palette =>
      $composableBuilder(column: $table.palette, builder: (column) => column);

  GeneratedColumn<String> get textScale =>
      $composableBuilder(column: $table.textScale, builder: (column) => column);

  GeneratedColumn<String> get density =>
      $composableBuilder(column: $table.density, builder: (column) => column);

  GeneratedColumn<String> get dictViewMode => $composableBuilder(
    column: $table.dictViewMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dictGridColumns => $composableBuilder(
    column: $table.dictGridColumns,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get searchExamples => $composableBuilder(
    column: $table.searchExamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyGoal =>
      $composableBuilder(column: $table.dailyGoal, builder: (column) => column);

  GeneratedColumn<int> get sessionSize => $composableBuilder(
    column: $table.sessionSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keyboardLayout => $composableBuilder(
    column: $table.keyboardLayout,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoNextOnCorrect => $composableBuilder(
    column: $table.autoNextOnCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flashcardMode => $composableBuilder(
    column: $table.flashcardMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flashcardSeconds => $composableBuilder(
    column: $table.flashcardSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get choiceDirection => $composableBuilder(
    column: $table.choiceDirection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get speedLimitMs => $composableBuilder(
    column: $table.speedLimitMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedWordbookIds => $composableBuilder(
    column: $table.selectedWordbookIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioSource => $composableBuilder(
    column: $table.audioSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPackIds => $composableBuilder(
    column: $table.audioPackIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ttsEnVoice => $composableBuilder(
    column: $table.ttsEnVoice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ttsJaVoice => $composableBuilder(
    column: $table.ttsJaVoice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ttsRate =>
      $composableBuilder(column: $table.ttsRate, builder: (column) => column);

  GeneratedColumn<double> get ttsPitch =>
      $composableBuilder(column: $table.ttsPitch, builder: (column) => column);

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.ownerProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordbooksRefs<T extends Object>(
    Expression<T> Function($$WordbooksTableAnnotationComposer a) f,
  ) {
    final $$WordbooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbooks,
      getReferencedColumn: (t) => t.ownerProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordbooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordReviewsRefs<T extends Object>(
    Expression<T> Function($$WordReviewsTableAnnotationComposer a) f,
  ) {
    final $$WordReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordReviews,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partReviewsRefs<T extends Object>(
    Expression<T> Function($$PartReviewsTableAnnotationComposer a) f,
  ) {
    final $$PartReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partReviews,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.partReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resolvedConfusionsRefs<T extends Object>(
    Expression<T> Function($$ResolvedConfusionsTableAnnotationComposer a) f,
  ) {
    final $$ResolvedConfusionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.resolvedConfusions,
          getReferencedColumn: (t) => t.profileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ResolvedConfusionsTableAnnotationComposer(
                $db: $db,
                $table: $db.resolvedConfusions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studySessionsRefs<T extends Object>(
    Expression<T> Function($$StudySessionsTableAnnotationComposer a) f,
  ) {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> learningLogsRefs<T extends Object>(
    Expression<T> Function($$LearningLogsTableAnnotationComposer a) f,
  ) {
    final $$LearningLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailyStatsRefs<T extends Object>(
    Expression<T> Function($$DailyStatsTableAnnotationComposer a) f,
  ) {
    final $$DailyStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyStats,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> achievementsRefs<T extends Object>(
    Expression<T> Function($$AchievementsTableAnnotationComposer a) f,
  ) {
    final $$AchievementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.achievements,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AchievementsTableAnnotationComposer(
            $db: $db,
            $table: $db.achievements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vocabSizeTestsRefs<T extends Object>(
    Expression<T> Function($$VocabSizeTestsTableAnnotationComposer a) f,
  ) {
    final $$VocabSizeTestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vocabSizeTests,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabSizeTestsTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabSizeTests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool wordsRefs,
            bool wordbooksRefs,
            bool wordReviewsRefs,
            bool partReviewsRefs,
            bool resolvedConfusionsRefs,
            bool studySessionsRefs,
            bool learningLogsRefs,
            bool dailyStatsRefs,
            bool achievementsRefs,
            bool vocabSizeTestsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> colorSeed = const Value.absent(),
                Value<String> palette = const Value.absent(),
                Value<String> textScale = const Value.absent(),
                Value<String> density = const Value.absent(),
                Value<String> dictViewMode = const Value.absent(),
                Value<String> dictGridColumns = const Value.absent(),
                Value<bool> searchExamples = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<int> sessionSize = const Value.absent(),
                Value<String> keyboardLayout = const Value.absent(),
                Value<bool> autoNextOnCorrect = const Value.absent(),
                Value<String> flashcardMode = const Value.absent(),
                Value<int> flashcardSeconds = const Value.absent(),
                Value<String> choiceDirection = const Value.absent(),
                Value<int> speedLimitMs = const Value.absent(),
                Value<String> selectedWordbookIds = const Value.absent(),
                Value<String> audioSource = const Value.absent(),
                Value<String> audioPackIds = const Value.absent(),
                Value<String> ttsEnVoice = const Value.absent(),
                Value<String> ttsJaVoice = const Value.absent(),
                Value<double> ttsRate = const Value.absent(),
                Value<double> ttsPitch = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                colorSeed: colorSeed,
                palette: palette,
                textScale: textScale,
                density: density,
                dictViewMode: dictViewMode,
                dictGridColumns: dictGridColumns,
                searchExamples: searchExamples,
                dailyGoal: dailyGoal,
                sessionSize: sessionSize,
                keyboardLayout: keyboardLayout,
                autoNextOnCorrect: autoNextOnCorrect,
                flashcardMode: flashcardMode,
                flashcardSeconds: flashcardSeconds,
                choiceDirection: choiceDirection,
                speedLimitMs: speedLimitMs,
                selectedWordbookIds: selectedWordbookIds,
                audioSource: audioSource,
                audioPackIds: audioPackIds,
                ttsEnVoice: ttsEnVoice,
                ttsJaVoice: ttsJaVoice,
                ttsRate: ttsRate,
                ttsPitch: ttsPitch,
                reminderEnabled: reminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> emoji = const Value.absent(),
                required int colorSeed,
                Value<String> palette = const Value.absent(),
                Value<String> textScale = const Value.absent(),
                Value<String> density = const Value.absent(),
                Value<String> dictViewMode = const Value.absent(),
                Value<String> dictGridColumns = const Value.absent(),
                Value<bool> searchExamples = const Value.absent(),
                Value<int> dailyGoal = const Value.absent(),
                Value<int> sessionSize = const Value.absent(),
                Value<String> keyboardLayout = const Value.absent(),
                Value<bool> autoNextOnCorrect = const Value.absent(),
                Value<String> flashcardMode = const Value.absent(),
                Value<int> flashcardSeconds = const Value.absent(),
                Value<String> choiceDirection = const Value.absent(),
                Value<int> speedLimitMs = const Value.absent(),
                Value<String> selectedWordbookIds = const Value.absent(),
                Value<String> audioSource = const Value.absent(),
                Value<String> audioPackIds = const Value.absent(),
                Value<String> ttsEnVoice = const Value.absent(),
                Value<String> ttsJaVoice = const Value.absent(),
                Value<double> ttsRate = const Value.absent(),
                Value<double> ttsPitch = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                colorSeed: colorSeed,
                palette: palette,
                textScale: textScale,
                density: density,
                dictViewMode: dictViewMode,
                dictGridColumns: dictGridColumns,
                searchExamples: searchExamples,
                dailyGoal: dailyGoal,
                sessionSize: sessionSize,
                keyboardLayout: keyboardLayout,
                autoNextOnCorrect: autoNextOnCorrect,
                flashcardMode: flashcardMode,
                flashcardSeconds: flashcardSeconds,
                choiceDirection: choiceDirection,
                speedLimitMs: speedLimitMs,
                selectedWordbookIds: selectedWordbookIds,
                audioSource: audioSource,
                audioPackIds: audioPackIds,
                ttsEnVoice: ttsEnVoice,
                ttsJaVoice: ttsJaVoice,
                ttsRate: ttsRate,
                ttsPitch: ttsPitch,
                reminderEnabled: reminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordsRefs = false,
                wordbooksRefs = false,
                wordReviewsRefs = false,
                partReviewsRefs = false,
                resolvedConfusionsRefs = false,
                studySessionsRefs = false,
                learningLogsRefs = false,
                dailyStatsRefs = false,
                achievementsRefs = false,
                vocabSizeTestsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordsRefs) db.words,
                    if (wordbooksRefs) db.wordbooks,
                    if (wordReviewsRefs) db.wordReviews,
                    if (partReviewsRefs) db.partReviews,
                    if (resolvedConfusionsRefs) db.resolvedConfusions,
                    if (studySessionsRefs) db.studySessions,
                    if (learningLogsRefs) db.learningLogs,
                    if (dailyStatsRefs) db.dailyStats,
                    if (achievementsRefs) db.achievements,
                    if (vocabSizeTestsRefs) db.vocabSizeTests,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Word
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._wordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).wordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordbooksRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Wordbook
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._wordbooksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).wordbooksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerProfileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordReviewsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          WordReview
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._wordReviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).wordReviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (partReviewsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          PartReview
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._partReviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).partReviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resolvedConfusionsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          ResolvedConfusion
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._resolvedConfusionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).resolvedConfusionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studySessionsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          StudySession
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._studySessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).studySessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (learningLogsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          LearningLog
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._learningLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).learningLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyStatsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          DailyStat
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._dailyStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (achievementsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Achievement
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._achievementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).achievementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vocabSizeTestsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          VocabSizeTest
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._vocabSizeTestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).vocabSizeTestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool wordsRefs,
        bool wordbooksRefs,
        bool wordReviewsRefs,
        bool partReviewsRefs,
        bool resolvedConfusionsRefs,
        bool studySessionsRefs,
        bool learningLogsRefs,
        bool dailyStatsRefs,
        bool achievementsRefs,
        bool vocabSizeTestsRefs,
      })
    >;
typedef $$WordFamiliesTableCreateCompanionBuilder =
    WordFamiliesCompanion Function({
      Value<int> id,
      required String baseForm,
      Value<String?> note,
    });
typedef $$WordFamiliesTableUpdateCompanionBuilder =
    WordFamiliesCompanion Function({
      Value<int> id,
      Value<String> baseForm,
      Value<String?> note,
    });

final class $$WordFamiliesTableReferences
    extends BaseReferences<_$AppDatabase, $WordFamiliesTable, WordFamily> {
  $$WordFamiliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: 'word_families__id__words__family_id',
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordFamiliesTableFilterComposer
    extends Composer<_$AppDatabase, $WordFamiliesTable> {
  $$WordFamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseForm => $composableBuilder(
    column: $table.baseForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordFamiliesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordFamiliesTable> {
  $$WordFamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseForm => $composableBuilder(
    column: $table.baseForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordFamiliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordFamiliesTable> {
  $$WordFamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseForm =>
      $composableBuilder(column: $table.baseForm, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.familyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordFamiliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordFamiliesTable,
          WordFamily,
          $$WordFamiliesTableFilterComposer,
          $$WordFamiliesTableOrderingComposer,
          $$WordFamiliesTableAnnotationComposer,
          $$WordFamiliesTableCreateCompanionBuilder,
          $$WordFamiliesTableUpdateCompanionBuilder,
          (WordFamily, $$WordFamiliesTableReferences),
          WordFamily,
          PrefetchHooks Function({bool wordsRefs})
        > {
  $$WordFamiliesTableTableManager(_$AppDatabase db, $WordFamiliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordFamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordFamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordFamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> baseForm = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) =>
                  WordFamiliesCompanion(id: id, baseForm: baseForm, note: note),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String baseForm,
                Value<String?> note = const Value.absent(),
              }) => WordFamiliesCompanion.insert(
                id: id,
                baseForm: baseForm,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordFamiliesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordsRefs) db.words],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordsRefs)
                    await $_getPrefetchedData<
                      WordFamily,
                      $WordFamiliesTable,
                      Word
                    >(
                      currentTable: table,
                      referencedTable: $$WordFamiliesTableReferences
                          ._wordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordFamiliesTableReferences(
                            db,
                            table,
                            p0,
                          ).wordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.familyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordFamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordFamiliesTable,
      WordFamily,
      $$WordFamiliesTableFilterComposer,
      $$WordFamiliesTableOrderingComposer,
      $$WordFamiliesTableAnnotationComposer,
      $$WordFamiliesTableCreateCompanionBuilder,
      $$WordFamiliesTableUpdateCompanionBuilder,
      (WordFamily, $$WordFamiliesTableReferences),
      WordFamily,
      PrefetchHooks Function({bool wordsRefs})
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String headword,
      required String partOfSpeech,
      Value<String?> phonetic,
      required String meaning,
      Value<String?> partsNote,
      Value<String?> confusionNote,
      Value<int?> familyId,
      Value<int> level,
      Value<int?> frequencyRank,
      Value<String?> presetId,
      Value<int?> ownerProfileId,
      Value<bool> isDraft,
      Value<bool> isEdited,
      Value<bool> isExcluded,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> headword,
      Value<String> partOfSpeech,
      Value<String?> phonetic,
      Value<String> meaning,
      Value<String?> partsNote,
      Value<String?> confusionNote,
      Value<int?> familyId,
      Value<int> level,
      Value<int?> frequencyRank,
      Value<String?> presetId,
      Value<int?> ownerProfileId,
      Value<bool> isDraft,
      Value<bool> isEdited,
      Value<bool> isExcluded,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordFamiliesTable _familyIdTable(_$AppDatabase db) =>
      db.wordFamilies.createAlias('words__family_id__word_families__id');

  $$WordFamiliesTableProcessedTableManager? get familyId {
    final $_column = $_itemColumn<int>('family_id');
    if ($_column == null) return null;
    final manager = $$WordFamiliesTableTableManager(
      $_db,
      $_db.wordFamilies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProfilesTable _ownerProfileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('words__owner_profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager? get ownerProfileId {
    final $_column = $_itemColumn<int>('owner_profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WordExamplesTable, List<WordExample>>
  _wordExamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordExamples,
    aliasName: 'words__id__word_examples__word_id',
  );

  $$WordExamplesTableProcessedTableManager get wordExamplesRefs {
    final manager = $$WordExamplesTableTableManager(
      $_db,
      $_db.wordExamples,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordExamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordbookEntriesTable, List<WordbookEntry>>
  _wordbookEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordbookEntries,
    aliasName: 'words__id__wordbook_entries__word_id',
  );

  $$WordbookEntriesTableProcessedTableManager get wordbookEntriesRefs {
    final manager = $$WordbookEntriesTableTableManager(
      $_db,
      $_db.wordbookEntries,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wordbookEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordPartLinksTable, List<WordPartLink>>
  _wordPartLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordPartLinks,
    aliasName: 'words__id__word_part_links__word_id',
  );

  $$WordPartLinksTableProcessedTableManager get wordPartLinksRefs {
    final manager = $$WordPartLinksTableTableManager(
      $_db,
      $_db.wordPartLinks,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordPartLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordReviewsTable, List<WordReview>>
  _wordReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordReviews,
    aliasName: 'words__id__word_reviews__word_id',
  );

  $$WordReviewsTableProcessedTableManager get wordReviewsRefs {
    final manager = $$WordReviewsTableTableManager(
      $_db,
      $_db.wordReviews,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResolvedConfusionsTable, List<ResolvedConfusion>>
  _resolvedConfusionsAsATable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resolvedConfusions,
        aliasName: 'words__id__resolved_confusions__word_id_a',
      );

  $$ResolvedConfusionsTableProcessedTableManager get resolvedConfusionsAsA {
    final manager = $$ResolvedConfusionsTableTableManager(
      $_db,
      $_db.resolvedConfusions,
    ).filter((f) => f.wordIdA.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resolvedConfusionsAsATable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ResolvedConfusionsTable, List<ResolvedConfusion>>
  _resolvedConfusionsAsBTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.resolvedConfusions,
        aliasName: 'words__id__resolved_confusions__word_id_b',
      );

  $$ResolvedConfusionsTableProcessedTableManager get resolvedConfusionsAsB {
    final manager = $$ResolvedConfusionsTableTableManager(
      $_db,
      $_db.resolvedConfusions,
    ).filter((f) => f.wordIdB.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _resolvedConfusionsAsBTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LearningLogsTable, List<LearningLog>>
  _learningLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.learningLogs,
    aliasName: 'words__id__learning_logs__word_id',
  );

  $$LearningLogsTableProcessedTableManager get learningLogsRefs {
    final manager = $$LearningLogsTableTableManager(
      $_db,
      $_db.learningLogs,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_learningLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordAudiosTable, List<WordAudio>>
  _wordAudiosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordAudios,
    aliasName: 'words__id__word_audios__word_id',
  );

  $$WordAudiosTableProcessedTableManager get wordAudiosRefs {
    final manager = $$WordAudiosTableTableManager(
      $_db,
      $_db.wordAudios,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordAudiosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partsNote => $composableBuilder(
    column: $table.partsNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confusionNote => $composableBuilder(
    column: $table.confusionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyRank => $composableBuilder(
    column: $table.frequencyRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDraft => $composableBuilder(
    column: $table.isDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExcluded => $composableBuilder(
    column: $table.isExcluded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WordFamiliesTableFilterComposer get familyId {
    final $$WordFamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.wordFamilies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordFamiliesTableFilterComposer(
            $db: $db,
            $table: $db.wordFamilies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableFilterComposer get ownerProfileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> wordExamplesRefs(
    Expression<bool> Function($$WordExamplesTableFilterComposer f) f,
  ) {
    final $$WordExamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordExamples,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordExamplesTableFilterComposer(
            $db: $db,
            $table: $db.wordExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordbookEntriesRefs(
    Expression<bool> Function($$WordbookEntriesTableFilterComposer f) f,
  ) {
    final $$WordbookEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbookEntries,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbookEntriesTableFilterComposer(
            $db: $db,
            $table: $db.wordbookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordPartLinksRefs(
    Expression<bool> Function($$WordPartLinksTableFilterComposer f) f,
  ) {
    final $$WordPartLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPartLinks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartLinksTableFilterComposer(
            $db: $db,
            $table: $db.wordPartLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordReviewsRefs(
    Expression<bool> Function($$WordReviewsTableFilterComposer f) f,
  ) {
    final $$WordReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordReviews,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordReviewsTableFilterComposer(
            $db: $db,
            $table: $db.wordReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resolvedConfusionsAsA(
    Expression<bool> Function($$ResolvedConfusionsTableFilterComposer f) f,
  ) {
    final $$ResolvedConfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resolvedConfusions,
      getReferencedColumn: (t) => t.wordIdA,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResolvedConfusionsTableFilterComposer(
            $db: $db,
            $table: $db.resolvedConfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> resolvedConfusionsAsB(
    Expression<bool> Function($$ResolvedConfusionsTableFilterComposer f) f,
  ) {
    final $$ResolvedConfusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.resolvedConfusions,
      getReferencedColumn: (t) => t.wordIdB,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResolvedConfusionsTableFilterComposer(
            $db: $db,
            $table: $db.resolvedConfusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> learningLogsRefs(
    Expression<bool> Function($$LearningLogsTableFilterComposer f) f,
  ) {
    final $$LearningLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableFilterComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordAudiosRefs(
    Expression<bool> Function($$WordAudiosTableFilterComposer f) f,
  ) {
    final $$WordAudiosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordAudios,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordAudiosTableFilterComposer(
            $db: $db,
            $table: $db.wordAudios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partsNote => $composableBuilder(
    column: $table.partsNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confusionNote => $composableBuilder(
    column: $table.confusionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyRank => $composableBuilder(
    column: $table.frequencyRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDraft => $composableBuilder(
    column: $table.isDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExcluded => $composableBuilder(
    column: $table.isExcluded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordFamiliesTableOrderingComposer get familyId {
    final $$WordFamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.wordFamilies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordFamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.wordFamilies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableOrderingComposer get ownerProfileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get partsNote =>
      $composableBuilder(column: $table.partsNote, builder: (column) => column);

  GeneratedColumn<String> get confusionNote => $composableBuilder(
    column: $table.confusionNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get frequencyRank => $composableBuilder(
    column: $table.frequencyRank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<bool> get isDraft =>
      $composableBuilder(column: $table.isDraft, builder: (column) => column);

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  GeneratedColumn<bool> get isExcluded => $composableBuilder(
    column: $table.isExcluded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WordFamiliesTableAnnotationComposer get familyId {
    final $$WordFamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.wordFamilies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordFamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordFamilies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableAnnotationComposer get ownerProfileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> wordExamplesRefs<T extends Object>(
    Expression<T> Function($$WordExamplesTableAnnotationComposer a) f,
  ) {
    final $$WordExamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordExamples,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordExamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordbookEntriesRefs<T extends Object>(
    Expression<T> Function($$WordbookEntriesTableAnnotationComposer a) f,
  ) {
    final $$WordbookEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbookEntries,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbookEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordbookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordPartLinksRefs<T extends Object>(
    Expression<T> Function($$WordPartLinksTableAnnotationComposer a) f,
  ) {
    final $$WordPartLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPartLinks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordPartLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordReviewsRefs<T extends Object>(
    Expression<T> Function($$WordReviewsTableAnnotationComposer a) f,
  ) {
    final $$WordReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordReviews,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> resolvedConfusionsAsA<T extends Object>(
    Expression<T> Function($$ResolvedConfusionsTableAnnotationComposer a) f,
  ) {
    final $$ResolvedConfusionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.resolvedConfusions,
          getReferencedColumn: (t) => t.wordIdA,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ResolvedConfusionsTableAnnotationComposer(
                $db: $db,
                $table: $db.resolvedConfusions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> resolvedConfusionsAsB<T extends Object>(
    Expression<T> Function($$ResolvedConfusionsTableAnnotationComposer a) f,
  ) {
    final $$ResolvedConfusionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.resolvedConfusions,
          getReferencedColumn: (t) => t.wordIdB,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ResolvedConfusionsTableAnnotationComposer(
                $db: $db,
                $table: $db.resolvedConfusions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> learningLogsRefs<T extends Object>(
    Expression<T> Function($$LearningLogsTableAnnotationComposer a) f,
  ) {
    final $$LearningLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordAudiosRefs<T extends Object>(
    Expression<T> Function($$WordAudiosTableAnnotationComposer a) f,
  ) {
    final $$WordAudiosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordAudios,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordAudiosTableAnnotationComposer(
            $db: $db,
            $table: $db.wordAudios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({
            bool familyId,
            bool ownerProfileId,
            bool wordExamplesRefs,
            bool wordbookEntriesRefs,
            bool wordPartLinksRefs,
            bool wordReviewsRefs,
            bool resolvedConfusionsAsA,
            bool resolvedConfusionsAsB,
            bool learningLogsRefs,
            bool wordAudiosRefs,
          })
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> headword = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> partsNote = const Value.absent(),
                Value<String?> confusionNote = const Value.absent(),
                Value<int?> familyId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int?> frequencyRank = const Value.absent(),
                Value<String?> presetId = const Value.absent(),
                Value<int?> ownerProfileId = const Value.absent(),
                Value<bool> isDraft = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<bool> isExcluded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                headword: headword,
                partOfSpeech: partOfSpeech,
                phonetic: phonetic,
                meaning: meaning,
                partsNote: partsNote,
                confusionNote: confusionNote,
                familyId: familyId,
                level: level,
                frequencyRank: frequencyRank,
                presetId: presetId,
                ownerProfileId: ownerProfileId,
                isDraft: isDraft,
                isEdited: isEdited,
                isExcluded: isExcluded,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String headword,
                required String partOfSpeech,
                Value<String?> phonetic = const Value.absent(),
                required String meaning,
                Value<String?> partsNote = const Value.absent(),
                Value<String?> confusionNote = const Value.absent(),
                Value<int?> familyId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int?> frequencyRank = const Value.absent(),
                Value<String?> presetId = const Value.absent(),
                Value<int?> ownerProfileId = const Value.absent(),
                Value<bool> isDraft = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<bool> isExcluded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                headword: headword,
                partOfSpeech: partOfSpeech,
                phonetic: phonetic,
                meaning: meaning,
                partsNote: partsNote,
                confusionNote: confusionNote,
                familyId: familyId,
                level: level,
                frequencyRank: frequencyRank,
                presetId: presetId,
                ownerProfileId: ownerProfileId,
                isDraft: isDraft,
                isEdited: isEdited,
                isExcluded: isExcluded,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                familyId = false,
                ownerProfileId = false,
                wordExamplesRefs = false,
                wordbookEntriesRefs = false,
                wordPartLinksRefs = false,
                wordReviewsRefs = false,
                resolvedConfusionsAsA = false,
                resolvedConfusionsAsB = false,
                learningLogsRefs = false,
                wordAudiosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordExamplesRefs) db.wordExamples,
                    if (wordbookEntriesRefs) db.wordbookEntries,
                    if (wordPartLinksRefs) db.wordPartLinks,
                    if (wordReviewsRefs) db.wordReviews,
                    if (resolvedConfusionsAsA) db.resolvedConfusions,
                    if (resolvedConfusionsAsB) db.resolvedConfusions,
                    if (learningLogsRefs) db.learningLogs,
                    if (wordAudiosRefs) db.wordAudios,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (familyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.familyId,
                                    referencedTable: $$WordsTableReferences
                                        ._familyIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._familyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (ownerProfileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerProfileId,
                                    referencedTable: $$WordsTableReferences
                                        ._ownerProfileIdTable(db),
                                    referencedColumn: $$WordsTableReferences
                                        ._ownerProfileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordExamplesRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          WordExample
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordExamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordExamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordbookEntriesRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          WordbookEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordbookEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordbookEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordPartLinksRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          WordPartLink
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordPartLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordPartLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordReviewsRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          WordReview
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordReviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordReviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resolvedConfusionsAsA)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          ResolvedConfusion
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._resolvedConfusionsAsATable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).resolvedConfusionsAsA,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordIdA == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (resolvedConfusionsAsB)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          ResolvedConfusion
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._resolvedConfusionsAsBTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).resolvedConfusionsAsB,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordIdB == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (learningLogsRefs)
                        await $_getPrefetchedData<
                          Word,
                          $WordsTable,
                          LearningLog
                        >(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._learningLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordAudiosRefs)
                        await $_getPrefetchedData<Word, $WordsTable, WordAudio>(
                          currentTable: table,
                          referencedTable: $$WordsTableReferences
                              ._wordAudiosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordAudiosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({
        bool familyId,
        bool ownerProfileId,
        bool wordExamplesRefs,
        bool wordbookEntriesRefs,
        bool wordPartLinksRefs,
        bool wordReviewsRefs,
        bool resolvedConfusionsAsA,
        bool resolvedConfusionsAsB,
        bool learningLogsRefs,
        bool wordAudiosRefs,
      })
    >;
typedef $$WordExamplesTableCreateCompanionBuilder =
    WordExamplesCompanion Function({
      Value<int> id,
      required int wordId,
      required String exampleEn,
      Value<String?> exampleJa,
      Value<String?> sourcePresetId,
      Value<int> sortOrder,
    });
typedef $$WordExamplesTableUpdateCompanionBuilder =
    WordExamplesCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<String> exampleEn,
      Value<String?> exampleJa,
      Value<String?> sourcePresetId,
      Value<int> sortOrder,
    });

final class $$WordExamplesTableReferences
    extends BaseReferences<_$AppDatabase, $WordExamplesTable, WordExample> {
  $$WordExamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_examples__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordExamplesTableFilterComposer
    extends Composer<_$AppDatabase, $WordExamplesTable> {
  $$WordExamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleJa => $composableBuilder(
    column: $table.exampleJa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePresetId => $composableBuilder(
    column: $table.sourcePresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordExamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordExamplesTable> {
  $$WordExamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleJa => $composableBuilder(
    column: $table.exampleJa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePresetId => $composableBuilder(
    column: $table.sourcePresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordExamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordExamplesTable> {
  $$WordExamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exampleEn =>
      $composableBuilder(column: $table.exampleEn, builder: (column) => column);

  GeneratedColumn<String> get exampleJa =>
      $composableBuilder(column: $table.exampleJa, builder: (column) => column);

  GeneratedColumn<String> get sourcePresetId => $composableBuilder(
    column: $table.sourcePresetId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordExamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordExamplesTable,
          WordExample,
          $$WordExamplesTableFilterComposer,
          $$WordExamplesTableOrderingComposer,
          $$WordExamplesTableAnnotationComposer,
          $$WordExamplesTableCreateCompanionBuilder,
          $$WordExamplesTableUpdateCompanionBuilder,
          (WordExample, $$WordExamplesTableReferences),
          WordExample,
          PrefetchHooks Function({bool wordId})
        > {
  $$WordExamplesTableTableManager(_$AppDatabase db, $WordExamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordExamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordExamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordExamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<String> exampleEn = const Value.absent(),
                Value<String?> exampleJa = const Value.absent(),
                Value<String?> sourcePresetId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WordExamplesCompanion(
                id: id,
                wordId: wordId,
                exampleEn: exampleEn,
                exampleJa: exampleJa,
                sourcePresetId: sourcePresetId,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required String exampleEn,
                Value<String?> exampleJa = const Value.absent(),
                Value<String?> sourcePresetId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WordExamplesCompanion.insert(
                id: id,
                wordId: wordId,
                exampleEn: exampleEn,
                exampleJa: exampleJa,
                sourcePresetId: sourcePresetId,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordExamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordExamplesTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordExamplesTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordExamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordExamplesTable,
      WordExample,
      $$WordExamplesTableFilterComposer,
      $$WordExamplesTableOrderingComposer,
      $$WordExamplesTableAnnotationComposer,
      $$WordExamplesTableCreateCompanionBuilder,
      $$WordExamplesTableUpdateCompanionBuilder,
      (WordExample, $$WordExamplesTableReferences),
      WordExample,
      PrefetchHooks Function({bool wordId})
    >;
typedef $$WordbooksTableCreateCompanionBuilder =
    WordbooksCompanion Function({
      Value<int> id,
      required String name,
      required String emoji,
      required int colorSeed,
      required String category,
      required String source,
      Value<String?> presetId,
      Value<int?> ownerProfileId,
      Value<int> seedVersion,
      Value<int?> bandSize,
      Value<String?> note,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$WordbooksTableUpdateCompanionBuilder =
    WordbooksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> colorSeed,
      Value<String> category,
      Value<String> source,
      Value<String?> presetId,
      Value<int?> ownerProfileId,
      Value<int> seedVersion,
      Value<int?> bandSize,
      Value<String?> note,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WordbooksTableReferences
    extends BaseReferences<_$AppDatabase, $WordbooksTable, Wordbook> {
  $$WordbooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _ownerProfileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('wordbooks__owner_profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager? get ownerProfileId {
    final $_column = $_itemColumn<int>('owner_profile_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WordbookEntriesTable, List<WordbookEntry>>
  _wordbookEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordbookEntries,
    aliasName: 'wordbooks__id__wordbook_entries__wordbook_id',
  );

  $$WordbookEntriesTableProcessedTableManager get wordbookEntriesRefs {
    final manager = $$WordbookEntriesTableTableManager(
      $_db,
      $_db.wordbookEntries,
    ).filter((f) => f.wordbookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wordbookEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordbooksTableFilterComposer
    extends Composer<_$AppDatabase, $WordbooksTable> {
  $$WordbooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bandSize => $composableBuilder(
    column: $table.bandSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get ownerProfileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> wordbookEntriesRefs(
    Expression<bool> Function($$WordbookEntriesTableFilterComposer f) f,
  ) {
    final $$WordbookEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbookEntries,
      getReferencedColumn: (t) => t.wordbookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbookEntriesTableFilterComposer(
            $db: $db,
            $table: $db.wordbookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordbooksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordbooksTable> {
  $$WordbooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bandSize => $composableBuilder(
    column: $table.bandSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get ownerProfileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordbooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordbooksTable> {
  $$WordbooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get colorSeed =>
      $composableBuilder(column: $table.colorSeed, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<int> get seedVersion => $composableBuilder(
    column: $table.seedVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bandSize =>
      $composableBuilder(column: $table.bandSize, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get ownerProfileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerProfileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> wordbookEntriesRefs<T extends Object>(
    Expression<T> Function($$WordbookEntriesTableAnnotationComposer a) f,
  ) {
    final $$WordbookEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordbookEntries,
      getReferencedColumn: (t) => t.wordbookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbookEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.wordbookEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordbooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordbooksTable,
          Wordbook,
          $$WordbooksTableFilterComposer,
          $$WordbooksTableOrderingComposer,
          $$WordbooksTableAnnotationComposer,
          $$WordbooksTableCreateCompanionBuilder,
          $$WordbooksTableUpdateCompanionBuilder,
          (Wordbook, $$WordbooksTableReferences),
          Wordbook,
          PrefetchHooks Function({
            bool ownerProfileId,
            bool wordbookEntriesRefs,
          })
        > {
  $$WordbooksTableTableManager(_$AppDatabase db, $WordbooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordbooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordbooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordbooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> colorSeed = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> presetId = const Value.absent(),
                Value<int?> ownerProfileId = const Value.absent(),
                Value<int> seedVersion = const Value.absent(),
                Value<int?> bandSize = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordbooksCompanion(
                id: id,
                name: name,
                emoji: emoji,
                colorSeed: colorSeed,
                category: category,
                source: source,
                presetId: presetId,
                ownerProfileId: ownerProfileId,
                seedVersion: seedVersion,
                bandSize: bandSize,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String emoji,
                required int colorSeed,
                required String category,
                required String source,
                Value<String?> presetId = const Value.absent(),
                Value<int?> ownerProfileId = const Value.absent(),
                Value<int> seedVersion = const Value.absent(),
                Value<int?> bandSize = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WordbooksCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                colorSeed: colorSeed,
                category: category,
                source: source,
                presetId: presetId,
                ownerProfileId: ownerProfileId,
                seedVersion: seedVersion,
                bandSize: bandSize,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordbooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ownerProfileId = false, wordbookEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordbookEntriesRefs) db.wordbookEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ownerProfileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerProfileId,
                                    referencedTable: $$WordbooksTableReferences
                                        ._ownerProfileIdTable(db),
                                    referencedColumn: $$WordbooksTableReferences
                                        ._ownerProfileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordbookEntriesRefs)
                        await $_getPrefetchedData<
                          Wordbook,
                          $WordbooksTable,
                          WordbookEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WordbooksTableReferences
                              ._wordbookEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordbooksTableReferences(
                                db,
                                table,
                                p0,
                              ).wordbookEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wordbookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordbooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordbooksTable,
      Wordbook,
      $$WordbooksTableFilterComposer,
      $$WordbooksTableOrderingComposer,
      $$WordbooksTableAnnotationComposer,
      $$WordbooksTableCreateCompanionBuilder,
      $$WordbooksTableUpdateCompanionBuilder,
      (Wordbook, $$WordbooksTableReferences),
      Wordbook,
      PrefetchHooks Function({bool ownerProfileId, bool wordbookEntriesRefs})
    >;
typedef $$WordbookEntriesTableCreateCompanionBuilder =
    WordbookEntriesCompanion Function({
      required int wordbookId,
      required int wordId,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$WordbookEntriesTableUpdateCompanionBuilder =
    WordbookEntriesCompanion Function({
      Value<int> wordbookId,
      Value<int> wordId,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$WordbookEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WordbookEntriesTable, WordbookEntry> {
  $$WordbookEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordbooksTable _wordbookIdTable(_$AppDatabase db) =>
      db.wordbooks.createAlias('wordbook_entries__wordbook_id__wordbooks__id');

  $$WordbooksTableProcessedTableManager get wordbookId {
    final $_column = $_itemColumn<int>('wordbook_id')!;

    final manager = $$WordbooksTableTableManager(
      $_db,
      $_db.wordbooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordbookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('wordbook_entries__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordbookEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WordbookEntriesTable> {
  $$WordbookEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$WordbooksTableFilterComposer get wordbookId {
    final $$WordbooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordbookId,
      referencedTable: $db.wordbooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbooksTableFilterComposer(
            $db: $db,
            $table: $db.wordbooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordbookEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WordbookEntriesTable> {
  $$WordbookEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordbooksTableOrderingComposer get wordbookId {
    final $$WordbooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordbookId,
      referencedTable: $db.wordbooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbooksTableOrderingComposer(
            $db: $db,
            $table: $db.wordbooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordbookEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordbookEntriesTable> {
  $$WordbookEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WordbooksTableAnnotationComposer get wordbookId {
    final $$WordbooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordbookId,
      referencedTable: $db.wordbooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordbooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordbooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordbookEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordbookEntriesTable,
          WordbookEntry,
          $$WordbookEntriesTableFilterComposer,
          $$WordbookEntriesTableOrderingComposer,
          $$WordbookEntriesTableAnnotationComposer,
          $$WordbookEntriesTableCreateCompanionBuilder,
          $$WordbookEntriesTableUpdateCompanionBuilder,
          (WordbookEntry, $$WordbookEntriesTableReferences),
          WordbookEntry,
          PrefetchHooks Function({bool wordbookId, bool wordId})
        > {
  $$WordbookEntriesTableTableManager(
    _$AppDatabase db,
    $WordbookEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordbookEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordbookEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordbookEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordbookId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordbookEntriesCompanion(
                wordbookId: wordbookId,
                wordId: wordId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int wordbookId,
                required int wordId,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordbookEntriesCompanion.insert(
                wordbookId: wordbookId,
                wordId: wordId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordbookEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordbookId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordbookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordbookId,
                                referencedTable:
                                    $$WordbookEntriesTableReferences
                                        ._wordbookIdTable(db),
                                referencedColumn:
                                    $$WordbookEntriesTableReferences
                                        ._wordbookIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable:
                                    $$WordbookEntriesTableReferences
                                        ._wordIdTable(db),
                                referencedColumn:
                                    $$WordbookEntriesTableReferences
                                        ._wordIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordbookEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordbookEntriesTable,
      WordbookEntry,
      $$WordbookEntriesTableFilterComposer,
      $$WordbookEntriesTableOrderingComposer,
      $$WordbookEntriesTableAnnotationComposer,
      $$WordbookEntriesTableCreateCompanionBuilder,
      $$WordbookEntriesTableUpdateCompanionBuilder,
      (WordbookEntry, $$WordbookEntriesTableReferences),
      WordbookEntry,
      PrefetchHooks Function({bool wordbookId, bool wordId})
    >;
typedef $$WordPartsTableCreateCompanionBuilder =
    WordPartsCompanion Function({
      Value<int> id,
      required String form,
      required String type,
      required String meaning,
      Value<String?> origin,
      Value<String?> note,
      Value<int> level,
    });
typedef $$WordPartsTableUpdateCompanionBuilder =
    WordPartsCompanion Function({
      Value<int> id,
      Value<String> form,
      Value<String> type,
      Value<String> meaning,
      Value<String?> origin,
      Value<String?> note,
      Value<int> level,
    });

final class $$WordPartsTableReferences
    extends BaseReferences<_$AppDatabase, $WordPartsTable, WordPart> {
  $$WordPartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordPartLinksTable, List<WordPartLink>>
  _wordPartLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordPartLinks,
    aliasName: 'word_parts__id__word_part_links__part_id',
  );

  $$WordPartLinksTableProcessedTableManager get wordPartLinksRefs {
    final manager = $$WordPartLinksTableTableManager(
      $_db,
      $_db.wordPartLinks,
    ).filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordPartLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PartReviewsTable, List<PartReview>>
  _partReviewsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.partReviews,
    aliasName: 'word_parts__id__part_reviews__part_id',
  );

  $$PartReviewsTableProcessedTableManager get partReviewsRefs {
    final manager = $$PartReviewsTableTableManager(
      $_db,
      $_db.partReviews,
    ).filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_partReviewsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LearningLogsTable, List<LearningLog>>
  _learningLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.learningLogs,
    aliasName: 'word_parts__id__learning_logs__part_id',
  );

  $$LearningLogsTableProcessedTableManager get learningLogsRefs {
    final manager = $$LearningLogsTableTableManager(
      $_db,
      $_db.learningLogs,
    ).filter((f) => f.partId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_learningLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordPartsTableFilterComposer
    extends Composer<_$AppDatabase, $WordPartsTable> {
  $$WordPartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordPartLinksRefs(
    Expression<bool> Function($$WordPartLinksTableFilterComposer f) f,
  ) {
    final $$WordPartLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPartLinks,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartLinksTableFilterComposer(
            $db: $db,
            $table: $db.wordPartLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> partReviewsRefs(
    Expression<bool> Function($$PartReviewsTableFilterComposer f) f,
  ) {
    final $$PartReviewsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partReviews,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartReviewsTableFilterComposer(
            $db: $db,
            $table: $db.partReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> learningLogsRefs(
    Expression<bool> Function($$LearningLogsTableFilterComposer f) f,
  ) {
    final $$LearningLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableFilterComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordPartsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordPartsTable> {
  $$WordPartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordPartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordPartsTable> {
  $$WordPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  Expression<T> wordPartLinksRefs<T extends Object>(
    Expression<T> Function($$WordPartLinksTableAnnotationComposer a) f,
  ) {
    final $$WordPartLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordPartLinks,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordPartLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> partReviewsRefs<T extends Object>(
    Expression<T> Function($$PartReviewsTableAnnotationComposer a) f,
  ) {
    final $$PartReviewsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.partReviews,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartReviewsTableAnnotationComposer(
            $db: $db,
            $table: $db.partReviews,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> learningLogsRefs<T extends Object>(
    Expression<T> Function($$LearningLogsTableAnnotationComposer a) f,
  ) {
    final $$LearningLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordPartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordPartsTable,
          WordPart,
          $$WordPartsTableFilterComposer,
          $$WordPartsTableOrderingComposer,
          $$WordPartsTableAnnotationComposer,
          $$WordPartsTableCreateCompanionBuilder,
          $$WordPartsTableUpdateCompanionBuilder,
          (WordPart, $$WordPartsTableReferences),
          WordPart,
          PrefetchHooks Function({
            bool wordPartLinksRefs,
            bool partReviewsRefs,
            bool learningLogsRefs,
          })
        > {
  $$WordPartsTableTableManager(_$AppDatabase db, $WordPartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> level = const Value.absent(),
              }) => WordPartsCompanion(
                id: id,
                form: form,
                type: type,
                meaning: meaning,
                origin: origin,
                note: note,
                level: level,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String form,
                required String type,
                required String meaning,
                Value<String?> origin = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> level = const Value.absent(),
              }) => WordPartsCompanion.insert(
                id: id,
                form: form,
                type: type,
                meaning: meaning,
                origin: origin,
                note: note,
                level: level,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordPartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wordPartLinksRefs = false,
                partReviewsRefs = false,
                learningLogsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wordPartLinksRefs) db.wordPartLinks,
                    if (partReviewsRefs) db.partReviews,
                    if (learningLogsRefs) db.learningLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wordPartLinksRefs)
                        await $_getPrefetchedData<
                          WordPart,
                          $WordPartsTable,
                          WordPartLink
                        >(
                          currentTable: table,
                          referencedTable: $$WordPartsTableReferences
                              ._wordPartLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordPartsTableReferences(
                                db,
                                table,
                                p0,
                              ).wordPartLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (partReviewsRefs)
                        await $_getPrefetchedData<
                          WordPart,
                          $WordPartsTable,
                          PartReview
                        >(
                          currentTable: table,
                          referencedTable: $$WordPartsTableReferences
                              ._partReviewsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordPartsTableReferences(
                                db,
                                table,
                                p0,
                              ).partReviewsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (learningLogsRefs)
                        await $_getPrefetchedData<
                          WordPart,
                          $WordPartsTable,
                          LearningLog
                        >(
                          currentTable: table,
                          referencedTable: $$WordPartsTableReferences
                              ._learningLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WordPartsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.partId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WordPartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordPartsTable,
      WordPart,
      $$WordPartsTableFilterComposer,
      $$WordPartsTableOrderingComposer,
      $$WordPartsTableAnnotationComposer,
      $$WordPartsTableCreateCompanionBuilder,
      $$WordPartsTableUpdateCompanionBuilder,
      (WordPart, $$WordPartsTableReferences),
      WordPart,
      PrefetchHooks Function({
        bool wordPartLinksRefs,
        bool partReviewsRefs,
        bool learningLogsRefs,
      })
    >;
typedef $$WordPartLinksTableCreateCompanionBuilder =
    WordPartLinksCompanion Function({
      required int wordId,
      required int partId,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$WordPartLinksTableUpdateCompanionBuilder =
    WordPartLinksCompanion Function({
      Value<int> wordId,
      Value<int> partId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$WordPartLinksTableReferences
    extends BaseReferences<_$AppDatabase, $WordPartLinksTable, WordPartLink> {
  $$WordPartLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_part_links__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordPartsTable _partIdTable(_$AppDatabase db) =>
      db.wordParts.createAlias('word_part_links__part_id__word_parts__id');

  $$WordPartsTableProcessedTableManager get partId {
    final $_column = $_itemColumn<int>('part_id')!;

    final manager = $$WordPartsTableTableManager(
      $_db,
      $_db.wordParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordPartLinksTableFilterComposer
    extends Composer<_$AppDatabase, $WordPartLinksTable> {
  $$WordPartLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableFilterComposer get partId {
    final $$WordPartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableFilterComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPartLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordPartLinksTable> {
  $$WordPartLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableOrderingComposer get partId {
    final $$WordPartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableOrderingComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPartLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordPartLinksTable> {
  $$WordPartLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableAnnotationComposer get partId {
    final $$WordPartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordPartLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordPartLinksTable,
          WordPartLink,
          $$WordPartLinksTableFilterComposer,
          $$WordPartLinksTableOrderingComposer,
          $$WordPartLinksTableAnnotationComposer,
          $$WordPartLinksTableCreateCompanionBuilder,
          $$WordPartLinksTableUpdateCompanionBuilder,
          (WordPartLink, $$WordPartLinksTableReferences),
          WordPartLink,
          PrefetchHooks Function({bool wordId, bool partId})
        > {
  $$WordPartLinksTableTableManager(_$AppDatabase db, $WordPartLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordPartLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordPartLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordPartLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<int> partId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordPartLinksCompanion(
                wordId: wordId,
                partId: partId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int wordId,
                required int partId,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordPartLinksCompanion.insert(
                wordId: wordId,
                partId: partId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordPartLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, partId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordPartLinksTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordPartLinksTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (partId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partId,
                                referencedTable: $$WordPartLinksTableReferences
                                    ._partIdTable(db),
                                referencedColumn: $$WordPartLinksTableReferences
                                    ._partIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordPartLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordPartLinksTable,
      WordPartLink,
      $$WordPartLinksTableFilterComposer,
      $$WordPartLinksTableOrderingComposer,
      $$WordPartLinksTableAnnotationComposer,
      $$WordPartLinksTableCreateCompanionBuilder,
      $$WordPartLinksTableUpdateCompanionBuilder,
      (WordPartLink, $$WordPartLinksTableReferences),
      WordPartLink,
      PrefetchHooks Function({bool wordId, bool partId})
    >;
typedef $$WordReviewsTableCreateCompanionBuilder =
    WordReviewsCompanion Function({
      required int profileId,
      required int wordId,
      Value<int> repetition,
      Value<double> intervalDays,
      Value<double> easeFactor,
      required DateTime dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> firstLearnedAt,
      Value<int> lapses,
      Value<int> correctStreak,
      Value<int> totalCorrect,
      Value<int> totalIncorrect,
      Value<int> masteryLevel,
      Value<int> rowid,
    });
typedef $$WordReviewsTableUpdateCompanionBuilder =
    WordReviewsCompanion Function({
      Value<int> profileId,
      Value<int> wordId,
      Value<int> repetition,
      Value<double> intervalDays,
      Value<double> easeFactor,
      Value<DateTime> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> firstLearnedAt,
      Value<int> lapses,
      Value<int> correctStreak,
      Value<int> totalCorrect,
      Value<int> totalIncorrect,
      Value<int> masteryLevel,
      Value<int> rowid,
    });

final class $$WordReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $WordReviewsTable, WordReview> {
  $$WordReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('word_reviews__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_reviews__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $WordReviewsTable> {
  $$WordReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordReviewsTable> {
  $$WordReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordReviewsTable> {
  $$WordReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordReviewsTable,
          WordReview,
          $$WordReviewsTableFilterComposer,
          $$WordReviewsTableOrderingComposer,
          $$WordReviewsTableAnnotationComposer,
          $$WordReviewsTableCreateCompanionBuilder,
          $$WordReviewsTableUpdateCompanionBuilder,
          (WordReview, $$WordReviewsTableReferences),
          WordReview,
          PrefetchHooks Function({bool profileId, bool wordId})
        > {
  $$WordReviewsTableTableManager(_$AppDatabase db, $WordReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> repetition = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalIncorrect = const Value.absent(),
                Value<int> masteryLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordReviewsCompanion(
                profileId: profileId,
                wordId: wordId,
                repetition: repetition,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                firstLearnedAt: firstLearnedAt,
                lapses: lapses,
                correctStreak: correctStreak,
                totalCorrect: totalCorrect,
                totalIncorrect: totalIncorrect,
                masteryLevel: masteryLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required int wordId,
                Value<int> repetition = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                required DateTime dueAt,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalIncorrect = const Value.absent(),
                Value<int> masteryLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordReviewsCompanion.insert(
                profileId: profileId,
                wordId: wordId,
                repetition: repetition,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                firstLearnedAt: firstLearnedAt,
                lapses: lapses,
                correctStreak: correctStreak,
                totalCorrect: totalCorrect,
                totalIncorrect: totalIncorrect,
                masteryLevel: masteryLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, wordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$WordReviewsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$WordReviewsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordReviewsTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordReviewsTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordReviewsTable,
      WordReview,
      $$WordReviewsTableFilterComposer,
      $$WordReviewsTableOrderingComposer,
      $$WordReviewsTableAnnotationComposer,
      $$WordReviewsTableCreateCompanionBuilder,
      $$WordReviewsTableUpdateCompanionBuilder,
      (WordReview, $$WordReviewsTableReferences),
      WordReview,
      PrefetchHooks Function({bool profileId, bool wordId})
    >;
typedef $$PartReviewsTableCreateCompanionBuilder =
    PartReviewsCompanion Function({
      required int profileId,
      required int partId,
      Value<int> repetition,
      Value<double> intervalDays,
      Value<double> easeFactor,
      required DateTime dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> firstLearnedAt,
      Value<int> lapses,
      Value<int> correctStreak,
      Value<int> totalCorrect,
      Value<int> totalIncorrect,
      Value<int> masteryLevel,
      Value<int> rowid,
    });
typedef $$PartReviewsTableUpdateCompanionBuilder =
    PartReviewsCompanion Function({
      Value<int> profileId,
      Value<int> partId,
      Value<int> repetition,
      Value<double> intervalDays,
      Value<double> easeFactor,
      Value<DateTime> dueAt,
      Value<DateTime?> lastReviewedAt,
      Value<DateTime?> firstLearnedAt,
      Value<int> lapses,
      Value<int> correctStreak,
      Value<int> totalCorrect,
      Value<int> totalIncorrect,
      Value<int> masteryLevel,
      Value<int> rowid,
    });

final class $$PartReviewsTableReferences
    extends BaseReferences<_$AppDatabase, $PartReviewsTable, PartReview> {
  $$PartReviewsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('part_reviews__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordPartsTable _partIdTable(_$AppDatabase db) =>
      db.wordParts.createAlias('part_reviews__part_id__word_parts__id');

  $$WordPartsTableProcessedTableManager get partId {
    final $_column = $_itemColumn<int>('part_id')!;

    final manager = $$WordPartsTableTableManager(
      $_db,
      $_db.wordParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PartReviewsTableFilterComposer
    extends Composer<_$AppDatabase, $PartReviewsTable> {
  $$PartReviewsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableFilterComposer get partId {
    final $$WordPartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableFilterComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartReviewsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartReviewsTable> {
  $$PartReviewsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableOrderingComposer get partId {
    final $$WordPartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableOrderingComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartReviewsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartReviewsTable> {
  $$PartReviewsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLearnedAt => $composableBuilder(
    column: $table.firstLearnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalIncorrect => $composableBuilder(
    column: $table.totalIncorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get masteryLevel => $composableBuilder(
    column: $table.masteryLevel,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableAnnotationComposer get partId {
    final $$WordPartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartReviewsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartReviewsTable,
          PartReview,
          $$PartReviewsTableFilterComposer,
          $$PartReviewsTableOrderingComposer,
          $$PartReviewsTableAnnotationComposer,
          $$PartReviewsTableCreateCompanionBuilder,
          $$PartReviewsTableUpdateCompanionBuilder,
          (PartReview, $$PartReviewsTableReferences),
          PartReview,
          PrefetchHooks Function({bool profileId, bool partId})
        > {
  $$PartReviewsTableTableManager(_$AppDatabase db, $PartReviewsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartReviewsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartReviewsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartReviewsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> partId = const Value.absent(),
                Value<int> repetition = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalIncorrect = const Value.absent(),
                Value<int> masteryLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartReviewsCompanion(
                profileId: profileId,
                partId: partId,
                repetition: repetition,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                firstLearnedAt: firstLearnedAt,
                lapses: lapses,
                correctStreak: correctStreak,
                totalCorrect: totalCorrect,
                totalIncorrect: totalIncorrect,
                masteryLevel: masteryLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required int partId,
                Value<int> repetition = const Value.absent(),
                Value<double> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                required DateTime dueAt,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<DateTime?> firstLearnedAt = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalIncorrect = const Value.absent(),
                Value<int> masteryLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartReviewsCompanion.insert(
                profileId: profileId,
                partId: partId,
                repetition: repetition,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                dueAt: dueAt,
                lastReviewedAt: lastReviewedAt,
                firstLearnedAt: firstLearnedAt,
                lapses: lapses,
                correctStreak: correctStreak,
                totalCorrect: totalCorrect,
                totalIncorrect: totalIncorrect,
                masteryLevel: masteryLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartReviewsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false, partId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$PartReviewsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$PartReviewsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (partId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.partId,
                                referencedTable: $$PartReviewsTableReferences
                                    ._partIdTable(db),
                                referencedColumn: $$PartReviewsTableReferences
                                    ._partIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PartReviewsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartReviewsTable,
      PartReview,
      $$PartReviewsTableFilterComposer,
      $$PartReviewsTableOrderingComposer,
      $$PartReviewsTableAnnotationComposer,
      $$PartReviewsTableCreateCompanionBuilder,
      $$PartReviewsTableUpdateCompanionBuilder,
      (PartReview, $$PartReviewsTableReferences),
      PartReview,
      PrefetchHooks Function({bool profileId, bool partId})
    >;
typedef $$ResolvedConfusionsTableCreateCompanionBuilder =
    ResolvedConfusionsCompanion Function({
      required int profileId,
      required int wordIdA,
      required int wordIdB,
      Value<DateTime> resolvedAt,
      Value<int> rowid,
    });
typedef $$ResolvedConfusionsTableUpdateCompanionBuilder =
    ResolvedConfusionsCompanion Function({
      Value<int> profileId,
      Value<int> wordIdA,
      Value<int> wordIdB,
      Value<DateTime> resolvedAt,
      Value<int> rowid,
    });

final class $$ResolvedConfusionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ResolvedConfusionsTable,
          ResolvedConfusion
        > {
  $$ResolvedConfusionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('resolved_confusions__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdATable(_$AppDatabase db) =>
      db.words.createAlias('resolved_confusions__word_id_a__words__id');

  $$WordsTableProcessedTableManager get wordIdA {
    final $_column = $_itemColumn<int>('word_id_a')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdATable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdBTable(_$AppDatabase db) =>
      db.words.createAlias('resolved_confusions__word_id_b__words__id');

  $$WordsTableProcessedTableManager get wordIdB {
    final $_column = $_itemColumn<int>('word_id_b')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdBTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResolvedConfusionsTableFilterComposer
    extends Composer<_$AppDatabase, $ResolvedConfusionsTable> {
  $$ResolvedConfusionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordIdA {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdA,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordIdB {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdB,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResolvedConfusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResolvedConfusionsTable> {
  $$ResolvedConfusionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordIdA {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdA,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordIdB {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdB,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResolvedConfusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResolvedConfusionsTable> {
  $$ResolvedConfusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordIdA {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdA,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordIdB {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordIdB,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResolvedConfusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResolvedConfusionsTable,
          ResolvedConfusion,
          $$ResolvedConfusionsTableFilterComposer,
          $$ResolvedConfusionsTableOrderingComposer,
          $$ResolvedConfusionsTableAnnotationComposer,
          $$ResolvedConfusionsTableCreateCompanionBuilder,
          $$ResolvedConfusionsTableUpdateCompanionBuilder,
          (ResolvedConfusion, $$ResolvedConfusionsTableReferences),
          ResolvedConfusion,
          PrefetchHooks Function({bool profileId, bool wordIdA, bool wordIdB})
        > {
  $$ResolvedConfusionsTableTableManager(
    _$AppDatabase db,
    $ResolvedConfusionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResolvedConfusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResolvedConfusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResolvedConfusionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<int> wordIdA = const Value.absent(),
                Value<int> wordIdB = const Value.absent(),
                Value<DateTime> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResolvedConfusionsCompanion(
                profileId: profileId,
                wordIdA: wordIdA,
                wordIdB: wordIdB,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required int wordIdA,
                required int wordIdB,
                Value<DateTime> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResolvedConfusionsCompanion.insert(
                profileId: profileId,
                wordIdA: wordIdA,
                wordIdB: wordIdB,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResolvedConfusionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, wordIdA = false, wordIdB = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$ResolvedConfusionsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$ResolvedConfusionsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (wordIdA) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordIdA,
                                    referencedTable:
                                        $$ResolvedConfusionsTableReferences
                                            ._wordIdATable(db),
                                    referencedColumn:
                                        $$ResolvedConfusionsTableReferences
                                            ._wordIdATable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (wordIdB) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordIdB,
                                    referencedTable:
                                        $$ResolvedConfusionsTableReferences
                                            ._wordIdBTable(db),
                                    referencedColumn:
                                        $$ResolvedConfusionsTableReferences
                                            ._wordIdBTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ResolvedConfusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResolvedConfusionsTable,
      ResolvedConfusion,
      $$ResolvedConfusionsTableFilterComposer,
      $$ResolvedConfusionsTableOrderingComposer,
      $$ResolvedConfusionsTableAnnotationComposer,
      $$ResolvedConfusionsTableCreateCompanionBuilder,
      $$ResolvedConfusionsTableUpdateCompanionBuilder,
      (ResolvedConfusion, $$ResolvedConfusionsTableReferences),
      ResolvedConfusion,
      PrefetchHooks Function({bool profileId, bool wordIdA, bool wordIdB})
    >;
typedef $$StudySessionsTableCreateCompanionBuilder =
    StudySessionsCompanion Function({
      required String id,
      required int profileId,
      required String mode,
      Value<String> wordbookIds,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> plannedCount,
      Value<int> answeredCount,
      Value<int> correctCount,
      Value<int> xpEarned,
      Value<int?> avgReactionMs,
      Value<int> rowid,
    });
typedef $$StudySessionsTableUpdateCompanionBuilder =
    StudySessionsCompanion Function({
      Value<String> id,
      Value<int> profileId,
      Value<String> mode,
      Value<String> wordbookIds,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> plannedCount,
      Value<int> answeredCount,
      Value<int> correctCount,
      Value<int> xpEarned,
      Value<int?> avgReactionMs,
      Value<int> rowid,
    });

final class $$StudySessionsTableReferences
    extends BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession> {
  $$StudySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('study_sessions__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LearningLogsTable, List<LearningLog>>
  _learningLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.learningLogs,
    aliasName: 'study_sessions__id__learning_logs__session_id',
  );

  $$LearningLogsTableProcessedTableManager get learningLogsRefs {
    final manager = $$LearningLogsTableTableManager(
      $_db,
      $_db.learningLogs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_learningLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordbookIds => $composableBuilder(
    column: $table.wordbookIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedCount => $composableBuilder(
    column: $table.plannedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> learningLogsRefs(
    Expression<bool> Function($$LearningLogsTableFilterComposer f) f,
  ) {
    final $$LearningLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableFilterComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordbookIds => $composableBuilder(
    column: $table.wordbookIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedCount => $composableBuilder(
    column: $table.plannedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpEarned => $composableBuilder(
    column: $table.xpEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get wordbookIds => $composableBuilder(
    column: $table.wordbookIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedCount => $composableBuilder(
    column: $table.plannedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpEarned =>
      $composableBuilder(column: $table.xpEarned, builder: (column) => column);

  GeneratedColumn<int> get avgReactionMs => $composableBuilder(
    column: $table.avgReactionMs,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> learningLogsRefs<T extends Object>(
    Expression<T> Function($$LearningLogsTableAnnotationComposer a) f,
  ) {
    final $$LearningLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.learningLogs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LearningLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.learningLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionsTable,
          StudySession,
          $$StudySessionsTableFilterComposer,
          $$StudySessionsTableOrderingComposer,
          $$StudySessionsTableAnnotationComposer,
          $$StudySessionsTableCreateCompanionBuilder,
          $$StudySessionsTableUpdateCompanionBuilder,
          (StudySession, $$StudySessionsTableReferences),
          StudySession,
          PrefetchHooks Function({bool profileId, bool learningLogsRefs})
        > {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> wordbookIds = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> plannedCount = const Value.absent(),
                Value<int> answeredCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<int?> avgReactionMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion(
                id: id,
                profileId: profileId,
                mode: mode,
                wordbookIds: wordbookIds,
                startedAt: startedAt,
                finishedAt: finishedAt,
                plannedCount: plannedCount,
                answeredCount: answeredCount,
                correctCount: correctCount,
                xpEarned: xpEarned,
                avgReactionMs: avgReactionMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int profileId,
                required String mode,
                Value<String> wordbookIds = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> plannedCount = const Value.absent(),
                Value<int> answeredCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> xpEarned = const Value.absent(),
                Value<int?> avgReactionMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionsCompanion.insert(
                id: id,
                profileId: profileId,
                mode: mode,
                wordbookIds: wordbookIds,
                startedAt: startedAt,
                finishedAt: finishedAt,
                plannedCount: plannedCount,
                answeredCount: answeredCount,
                correctCount: correctCount,
                xpEarned: xpEarned,
                avgReactionMs: avgReactionMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, learningLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (learningLogsRefs) db.learningLogs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$StudySessionsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$StudySessionsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (learningLogsRefs)
                        await $_getPrefetchedData<
                          StudySession,
                          $StudySessionsTable,
                          LearningLog
                        >(
                          currentTable: table,
                          referencedTable: $$StudySessionsTableReferences
                              ._learningLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudySessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).learningLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionsTable,
      StudySession,
      $$StudySessionsTableFilterComposer,
      $$StudySessionsTableOrderingComposer,
      $$StudySessionsTableAnnotationComposer,
      $$StudySessionsTableCreateCompanionBuilder,
      $$StudySessionsTableUpdateCompanionBuilder,
      (StudySession, $$StudySessionsTableReferences),
      StudySession,
      PrefetchHooks Function({bool profileId, bool learningLogsRefs})
    >;
typedef $$LearningLogsTableCreateCompanionBuilder =
    LearningLogsCompanion Function({
      Value<int> id,
      required int profileId,
      required String sessionId,
      Value<int?> wordId,
      Value<int?> partId,
      required String mode,
      required String direction,
      required bool isCorrect,
      required int grade,
      Value<String?> answeredText,
      Value<int> hintUsed,
      Value<int> replayCount,
      required int elapsedMs,
      required DateTime answeredAt,
    });
typedef $$LearningLogsTableUpdateCompanionBuilder =
    LearningLogsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<String> sessionId,
      Value<int?> wordId,
      Value<int?> partId,
      Value<String> mode,
      Value<String> direction,
      Value<bool> isCorrect,
      Value<int> grade,
      Value<String?> answeredText,
      Value<int> hintUsed,
      Value<int> replayCount,
      Value<int> elapsedMs,
      Value<DateTime> answeredAt,
    });

final class $$LearningLogsTableReferences
    extends BaseReferences<_$AppDatabase, $LearningLogsTable, LearningLog> {
  $$LearningLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('learning_logs__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudySessionsTable _sessionIdTable(_$AppDatabase db) => db
      .studySessions
      .createAlias('learning_logs__session_id__study_sessions__id');

  $$StudySessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionsTableTableManager(
      $_db,
      $_db.studySessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('learning_logs__word_id__words__id');

  $$WordsTableProcessedTableManager? get wordId {
    final $_column = $_itemColumn<int>('word_id');
    if ($_column == null) return null;
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordPartsTable _partIdTable(_$AppDatabase db) =>
      db.wordParts.createAlias('learning_logs__part_id__word_parts__id');

  $$WordPartsTableProcessedTableManager? get partId {
    final $_column = $_itemColumn<int>('part_id');
    if ($_column == null) return null;
    final manager = $$WordPartsTableTableManager(
      $_db,
      $_db.wordParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LearningLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LearningLogsTable> {
  $$LearningLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answeredText => $composableBuilder(
    column: $table.answeredText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintUsed => $composableBuilder(
    column: $table.hintUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionsTableFilterComposer get sessionId {
    final $$StudySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableFilterComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableFilterComposer get partId {
    final $$WordPartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableFilterComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearningLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningLogsTable> {
  $$LearningLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answeredText => $composableBuilder(
    column: $table.answeredText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintUsed => $composableBuilder(
    column: $table.hintUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionsTableOrderingComposer get sessionId {
    final $$StudySessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableOrderingComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableOrderingComposer get partId {
    final $$WordPartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableOrderingComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearningLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningLogsTable> {
  $$LearningLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get answeredText => $composableBuilder(
    column: $table.answeredText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintUsed =>
      $composableBuilder(column: $table.hintUsed, builder: (column) => column);

  GeneratedColumn<int> get replayCount => $composableBuilder(
    column: $table.replayCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudySessionsTableAnnotationComposer get sessionId {
    final $$StudySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.studySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordPartsTableAnnotationComposer get partId {
    final $$WordPartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.wordParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordPartsTableAnnotationComposer(
            $db: $db,
            $table: $db.wordParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LearningLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearningLogsTable,
          LearningLog,
          $$LearningLogsTableFilterComposer,
          $$LearningLogsTableOrderingComposer,
          $$LearningLogsTableAnnotationComposer,
          $$LearningLogsTableCreateCompanionBuilder,
          $$LearningLogsTableUpdateCompanionBuilder,
          (LearningLog, $$LearningLogsTableReferences),
          LearningLog,
          PrefetchHooks Function({
            bool profileId,
            bool sessionId,
            bool wordId,
            bool partId,
          })
        > {
  $$LearningLogsTableTableManager(_$AppDatabase db, $LearningLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int?> wordId = const Value.absent(),
                Value<int?> partId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> grade = const Value.absent(),
                Value<String?> answeredText = const Value.absent(),
                Value<int> hintUsed = const Value.absent(),
                Value<int> replayCount = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
              }) => LearningLogsCompanion(
                id: id,
                profileId: profileId,
                sessionId: sessionId,
                wordId: wordId,
                partId: partId,
                mode: mode,
                direction: direction,
                isCorrect: isCorrect,
                grade: grade,
                answeredText: answeredText,
                hintUsed: hintUsed,
                replayCount: replayCount,
                elapsedMs: elapsedMs,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required String sessionId,
                Value<int?> wordId = const Value.absent(),
                Value<int?> partId = const Value.absent(),
                required String mode,
                required String direction,
                required bool isCorrect,
                required int grade,
                Value<String?> answeredText = const Value.absent(),
                Value<int> hintUsed = const Value.absent(),
                Value<int> replayCount = const Value.absent(),
                required int elapsedMs,
                required DateTime answeredAt,
              }) => LearningLogsCompanion.insert(
                id: id,
                profileId: profileId,
                sessionId: sessionId,
                wordId: wordId,
                partId: partId,
                mode: mode,
                direction: direction,
                isCorrect: isCorrect,
                grade: grade,
                answeredText: answeredText,
                hintUsed: hintUsed,
                replayCount: replayCount,
                elapsedMs: elapsedMs,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LearningLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                profileId = false,
                sessionId = false,
                wordId = false,
                partId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable:
                                        $$LearningLogsTableReferences
                                            ._profileIdTable(db),
                                    referencedColumn:
                                        $$LearningLogsTableReferences
                                            ._profileIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$LearningLogsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$LearningLogsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (wordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wordId,
                                    referencedTable:
                                        $$LearningLogsTableReferences
                                            ._wordIdTable(db),
                                    referencedColumn:
                                        $$LearningLogsTableReferences
                                            ._wordIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (partId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partId,
                                    referencedTable:
                                        $$LearningLogsTableReferences
                                            ._partIdTable(db),
                                    referencedColumn:
                                        $$LearningLogsTableReferences
                                            ._partIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LearningLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearningLogsTable,
      LearningLog,
      $$LearningLogsTableFilterComposer,
      $$LearningLogsTableOrderingComposer,
      $$LearningLogsTableAnnotationComposer,
      $$LearningLogsTableCreateCompanionBuilder,
      $$LearningLogsTableUpdateCompanionBuilder,
      (LearningLog, $$LearningLogsTableReferences),
      LearningLog,
      PrefetchHooks Function({
        bool profileId,
        bool sessionId,
        bool wordId,
        bool partId,
      })
    >;
typedef $$DailyStatsTableCreateCompanionBuilder =
    DailyStatsCompanion Function({
      required int profileId,
      required String studyDate,
      Value<int> answeredCount,
      Value<int> correctCount,
      Value<int> xp,
      Value<int> studySeconds,
      required int goalCount,
      Value<bool> goalMet,
      Value<int> rowid,
    });
typedef $$DailyStatsTableUpdateCompanionBuilder =
    DailyStatsCompanion Function({
      Value<int> profileId,
      Value<String> studyDate,
      Value<int> answeredCount,
      Value<int> correctCount,
      Value<int> xp,
      Value<int> studySeconds,
      Value<int> goalCount,
      Value<bool> goalMet,
      Value<int> rowid,
    });

final class $$DailyStatsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStat> {
  $$DailyStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('daily_stats__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get studyDate => $composableBuilder(
    column: $table.studyDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalCount => $composableBuilder(
    column: $table.goalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get studyDate => $composableBuilder(
    column: $table.studyDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalCount => $composableBuilder(
    column: $table.goalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalMet => $composableBuilder(
    column: $table.goalMet,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get studyDate =>
      $composableBuilder(column: $table.studyDate, builder: (column) => column);

  GeneratedColumn<int> get answeredCount => $composableBuilder(
    column: $table.answeredCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalCount =>
      $composableBuilder(column: $table.goalCount, builder: (column) => column);

  GeneratedColumn<bool> get goalMet =>
      $composableBuilder(column: $table.goalMet, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStatsTable,
          DailyStat,
          $$DailyStatsTableFilterComposer,
          $$DailyStatsTableOrderingComposer,
          $$DailyStatsTableAnnotationComposer,
          $$DailyStatsTableCreateCompanionBuilder,
          $$DailyStatsTableUpdateCompanionBuilder,
          (DailyStat, $$DailyStatsTableReferences),
          DailyStat,
          PrefetchHooks Function({bool profileId})
        > {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<String> studyDate = const Value.absent(),
                Value<int> answeredCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> goalCount = const Value.absent(),
                Value<bool> goalMet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatsCompanion(
                profileId: profileId,
                studyDate: studyDate,
                answeredCount: answeredCount,
                correctCount: correctCount,
                xp: xp,
                studySeconds: studySeconds,
                goalCount: goalCount,
                goalMet: goalMet,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required String studyDate,
                Value<int> answeredCount = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                required int goalCount,
                Value<bool> goalMet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStatsCompanion.insert(
                profileId: profileId,
                studyDate: studyDate,
                answeredCount: answeredCount,
                correctCount: correctCount,
                xp: xp,
                studySeconds: studySeconds,
                goalCount: goalCount,
                goalMet: goalMet,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$DailyStatsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$DailyStatsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStatsTable,
      DailyStat,
      $$DailyStatsTableFilterComposer,
      $$DailyStatsTableOrderingComposer,
      $$DailyStatsTableAnnotationComposer,
      $$DailyStatsTableCreateCompanionBuilder,
      $$DailyStatsTableUpdateCompanionBuilder,
      (DailyStat, $$DailyStatsTableReferences),
      DailyStat,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required int profileId,
      required String code,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> profileId,
      Value<String> code,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

final class $$AchievementsTableReferences
    extends BaseReferences<_$AppDatabase, $AchievementsTable, Achievement> {
  $$AchievementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('achievements__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (Achievement, $$AchievementsTableReferences),
          Achievement,
          PrefetchHooks Function({bool profileId})
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> profileId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                profileId: profileId,
                code: code,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int profileId,
                required String code,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                profileId: profileId,
                code: code,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AchievementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$AchievementsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn: $$AchievementsTableReferences
                                    ._profileIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (Achievement, $$AchievementsTableReferences),
      Achievement,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$VocabSizeTestsTableCreateCompanionBuilder =
    VocabSizeTestsCompanion Function({
      Value<int> id,
      required int profileId,
      required DateTime takenAt,
      required int estimatedSize,
      required double falseAlarmRate,
      Value<String> bandResults,
      Value<String> askedWordIds,
    });
typedef $$VocabSizeTestsTableUpdateCompanionBuilder =
    VocabSizeTestsCompanion Function({
      Value<int> id,
      Value<int> profileId,
      Value<DateTime> takenAt,
      Value<int> estimatedSize,
      Value<double> falseAlarmRate,
      Value<String> bandResults,
      Value<String> askedWordIds,
    });

final class $$VocabSizeTestsTableReferences
    extends BaseReferences<_$AppDatabase, $VocabSizeTestsTable, VocabSizeTest> {
  $$VocabSizeTestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('vocab_size_tests__profile_id__profiles__id');

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VocabSizeTestsTableFilterComposer
    extends Composer<_$AppDatabase, $VocabSizeTestsTable> {
  $$VocabSizeTestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedSize => $composableBuilder(
    column: $table.estimatedSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get falseAlarmRate => $composableBuilder(
    column: $table.falseAlarmRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandResults => $composableBuilder(
    column: $table.bandResults,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get askedWordIds => $composableBuilder(
    column: $table.askedWordIds,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VocabSizeTestsTableOrderingComposer
    extends Composer<_$AppDatabase, $VocabSizeTestsTable> {
  $$VocabSizeTestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedSize => $composableBuilder(
    column: $table.estimatedSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get falseAlarmRate => $composableBuilder(
    column: $table.falseAlarmRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandResults => $composableBuilder(
    column: $table.bandResults,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get askedWordIds => $composableBuilder(
    column: $table.askedWordIds,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VocabSizeTestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VocabSizeTestsTable> {
  $$VocabSizeTestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get estimatedSize => $composableBuilder(
    column: $table.estimatedSize,
    builder: (column) => column,
  );

  GeneratedColumn<double> get falseAlarmRate => $composableBuilder(
    column: $table.falseAlarmRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bandResults => $composableBuilder(
    column: $table.bandResults,
    builder: (column) => column,
  );

  GeneratedColumn<String> get askedWordIds => $composableBuilder(
    column: $table.askedWordIds,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VocabSizeTestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VocabSizeTestsTable,
          VocabSizeTest,
          $$VocabSizeTestsTableFilterComposer,
          $$VocabSizeTestsTableOrderingComposer,
          $$VocabSizeTestsTableAnnotationComposer,
          $$VocabSizeTestsTableCreateCompanionBuilder,
          $$VocabSizeTestsTableUpdateCompanionBuilder,
          (VocabSizeTest, $$VocabSizeTestsTableReferences),
          VocabSizeTest,
          PrefetchHooks Function({bool profileId})
        > {
  $$VocabSizeTestsTableTableManager(
    _$AppDatabase db,
    $VocabSizeTestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabSizeTestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabSizeTestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabSizeTestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> profileId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> estimatedSize = const Value.absent(),
                Value<double> falseAlarmRate = const Value.absent(),
                Value<String> bandResults = const Value.absent(),
                Value<String> askedWordIds = const Value.absent(),
              }) => VocabSizeTestsCompanion(
                id: id,
                profileId: profileId,
                takenAt: takenAt,
                estimatedSize: estimatedSize,
                falseAlarmRate: falseAlarmRate,
                bandResults: bandResults,
                askedWordIds: askedWordIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int profileId,
                required DateTime takenAt,
                required int estimatedSize,
                required double falseAlarmRate,
                Value<String> bandResults = const Value.absent(),
                Value<String> askedWordIds = const Value.absent(),
              }) => VocabSizeTestsCompanion.insert(
                id: id,
                profileId: profileId,
                takenAt: takenAt,
                estimatedSize: estimatedSize,
                falseAlarmRate: falseAlarmRate,
                bandResults: bandResults,
                askedWordIds: askedWordIds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VocabSizeTestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.profileId,
                                referencedTable: $$VocabSizeTestsTableReferences
                                    ._profileIdTable(db),
                                referencedColumn:
                                    $$VocabSizeTestsTableReferences
                                        ._profileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VocabSizeTestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VocabSizeTestsTable,
      VocabSizeTest,
      $$VocabSizeTestsTableFilterComposer,
      $$VocabSizeTestsTableOrderingComposer,
      $$VocabSizeTestsTableAnnotationComposer,
      $$VocabSizeTestsTableCreateCompanionBuilder,
      $$VocabSizeTestsTableUpdateCompanionBuilder,
      (VocabSizeTest, $$VocabSizeTestsTableReferences),
      VocabSizeTest,
      PrefetchHooks Function({bool profileId})
    >;
typedef $$AudioPacksTableCreateCompanionBuilder =
    AudioPacksCompanion Function({
      Value<int> id,
      required String packId,
      required String name,
      required String source,
      required String lang,
      Value<String?> note,
      Value<int> entryCount,
      Value<DateTime> installedAt,
      Value<int> sortOrder,
    });
typedef $$AudioPacksTableUpdateCompanionBuilder =
    AudioPacksCompanion Function({
      Value<int> id,
      Value<String> packId,
      Value<String> name,
      Value<String> source,
      Value<String> lang,
      Value<String?> note,
      Value<int> entryCount,
      Value<DateTime> installedAt,
      Value<int> sortOrder,
    });

final class $$AudioPacksTableReferences
    extends BaseReferences<_$AppDatabase, $AudioPacksTable, AudioPack> {
  $$AudioPacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordAudiosTable, List<WordAudio>>
  _wordAudiosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordAudios,
    aliasName: 'audio_packs__id__word_audios__pack_id',
  );

  $$WordAudiosTableProcessedTableManager get wordAudiosRefs {
    final manager = $$WordAudiosTableTableManager(
      $_db,
      $_db.wordAudios,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordAudiosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioPacksTableFilterComposer
    extends Composer<_$AppDatabase, $AudioPacksTable> {
  $$AudioPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordAudiosRefs(
    Expression<bool> Function($$WordAudiosTableFilterComposer f) f,
  ) {
    final $$WordAudiosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordAudios,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordAudiosTableFilterComposer(
            $db: $db,
            $table: $db.wordAudios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioPacksTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioPacksTable> {
  $$AudioPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioPacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioPacksTable> {
  $$AudioPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> wordAudiosRefs<T extends Object>(
    Expression<T> Function($$WordAudiosTableAnnotationComposer a) f,
  ) {
    final $$WordAudiosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordAudios,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordAudiosTableAnnotationComposer(
            $db: $db,
            $table: $db.wordAudios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioPacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioPacksTable,
          AudioPack,
          $$AudioPacksTableFilterComposer,
          $$AudioPacksTableOrderingComposer,
          $$AudioPacksTableAnnotationComposer,
          $$AudioPacksTableCreateCompanionBuilder,
          $$AudioPacksTableUpdateCompanionBuilder,
          (AudioPack, $$AudioPacksTableReferences),
          AudioPack,
          PrefetchHooks Function({bool wordAudiosRefs})
        > {
  $$AudioPacksTableTableManager(_$AppDatabase db, $AudioPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => AudioPacksCompanion(
                id: id,
                packId: packId,
                name: name,
                source: source,
                lang: lang,
                note: note,
                entryCount: entryCount,
                installedAt: installedAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packId,
                required String name,
                required String source,
                required String lang,
                Value<String?> note = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => AudioPacksCompanion.insert(
                id: id,
                packId: packId,
                name: name,
                source: source,
                lang: lang,
                note: note,
                entryCount: entryCount,
                installedAt: installedAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AudioPacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordAudiosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordAudiosRefs) db.wordAudios],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordAudiosRefs)
                    await $_getPrefetchedData<
                      AudioPack,
                      $AudioPacksTable,
                      WordAudio
                    >(
                      currentTable: table,
                      referencedTable: $$AudioPacksTableReferences
                          ._wordAudiosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AudioPacksTableReferences(
                            db,
                            table,
                            p0,
                          ).wordAudiosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.packId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AudioPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioPacksTable,
      AudioPack,
      $$AudioPacksTableFilterComposer,
      $$AudioPacksTableOrderingComposer,
      $$AudioPacksTableAnnotationComposer,
      $$AudioPacksTableCreateCompanionBuilder,
      $$AudioPacksTableUpdateCompanionBuilder,
      (AudioPack, $$AudioPacksTableReferences),
      AudioPack,
      PrefetchHooks Function({bool wordAudiosRefs})
    >;
typedef $$WordAudiosTableCreateCompanionBuilder =
    WordAudiosCompanion Function({
      Value<int> id,
      required int wordId,
      required int packId,
      required String lang,
      required String filePath,
    });
typedef $$WordAudiosTableUpdateCompanionBuilder =
    WordAudiosCompanion Function({
      Value<int> id,
      Value<int> wordId,
      Value<int> packId,
      Value<String> lang,
      Value<String> filePath,
    });

final class $$WordAudiosTableReferences
    extends BaseReferences<_$AppDatabase, $WordAudiosTable, WordAudio> {
  $$WordAudiosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_audios__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AudioPacksTable _packIdTable(_$AppDatabase db) =>
      db.audioPacks.createAlias('word_audios__pack_id__audio_packs__id');

  $$AudioPacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<int>('pack_id')!;

    final manager = $$AudioPacksTableTableManager(
      $_db,
      $_db.audioPacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordAudiosTableFilterComposer
    extends Composer<_$AppDatabase, $WordAudiosTable> {
  $$WordAudiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioPacksTableFilterComposer get packId {
    final $$AudioPacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.audioPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPacksTableFilterComposer(
            $db: $db,
            $table: $db.audioPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordAudiosTableOrderingComposer
    extends Composer<_$AppDatabase, $WordAudiosTable> {
  $$WordAudiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioPacksTableOrderingComposer get packId {
    final $$AudioPacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.audioPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPacksTableOrderingComposer(
            $db: $db,
            $table: $db.audioPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordAudiosTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordAudiosTable> {
  $$WordAudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AudioPacksTableAnnotationComposer get packId {
    final $$AudioPacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.audioPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioPacksTableAnnotationComposer(
            $db: $db,
            $table: $db.audioPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordAudiosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordAudiosTable,
          WordAudio,
          $$WordAudiosTableFilterComposer,
          $$WordAudiosTableOrderingComposer,
          $$WordAudiosTableAnnotationComposer,
          $$WordAudiosTableCreateCompanionBuilder,
          $$WordAudiosTableUpdateCompanionBuilder,
          (WordAudio, $$WordAudiosTableReferences),
          WordAudio,
          PrefetchHooks Function({bool wordId, bool packId})
        > {
  $$WordAudiosTableTableManager(_$AppDatabase db, $WordAudiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordAudiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordAudiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordAudiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> packId = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> filePath = const Value.absent(),
              }) => WordAudiosCompanion(
                id: id,
                wordId: wordId,
                packId: packId,
                lang: lang,
                filePath: filePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wordId,
                required int packId,
                required String lang,
                required String filePath,
              }) => WordAudiosCompanion.insert(
                id: id,
                wordId: wordId,
                packId: packId,
                lang: lang,
                filePath: filePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordAudiosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordAudiosTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordAudiosTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (packId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.packId,
                                referencedTable: $$WordAudiosTableReferences
                                    ._packIdTable(db),
                                referencedColumn: $$WordAudiosTableReferences
                                    ._packIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordAudiosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordAudiosTable,
      WordAudio,
      $$WordAudiosTableFilterComposer,
      $$WordAudiosTableOrderingComposer,
      $$WordAudiosTableAnnotationComposer,
      $$WordAudiosTableCreateCompanionBuilder,
      $$WordAudiosTableUpdateCompanionBuilder,
      (WordAudio, $$WordAudiosTableReferences),
      WordAudio,
      PrefetchHooks Function({bool wordId, bool packId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$WordFamiliesTableTableManager get wordFamilies =>
      $$WordFamiliesTableTableManager(_db, _db.wordFamilies);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordExamplesTableTableManager get wordExamples =>
      $$WordExamplesTableTableManager(_db, _db.wordExamples);
  $$WordbooksTableTableManager get wordbooks =>
      $$WordbooksTableTableManager(_db, _db.wordbooks);
  $$WordbookEntriesTableTableManager get wordbookEntries =>
      $$WordbookEntriesTableTableManager(_db, _db.wordbookEntries);
  $$WordPartsTableTableManager get wordParts =>
      $$WordPartsTableTableManager(_db, _db.wordParts);
  $$WordPartLinksTableTableManager get wordPartLinks =>
      $$WordPartLinksTableTableManager(_db, _db.wordPartLinks);
  $$WordReviewsTableTableManager get wordReviews =>
      $$WordReviewsTableTableManager(_db, _db.wordReviews);
  $$PartReviewsTableTableManager get partReviews =>
      $$PartReviewsTableTableManager(_db, _db.partReviews);
  $$ResolvedConfusionsTableTableManager get resolvedConfusions =>
      $$ResolvedConfusionsTableTableManager(_db, _db.resolvedConfusions);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$LearningLogsTableTableManager get learningLogs =>
      $$LearningLogsTableTableManager(_db, _db.learningLogs);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$VocabSizeTestsTableTableManager get vocabSizeTests =>
      $$VocabSizeTestsTableTableManager(_db, _db.vocabSizeTests);
  $$AudioPacksTableTableManager get audioPacks =>
      $$AudioPacksTableTableManager(_db, _db.audioPacks);
  $$WordAudiosTableTableManager get wordAudios =>
      $$WordAudiosTableTableManager(_db, _db.wordAudios);
}
