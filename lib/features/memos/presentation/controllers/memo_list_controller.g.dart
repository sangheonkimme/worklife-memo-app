// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchMemosHash() => r'c1843d84e31d3cca08dac586432307bad57f9393';

/// See also [watchMemos].
@ProviderFor(watchMemos)
final watchMemosProvider = Provider<WatchMemos>.internal(
  watchMemos,
  name: r'watchMemosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchMemosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchMemosRef = ProviderRef<WatchMemos>;
String _$watchPinnedMemosHash() => r'2fc769b0c09abc75d32d8bec9f3ab0326b8bf52c';

/// See also [watchPinnedMemos].
@ProviderFor(watchPinnedMemos)
final watchPinnedMemosProvider = Provider<WatchPinnedMemos>.internal(
  watchPinnedMemos,
  name: r'watchPinnedMemosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchPinnedMemosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchPinnedMemosRef = ProviderRef<WatchPinnedMemos>;
String _$getMemoHash() => r'8ce09ff7649f349535e4bc4e57e73c7e3e7a359c';

/// See also [getMemo].
@ProviderFor(getMemo)
final getMemoProvider = Provider<GetMemo>.internal(
  getMemo,
  name: r'getMemoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getMemoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetMemoRef = ProviderRef<GetMemo>;
String _$memoListHash() => r'4d89e2ffd2a5e61ed5b1ff01ce1f52368a8e5559';

/// See also [memoList].
@ProviderFor(memoList)
final memoListProvider = StreamProvider<List<Memo>>.internal(
  memoList,
  name: r'memoListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MemoListRef = StreamProviderRef<List<Memo>>;
String _$pinnedMemoListHash() => r'12bc93d68da73e571a83c977824e3a684a795f0c';

/// See also [pinnedMemoList].
@ProviderFor(pinnedMemoList)
final pinnedMemoListProvider = StreamProvider<List<Memo>>.internal(
  pinnedMemoList,
  name: r'pinnedMemoListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pinnedMemoListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PinnedMemoListRef = StreamProviderRef<List<Memo>>;
String _$memoByIdHash() => r'09ef3314a11836a5a3fa99150462a3a8577f7e6c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [memoById].
@ProviderFor(memoById)
const memoByIdProvider = MemoByIdFamily();

/// See also [memoById].
class MemoByIdFamily extends Family<AsyncValue<Memo?>> {
  /// See also [memoById].
  const MemoByIdFamily();

  /// See also [memoById].
  MemoByIdProvider call(
    int id,
  ) {
    return MemoByIdProvider(
      id,
    );
  }

  @override
  MemoByIdProvider getProviderOverride(
    covariant MemoByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'memoByIdProvider';
}

/// See also [memoById].
class MemoByIdProvider extends AutoDisposeFutureProvider<Memo?> {
  /// See also [memoById].
  MemoByIdProvider(
    int id,
  ) : this._internal(
          (ref) => memoById(
            ref as MemoByIdRef,
            id,
          ),
          from: memoByIdProvider,
          name: r'memoByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$memoByIdHash,
          dependencies: MemoByIdFamily._dependencies,
          allTransitiveDependencies: MemoByIdFamily._allTransitiveDependencies,
          id: id,
        );

  MemoByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Memo?> Function(MemoByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemoByIdProvider._internal(
        (ref) => create(ref as MemoByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Memo?> createElement() {
    return _MemoByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MemoByIdRef on AutoDisposeFutureProviderRef<Memo?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _MemoByIdProviderElement extends AutoDisposeFutureProviderElement<Memo?>
    with MemoByIdRef {
  _MemoByIdProviderElement(super.provider);

  @override
  int get id => (origin as MemoByIdProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
