import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walkntalk/main.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {}; // Disable debug logs
  }

  runApp(const MyApp(isLoggedIn: true,));
}
