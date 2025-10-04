import 'dart:io';

import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/image_pick/image_pick.dart';
import '../../utils/colors.dart';
import '../../utils/custom_icons.dart';
import '../../utils/dimens.dart';

class AttachmentBottomSheet extends StatelessWidget {
  const AttachmentBottomSheet({super.key, required this.setFile});

  final Function(File?) setFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: screenWidth * 0.1,
          height: averageScreenSize * 0.008,
          decoration: BoxDecoration(color: violet40, borderRadius: BorderRadius.circular(averageScreenSize * 0.01)),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () async {
                setFile(await pickAndCropImage(context));
              },
              child: Container(
                width: screenWidth * 0.35,
                height: screenHeight * 0.15,
                decoration: BoxDecoration(
                  color: violet20,
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CustomIcons.gallery_icons, size: averageScreenSize * 0.07, color: violet100),
                    SizedBox(height: screenHeight * 0.01),
                    Text(languages.gallery, style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                setFile(await captureAndCropImage(context));
              },
              child: Container(
                width: screenWidth * 0.35,
                height: screenHeight * 0.15,
                decoration: BoxDecoration(
                  color: violet20,
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CustomIcons.camera_icons, size: averageScreenSize * 0.07, color: violet100),
                    SizedBox(height: screenHeight * 0.01),
                    Text(languages.camera, style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
