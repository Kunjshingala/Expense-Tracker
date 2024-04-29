import 'package:flutter/material.dart';

class ProfileFeatureOption {
  final IconData iconData;
  final Color iconColor;
  final Color iconBG;
  final String label;
  final Function()? onPressed;

  ProfileFeatureOption({
    required this.iconData,
    required this.iconColor,
    required this.iconBG,
    required this.label,
    required this.onPressed,
  });
}

class UserDetails {
  final String name;
  final String profileUrl;

  UserDetails({required this.name, required this.profileUrl});
}
