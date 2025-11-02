// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upsertMemoHash() => r'c591df67b0082181ac906d056385b3cc82947e9c';

/// See also [upsertMemo].
@ProviderFor(upsertMemo)
final upsertMemoProvider = FutureProvider<UpsertMemo>.internal(
  upsertMemo,
  name: r'upsertMemoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$upsertMemoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpsertMemoRef = FutureProviderRef<UpsertMemo>;
String _$deleteMemoHash() => r'4d9304ba1b47dad4150982011457ae9ee26a8627';

/// See also [deleteMemo].
@ProviderFor(deleteMemo)
final deleteMemoProvider = FutureProvider<DeleteMemo>.internal(
  deleteMemo,
  name: r'deleteMemoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deleteMemoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteMemoRef = FutureProviderRef<DeleteMemo>;
String _$togglePinHash() => r'c17502a51f4cd8d3cfd71a482d9f0bd7fb57d863';

/// See also [togglePin].
@ProviderFor(togglePin)
final togglePinProvider = FutureProvider<TogglePin>.internal(
  togglePin,
  name: r'togglePinProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$togglePinHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TogglePinRef = FutureProviderRef<TogglePin>;
String _$memoEditorControllerHash() =>
    r'1b4c08ccf685eeaeadfe3f44d8b4f92cee687569';

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

abstract class _$MemoEditorController
    extends BuildlessAutoDisposeAsyncNotifier<MemoEditorState> {
  late final int? memoId;

  FutureOr<MemoEditorState> build({
    int? memoId,
  });
}

/// See also [MemoEditorController].
@ProviderFor(MemoEditorController)
const memoEditorControllerProvider = MemoEditorControllerFamily();

/// See also [MemoEditorController].
class MemoEditorControllerFamily extends Family<AsyncValue<MemoEditorState>> {
  /// See also [MemoEditorController].
  const MemoEditorControllerFamily();

  /// See also [MemoEditorController].
  MemoEditorControllerProvider call({
    int? memoId,
  }) {
    return MemoEditorControllerProvider(
      memoId: memoId,
    );
  }

  @override
  MemoEditorControllerProvider getProviderOverride(
    covariant MemoEditorControllerProvider provider,
  ) {
    return call(
      memoId: provider.memoId,
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
  String? get name => r'memoEditorControllerProvider';
}

/// See also [MemoEditorController].
class MemoEditorControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MemoEditorController, MemoEditorState> {
  /// See also [MemoEditorController].
  MemoEditorControllerProvider({
    int? memoId,
  }) : this._internal(
          () => MemoEditorController()..memoId = memoId,
          from: memoEditorControllerProvider,
          name: r'memoEditorControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$memoEditorControllerHash,
          dependencies: MemoEditorControllerFamily._dependencies,
          allTransitiveDependencies:
              MemoEditorControllerFamily._allTransitiveDependencies,
          memoId: memoId,
        );

  MemoEditorControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memoId,
  }) : super.internal();

  final int? memoId;

  @override
  FutureOr<MemoEditorState> runNotifierBuild(
    covariant MemoEditorController notifier,
  ) {
    return notifier.build(
      memoId: memoId,
    );
  }

  @override
  Override overrideWith(MemoEditorController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MemoEditorControllerProvider._internal(
        () => create()..memoId = memoId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memoId: memoId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MemoEditorController, MemoEditorState>
      createElement() {
    return _MemoEditorControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoEditorControllerProvider && other.memoId == memoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MemoEditorControllerRef
    on AutoDisposeAsyncNotifierProviderRef<MemoEditorState> {
  /// The parameter `memoId` of this provider.
  int? get memoId;
}

class _MemoEditorControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MemoEditorController,
        MemoEditorState> with MemoEditorControllerRef {
  _MemoEditorControllerProviderElement(super.provider);

  @override
  int? get memoId => (origin as MemoEditorControllerProvider).memoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
