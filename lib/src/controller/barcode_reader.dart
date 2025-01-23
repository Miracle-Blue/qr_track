part of 'zxing.dart';

// Reads barcode from Uint8List image bytes
Code zxingReadBarcode(Uint8List bytes, DecodeParams params) => _readBarcode(bytes, params);

Code _readBarcode(Uint8List bytes, DecodeParams params) =>
    bindings.readBarcode(params.toDecodeBarcodeParams(bytes)).toCode();
