import '../../core/models/content.dart';
import '../../core/state/game_state.dart';

/// 何度か来るまでは「窓際の人」のような呼び名で表示する。
const nameRevealVisits = 3;

String visitorDisplayName(VisitorDef def, VisitorRecord? rec) =>
    (rec?.visits ?? 0) >= nameRevealVisits ? def.name : def.silhouetteName;

/// 来店回数に応じて開いたプロフィール。
List<String> unlockedProfile(VisitorDef def, VisitorRecord? rec) => [
  for (final (need, text) in def.profile)
    if ((rec?.visits ?? 0) >= need) text,
];

/// 次のプロフィールが開くまでの回数。全部開いていれば null。
int? visitsToNextProfile(VisitorDef def, VisitorRecord? rec) {
  final v = rec?.visits ?? 0;
  for (final (need, _) in def.profile) {
    if (v < need) return need - v;
  }
  return null;
}
