part of 'zxing.dart';

/// Reads barcodes from Uint8List image bytes
Codes zxingReadBarcodes(Uint8List bytes, DecodeParams params) => _readBarcodes(bytes, params);

Codes _readBarcodes(Uint8List bytes, DecodeParams params) {
  final CodeResults result = bindings.readBarcodes(params.toDecodeBarcodeParams(bytes));
  final List<Code> codes = <Code>[];

  if (result.count == 0 || result.results == nullptr) {
    return Codes(codes: codes, duration: result.duration);
  }

  for (int i = 0; i < result.count; i++) {
    codes.add(result.results[i].toCode());
  }
  malloc.free(result.results);
  return Codes(codes: codes, duration: result.duration);
}
