import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

Future<Uint8List> convertImage(CameraImage image) async {
  try {
    return image.planes.first.bytes;
  } catch (e) {
    developer.log('>>>>>>>>>>>> ERROR: $e');
  }
  return Uint8List(0);
}

Uint8List rgbBytes(imglib.Image image) {
  return image.getBytes(order: imglib.ChannelOrder.rgb);
}
