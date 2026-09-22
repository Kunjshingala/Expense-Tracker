import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

logD(String tag, {required String message, bool inRelease = false}) {
  if (inRelease && kReleaseMode) {
    dev.log('$tag, $message');
  } else if (kDebugMode) {
    dev.log('$tag, $message');
  }
}
