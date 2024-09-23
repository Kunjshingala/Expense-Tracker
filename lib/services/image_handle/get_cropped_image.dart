import 'dart:io';

import 'package:expense_tracker/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../permission_handle/permission_handle.dart';

Future<File?> captureAndCropImage(BuildContext context) async {
  bool camaraPermissionAllowed = await checkCameraPermission();

  if (camaraPermissionAllowed) {
    final xFile = (await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100))!;
    final file = File(xFile.path);

    if (context.mounted) {
      final croppedFile = await cropImage(context, file);
      return croppedFile;
    }
  }
  return null;
}

Future<File?> pickAndCropImage(BuildContext context) async {
  bool isStoragePermissionAllowed = await checkStoragePermission();

  if (isStoragePermissionAllowed) {
    final xFile = (await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100))!;
    final file = File(xFile.path);

    if (context.mounted) Navigator.pop(context);

    if (context.mounted) {
      final croppedFile = await cropImage(context, file);
      return croppedFile;
    }
  }
  return null;
}

Future<File> cropImage(BuildContext context, File sourceFile) async {
  final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourceFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: violet100Color,
            toolbarWidgetColor: light100Color,
            activeControlsWidgetColor: violet100Color,
            cropGridColor: violet20Color,
            lockAspectRatio: false,
            initAspectRatio: CropAspectRatioPreset.original,
            aspectRatioPresets: [CropAspectRatioPreset.square]),
        IOSUiSettings(
            title: 'Image Cropper',
            aspectRatioLockEnabled: true,
            aspectRatioPresets: [CropAspectRatioPreset.square]),
        WebUiSettings(context: context),
      ]);

  imageCache.clear();

  if (croppedFile != null) {
    return File(croppedFile.path);
  } else {
    return sourceFile;
  }
}
