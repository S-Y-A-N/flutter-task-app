import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

double maxWidth = 1000;

Widget loadImage(String path) {
  if (!kIsWeb) {
    bool imageExists = File(path).existsSync();

    if (imageExists) {
      return Image.asset(path);
    }
  }

  return SizedBox.shrink();
}
