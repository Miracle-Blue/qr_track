part of 'zxing.dart';

/// Supported platforms enum
enum SupportedPlatform { android, ios, linux, windows, macos, unknown }

/// Library name mapping
const Map<SupportedPlatform, String> _libraryNames = {
  SupportedPlatform.android: 'libqr_track.so',
  SupportedPlatform.linux: 'libqr_track.so',
  SupportedPlatform.windows: 'qr_track.dll',
  SupportedPlatform.macos: 'libqr_track.dylib',
  SupportedPlatform.ios: '', // Uses process()
};

/// Get current platform
SupportedPlatform _getCurrentPlatform() {
  if (Platform.isAndroid) return SupportedPlatform.android;
  if (Platform.isIOS) return SupportedPlatform.ios;
  if (Platform.isLinux) return SupportedPlatform.linux;
  if (Platform.isWindows) return SupportedPlatform.windows;
  if (Platform.isMacOS) return SupportedPlatform.macos;
  return SupportedPlatform.unknown;
}

/// Get library path
String _getLibraryPath(SupportedPlatform platform) {
  final libraryName = _libraryNames[platform];
  if (libraryName == null) {
    throw UnsupportedError('Platform ${platform.name} is not supported');
  }

  if (platform == SupportedPlatform.android) {
    return libraryName;
  }

  final executableDir = Directory(Platform.resolvedExecutable).parent;
  return path.join(executableDir.path, 'lib', libraryName);
}

/// Open dynamic library with error handling
DynamicLibrary _openDynamicLibrary() {
  try {
    final platform = _getCurrentPlatform();
    developer.log('Loading library for platform: ${platform.name}');

    if (platform == SupportedPlatform.ios) {
      developer.log('Using process() for iOS');
      return DynamicLibrary.process();
    }

    if (platform == SupportedPlatform.unknown) {
      throw UnsupportedError('Unsupported platform');
    }

    final libraryPath = _getLibraryPath(platform);
    developer.log('Loading library from: $libraryPath');

    return DynamicLibrary.open(libraryPath);
  } catch (e) {
    developer.log('Failed to load library: $e', error: e);
    rethrow;
  }
}

/// Initialize bindings
final DynamicLibrary dylib = _openDynamicLibrary();
final BindingsGenerated bindings = BindingsGenerated(dylib);
