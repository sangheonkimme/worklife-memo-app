import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_search_query.g.dart';

@Riverpod(keepAlive: true)
class MemoSearchQuery extends _$MemoSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}
