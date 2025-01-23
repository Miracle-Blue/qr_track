import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'src/model/code.dart';
import 'src/model/encode.dart';
import 'src/model/params.dart';
import 'zxing_mobile.dart';

export 'package:camera/camera.dart' show ResolutionPreset, CameraLensDirection;

export 'src/widget/qr_view.dart';
export 'src/widget/qr_view_controller.dart';

final Zxing zx = Zxing();

abstract class Zxing {
  /// factory constructor to return the correct implementation.
  factory Zxing() => getZxing();

  String version() => '';
  void setLogEnabled(bool enabled) {}
  String barcodeFormatName(int format) => '';

  /// Creates barcode from the given contents
  Encode encodeBarcode({
    required String contents,
    required EncodeParams params,
  });

  /// Starts reading barcode from the camera
  Future<void> startCameraProcessing();

  /// Stops reading barcode from the camera
  void stopCameraProcessing();

  /// Reads barcode from the camera
  Future<Code> processCameraImage(CameraImage image, DecodeParams params);

  /// Reads barcodes from the camera
  Future<Codes> processCameraImageMulti(CameraImage image, DecodeParams params);

  /// Reads barcode from Uint8List image bytes
  Code readBarcode(Uint8List bytes, DecodeParams params);

  /// Reads barcodes from Uint8List image bytes
  Codes readBarcodes(Uint8List bytes, DecodeParams params);
}
