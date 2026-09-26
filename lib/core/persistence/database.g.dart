// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayerStateTable extends PlayerState
    with TableInfo<$PlayerStateTable, PlayerStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _moneyMeta = const VerificationMeta('money');
  @override
  late final GeneratedColumn<int> money = GeneratedColumn<int>(
    'money',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registerMeta = const VerificationMeta(
    'register',
  );
  @override
  late final GeneratedColumn<int> register = GeneratedColumn<int>(
    'register',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ticketsMeta = const VerificationMeta(
    'tickets',
  );
  @override
  late final GeneratedColumn<int> tickets = GeneratedColumn<int>(
    'tickets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSimulatedAtMeta = const VerificationMeta(
    'lastSimulatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSimulatedAt =
      GeneratedColumn<DateTime>(
        'last_simulated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastDailyTicketDateMeta =
      const VerificationMeta('lastDailyTicketDate');
  @override
  late final GeneratedColumn<String> lastDailyTicketDate =
      GeneratedColumn<String>(
        'last_daily_ticket_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gachaPityMeta = const VerificationMeta(
    'gachaPity',
  );
  @override
  late final GeneratedColumn<int> gachaPity = GeneratedColumn<int>(
    'gacha_pity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gachaDrawsMeta = const VerificationMeta(
    'gachaDraws',
  );
  @override
  late final GeneratedColumn<int> gachaDraws = GeneratedColumn<int>(
    'gacha_draws',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adFreeMeta = const VerificationMeta('adFree');
  @override
  late final GeneratedColumn<bool> adFree = GeneratedColumn<bool>(
    'ad_free',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ad_free" IN (0, 1))',
    ),
  );
  static const VerificationMeta _activeBgmMeta = const VerificationMeta(
    'activeBgm',
  );
  @override
  late final GeneratedColumn<String> activeBgm = GeneratedColumn<String>(
    'active_bgm',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debugOffsetMinutesMeta =
      const VerificationMeta('debugOffsetMinutes');
  @override
  late final GeneratedColumn<int> debugOffsetMinutes = GeneratedColumn<int>(
    'debug_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatedJsonMeta = const VerificationMeta(
    'seatedJson',
  );
  @override
  late final GeneratedColumn<String> seatedJson = GeneratedColumn<String>(
    'seated_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recentVisitsJsonMeta = const VerificationMeta(
    'recentVisitsJson',
  );
  @override
  late final GeneratedColumn<String> recentVisitsJson = GeneratedColumn<String>(
    'recent_visits_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeEffectsJsonMeta = const VerificationMeta(
    'activeEffectsJson',
  );
  @override
  late final GeneratedColumn<String> activeEffectsJson =
      GeneratedColumn<String>(
        'active_effects_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingReportJsonMeta = const VerificationMeta(
    'pendingReportJson',
  );
  @override
  late final GeneratedColumn<String> pendingReportJson =
      GeneratedColumn<String>(
        'pending_report_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    money,
    register,
    tickets,
    lastSimulatedAt,
    lastDailyTicketDate,
    gachaPity,
    gachaDraws,
    adFree,
    activeBgm,
    debugOffsetMinutes,
    seatedJson,
    recentVisitsJson,
    activeEffectsJson,
    settingsJson,
    pendingReportJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('money')) {
      context.handle(
        _moneyMeta,
        money.isAcceptableOrUnknown(data['money']!, _moneyMeta),
      );
    } else if (isInserting) {
      context.missing(_moneyMeta);
    }
    if (data.containsKey('register')) {
      context.handle(
        _registerMeta,
        register.isAcceptableOrUnknown(data['register']!, _registerMeta),
      );
    } else if (isInserting) {
      context.missing(_registerMeta);
    }
    if (data.containsKey('tickets')) {
      context.handle(
        _ticketsMeta,
        tickets.isAcceptableOrUnknown(data['tickets']!, _ticketsMeta),
      );
    } else if (isInserting) {
      context.missing(_ticketsMeta);
    }
    if (data.containsKey('last_simulated_at')) {
      context.handle(
        _lastSimulatedAtMeta,
        lastSimulatedAt.isAcceptableOrUnknown(
          data['last_simulated_at']!,
          _lastSimulatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSimulatedAtMeta);
    }
    if (data.containsKey('last_daily_ticket_date')) {
      context.handle(
        _lastDailyTicketDateMeta,
        lastDailyTicketDate.isAcceptableOrUnknown(
          data['last_daily_ticket_date']!,
          _lastDailyTicketDateMeta,
        ),
      );
    }
    if (data.containsKey('gacha_pity')) {
      context.handle(
        _gachaPityMeta,
        gachaPity.isAcceptableOrUnknown(data['gacha_pity']!, _gachaPityMeta),
      );
    } else if (isInserting) {
      context.missing(_gachaPityMeta);
    }
    if (data.containsKey('gacha_draws')) {
      context.handle(
        _gachaDrawsMeta,
        gachaDraws.isAcceptableOrUnknown(data['gacha_draws']!, _gachaDrawsMeta),
      );
    } else if (isInserting) {
      context.missing(_gachaDrawsMeta);
    }
    if (data.containsKey('ad_free')) {
      context.handle(
        _adFreeMeta,
        adFree.isAcceptableOrUnknown(data['ad_free']!, _adFreeMeta),
      );
    } else if (isInserting) {
      context.missing(_adFreeMeta);
    }
    if (data.containsKey('active_bgm')) {
      context.handle(
        _activeBgmMeta,
        activeBgm.isAcceptableOrUnknown(data['active_bgm']!, _activeBgmMeta),
      );
    }
    if (data.containsKey('debug_offset_minutes')) {
      context.handle(
        _debugOffsetMinutesMeta,
        debugOffsetMinutes.isAcceptableOrUnknown(
          data['debug_offset_minutes']!,
          _debugOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_debugOffsetMinutesMeta);
    }
    if (data.containsKey('seated_json')) {
      context.handle(
        _seatedJsonMeta,
        seatedJson.isAcceptableOrUnknown(data['seated_json']!, _seatedJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_seatedJsonMeta);
    }
    if (data.containsKey('recent_visits_json')) {
      context.handle(
        _recentVisitsJsonMeta,
        recentVisitsJson.isAcceptableOrUnknown(
          data['recent_visits_json']!,
          _recentVisitsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recentVisitsJsonMeta);
    }
    if (data.containsKey('active_effects_json')) {
      context.handle(
        _activeEffectsJsonMeta,
        activeEffectsJson.isAcceptableOrUnknown(
          data['active_effects_json']!,
          _activeEffectsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeEffectsJsonMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('pending_report_json')) {
      context.handle(
        _pendingReportJsonMeta,
        pendingReportJson.isAcceptableOrUnknown(
          data['pending_report_json']!,
          _pendingReportJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      money: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}money'],
      )!,
      register: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}register'],
      )!,
      tickets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tickets'],
      )!,
      lastSimulatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_simulated_at'],
      )!,
      lastDailyTicketDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_daily_ticket_date'],
      ),
      gachaPity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gacha_pity'],
      )!,
      gachaDraws: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gacha_draws'],
      )!,
      adFree: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ad_free'],
      )!,
      activeBgm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_bgm'],
      ),
      debugOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}debug_offset_minutes'],
      )!,
      seatedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seated_json'],
      )!,
      recentVisitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recent_visits_json'],
      )!,
      activeEffectsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_effects_json'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      pendingReportJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pending_report_json'],
      ),
    );
  }

  @override
  $PlayerStateTable createAlias(String alias) {
    return $PlayerStateTable(attachedDatabase, alias);
  }
}

class PlayerStateData extends DataClass implements Insertable<PlayerStateData> {
  final int id;
  final int money;
  final int register;
  final int tickets;
  final DateTime lastSimulatedAt;
  final String? lastDailyTicketDate;
  final int gachaPity;
  final int gachaDraws;
  final bool adFree;
  final String? activeBgm;
  final int debugOffsetMinutes;

  /// 画面の状態に近いもの（席の客・直近の来店・設定・未読の放置結果）は
  /// 検索しないので JSON のまま持つ。
  final String seatedJson;
  final String recentVisitsJson;
  final String activeEffectsJson;
  final String settingsJson;
  final String? pendingReportJson;
  const PlayerStateData({
    required this.id,
    required this.money,
    required this.register,
    required this.tickets,
    required this.lastSimulatedAt,
    this.lastDailyTicketDate,
    required this.gachaPity,
    required this.gachaDraws,
    required this.adFree,
    this.activeBgm,
    required this.debugOffsetMinutes,
    required this.seatedJson,
    required this.recentVisitsJson,
    required this.activeEffectsJson,
    required this.settingsJson,
    this.pendingReportJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['money'] = Variable<int>(money);
    map['register'] = Variable<int>(register);
    map['tickets'] = Variable<int>(tickets);
    map['last_simulated_at'] = Variable<DateTime>(lastSimulatedAt);
    if (!nullToAbsent || lastDailyTicketDate != null) {
      map['last_daily_ticket_date'] = Variable<String>(lastDailyTicketDate);
    }
    map['gacha_pity'] = Variable<int>(gachaPity);
    map['gacha_draws'] = Variable<int>(gachaDraws);
    map['ad_free'] = Variable<bool>(adFree);
    if (!nullToAbsent || activeBgm != null) {
      map['active_bgm'] = Variable<String>(activeBgm);
    }
    map['debug_offset_minutes'] = Variable<int>(debugOffsetMinutes);
    map['seated_json'] = Variable<String>(seatedJson);
    map['recent_visits_json'] = Variable<String>(recentVisitsJson);
    map['active_effects_json'] = Variable<String>(activeEffectsJson);
    map['settings_json'] = Variable<String>(settingsJson);
    if (!nullToAbsent || pendingReportJson != null) {
      map['pending_report_json'] = Variable<String>(pendingReportJson);
    }
    return map;
  }

  PlayerStateCompanion toCompanion(bool nullToAbsent) {
    return PlayerStateCompanion(
      id: Value(id),
      money: Value(money),
      register: Value(register),
      tickets: Value(tickets),
      lastSimulatedAt: Value(lastSimulatedAt),
      lastDailyTicketDate: lastDailyTicketDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDailyTicketDate),
      gachaPity: Value(gachaPity),
      gachaDraws: Value(gachaDraws),
      adFree: Value(adFree),
      activeBgm: activeBgm == null && nullToAbsent
          ? const Value.absent()
          : Value(activeBgm),
      debugOffsetMinutes: Value(debugOffsetMinutes),
      seatedJson: Value(seatedJson),
      recentVisitsJson: Value(recentVisitsJson),
      activeEffectsJson: Value(activeEffectsJson),
      settingsJson: Value(settingsJson),
      pendingReportJson: pendingReportJson == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingReportJson),
    );
  }

  factory PlayerStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerStateData(
      id: serializer.fromJson<int>(json['id']),
      money: serializer.fromJson<int>(json['money']),
      register: serializer.fromJson<int>(json['register']),
      tickets: serializer.fromJson<int>(json['tickets']),
      lastSimulatedAt: serializer.fromJson<DateTime>(json['lastSimulatedAt']),
      lastDailyTicketDate: serializer.fromJson<String?>(
        json['lastDailyTicketDate'],
      ),
      gachaPity: serializer.fromJson<int>(json['gachaPity']),
      gachaDraws: serializer.fromJson<int>(json['gachaDraws']),
      adFree: serializer.fromJson<bool>(json['adFree']),
      activeBgm: serializer.fromJson<String?>(json['activeBgm']),
      debugOffsetMinutes: serializer.fromJson<int>(json['debugOffsetMinutes']),
      seatedJson: serializer.fromJson<String>(json['seatedJson']),
      recentVisitsJson: serializer.fromJson<String>(json['recentVisitsJson']),
      activeEffectsJson: serializer.fromJson<String>(json['activeEffectsJson']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      pendingReportJson: serializer.fromJson<String?>(
        json['pendingReportJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'money': serializer.toJson<int>(money),
      'register': serializer.toJson<int>(register),
      'tickets': serializer.toJson<int>(tickets),
      'lastSimulatedAt': serializer.toJson<DateTime>(lastSimulatedAt),
      'lastDailyTicketDate': serializer.toJson<String?>(lastDailyTicketDate),
      'gachaPity': serializer.toJson<int>(gachaPity),
      'gachaDraws': serializer.toJson<int>(gachaDraws),
      'adFree': serializer.toJson<bool>(adFree),
      'activeBgm': serializer.toJson<String?>(activeBgm),
      'debugOffsetMinutes': serializer.toJson<int>(debugOffsetMinutes),
      'seatedJson': serializer.toJson<String>(seatedJson),
      'recentVisitsJson': serializer.toJson<String>(recentVisitsJson),
      'activeEffectsJson': serializer.toJson<String>(activeEffectsJson),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'pendingReportJson': serializer.toJson<String?>(pendingReportJson),
    };
  }

  PlayerStateData copyWith({
    int? id,
    int? money,
    int? register,
    int? tickets,
    DateTime? lastSimulatedAt,
    Value<String?> lastDailyTicketDate = const Value.absent(),
    int? gachaPity,
    int? gachaDraws,
    bool? adFree,
    Value<String?> activeBgm = const Value.absent(),
    int? debugOffsetMinutes,
    String? seatedJson,
    String? recentVisitsJson,
    String? activeEffectsJson,
    String? settingsJson,
    Value<String?> pendingReportJson = const Value.absent(),
  }) => PlayerStateData(
    id: id ?? this.id,
    money: money ?? this.money,
    register: register ?? this.register,
    tickets: tickets ?? this.tickets,
    lastSimulatedAt: lastSimulatedAt ?? this.lastSimulatedAt,
    lastDailyTicketDate: lastDailyTicketDate.present
        ? lastDailyTicketDate.value
        : this.lastDailyTicketDate,
    gachaPity: gachaPity ?? this.gachaPity,
    gachaDraws: gachaDraws ?? this.gachaDraws,
    adFree: adFree ?? this.adFree,
    activeBgm: activeBgm.present ? activeBgm.value : this.activeBgm,
    debugOffsetMinutes: debugOffsetMinutes ?? this.debugOffsetMinutes,
    seatedJson: seatedJson ?? this.seatedJson,
    recentVisitsJson: recentVisitsJson ?? this.recentVisitsJson,
    activeEffectsJson: activeEffectsJson ?? this.activeEffectsJson,
    settingsJson: settingsJson ?? this.settingsJson,
    pendingReportJson: pendingReportJson.present
        ? pendingReportJson.value
        : this.pendingReportJson,
  );
  PlayerStateData copyWithCompanion(PlayerStateCompanion data) {
    return PlayerStateData(
      id: data.id.present ? data.id.value : this.id,
      money: data.money.present ? data.money.value : this.money,
      register: data.register.present ? data.register.value : this.register,
      tickets: data.tickets.present ? data.tickets.value : this.tickets,
      lastSimulatedAt: data.lastSimulatedAt.present
          ? data.lastSimulatedAt.value
          : this.lastSimulatedAt,
      lastDailyTicketDate: data.lastDailyTicketDate.present
          ? data.lastDailyTicketDate.value
          : this.lastDailyTicketDate,
      gachaPity: data.gachaPity.present ? data.gachaPity.value : this.gachaPity,
      gachaDraws: data.gachaDraws.present
          ? data.gachaDraws.value
          : this.gachaDraws,
      adFree: data.adFree.present ? data.adFree.value : this.adFree,
      activeBgm: data.activeBgm.present ? data.activeBgm.value : this.activeBgm,
      debugOffsetMinutes: data.debugOffsetMinutes.present
          ? data.debugOffsetMinutes.value
          : this.debugOffsetMinutes,
      seatedJson: data.seatedJson.present
          ? data.seatedJson.value
          : this.seatedJson,
      recentVisitsJson: data.recentVisitsJson.present
          ? data.recentVisitsJson.value
          : this.recentVisitsJson,
      activeEffectsJson: data.activeEffectsJson.present
          ? data.activeEffectsJson.value
          : this.activeEffectsJson,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      pendingReportJson: data.pendingReportJson.present
          ? data.pendingReportJson.value
          : this.pendingReportJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateData(')
          ..write('id: $id, ')
          ..write('money: $money, ')
          ..write('register: $register, ')
          ..write('tickets: $tickets, ')
          ..write('lastSimulatedAt: $lastSimulatedAt, ')
          ..write('lastDailyTicketDate: $lastDailyTicketDate, ')
          ..write('gachaPity: $gachaPity, ')
          ..write('gachaDraws: $gachaDraws, ')
          ..write('adFree: $adFree, ')
          ..write('activeBgm: $activeBgm, ')
          ..write('debugOffsetMinutes: $debugOffsetMinutes, ')
          ..write('seatedJson: $seatedJson, ')
          ..write('recentVisitsJson: $recentVisitsJson, ')
          ..write('activeEffectsJson: $activeEffectsJson, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('pendingReportJson: $pendingReportJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    money,
    register,
    tickets,
    lastSimulatedAt,
    lastDailyTicketDate,
    gachaPity,
    gachaDraws,
    adFree,
    activeBgm,
    debugOffsetMinutes,
    seatedJson,
    recentVisitsJson,
    activeEffectsJson,
    settingsJson,
    pendingReportJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerStateData &&
          other.id == this.id &&
          other.money == this.money &&
          other.register == this.register &&
          other.tickets == this.tickets &&
          other.lastSimulatedAt == this.lastSimulatedAt &&
          other.lastDailyTicketDate == this.lastDailyTicketDate &&
          other.gachaPity == this.gachaPity &&
          other.gachaDraws == this.gachaDraws &&
          other.adFree == this.adFree &&
          other.activeBgm == this.activeBgm &&
          other.debugOffsetMinutes == this.debugOffsetMinutes &&
          other.seatedJson == this.seatedJson &&
          other.recentVisitsJson == this.recentVisitsJson &&
          other.activeEffectsJson == this.activeEffectsJson &&
          other.settingsJson == this.settingsJson &&
          other.pendingReportJson == this.pendingReportJson);
}

class PlayerStateCompanion extends UpdateCompanion<PlayerStateData> {
  final Value<int> id;
  final Value<int> money;
  final Value<int> register;
  final Value<int> tickets;
  final Value<DateTime> lastSimulatedAt;
  final Value<String?> lastDailyTicketDate;
  final Value<int> gachaPity;
  final Value<int> gachaDraws;
  final Value<bool> adFree;
  final Value<String?> activeBgm;
  final Value<int> debugOffsetMinutes;
  final Value<String> seatedJson;
  final Value<String> recentVisitsJson;
  final Value<String> activeEffectsJson;
  final Value<String> settingsJson;
  final Value<String?> pendingReportJson;
  const PlayerStateCompanion({
    this.id = const Value.absent(),
    this.money = const Value.absent(),
    this.register = const Value.absent(),
    this.tickets = const Value.absent(),
    this.lastSimulatedAt = const Value.absent(),
    this.lastDailyTicketDate = const Value.absent(),
    this.gachaPity = const Value.absent(),
    this.gachaDraws = const Value.absent(),
    this.adFree = const Value.absent(),
    this.activeBgm = const Value.absent(),
    this.debugOffsetMinutes = const Value.absent(),
    this.seatedJson = const Value.absent(),
    this.recentVisitsJson = const Value.absent(),
    this.activeEffectsJson = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.pendingReportJson = const Value.absent(),
  });
  PlayerStateCompanion.insert({
    this.id = const Value.absent(),
    required int money,
    required int register,
    required int tickets,
    required DateTime lastSimulatedAt,
    this.lastDailyTicketDate = const Value.absent(),
    required int gachaPity,
    required int gachaDraws,
    required bool adFree,
    this.activeBgm = const Value.absent(),
    required int debugOffsetMinutes,
    required String seatedJson,
    required String recentVisitsJson,
    required String activeEffectsJson,
    required String settingsJson,
    this.pendingReportJson = const Value.absent(),
  }) : money = Value(money),
       register = Value(register),
       tickets = Value(tickets),
       lastSimulatedAt = Value(lastSimulatedAt),
       gachaPity = Value(gachaPity),
       gachaDraws = Value(gachaDraws),
       adFree = Value(adFree),
       debugOffsetMinutes = Value(debugOffsetMinutes),
       seatedJson = Value(seatedJson),
       recentVisitsJson = Value(recentVisitsJson),
       activeEffectsJson = Value(activeEffectsJson),
       settingsJson = Value(settingsJson);
  static Insertable<PlayerStateData> custom({
    Expression<int>? id,
    Expression<int>? money,
    Expression<int>? register,
    Expression<int>? tickets,
    Expression<DateTime>? lastSimulatedAt,
    Expression<String>? lastDailyTicketDate,
    Expression<int>? gachaPity,
    Expression<int>? gachaDraws,
    Expression<bool>? adFree,
    Expression<String>? activeBgm,
    Expression<int>? debugOffsetMinutes,
    Expression<String>? seatedJson,
    Expression<String>? recentVisitsJson,
    Expression<String>? activeEffectsJson,
    Expression<String>? settingsJson,
    Expression<String>? pendingReportJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (money != null) 'money': money,
      if (register != null) 'register': register,
      if (tickets != null) 'tickets': tickets,
      if (lastSimulatedAt != null) 'last_simulated_at': lastSimulatedAt,
      if (lastDailyTicketDate != null)
        'last_daily_ticket_date': lastDailyTicketDate,
      if (gachaPity != null) 'gacha_pity': gachaPity,
      if (gachaDraws != null) 'gacha_draws': gachaDraws,
      if (adFree != null) 'ad_free': adFree,
      if (activeBgm != null) 'active_bgm': activeBgm,
      if (debugOffsetMinutes != null)
        'debug_offset_minutes': debugOffsetMinutes,
      if (seatedJson != null) 'seated_json': seatedJson,
      if (recentVisitsJson != null) 'recent_visits_json': recentVisitsJson,
      if (activeEffectsJson != null) 'active_effects_json': activeEffectsJson,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (pendingReportJson != null) 'pending_report_json': pendingReportJson,
    });
  }

  PlayerStateCompanion copyWith({
    Value<int>? id,
    Value<int>? money,
    Value<int>? register,
    Value<int>? tickets,
    Value<DateTime>? lastSimulatedAt,
    Value<String?>? lastDailyTicketDate,
    Value<int>? gachaPity,
    Value<int>? gachaDraws,
    Value<bool>? adFree,
    Value<String?>? activeBgm,
    Value<int>? debugOffsetMinutes,
    Value<String>? seatedJson,
    Value<String>? recentVisitsJson,
    Value<String>? activeEffectsJson,
    Value<String>? settingsJson,
    Value<String?>? pendingReportJson,
  }) {
    return PlayerStateCompanion(
      id: id ?? this.id,
      money: money ?? this.money,
      register: register ?? this.register,
      tickets: tickets ?? this.tickets,
      lastSimulatedAt: lastSimulatedAt ?? this.lastSimulatedAt,
      lastDailyTicketDate: lastDailyTicketDate ?? this.lastDailyTicketDate,
      gachaPity: gachaPity ?? this.gachaPity,
      gachaDraws: gachaDraws ?? this.gachaDraws,
      adFree: adFree ?? this.adFree,
      activeBgm: activeBgm ?? this.activeBgm,
      debugOffsetMinutes: debugOffsetMinutes ?? this.debugOffsetMinutes,
      seatedJson: seatedJson ?? this.seatedJson,
      recentVisitsJson: recentVisitsJson ?? this.recentVisitsJson,
      activeEffectsJson: activeEffectsJson ?? this.activeEffectsJson,
      settingsJson: settingsJson ?? this.settingsJson,
      pendingReportJson: pendingReportJson ?? this.pendingReportJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (money.present) {
      map['money'] = Variable<int>(money.value);
    }
    if (register.present) {
      map['register'] = Variable<int>(register.value);
    }
    if (tickets.present) {
      map['tickets'] = Variable<int>(tickets.value);
    }
    if (lastSimulatedAt.present) {
      map['last_simulated_at'] = Variable<DateTime>(lastSimulatedAt.value);
    }
    if (lastDailyTicketDate.present) {
      map['last_daily_ticket_date'] = Variable<String>(
        lastDailyTicketDate.value,
      );
    }
    if (gachaPity.present) {
      map['gacha_pity'] = Variable<int>(gachaPity.value);
    }
    if (gachaDraws.present) {
      map['gacha_draws'] = Variable<int>(gachaDraws.value);
    }
    if (adFree.present) {
      map['ad_free'] = Variable<bool>(adFree.value);
    }
    if (activeBgm.present) {
      map['active_bgm'] = Variable<String>(activeBgm.value);
    }
    if (debugOffsetMinutes.present) {
      map['debug_offset_minutes'] = Variable<int>(debugOffsetMinutes.value);
    }
    if (seatedJson.present) {
      map['seated_json'] = Variable<String>(seatedJson.value);
    }
    if (recentVisitsJson.present) {
      map['recent_visits_json'] = Variable<String>(recentVisitsJson.value);
    }
    if (activeEffectsJson.present) {
      map['active_effects_json'] = Variable<String>(activeEffectsJson.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (pendingReportJson.present) {
      map['pending_report_json'] = Variable<String>(pendingReportJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStateCompanion(')
          ..write('id: $id, ')
          ..write('money: $money, ')
          ..write('register: $register, ')
          ..write('tickets: $tickets, ')
          ..write('lastSimulatedAt: $lastSimulatedAt, ')
          ..write('lastDailyTicketDate: $lastDailyTicketDate, ')
          ..write('gachaPity: $gachaPity, ')
          ..write('gachaDraws: $gachaDraws, ')
          ..write('adFree: $adFree, ')
          ..write('activeBgm: $activeBgm, ')
          ..write('debugOffsetMinutes: $debugOffsetMinutes, ')
          ..write('seatedJson: $seatedJson, ')
          ..write('recentVisitsJson: $recentVisitsJson, ')
          ..write('activeEffectsJson: $activeEffectsJson, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('pendingReportJson: $pendingReportJson')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [kind, refId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, refId};
  @override
  InventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryData(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      )!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryData extends DataClass implements Insertable<InventoryData> {
  /// item / menu / product / episode / receipt
  final String kind;
  final String refId;
  const InventoryData({required this.kind, required this.refId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['ref_id'] = Variable<String>(refId);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(kind: Value(kind), refId: Value(refId));
  }

  factory InventoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryData(
      kind: serializer.fromJson<String>(json['kind']),
      refId: serializer.fromJson<String>(json['refId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'refId': serializer.toJson<String>(refId),
    };
  }

  InventoryData copyWith({String? kind, String? refId}) =>
      InventoryData(kind: kind ?? this.kind, refId: refId ?? this.refId);
  InventoryData copyWithCompanion(InventoryCompanion data) {
    return InventoryData(
      kind: data.kind.present ? data.kind.value : this.kind,
      refId: data.refId.present ? data.refId.value : this.refId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryData(')
          ..write('kind: $kind, ')
          ..write('refId: $refId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, refId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryData &&
          other.kind == this.kind &&
          other.refId == this.refId);
}

class InventoryCompanion extends UpdateCompanion<InventoryData> {
  final Value<String> kind;
  final Value<String> refId;
  final Value<int> rowid;
  const InventoryCompanion({
    this.kind = const Value.absent(),
    this.refId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    required String kind,
    required String refId,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       refId = Value(refId);
  static Insertable<InventoryData> custom({
    Expression<String>? kind,
    Expression<String>? refId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (refId != null) 'ref_id': refId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({
    Value<String>? kind,
    Value<String>? refId,
    Value<int>? rowid,
  }) {
    return InventoryCompanion(
      kind: kind ?? this.kind,
      refId: refId ?? this.refId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacementTable extends Placement
    with TableInfo<$PlacementTable, PlacementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacementTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slot, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'placement';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlacementData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  PlacementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlacementData(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $PlacementTable createAlias(String alias) {
    return $PlacementTable(attachedDatabase, alias);
  }
}

class PlacementData extends DataClass implements Insertable<PlacementData> {
  final String slot;
  final String itemId;
  const PlacementData({required this.slot, required this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<String>(slot);
    map['item_id'] = Variable<String>(itemId);
    return map;
  }

  PlacementCompanion toCompanion(bool nullToAbsent) {
    return PlacementCompanion(slot: Value(slot), itemId: Value(itemId));
  }

  factory PlacementData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlacementData(
      slot: serializer.fromJson<String>(json['slot']),
      itemId: serializer.fromJson<String>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<String>(slot),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  PlacementData copyWith({String? slot, String? itemId}) =>
      PlacementData(slot: slot ?? this.slot, itemId: itemId ?? this.itemId);
  PlacementData copyWithCompanion(PlacementCompanion data) {
    return PlacementData(
      slot: data.slot.present ? data.slot.value : this.slot,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlacementData(')
          ..write('slot: $slot, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlacementData &&
          other.slot == this.slot &&
          other.itemId == this.itemId);
}

class PlacementCompanion extends UpdateCompanion<PlacementData> {
  final Value<String> slot;
  final Value<String> itemId;
  final Value<int> rowid;
  const PlacementCompanion({
    this.slot = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacementCompanion.insert({
    required String slot,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : slot = Value(slot),
       itemId = Value(itemId);
  static Insertable<PlacementData> custom({
    Expression<String>? slot,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacementCompanion copyWith({
    Value<String>? slot,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return PlacementCompanion(
      slot: slot ?? this.slot,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacementCompanion(')
          ..write('slot: $slot, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitorStateTable extends VisitorState
    with TableInfo<$VisitorStateTable, VisitorStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitorStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _visitorIdMeta = const VerificationMeta(
    'visitorId',
  );
  @override
  late final GeneratedColumn<String> visitorId = GeneratedColumn<String>(
    'visitor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitsMeta = const VerificationMeta('visits');
  @override
  late final GeneratedColumn<int> visits = GeneratedColumn<int>(
    'visits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteKnownMeta = const VerificationMeta(
    'favoriteKnown',
  );
  @override
  late final GeneratedColumn<bool> favoriteKnown = GeneratedColumn<bool>(
    'favorite_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite_known" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    visitorId,
    visits,
    firstSeenAt,
    lastSeenAt,
    favoriteKnown,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visitor_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitorStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('visitor_id')) {
      context.handle(
        _visitorIdMeta,
        visitorId.isAcceptableOrUnknown(data['visitor_id']!, _visitorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitorIdMeta);
    }
    if (data.containsKey('visits')) {
      context.handle(
        _visitsMeta,
        visits.isAcceptableOrUnknown(data['visits']!, _visitsMeta),
      );
    } else if (isInserting) {
      context.missing(_visitsMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('favorite_known')) {
      context.handle(
        _favoriteKnownMeta,
        favoriteKnown.isAcceptableOrUnknown(
          data['favorite_known']!,
          _favoriteKnownMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoriteKnownMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {visitorId};
  @override
  VisitorStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitorStateData(
      visitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visitor_id'],
      )!,
      visits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visits'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      favoriteKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite_known'],
      )!,
    );
  }

  @override
  $VisitorStateTable createAlias(String alias) {
    return $VisitorStateTable(attachedDatabase, alias);
  }
}

class VisitorStateData extends DataClass
    implements Insertable<VisitorStateData> {
  final String visitorId;
  final int visits;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final bool favoriteKnown;
  const VisitorStateData({
    required this.visitorId,
    required this.visits,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.favoriteKnown,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['visitor_id'] = Variable<String>(visitorId);
    map['visits'] = Variable<int>(visits);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    map['favorite_known'] = Variable<bool>(favoriteKnown);
    return map;
  }

  VisitorStateCompanion toCompanion(bool nullToAbsent) {
    return VisitorStateCompanion(
      visitorId: Value(visitorId),
      visits: Value(visits),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
      favoriteKnown: Value(favoriteKnown),
    );
  }

  factory VisitorStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitorStateData(
      visitorId: serializer.fromJson<String>(json['visitorId']),
      visits: serializer.fromJson<int>(json['visits']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      favoriteKnown: serializer.fromJson<bool>(json['favoriteKnown']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'visitorId': serializer.toJson<String>(visitorId),
      'visits': serializer.toJson<int>(visits),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'favoriteKnown': serializer.toJson<bool>(favoriteKnown),
    };
  }

  VisitorStateData copyWith({
    String? visitorId,
    int? visits,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    bool? favoriteKnown,
  }) => VisitorStateData(
    visitorId: visitorId ?? this.visitorId,
    visits: visits ?? this.visits,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    favoriteKnown: favoriteKnown ?? this.favoriteKnown,
  );
  VisitorStateData copyWithCompanion(VisitorStateCompanion data) {
    return VisitorStateData(
      visitorId: data.visitorId.present ? data.visitorId.value : this.visitorId,
      visits: data.visits.present ? data.visits.value : this.visits,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      favoriteKnown: data.favoriteKnown.present
          ? data.favoriteKnown.value
          : this.favoriteKnown,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitorStateData(')
          ..write('visitorId: $visitorId, ')
          ..write('visits: $visits, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('favoriteKnown: $favoriteKnown')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(visitorId, visits, firstSeenAt, lastSeenAt, favoriteKnown);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitorStateData &&
          other.visitorId == this.visitorId &&
          other.visits == this.visits &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.favoriteKnown == this.favoriteKnown);
}

class VisitorStateCompanion extends UpdateCompanion<VisitorStateData> {
  final Value<String> visitorId;
  final Value<int> visits;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> lastSeenAt;
  final Value<bool> favoriteKnown;
  final Value<int> rowid;
  const VisitorStateCompanion({
    this.visitorId = const Value.absent(),
    this.visits = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.favoriteKnown = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitorStateCompanion.insert({
    required String visitorId,
    required int visits,
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
    required bool favoriteKnown,
    this.rowid = const Value.absent(),
  }) : visitorId = Value(visitorId),
       visits = Value(visits),
       firstSeenAt = Value(firstSeenAt),
       lastSeenAt = Value(lastSeenAt),
       favoriteKnown = Value(favoriteKnown);
  static Insertable<VisitorStateData> custom({
    Expression<String>? visitorId,
    Expression<int>? visits,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? favoriteKnown,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (visitorId != null) 'visitor_id': visitorId,
      if (visits != null) 'visits': visits,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (favoriteKnown != null) 'favorite_known': favoriteKnown,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitorStateCompanion copyWith({
    Value<String>? visitorId,
    Value<int>? visits,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? lastSeenAt,
    Value<bool>? favoriteKnown,
    Value<int>? rowid,
  }) {
    return VisitorStateCompanion(
      visitorId: visitorId ?? this.visitorId,
      visits: visits ?? this.visits,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      favoriteKnown: favoriteKnown ?? this.favoriteKnown,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (visitorId.present) {
      map['visitor_id'] = Variable<String>(visitorId.value);
    }
    if (visits.present) {
      map['visits'] = Variable<int>(visits.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (favoriteKnown.present) {
      map['favorite_known'] = Variable<bool>(favoriteKnown.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitorStateCompanion(')
          ..write('visitorId: $visitorId, ')
          ..write('visits: $visits, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('favoriteKnown: $favoriteKnown, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventStateTable extends EventState
    with TableInfo<$EventStateTable, EventStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<String> chainId = GeneratedColumn<String>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextStepMeta = const VerificationMeta(
    'nextStep',
  );
  @override
  late final GeneratedColumn<int> nextStep = GeneratedColumn<int>(
    'next_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastStepAtMeta = const VerificationMeta(
    'lastStepAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastStepAt = GeneratedColumn<DateTime>(
    'last_step_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chainId, nextStep, lastStepAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('next_step')) {
      context.handle(
        _nextStepMeta,
        nextStep.isAcceptableOrUnknown(data['next_step']!, _nextStepMeta),
      );
    } else if (isInserting) {
      context.missing(_nextStepMeta);
    }
    if (data.containsKey('last_step_at')) {
      context.handle(
        _lastStepAtMeta,
        lastStepAt.isAcceptableOrUnknown(
          data['last_step_at']!,
          _lastStepAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chainId};
  @override
  EventStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventStateData(
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chain_id'],
      )!,
      nextStep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_step'],
      )!,
      lastStepAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_step_at'],
      ),
    );
  }

  @override
  $EventStateTable createAlias(String alias) {
    return $EventStateTable(attachedDatabase, alias);
  }
}

class EventStateData extends DataClass implements Insertable<EventStateData> {
  final String chainId;
  final int nextStep;
  final DateTime? lastStepAt;
  const EventStateData({
    required this.chainId,
    required this.nextStep,
    this.lastStepAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chain_id'] = Variable<String>(chainId);
    map['next_step'] = Variable<int>(nextStep);
    if (!nullToAbsent || lastStepAt != null) {
      map['last_step_at'] = Variable<DateTime>(lastStepAt);
    }
    return map;
  }

  EventStateCompanion toCompanion(bool nullToAbsent) {
    return EventStateCompanion(
      chainId: Value(chainId),
      nextStep: Value(nextStep),
      lastStepAt: lastStepAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStepAt),
    );
  }

  factory EventStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventStateData(
      chainId: serializer.fromJson<String>(json['chainId']),
      nextStep: serializer.fromJson<int>(json['nextStep']),
      lastStepAt: serializer.fromJson<DateTime?>(json['lastStepAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chainId': serializer.toJson<String>(chainId),
      'nextStep': serializer.toJson<int>(nextStep),
      'lastStepAt': serializer.toJson<DateTime?>(lastStepAt),
    };
  }

  EventStateData copyWith({
    String? chainId,
    int? nextStep,
    Value<DateTime?> lastStepAt = const Value.absent(),
  }) => EventStateData(
    chainId: chainId ?? this.chainId,
    nextStep: nextStep ?? this.nextStep,
    lastStepAt: lastStepAt.present ? lastStepAt.value : this.lastStepAt,
  );
  EventStateData copyWithCompanion(EventStateCompanion data) {
    return EventStateData(
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      nextStep: data.nextStep.present ? data.nextStep.value : this.nextStep,
      lastStepAt: data.lastStepAt.present
          ? data.lastStepAt.value
          : this.lastStepAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventStateData(')
          ..write('chainId: $chainId, ')
          ..write('nextStep: $nextStep, ')
          ..write('lastStepAt: $lastStepAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chainId, nextStep, lastStepAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventStateData &&
          other.chainId == this.chainId &&
          other.nextStep == this.nextStep &&
          other.lastStepAt == this.lastStepAt);
}

class EventStateCompanion extends UpdateCompanion<EventStateData> {
  final Value<String> chainId;
  final Value<int> nextStep;
  final Value<DateTime?> lastStepAt;
  final Value<int> rowid;
  const EventStateCompanion({
    this.chainId = const Value.absent(),
    this.nextStep = const Value.absent(),
    this.lastStepAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventStateCompanion.insert({
    required String chainId,
    required int nextStep,
    this.lastStepAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chainId = Value(chainId),
       nextStep = Value(nextStep);
  static Insertable<EventStateData> custom({
    Expression<String>? chainId,
    Expression<int>? nextStep,
    Expression<DateTime>? lastStepAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chainId != null) 'chain_id': chainId,
      if (nextStep != null) 'next_step': nextStep,
      if (lastStepAt != null) 'last_step_at': lastStepAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventStateCompanion copyWith({
    Value<String>? chainId,
    Value<int>? nextStep,
    Value<DateTime?>? lastStepAt,
    Value<int>? rowid,
  }) {
    return EventStateCompanion(
      chainId: chainId ?? this.chainId,
      nextStep: nextStep ?? this.nextStep,
      lastStepAt: lastStepAt ?? this.lastStepAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chainId.present) {
      map['chain_id'] = Variable<String>(chainId.value);
    }
    if (nextStep.present) {
      map['next_step'] = Variable<int>(nextStep.value);
    }
    if (lastStepAt.present) {
      map['last_step_at'] = Variable<DateTime>(lastStepAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventStateCompanion(')
          ..write('chainId: $chainId, ')
          ..write('nextStep: $nextStep, ')
          ..write('lastStepAt: $lastStepAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FragmentsTable extends Fragments
    with TableInfo<$FragmentsTable, Fragment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FragmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chainIdMeta = const VerificationMeta(
    'chainId',
  );
  @override
  late final GeneratedColumn<String> chainId = GeneratedColumn<String>(
    'chain_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chainId, step, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fragments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fragment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chain_id')) {
      context.handle(
        _chainIdMeta,
        chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chainIdMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chainId, step};
  @override
  Fragment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fragment(
      chainId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chain_id'],
      )!,
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $FragmentsTable createAlias(String alias) {
    return $FragmentsTable(attachedDatabase, alias);
  }
}

class Fragment extends DataClass implements Insertable<Fragment> {
  final String chainId;
  final int step;
  final DateTime at;
  const Fragment({required this.chainId, required this.step, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chain_id'] = Variable<String>(chainId);
    map['step'] = Variable<int>(step);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  FragmentsCompanion toCompanion(bool nullToAbsent) {
    return FragmentsCompanion(
      chainId: Value(chainId),
      step: Value(step),
      at: Value(at),
    );
  }

  factory Fragment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fragment(
      chainId: serializer.fromJson<String>(json['chainId']),
      step: serializer.fromJson<int>(json['step']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chainId': serializer.toJson<String>(chainId),
      'step': serializer.toJson<int>(step),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  Fragment copyWith({String? chainId, int? step, DateTime? at}) => Fragment(
    chainId: chainId ?? this.chainId,
    step: step ?? this.step,
    at: at ?? this.at,
  );
  Fragment copyWithCompanion(FragmentsCompanion data) {
    return Fragment(
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      step: data.step.present ? data.step.value : this.step,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fragment(')
          ..write('chainId: $chainId, ')
          ..write('step: $step, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chainId, step, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fragment &&
          other.chainId == this.chainId &&
          other.step == this.step &&
          other.at == this.at);
}

class FragmentsCompanion extends UpdateCompanion<Fragment> {
  final Value<String> chainId;
  final Value<int> step;
  final Value<DateTime> at;
  final Value<int> rowid;
  const FragmentsCompanion({
    this.chainId = const Value.absent(),
    this.step = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FragmentsCompanion.insert({
    required String chainId,
    required int step,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : chainId = Value(chainId),
       step = Value(step),
       at = Value(at);
  static Insertable<Fragment> custom({
    Expression<String>? chainId,
    Expression<int>? step,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chainId != null) 'chain_id': chainId,
      if (step != null) 'step': step,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FragmentsCompanion copyWith({
    Value<String>? chainId,
    Value<int>? step,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return FragmentsCompanion(
      chainId: chainId ?? this.chainId,
      step: step ?? this.step,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chainId.present) {
      map['chain_id'] = Variable<String>(chainId.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FragmentsCompanion(')
          ..write('chainId: $chainId, ')
          ..write('step: $step, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsEventsTable extends AnalyticsEvents
    with TableInfo<$AnalyticsEventsTable, AnalyticsEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, at, name, paramsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_paramsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      )!,
    );
  }

  @override
  $AnalyticsEventsTable createAlias(String alias) {
    return $AnalyticsEventsTable(attachedDatabase, alias);
  }
}

class AnalyticsEvent extends DataClass implements Insertable<AnalyticsEvent> {
  final int id;
  final DateTime at;
  final String name;
  final String paramsJson;
  const AnalyticsEvent({
    required this.id,
    required this.at,
    required this.name,
    required this.paramsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<DateTime>(at);
    map['name'] = Variable<String>(name);
    map['params_json'] = Variable<String>(paramsJson);
    return map;
  }

  AnalyticsEventsCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsEventsCompanion(
      id: Value(id),
      at: Value(at),
      name: Value(name),
      paramsJson: Value(paramsJson),
    );
  }

  factory AnalyticsEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsEvent(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      name: serializer.fromJson<String>(json['name']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<DateTime>(at),
      'name': serializer.toJson<String>(name),
      'paramsJson': serializer.toJson<String>(paramsJson),
    };
  }

  AnalyticsEvent copyWith({
    int? id,
    DateTime? at,
    String? name,
    String? paramsJson,
  }) => AnalyticsEvent(
    id: id ?? this.id,
    at: at ?? this.at,
    name: name ?? this.name,
    paramsJson: paramsJson ?? this.paramsJson,
  );
  AnalyticsEvent copyWithCompanion(AnalyticsEventsCompanion data) {
    return AnalyticsEvent(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      name: data.name.present ? data.name.value : this.name,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsEvent(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, name, paramsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsEvent &&
          other.id == this.id &&
          other.at == this.at &&
          other.name == this.name &&
          other.paramsJson == this.paramsJson);
}

class AnalyticsEventsCompanion extends UpdateCompanion<AnalyticsEvent> {
  final Value<int> id;
  final Value<DateTime> at;
  final Value<String> name;
  final Value<String> paramsJson;
  const AnalyticsEventsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.name = const Value.absent(),
    this.paramsJson = const Value.absent(),
  });
  AnalyticsEventsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime at,
    required String name,
    required String paramsJson,
  }) : at = Value(at),
       name = Value(name),
       paramsJson = Value(paramsJson);
  static Insertable<AnalyticsEvent> custom({
    Expression<int>? id,
    Expression<DateTime>? at,
    Expression<String>? name,
    Expression<String>? paramsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (name != null) 'name': name,
      if (paramsJson != null) 'params_json': paramsJson,
    });
  }

  AnalyticsEventsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? at,
    Value<String>? name,
    Value<String>? paramsJson,
  }) {
    return AnalyticsEventsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      name: name ?? this.name,
      paramsJson: paramsJson ?? this.paramsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsEventsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$YohakuDatabase extends GeneratedDatabase {
  _$YohakuDatabase(QueryExecutor e) : super(e);
  $YohakuDatabaseManager get managers => $YohakuDatabaseManager(this);
  late final $PlayerStateTable playerState = $PlayerStateTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $PlacementTable placement = $PlacementTable(this);
  late final $VisitorStateTable visitorState = $VisitorStateTable(this);
  late final $EventStateTable eventState = $EventStateTable(this);
  late final $FragmentsTable fragments = $FragmentsTable(this);
  late final $AnalyticsEventsTable analyticsEvents = $AnalyticsEventsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerState,
    inventory,
    placement,
    visitorState,
    eventState,
    fragments,
    analyticsEvents,
  ];
}

typedef $$PlayerStateTableCreateCompanionBuilder =
    PlayerStateCompanion Function({
      Value<int> id,
      required int money,
      required int register,
      required int tickets,
      required DateTime lastSimulatedAt,
      Value<String?> lastDailyTicketDate,
      required int gachaPity,
      required int gachaDraws,
      required bool adFree,
      Value<String?> activeBgm,
      required int debugOffsetMinutes,
      required String seatedJson,
      required String recentVisitsJson,
      required String activeEffectsJson,
      required String settingsJson,
      Value<String?> pendingReportJson,
    });
typedef $$PlayerStateTableUpdateCompanionBuilder =
    PlayerStateCompanion Function({
      Value<int> id,
      Value<int> money,
      Value<int> register,
      Value<int> tickets,
      Value<DateTime> lastSimulatedAt,
      Value<String?> lastDailyTicketDate,
      Value<int> gachaPity,
      Value<int> gachaDraws,
      Value<bool> adFree,
      Value<String?> activeBgm,
      Value<int> debugOffsetMinutes,
      Value<String> seatedJson,
      Value<String> recentVisitsJson,
      Value<String> activeEffectsJson,
      Value<String> settingsJson,
      Value<String?> pendingReportJson,
    });

class $$PlayerStateTableFilterComposer
    extends Composer<_$YohakuDatabase, $PlayerStateTable> {
  $$PlayerStateTableFilterComposer({
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

  ColumnFilters<int> get money => $composableBuilder(
    column: $table.money,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get register => $composableBuilder(
    column: $table.register,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tickets => $composableBuilder(
    column: $table.tickets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSimulatedAt => $composableBuilder(
    column: $table.lastSimulatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastDailyTicketDate => $composableBuilder(
    column: $table.lastDailyTicketDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gachaPity => $composableBuilder(
    column: $table.gachaPity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gachaDraws => $composableBuilder(
    column: $table.gachaDraws,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get adFree => $composableBuilder(
    column: $table.adFree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeBgm => $composableBuilder(
    column: $table.activeBgm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get debugOffsetMinutes => $composableBuilder(
    column: $table.debugOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seatedJson => $composableBuilder(
    column: $table.seatedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recentVisitsJson => $composableBuilder(
    column: $table.recentVisitsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeEffectsJson => $composableBuilder(
    column: $table.activeEffectsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pendingReportJson => $composableBuilder(
    column: $table.pendingReportJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerStateTableOrderingComposer
    extends Composer<_$YohakuDatabase, $PlayerStateTable> {
  $$PlayerStateTableOrderingComposer({
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

  ColumnOrderings<int> get money => $composableBuilder(
    column: $table.money,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get register => $composableBuilder(
    column: $table.register,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tickets => $composableBuilder(
    column: $table.tickets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSimulatedAt => $composableBuilder(
    column: $table.lastSimulatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastDailyTicketDate => $composableBuilder(
    column: $table.lastDailyTicketDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gachaPity => $composableBuilder(
    column: $table.gachaPity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gachaDraws => $composableBuilder(
    column: $table.gachaDraws,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adFree => $composableBuilder(
    column: $table.adFree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeBgm => $composableBuilder(
    column: $table.activeBgm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get debugOffsetMinutes => $composableBuilder(
    column: $table.debugOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seatedJson => $composableBuilder(
    column: $table.seatedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recentVisitsJson => $composableBuilder(
    column: $table.recentVisitsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeEffectsJson => $composableBuilder(
    column: $table.activeEffectsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pendingReportJson => $composableBuilder(
    column: $table.pendingReportJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerStateTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $PlayerStateTable> {
  $$PlayerStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get money =>
      $composableBuilder(column: $table.money, builder: (column) => column);

  GeneratedColumn<int> get register =>
      $composableBuilder(column: $table.register, builder: (column) => column);

  GeneratedColumn<int> get tickets =>
      $composableBuilder(column: $table.tickets, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSimulatedAt => $composableBuilder(
    column: $table.lastSimulatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastDailyTicketDate => $composableBuilder(
    column: $table.lastDailyTicketDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gachaPity =>
      $composableBuilder(column: $table.gachaPity, builder: (column) => column);

  GeneratedColumn<int> get gachaDraws => $composableBuilder(
    column: $table.gachaDraws,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get adFree =>
      $composableBuilder(column: $table.adFree, builder: (column) => column);

  GeneratedColumn<String> get activeBgm =>
      $composableBuilder(column: $table.activeBgm, builder: (column) => column);

  GeneratedColumn<int> get debugOffsetMinutes => $composableBuilder(
    column: $table.debugOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seatedJson => $composableBuilder(
    column: $table.seatedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recentVisitsJson => $composableBuilder(
    column: $table.recentVisitsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeEffectsJson => $composableBuilder(
    column: $table.activeEffectsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pendingReportJson => $composableBuilder(
    column: $table.pendingReportJson,
    builder: (column) => column,
  );
}

class $$PlayerStateTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $PlayerStateTable,
          PlayerStateData,
          $$PlayerStateTableFilterComposer,
          $$PlayerStateTableOrderingComposer,
          $$PlayerStateTableAnnotationComposer,
          $$PlayerStateTableCreateCompanionBuilder,
          $$PlayerStateTableUpdateCompanionBuilder,
          (
            PlayerStateData,
            BaseReferences<
              _$YohakuDatabase,
              $PlayerStateTable,
              PlayerStateData
            >,
          ),
          PlayerStateData,
          PrefetchHooks Function()
        > {
  $$PlayerStateTableTableManager(_$YohakuDatabase db, $PlayerStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> money = const Value.absent(),
                Value<int> register = const Value.absent(),
                Value<int> tickets = const Value.absent(),
                Value<DateTime> lastSimulatedAt = const Value.absent(),
                Value<String?> lastDailyTicketDate = const Value.absent(),
                Value<int> gachaPity = const Value.absent(),
                Value<int> gachaDraws = const Value.absent(),
                Value<bool> adFree = const Value.absent(),
                Value<String?> activeBgm = const Value.absent(),
                Value<int> debugOffsetMinutes = const Value.absent(),
                Value<String> seatedJson = const Value.absent(),
                Value<String> recentVisitsJson = const Value.absent(),
                Value<String> activeEffectsJson = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<String?> pendingReportJson = const Value.absent(),
              }) => PlayerStateCompanion(
                id: id,
                money: money,
                register: register,
                tickets: tickets,
                lastSimulatedAt: lastSimulatedAt,
                lastDailyTicketDate: lastDailyTicketDate,
                gachaPity: gachaPity,
                gachaDraws: gachaDraws,
                adFree: adFree,
                activeBgm: activeBgm,
                debugOffsetMinutes: debugOffsetMinutes,
                seatedJson: seatedJson,
                recentVisitsJson: recentVisitsJson,
                activeEffectsJson: activeEffectsJson,
                settingsJson: settingsJson,
                pendingReportJson: pendingReportJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int money,
                required int register,
                required int tickets,
                required DateTime lastSimulatedAt,
                Value<String?> lastDailyTicketDate = const Value.absent(),
                required int gachaPity,
                required int gachaDraws,
                required bool adFree,
                Value<String?> activeBgm = const Value.absent(),
                required int debugOffsetMinutes,
                required String seatedJson,
                required String recentVisitsJson,
                required String activeEffectsJson,
                required String settingsJson,
                Value<String?> pendingReportJson = const Value.absent(),
              }) => PlayerStateCompanion.insert(
                id: id,
                money: money,
                register: register,
                tickets: tickets,
                lastSimulatedAt: lastSimulatedAt,
                lastDailyTicketDate: lastDailyTicketDate,
                gachaPity: gachaPity,
                gachaDraws: gachaDraws,
                adFree: adFree,
                activeBgm: activeBgm,
                debugOffsetMinutes: debugOffsetMinutes,
                seatedJson: seatedJson,
                recentVisitsJson: recentVisitsJson,
                activeEffectsJson: activeEffectsJson,
                settingsJson: settingsJson,
                pendingReportJson: pendingReportJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerStateTable, PlayerStateData>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $PlayerStateTable,
                    PlayerStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerStateTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $PlayerStateTable,
      PlayerStateData,
      $$PlayerStateTableFilterComposer,
      $$PlayerStateTableOrderingComposer,
      $$PlayerStateTableAnnotationComposer,
      $$PlayerStateTableCreateCompanionBuilder,
      $$PlayerStateTableUpdateCompanionBuilder,
      (
        PlayerStateData,
        BaseReferences<_$YohakuDatabase, $PlayerStateTable, PlayerStateData>,
      ),
      PlayerStateData,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder = InventoryCompanion Function({
  required String kind,
  required String refId,
  Value<int> rowid,
});
typedef $$InventoryTableUpdateCompanionBuilder = InventoryCompanion Function({
  Value<String> kind,
  Value<String> refId,
  Value<int> rowid,
});

class $$InventoryTableFilterComposer
    extends Composer<_$YohakuDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTableOrderingComposer
    extends Composer<_$YohakuDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $InventoryTable,
          InventoryData,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (
            InventoryData,
            BaseReferences<_$YohakuDatabase, $InventoryTable, InventoryData>,
          ),
          InventoryData,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$YohakuDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> kind = const Value.absent(),
            Value<String> refId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => InventoryCompanion(kind: kind, refId: refId, rowid: rowid),
          createCompanionCallback:
              ({
                required String kind,
                required String refId,
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion.insert(
                kind: kind,
                refId: refId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryTable, InventoryData>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $InventoryTable,
                    InventoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $InventoryTable,
      InventoryData,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (
        InventoryData,
        BaseReferences<_$YohakuDatabase, $InventoryTable, InventoryData>,
      ),
      InventoryData,
      PrefetchHooks Function()
    >;
typedef $$PlacementTableCreateCompanionBuilder = PlacementCompanion Function({
  required String slot,
  required String itemId,
  Value<int> rowid,
});
typedef $$PlacementTableUpdateCompanionBuilder = PlacementCompanion Function({
  Value<String> slot,
  Value<String> itemId,
  Value<int> rowid,
});

class $$PlacementTableFilterComposer
    extends Composer<_$YohakuDatabase, $PlacementTable> {
  $$PlacementTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacementTableOrderingComposer
    extends Composer<_$YohakuDatabase, $PlacementTable> {
  $$PlacementTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacementTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $PlacementTable> {
  $$PlacementTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);
}

class $$PlacementTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $PlacementTable,
          PlacementData,
          $$PlacementTableFilterComposer,
          $$PlacementTableOrderingComposer,
          $$PlacementTableAnnotationComposer,
          $$PlacementTableCreateCompanionBuilder,
          $$PlacementTableUpdateCompanionBuilder,
          (
            PlacementData,
            BaseReferences<_$YohakuDatabase, $PlacementTable, PlacementData>,
          ),
          PlacementData,
          PrefetchHooks Function()
        > {
  $$PlacementTableTableManager(_$YohakuDatabase db, $PlacementTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacementTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacementTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlacementTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> slot = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PlacementCompanion(slot: slot, itemId: itemId, rowid: rowid),
          createCompanionCallback:
              ({
                required String slot,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => PlacementCompanion.insert(
                slot: slot,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlacementTable, PlacementData>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $PlacementTable,
                    PlacementData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacementTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $PlacementTable,
      PlacementData,
      $$PlacementTableFilterComposer,
      $$PlacementTableOrderingComposer,
      $$PlacementTableAnnotationComposer,
      $$PlacementTableCreateCompanionBuilder,
      $$PlacementTableUpdateCompanionBuilder,
      (
        PlacementData,
        BaseReferences<_$YohakuDatabase, $PlacementTable, PlacementData>,
      ),
      PlacementData,
      PrefetchHooks Function()
    >;
typedef $$VisitorStateTableCreateCompanionBuilder =
    VisitorStateCompanion Function({
      required String visitorId,
      required int visits,
      required DateTime firstSeenAt,
      required DateTime lastSeenAt,
      required bool favoriteKnown,
      Value<int> rowid,
    });
typedef $$VisitorStateTableUpdateCompanionBuilder =
    VisitorStateCompanion Function({
      Value<String> visitorId,
      Value<int> visits,
      Value<DateTime> firstSeenAt,
      Value<DateTime> lastSeenAt,
      Value<bool> favoriteKnown,
      Value<int> rowid,
    });

class $$VisitorStateTableFilterComposer
    extends Composer<_$YohakuDatabase, $VisitorStateTable> {
  $$VisitorStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get visitorId => $composableBuilder(
    column: $table.visitorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visits => $composableBuilder(
    column: $table.visits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favoriteKnown => $composableBuilder(
    column: $table.favoriteKnown,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitorStateTableOrderingComposer
    extends Composer<_$YohakuDatabase, $VisitorStateTable> {
  $$VisitorStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get visitorId => $composableBuilder(
    column: $table.visitorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visits => $composableBuilder(
    column: $table.visits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favoriteKnown => $composableBuilder(
    column: $table.favoriteKnown,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitorStateTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $VisitorStateTable> {
  $$VisitorStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get visitorId =>
      $composableBuilder(column: $table.visitorId, builder: (column) => column);

  GeneratedColumn<int> get visits =>
      $composableBuilder(column: $table.visits, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favoriteKnown => $composableBuilder(
    column: $table.favoriteKnown,
    builder: (column) => column,
  );
}

class $$VisitorStateTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $VisitorStateTable,
          VisitorStateData,
          $$VisitorStateTableFilterComposer,
          $$VisitorStateTableOrderingComposer,
          $$VisitorStateTableAnnotationComposer,
          $$VisitorStateTableCreateCompanionBuilder,
          $$VisitorStateTableUpdateCompanionBuilder,
          (
            VisitorStateData,
            BaseReferences<
              _$YohakuDatabase,
              $VisitorStateTable,
              VisitorStateData
            >,
          ),
          VisitorStateData,
          PrefetchHooks Function()
        > {
  $$VisitorStateTableTableManager(_$YohakuDatabase db, $VisitorStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitorStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitorStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitorStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> visitorId = const Value.absent(),
                Value<int> visits = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<bool> favoriteKnown = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitorStateCompanion(
                visitorId: visitorId,
                visits: visits,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                favoriteKnown: favoriteKnown,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String visitorId,
                required int visits,
                required DateTime firstSeenAt,
                required DateTime lastSeenAt,
                required bool favoriteKnown,
                Value<int> rowid = const Value.absent(),
              }) => VisitorStateCompanion.insert(
                visitorId: visitorId,
                visits: visits,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                favoriteKnown: favoriteKnown,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VisitorStateTable, VisitorStateData>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $VisitorStateTable,
                    VisitorStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitorStateTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $VisitorStateTable,
      VisitorStateData,
      $$VisitorStateTableFilterComposer,
      $$VisitorStateTableOrderingComposer,
      $$VisitorStateTableAnnotationComposer,
      $$VisitorStateTableCreateCompanionBuilder,
      $$VisitorStateTableUpdateCompanionBuilder,
      (
        VisitorStateData,
        BaseReferences<_$YohakuDatabase, $VisitorStateTable, VisitorStateData>,
      ),
      VisitorStateData,
      PrefetchHooks Function()
    >;
typedef $$EventStateTableCreateCompanionBuilder = EventStateCompanion Function({
  required String chainId,
  required int nextStep,
  Value<DateTime?> lastStepAt,
  Value<int> rowid,
});
typedef $$EventStateTableUpdateCompanionBuilder = EventStateCompanion Function({
  Value<String> chainId,
  Value<int> nextStep,
  Value<DateTime?> lastStepAt,
  Value<int> rowid,
});

class $$EventStateTableFilterComposer
    extends Composer<_$YohakuDatabase, $EventStateTable> {
  $$EventStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextStep => $composableBuilder(
    column: $table.nextStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastStepAt => $composableBuilder(
    column: $table.lastStepAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventStateTableOrderingComposer
    extends Composer<_$YohakuDatabase, $EventStateTable> {
  $$EventStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextStep => $composableBuilder(
    column: $table.nextStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastStepAt => $composableBuilder(
    column: $table.lastStepAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventStateTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $EventStateTable> {
  $$EventStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chainId =>
      $composableBuilder(column: $table.chainId, builder: (column) => column);

  GeneratedColumn<int> get nextStep =>
      $composableBuilder(column: $table.nextStep, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStepAt => $composableBuilder(
    column: $table.lastStepAt,
    builder: (column) => column,
  );
}

class $$EventStateTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $EventStateTable,
          EventStateData,
          $$EventStateTableFilterComposer,
          $$EventStateTableOrderingComposer,
          $$EventStateTableAnnotationComposer,
          $$EventStateTableCreateCompanionBuilder,
          $$EventStateTableUpdateCompanionBuilder,
          (
            EventStateData,
            BaseReferences<_$YohakuDatabase, $EventStateTable, EventStateData>,
          ),
          EventStateData,
          PrefetchHooks Function()
        > {
  $$EventStateTableTableManager(_$YohakuDatabase db, $EventStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chainId = const Value.absent(),
                Value<int> nextStep = const Value.absent(),
                Value<DateTime?> lastStepAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventStateCompanion(
                chainId: chainId,
                nextStep: nextStep,
                lastStepAt: lastStepAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chainId,
                required int nextStep,
                Value<DateTime?> lastStepAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventStateCompanion.insert(
                chainId: chainId,
                nextStep: nextStep,
                lastStepAt: lastStepAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventStateTable, EventStateData>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $EventStateTable,
                    EventStateData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventStateTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $EventStateTable,
      EventStateData,
      $$EventStateTableFilterComposer,
      $$EventStateTableOrderingComposer,
      $$EventStateTableAnnotationComposer,
      $$EventStateTableCreateCompanionBuilder,
      $$EventStateTableUpdateCompanionBuilder,
      (
        EventStateData,
        BaseReferences<_$YohakuDatabase, $EventStateTable, EventStateData>,
      ),
      EventStateData,
      PrefetchHooks Function()
    >;
typedef $$FragmentsTableCreateCompanionBuilder = FragmentsCompanion Function({
  required String chainId,
  required int step,
  required DateTime at,
  Value<int> rowid,
});
typedef $$FragmentsTableUpdateCompanionBuilder = FragmentsCompanion Function({
  Value<String> chainId,
  Value<int> step,
  Value<DateTime> at,
  Value<int> rowid,
});

class $$FragmentsTableFilterComposer
    extends Composer<_$YohakuDatabase, $FragmentsTable> {
  $$FragmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FragmentsTableOrderingComposer
    extends Composer<_$YohakuDatabase, $FragmentsTable> {
  $$FragmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chainId => $composableBuilder(
    column: $table.chainId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FragmentsTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $FragmentsTable> {
  $$FragmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chainId =>
      $composableBuilder(column: $table.chainId, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$FragmentsTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $FragmentsTable,
          Fragment,
          $$FragmentsTableFilterComposer,
          $$FragmentsTableOrderingComposer,
          $$FragmentsTableAnnotationComposer,
          $$FragmentsTableCreateCompanionBuilder,
          $$FragmentsTableUpdateCompanionBuilder,
          (
            Fragment,
            BaseReferences<_$YohakuDatabase, $FragmentsTable, Fragment>,
          ),
          Fragment,
          PrefetchHooks Function()
        > {
  $$FragmentsTableTableManager(_$YohakuDatabase db, $FragmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FragmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FragmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FragmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chainId = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FragmentsCompanion(
                chainId: chainId,
                step: step,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chainId,
                required int step,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => FragmentsCompanion.insert(
                chainId: chainId,
                step: step,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FragmentsTable, Fragment>(table),
                  BaseReferences<_$YohakuDatabase, $FragmentsTable, Fragment>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FragmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $FragmentsTable,
      Fragment,
      $$FragmentsTableFilterComposer,
      $$FragmentsTableOrderingComposer,
      $$FragmentsTableAnnotationComposer,
      $$FragmentsTableCreateCompanionBuilder,
      $$FragmentsTableUpdateCompanionBuilder,
      (Fragment, BaseReferences<_$YohakuDatabase, $FragmentsTable, Fragment>),
      Fragment,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsEventsTableCreateCompanionBuilder =
    AnalyticsEventsCompanion Function({
      Value<int> id,
      required DateTime at,
      required String name,
      required String paramsJson,
    });
typedef $$AnalyticsEventsTableUpdateCompanionBuilder =
    AnalyticsEventsCompanion Function({
      Value<int> id,
      Value<DateTime> at,
      Value<String> name,
      Value<String> paramsJson,
    });

class $$AnalyticsEventsTableFilterComposer
    extends Composer<_$YohakuDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsEventsTableOrderingComposer
    extends Composer<_$YohakuDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsEventsTableAnnotationComposer
    extends Composer<_$YohakuDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );
}

class $$AnalyticsEventsTableTableManager
    extends
        RootTableManager<
          _$YohakuDatabase,
          $AnalyticsEventsTable,
          AnalyticsEvent,
          $$AnalyticsEventsTableFilterComposer,
          $$AnalyticsEventsTableOrderingComposer,
          $$AnalyticsEventsTableAnnotationComposer,
          $$AnalyticsEventsTableCreateCompanionBuilder,
          $$AnalyticsEventsTableUpdateCompanionBuilder,
          (
            AnalyticsEvent,
            BaseReferences<
              _$YohakuDatabase,
              $AnalyticsEventsTable,
              AnalyticsEvent
            >,
          ),
          AnalyticsEvent,
          PrefetchHooks Function()
        > {
  $$AnalyticsEventsTableTableManager(
    _$YohakuDatabase db,
    $AnalyticsEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalyticsEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
              }) => AnalyticsEventsCompanion(
                id: id,
                at: at,
                name: name,
                paramsJson: paramsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime at,
                required String name,
                required String paramsJson,
              }) => AnalyticsEventsCompanion.insert(
                id: id,
                at: at,
                name: name,
                paramsJson: paramsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnalyticsEventsTable, AnalyticsEvent>(table),
                  BaseReferences<
                    _$YohakuDatabase,
                    $AnalyticsEventsTable,
                    AnalyticsEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$YohakuDatabase,
      $AnalyticsEventsTable,
      AnalyticsEvent,
      $$AnalyticsEventsTableFilterComposer,
      $$AnalyticsEventsTableOrderingComposer,
      $$AnalyticsEventsTableAnnotationComposer,
      $$AnalyticsEventsTableCreateCompanionBuilder,
      $$AnalyticsEventsTableUpdateCompanionBuilder,
      (
        AnalyticsEvent,
        BaseReferences<_$YohakuDatabase, $AnalyticsEventsTable, AnalyticsEvent>,
      ),
      AnalyticsEvent,
      PrefetchHooks Function()
    >;

class $YohakuDatabaseManager {
  final _$YohakuDatabase _db;
  $YohakuDatabaseManager(this._db);
  $$PlayerStateTableTableManager get playerState =>
      $$PlayerStateTableTableManager(_db, _db.playerState);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$PlacementTableTableManager get placement =>
      $$PlacementTableTableManager(_db, _db.placement);
  $$VisitorStateTableTableManager get visitorState =>
      $$VisitorStateTableTableManager(_db, _db.visitorState);
  $$EventStateTableTableManager get eventState =>
      $$EventStateTableTableManager(_db, _db.eventState);
  $$FragmentsTableTableManager get fragments =>
      $$FragmentsTableTableManager(_db, _db.fragments);
  $$AnalyticsEventsTableTableManager get analyticsEvents =>
      $$AnalyticsEventsTableTableManager(_db, _db.analyticsEvents);
}
