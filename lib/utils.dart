import 'dart:io';
import 'package:flutter/material.dart';

double maxWidth = 1000;

Widget loadImage(String path) {
  bool imageExists = File(path).existsSync();

  if (imageExists) {
    return Image.asset(path);
  } else {
    return SizedBox.shrink();
  }
}
