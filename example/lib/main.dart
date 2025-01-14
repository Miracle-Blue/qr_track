import 'dart:async';

import 'package:flutter/material.dart';

import 'src/common/util/logger.dart';
import 'src/common/widget/app.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<Future<void>>(
      () async {
        runApp(const App());
      },
      severe,
    );
