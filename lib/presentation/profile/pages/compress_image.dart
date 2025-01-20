import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile?> compressImage(File file) async {
  final targetPath = '${file.parent.path}/compressed_${file.path.split('/').last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '.jpg')}';
  if (kDebugMode) {
    print('Target path for compressed image: $targetPath');
  }

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 75,
    minWidth: 300,
    minHeight: 300,
  );

  if (result == null) {
    if (kDebugMode) {
      print('Compression failed');
    }
  } else {
    if (kDebugMode) {
      print('Compressed image saved at: ${result.path}');
    }
  }

  return result;
}
