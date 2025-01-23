import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraImage;

import 'qr_track.dart';
import 'src/controller/zxing.dart';
import 'src/model/code.dart';
import 'src/model/encode.dart';
import 'src/model/params.dart';

export 'bindings_generated.dart';
export 'src/controller/zxing.dart';
export 'src/util/extentions.dart';
export 'src/util/image_converter.dart';

Zxing getZxing() => ZxingMobile();

class ZxingMobile implements Zxing {
  ZxingMobile();

  @override
  String version() => zxingVersion();

  @override
  void setLogEnabled(bool enabled) => setZxingLogEnabled(enabled);

  @override
  String barcodeFormatName(int format) => zxingBarcodeFormatName(format);

  @override
  Encode encodeBarcode({
    required String contents,
    required EncodeParams params,
  }) =>
      zxingEncodeBarcode(contents: contents, params: params);

  @override
  Future<void> startCameraProcessing() => zxingStartCameraProcessing();

  @override
  void stopCameraProcessing() => zxingStopCameraProcessing();

  @override
  Future<Code> processCameraImage(CameraImage image, DecodeParams params) async =>
      await zxingProcessCameraImage(image, params) as Code;

  @override
  Future<Codes> processCameraImageMulti(CameraImage image, DecodeParams params) async =>
      await zxingProcessCameraImage(image, params) as Codes;

  @override
  Code readBarcode(Uint8List bytes, DecodeParams params) => zxingReadBarcode(bytes, params);

  @override
  Codes readBarcodes(Uint8List bytes, DecodeParams params) => zxingReadBarcodes(bytes, params);
}
