// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchMemosHash() => r'02b01dc8285550486544aee9d888ccaa043ddb7d';

/// See also [watchMemos].
@ProviderFor(watchMemos)
final watchMemosProvider = FutureProvider<WatchMemos>.internal(
  watchMemos,
  name: r'watchMemosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchMemosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchMemosRef = FutureProviderRef<WatchMemos>;
String _$watchPinnedMemosHash() => r'91fe0ab3f59856c57762386f1ed7f1e17018f373';

/// See also [watchPinnedMemos].
@ProviderFor(watchPinnedMemos)
final watchPinnedMemosProvider = FutureProvider<WatchPinnedMemos>.internal(
  watchPinnedMemos,
  name: r'watchPinnedMemosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchPinnedMemosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchPinnedMemosRef = FutureProviderRef<WatchPinnedMemos>;
String _$getMemoHash() => r'f94095db2e4493a09896ebb26aa91c68bbacf57e';

/// See also [getMemo].
@ProviderFor(getMemo)
final getMemoProvider = FutureProvider<GetMemo>.internal(
  getMemo,
  name: r'getMemoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getMemoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetMemoRef = FutureProviderRef<GetMemo>;
String _$memoListHash() => r'62993f6f74b5179bfe73cb6d1d539392f772de99';

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
String _$pinnedMemoListHash() => r'f2e109a424c7befa94a75ff93a585597c26d68b0';

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
String _$memoByIdHash() => r'905d54ac2bf117c4aa9b380be40a50caa1c59f80';

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
