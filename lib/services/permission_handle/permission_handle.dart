import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ui/common_view/snack_bar.dart';
import '../../utils/constant.dart';

/// Location Services Status.
Future<bool> getLocationServiceStatus(BuildContext context) async {
  bool isServicesEnabled = await Geolocator.isLocationServiceEnabled();

  if (isServicesEnabled) {
    return true;
  } else {
    await Geolocator.openLocationSettings();

    isServicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (isServicesEnabled) {
      return true;
    } else {
      if (context.mounted) {
        showMySnackBar(message: languages.locationServiceInfoMsg, messageType: MessageType.warning);
      }
      return false;
    }
  }
}

/// Location Permission.
Future<bool> getLocationPermission() async {
  LocationPermission permission;

  /// check Location services.
  getLocationServiceStatus(scaffoldMessengerKey.currentContext!);

  /// Permission
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
    return true;
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      showMySnackBar(message: languages.locationServiceMsg, messageType: MessageType.warning);
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Geolocator.openAppSettings();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      showMySnackBar(message: languages.locationServiceMsg, messageType: MessageType.warning);

      return false;
    }
  }
  return false;
}

/// Camera And Storage Permission.
Future<bool> checkStoragePermission() async {
  Map<Permission, PermissionStatus> status;
  final deviceInfo = DeviceInfoPlugin();
  var androidDeviceInfo = await deviceInfo.androidInfo;

  if (Platform.isAndroid && androidDeviceInfo.version.sdkInt > 32) {
    return true;
  } else {
    status = await [Permission.storage].request();

    if (status[Permission.storage]!.isGranted) {
      return true;
    } else if (status[Permission.camera]!.isDenied) {
      status = await [Permission.storage].request();

      if (status[Permission.storage]!.isGranted) {
        return true;
      } else {
        showMySnackBar(message: languages.storagePermissionMsg, messageType: MessageType.warning);

        return false;
      }
    } else if (status[Permission.storage]!.isPermanentlyDenied) {
      openAppSettings().then(
        (value) async {
          if (value) {
            if (status[Permission.storage]!.isGranted) {
              return true;
            } else {
              showMySnackBar(message: languages.storagePermissionMsg, messageType: MessageType.warning);
              return false;
            }
          } else {
            return false;
          }
        },
      );
    } else {
      return false;
    }
  }
  return false;
}

/// Camera Permission.
Future<bool> checkCameraPermission() async {
  Map<Permission, PermissionStatus> status;

  status = await [Permission.camera].request();

  if (status[Permission.camera]!.isGranted) {
    return true;
  } else if (status[Permission.camera]!.isDenied) {
    status = await [Permission.camera].request();

    if (status[Permission.camera]!.isGranted) {
      return true;
    } else {
      showMySnackBar(message: languages.cameraPermissionMsg, messageType: MessageType.warning);
    }
  } else if (status[Permission.camera]!.isPermanentlyDenied) {
    openAppSettings().then(
      (value) async {
        if (value) {
          status = await [Permission.camera].request();
          if (status[Permission.camera]!.isGranted) {
            return true;
          } else {
            showMySnackBar(message: languages.cameraPermissionMsg, messageType: MessageType.warning);

            return false;
          }
        }
      },
    );
  } else {
    return false;
  }
  return false;
}
