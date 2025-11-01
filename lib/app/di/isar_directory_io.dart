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
