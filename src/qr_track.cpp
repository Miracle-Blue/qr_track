#include "qr_track.h"

#include "common.h"
#include "dart_alloc.h"
#include "ReadBarcode.h"
#include "MultiFormatWriter.h"
#include "BitMatrix.h"
// #include "ZXVersion.h" // This file is not existing for iOS

#include <algorithm>
#include <chrono>
#include <string>
#include <vector>

using namespace ZXing;
using namespace std;
using std::chrono::steady_clock;

// Forward declare some impls
CodeResult _readBarcode(const DecodeBarcodeParams &params) noexcept;
CodeResults _readBarcodes(const DecodeBarcodeParams &params) noexcept;
EncodeResult _encodeBarcode(const EncodeBarcodeParams &params) noexcept;

//
// Public, exported FFI functions
//

extern "C"
{
  FUNCTION_ATTRIBUTE
  void setLogEnabled(bool enable) noexcept
  {
    setLoggingEnabled(enable);
  }

  FUNCTION_ATTRIBUTE
  char const *version() noexcept
  {
    // return ZXING_VERSION_STR; // TODO: Not working on iOS for now
    return "1.0.0";
  }

  FUNCTION_ATTRIBUTE
  CodeResult readBarcode(DecodeBarcodeParams *params) noexcept
  {
    unique_dart_ptr<DecodeBarcodeParams> _params(params);
    return _readBarcode(*_params);
  }

  FUNCTION_ATTRIBUTE
  CodeResults readBarcodes(DecodeBarcodeParams *params) noexcept
  {
    unique_dart_ptr<DecodeBarcodeParams> _params(params);
    return _readBarcodes(*_params);
  }

  FUNCTION_ATTRIBUTE
  EncodeResult encodeBarcode(EncodeBarcodeParams *params) noexcept
  {
    unique_dart_ptr<EncodeBarcodeParams> _params(params);
    return _encodeBarcode(*_params);
  }
}

//
// Helper functions
//

ImageView createCroppedImageView(const DecodeBarcodeParams &params)
{
  ImageView image{
      reinterpret_cast<const uint8_t *>(params.bytes),
      params.width,
      params.height,
      ImageFormat(params.imageFormat),
  };
  if (params.cropWidth > 0 && params.cropHeight > 0 && params.cropWidth < params.width && params.cropHeight < params.height)
  {
    image = image.cropped(params.cropLeft, params.cropTop, params.cropWidth, params.cropHeight);
  }
  return image;
}

ReaderOptions createReaderOptions(const DecodeBarcodeParams &params)
{
  return ReaderOptions()
      .setTryHarder(params.tryHarder)
      .setTryRotate(params.tryRotate)
      .setFormats(BarcodeFormat(params.format))
      .setTryInvert(params.tryInvert)
      .setReturnErrors(true);
}

/// Returns an owned C-string `char*` copied from a `std::string&`.
/// The owned pointer is safe to send back to Dart.
char *dartCstrFromString(const std::string &s)
{
  auto len = s.length();
  auto *out = dart_malloc<char>(len + 1);
  std::copy(s.begin(), s.end(), out);
  out[len] = '\0';
  return out;
}

/// Returns an owned C-string `char*` copied from the `exception::what()` message.
/// The owned pointer is safe to send back to Dart.
char *dartCstrFromException(const exception &e) noexcept
{
  auto *s = e.what();
  auto len = strlen(s);
  auto *out = dart_malloc<char>(len + 1);
  std::copy_n(s, len, out);
  out[len] = '\0';
  return out;
}

/// Returns an owned byte buffer `uint8_t*` copied from a `std::vector<uint8_t>&`.
/// The owned pointer is safe to send back to Dart.
uint8_t *dartBytesFromVector(const std::vector<uint8_t> &v)
{
  auto *bytes = dart_malloc<uint8_t>(v.size());
  std::copy(v.begin(), v.end(), bytes);
  return bytes;
}

/// Returns an owned byte buffer `uint8_t*` copied from a `Matrix<uint8_t>&`.
/// The owned pointer is safe to send back to Dart.
uint8_t *dartBytesFromMatrix(const Matrix<uint8_t> &matrix)
{
  auto length = matrix.size();
  auto *data = dart_malloc<uint8_t>(length);
  std::copy(matrix.begin(), matrix.end(), data);
  return data;
}

// Construct a `CodeResult` from a zxing barcode decode `Result` from within an
// image.
CodeResult codeResultFromResult(
    const Result &result,
    int duration,
    int width,
    int height)
{
  auto p = result.position();
  auto tl = p.topLeft();
  auto tr = p.topRight();
  auto bl = p.bottomLeft();
  auto br = p.bottomRight();

  CodeResult code{};
  code.isValid = result.isValid();
  code.text = result.isValid() ? dartCstrFromString(result.text()) : nullptr;
  code.bytes = result.isValid() ? dartBytesFromVector(result.bytes()) : nullptr;
  code.error = result.isValid() ? nullptr : dartCstrFromString(result.error().msg());
  code.length = static_cast<int>(result.bytes().size());
  code.format = static_cast<int>(result.format());
  code.pos = Pos{width, height, tl.x, tl.y, tr.x, tr.y, bl.x, bl.y, br.x, br.y};
  code.isInverted = result.isInverted();
  code.isMirrored = result.isMirrored();
  code.duration = duration;

  return code;
}

// Returns the duration elapsed in milliseconds since `start`.
int elapsed_ms(const steady_clock::time_point &start)
{
  auto end = steady_clock::now();
  auto duration = end - start;
  return chrono::duration_cast<chrono::milliseconds>(duration).count();
}

//
// FFI impls
//

CodeResult _readBarcode(const DecodeBarcodeParams &params) noexcept
{
  // Absolutely ensure we don't unwind across the FFI boundary.
  try
  {
    auto start = steady_clock::now();

    ImageView image = createCroppedImageView(params);
    ReaderOptions hints = createReaderOptions(params);
    Result result = ReadBarcode(image, hints);

    int duration = elapsed_ms(start);
    platform_log("Read Barcode in: %d ms\n", duration);
    return codeResultFromResult(result, duration, params.width, params.height);
  }
  catch (const exception &e)
  {
    platform_log("Exception while reading barcode: %s\n", e.what());
    CodeResult result{};
    result.isValid = false;
    result.error = dartCstrFromException(e);
    return result;
  }
}

CodeResults _readBarcodes(const DecodeBarcodeParams &params) noexcept
{
  // Absolutely ensure we don't unwind across the FFI boundary.
  try
  {
    auto start = steady_clock::now();

    ImageView image = createCroppedImageView(params);
    ReaderOptions hints = createReaderOptions(params);
    Results results = ReadBarcodes(image, hints);

    int duration = elapsed_ms(start);
    platform_log("Read Barcode in: %d ms\n", duration);

    if (results.empty())
    {
      return CodeResults{0, nullptr, duration};
    }

    auto *codes = dart_malloc<CodeResult>(results.size());
    int i = 0;
    for (const auto &result : results)
    {
      codes[i] = codeResultFromResult(result, duration, params.width, params.height);
      i++;
    }
    return CodeResults{i, codes, duration};
  }
  catch (const exception &e)
  {
    platform_log("Exception while reading barcodes: %s\n", e.what());
    return CodeResults{0, nullptr, 0};
  }
}

EncodeResult _encodeBarcode(const EncodeBarcodeParams &params) noexcept
{
  // Absolutely ensure we don't unwind across the FFI boundary.
  try
  {
    auto start = steady_clock::now();

    auto writer = MultiFormatWriter(BarcodeFormat(params.format))
                      .setMargin(params.margin)
                      .setEccLevel(params.eccLevel)
                      .setEncoding(CharacterSet::UTF8);
    auto bitMatrix = writer.encode(params.contents, params.width, params.height);
    auto matrix = ToMatrix<uint8_t>(bitMatrix);

    EncodeResult result{};
    result.isValid = true;
    result.format = params.format;
    // We need to return an owned pointer across the ffi boundary. Copy.
    result.data = dartBytesFromMatrix(matrix);
    result.length = matrix.size();

    int duration = elapsed_ms(start);
    platform_log("Encode Barcode in: %d ms\n", duration);
    return result;
  }
  catch (const exception &e)
  {
    platform_log(
        "Exception encoding text: \"%s\", error: %s\n",
        params.contents, e.what());

    EncodeResult result{};
    result.isValid = false;
    result.format = params.format;
    result.error = dartCstrFromException(e);
    return result;
  }
}
