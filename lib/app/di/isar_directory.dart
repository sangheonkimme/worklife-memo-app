import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_directory_stub.dart'
    if (dart.library.io) 'isar_directory_io.dart';

Future<String?> resolveIsarDirectory() async {
  if (kIsWeb) {
    return null;
  }

  try {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  } catch (_) {
    return fallbackIsarDirectory();
  }
}
