import 'package:flutter/material.dart';
import 'package:qr_track/qr_track.dart' as qr;

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
  late int sumResult;
  late Future<int> sumAsyncResult;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    sumResult = qr.sum(1, 2);
    sumAsyncResult = qr.sumAsync(3, 4);
  }

  @override
  void dispose() {
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'sum(1, 2) = $sumResult',
                  style: const TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                FutureBuilder<int>(
                  future: sumAsyncResult,
                  builder: (context, value) {
                    final displayValue = (value.hasData) ? value.data : 'loading';
                    return Text(
                      'await sumAsync(3, 4) = $displayValue',
                      style: const TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
