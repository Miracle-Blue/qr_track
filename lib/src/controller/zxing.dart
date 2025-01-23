import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'dart:isolate';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../../bindings_generated.dart';
import '../model/code.dart';
import '../model/encode.dart';
import '../model/format.dart';
import '../model/params.dart';
import '../util/extentions.dart';
import '../util/isolate_utils.dart';

part 'barcode_encoder.dart';
part 'barcode_reader.dart';
part 'barcodes_reader.dart';
part 'bindings.dart';
part 'camera_stream.dart';

/// Returns a version of the zxing library
String zxingVersion() => bindings.version().cast<Utf8>().toDartString();

/// Enables or disables the logging of the library
void setZxingLogEnabled(bool enabled) => bindings.setLogEnabled(enabled);

/// Returns a readable barcode format name
String zxingBarcodeFormatName(int format) => barcodeNames[format] ?? 'Unknown';

extension Uint8ListExt on Uint8List {
  /// Copy the [Uint8List] into a freshly allocated [Pointer<Uint8>].
  Pointer<Uint8> copyToNativePointer() {
    final Pointer<Uint8> ptr = malloc<Uint8>(length);
    final Uint8List view = ptr.asTypedList(length);
    view.setAll(0, this);
    return ptr;
  }
}
