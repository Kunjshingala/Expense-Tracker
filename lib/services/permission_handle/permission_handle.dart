import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
        showMySnackBar('This feature cant use, Enable location services', MessageType.warning);
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
      return false;
      showMySnackBar('Please allow permission to use this permission.', MessageType.warning);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    Geolocator.openAppSettings();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      showMySnackBar('Please allow permission to use this permission.', MessageType.warning);

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
        showMySnackBar('Storage Permission Needed', MessageType.warning);

        return false;
      }
    } else if (status[Permission.storage]!.isPermanentlyDenied) {
      openAppSettings().then(
        (value) async {
          if (value) {
            if (status[Permission.storage]!.isGranted) {
              return true;
            } else {
              showMySnackBar('Storage Permission Needed', MessageType.warning);
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
      showMySnackBar('Camera Permission Needed', MessageType.warning);
    }
  } else if (status[Permission.camera]!.isPermanentlyDenied) {
    openAppSettings().then(
      (value) async {
        if (value) {
          status = await [Permission.camera].request();
          if (status[Permission.camera]!.isGranted) {
            return true;
          } else {
            showMySnackBar('Camera Permission Needed', MessageType.warning);

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
