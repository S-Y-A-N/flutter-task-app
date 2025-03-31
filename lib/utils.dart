import 'dart:io';
import 'package:flutter/material.dart';

Widget loadImage(String path) {
  bool imageExists = File(path).existsSync();

  if (imageExists) {
    return Image.asset(path);
  } else {
    return SizedBox.shrink();
  }
}