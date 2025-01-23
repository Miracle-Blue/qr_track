import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_track/qr_track.dart';

import '../../common/util/logger.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  double? ratio;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: AspectRatio(
          aspectRatio: ratio ?? 9 / 16,
          child: QrView(
            onControllerCreated: (controller, exception) async {
              fine(controller);
              fine(exception);

              if (Platform.isAndroid) {
                info('Locking orientation to portraitUp');
                await controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
              }

              ratio = controller?.value.aspectRatio ?? 0.0;
              setState(() {});
            },
            onScan: info,
          ),
        ),
      );
}
