import 'dart:io';

String? _cachedFallbackPath;

Future<String?> fallbackIsarDirectory() async {
  if (_cachedFallbackPath != null) {
    return _cachedFallbackPath;
  }
  final tempDir = await Directory.systemTemp.createTemp('isar_db_');
  _cachedFallbackPath = tempDir.path;
  return _cachedFallbackPath;
}

Future<String> ensureIsarDirectory(String path) async {
  final baseDirectory = Directory(path);
  if (!await baseDirectory.exists()) {
    await baseDirectory.create(recursive: true);
  }

  final separator = Platform.pathSeparator;
  final normalizedPath = path.endsWith(separator) ? path : '$path$separator';
  final isarDirectory = Directory('${normalizedPath}isar');

  if (!await isarDirectory.exists()) {
    await isarDirectory.create(recursive: true);
  }

  return isarDirectory.path;
}

Future<void> clearIsarDirectory(String path) async {
  final directory = Directory(path);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
  }
}

Future<void> prepareResolvedIsarDirectory(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
}
