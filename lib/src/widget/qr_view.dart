import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../model/code.dart';
import '../model/format.dart';
import 'qr_view_controller.dart';

/// {@template qr_view}
/// QrView widget.
/// {@endtemplate}
class QrView extends StatefulWidget {
  /// {@macro qr_view}
  const QrView({
    this.onScan,
    this.onScanFailure,
    this.onControllerCreated,
    this.codeFormat = Format.any,
    this.scanDelay = const Duration(milliseconds: 500),
    this.scanDelaySuccess = const Duration(milliseconds: 1000),
    this.lensDirection = CameraLensDirection.back,
    super.key, // ignore: unused_element
  });

  /// Called when a code is detected
  final Function(Code)? onScan;

  /// Called when a code is not detected
  final Function(Code)? onScanFailure;

  /// Callback for when the [CameraController] is created.
  final void Function(CameraController? controller, CameraException? exception)? onControllerCreated;

  /// The direction that the camera is facing.
  final CameraLensDirection lensDirection;

  /// Delay between scans when no code is detected
  final Duration scanDelay;

  /// Delay between scans when a code is detected, will be ignored if isMultiScan is true
  final Duration scanDelaySuccess;

  /// Code format to scan
  final int codeFormat;

  @override
  State<QrView> createState() => _QrViewState();
}

/// View for widget QrView.
class _QrViewState extends QrViewController {
  @override
  Widget build(BuildContext context) {
    final bool isCameraReady =
        cameras.isNotEmpty && isCameraOn && controller != null && controller!.value.isInitialized;

    final Size size = MediaQuery.of(context).size;
    final double cameraMaxSize = max(size.width, size.height);

    return Stack(
      children: <Widget>[
        if (isCameraReady)
          Center(
            child: SizedBox(
              width: cameraMaxSize,
              height: cameraMaxSize,
              child: CameraPreview(controller!),
            ),
          ),
        if (!isCameraReady)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
