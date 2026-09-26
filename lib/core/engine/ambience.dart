import '../models/content.dart';

/// 家具＝性能ではなく、家具＝世界観生成装置。
/// 置かれている家具のタグを数え、成立している「雰囲気」を返す。
class AmbienceResolver {
  const AmbienceResolver(this.content);

  final TitleContent content;

  Map<String, int> tagCounts(Iterable<String> placedItemIds) {
    final counts = <String, int>{};
    for (final id in placedItemIds) {
      for (final tag in content.item(id).tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<AmbienceDef> resolve(Iterable<String> placedItemIds) {
    final counts = tagCounts(placedItemIds);
    return [
      for (final a in content.ambiences)
        if (a.requirements
                .where((r) => (counts[r.tag] ?? 0) >= r.count)
                .length >=
            a.minSatisfied)
          a,
    ];
  }

  /// 雰囲気まであと何が足りないか（家具画面のヒント用）。
  List<TagRequirement> missing(AmbienceDef a, Iterable<String> placedItemIds) {
    final counts = tagCounts(placedItemIds);
    return [
      for (final r in a.requirements)
        if ((counts[r.tag] ?? 0) < r.count) r,
    ];
  }
}
