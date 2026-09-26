import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// ローカルの正本（ローカルファースト）。企画書 17 の分け方に合わせたテーブル。
///
/// player_state   ― 1 行だけ。所持金・チケット・精算時刻など
/// inventory      ― 持っているもの（家具・メニュー・購入済み商品・エピソード）
/// placement      ― スロットごとの配置（企画書の furniture）
/// visitor_state  ― 客ごとの来店記録
/// event_state    ― 物語ごとの進み具合
/// fragments      ― 発見した出来事の段階
class PlayerState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get money => integer()();
  IntColumn get register => integer()();
  IntColumn get tickets => integer()();
  DateTimeColumn get lastSimulatedAt => dateTime()();
  TextColumn get lastDailyTicketDate => text().nullable()();
  IntColumn get gachaPity => integer()();
  IntColumn get gachaDraws => integer()();
  BoolColumn get adFree => boolean()();
  TextColumn get activeBgm => text().nullable()();
  IntColumn get debugOffsetMinutes => integer()();

  /// 画面の状態に近いもの（席の客・直近の来店・設定・未読の放置結果）は
  /// 検索しないので JSON のまま持つ。
  TextColumn get seatedJson => text()();
  TextColumn get recentVisitsJson => text()();
  TextColumn get activeEffectsJson => text()();
  TextColumn get settingsJson => text()();
  TextColumn get pendingReportJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Inventory extends Table {
  /// item / menu / product / episode
  TextColumn get kind => text()();
  TextColumn get refId => text()();

  @override
  Set<Column> get primaryKey => {kind, refId};
}

class Placement extends Table {
  TextColumn get slot => text()();
  TextColumn get itemId => text()();

  @override
  Set<Column> get primaryKey => {slot};
}

class VisitorState extends Table {
  TextColumn get visitorId => text()();
  IntColumn get visits => integer()();
  DateTimeColumn get firstSeenAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime()();
  BoolColumn get favoriteKnown => boolean()();

  @override
  Set<Column> get primaryKey => {visitorId};
}

class EventState extends Table {
  TextColumn get chainId => text()();
  IntColumn get nextStep => integer()();
  DateTimeColumn get lastStepAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {chainId};
}

class Fragments extends Table {
  TextColumn get chainId => text()();
  IntColumn get step => integer()();
  DateTimeColumn get at => dateTime()();

  @override
  Set<Column> get primaryKey => {chainId, step};
}

@DriftDatabase(
  tables: [
    PlayerState,
    Inventory,
    Placement,
    VisitorState,
    EventState,
    Fragments,
  ],
)
class YohakuDatabase extends _$YohakuDatabase {
  YohakuDatabase(super.e);

  /// 端末では SQLite ファイル、Web では wasm 版 SQLite（web/sqlite3.wasm）を使う。
  factory YohakuDatabase.open(String name) => YohakuDatabase(
    driftDatabase(
      name: name,
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );

  @override
  int get schemaVersion => 1;
}
