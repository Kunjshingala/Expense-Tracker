import 'dart:io';

import 'package:expense_tracker/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File> cropImage(BuildContext context, File sourceFile) async {
  final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourceFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Image Cropper',
          toolbarColor: violet100Color,
          toolbarWidgetColor: light100Color,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Image Cropper',
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(context: context),
      ]);

  imageCache.clear();

  if (croppedFile != null) {
    return File(croppedFile.path);
  } else {
    return sourceFile;
  }
}
