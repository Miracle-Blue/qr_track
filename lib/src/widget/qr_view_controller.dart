import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart'
    show
        CameraDescription,
        CameraController,
        availableCameras,
        CameraException,
        CameraImage,
        ImageFormatGroup,
        ResolutionPreset;
import 'package:flutter/material.dart';
import 'package:qr_track/qr_track.dart';

import '../model/code.dart';
import '../model/image_format.dart' as imf;
import '../model/params.dart';

/// State for widget QrView.
abstract class QrViewController extends State<QrView> with WidgetsBindingObserver {
  bool isCameraOn = false;
  bool isProcessing = false;

  List<CameraDescription> cameras = <CameraDescription>[];
  CameraDescription? selectedCamera;
  CameraController? controller;

  bool get isAndroid => Theme.of(context).platform == TargetPlatform.android;

  Future<void> initStateAsync() async {
    // Spawn a new isolate
    await zx.startCameraProcessing();
    final List<CameraDescription> cameras = await availableCameras();

    if (!mounted || !context.mounted) return;

    setState(() {
      this.cameras = cameras;
      if (cameras.isNotEmpty) {
        selectedCamera = cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == widget.lensDirection,
          orElse: () => cameras.first,
        );
        onNewCameraSelected(selectedCamera);
      }
    });
  }

  Future<void> onNewCameraSelected(CameraDescription? cameraDescription) async {
    if (cameraDescription == null) return;

    final CameraController? oldController = controller;
    if (oldController != null) {
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );

    controller = cameraController;

    try {
      await cameraController.initialize();
      widget.onControllerCreated?.call(controller, null);
      cameraController.addListener(rebuildOnMount);
      cameraController.startImageStream(processImageStream);
    } on CameraException catch (e) {
      developer.log('CameraException: ${e.code}: ${e.description}');
      widget.onControllerCreated?.call(null, e);
    } catch (e) {
      developer.log('Error: $e');
    }

    rebuildOnMount();
  }

  Future<void> processImageStream(CameraImage image) async {
    if (!isProcessing) {
      isProcessing = true;
      try {
        final DecodeParams params = DecodeParams(
          imageFormat: _imageFormat(image.format.group),
          format: widget.codeFormat,
          width: image.width,
          height: image.height,
          cropLeft: (image.width) ~/ 2,
          cropTop: (image.height) ~/ 2,
          cropWidth: 0,
          cropHeight: 0,
        );

        final Code result = await zx.processCameraImage(image, params);

        if (result.isValid) {
          widget.onScan?.call(result);

          if (!mounted || !context.mounted) return;

          setState(() {});
          await Future<void>.delayed(widget.scanDelaySuccess);
        } else {
          widget.onScanFailure?.call(result);
        }
      } on FileSystemException catch (e) {
        developer.log('FileSystemException: ${e.message}');
      } catch (e) {
        developer.log('Error: $e');
      }

      await Future<void>.delayed(widget.scanDelay);
      isProcessing = false;
    }

    return;
  }

  void rebuildOnMount() {
    if (mounted && context.mounted) setState(() => isCameraOn = true);
  }

  int _imageFormat(ImageFormatGroup group) {
    switch (group) {
      case ImageFormatGroup.unknown:
        return imf.ImageFormat.none;
      case ImageFormatGroup.bgra8888:
        return imf.ImageFormat.bgrx;
      case ImageFormatGroup.yuv420:
        return imf.ImageFormat.lum;
      case ImageFormatGroup.jpeg:
        return imf.ImageFormat.rgb;
      case ImageFormatGroup.nv21:
        return imf.ImageFormat.rgb;
    }
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initStateAsync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        if (cameras.isNotEmpty && !isCameraOn) {
          onNewCameraSelected(cameras.first);
        }
        break;
      case AppLifecycleState.detached:
        break;
      default:
        controller?.dispose();
        setState(() => isCameraOn = false);
        break;
    }
  }

  @override
  void dispose() {
    zx.stopCameraProcessing();
    controller?.removeListener(rebuildOnMount);
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  /* #endregion */
}
