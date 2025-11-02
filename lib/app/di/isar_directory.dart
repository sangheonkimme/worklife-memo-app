import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_directory_stub.dart'
    if (dart.library.io) 'isar_directory_io.dart' as impl;

export 'isar_directory_stub.dart'
    if (dart.library.io) 'isar_directory_io.dart'
    show clearIsarDirectory, prepareResolvedIsarDirectory;

Future<String?> resolveIsarDirectory() async {
  if (kIsWeb) {
    return null;
  }

  try {
    final dir = await getApplicationDocumentsDirectory();
    return impl.ensureIsarDirectory(dir.path);
  } catch (_) {
    final fallback = await impl.fallbackIsarDirectory();
    if (fallback == null) {
      return null;
    }
    return impl.ensureIsarDirectory(fallback);
  }
}
