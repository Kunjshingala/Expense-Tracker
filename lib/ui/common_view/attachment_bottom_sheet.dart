import 'dart:io';

import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/image_handle/get_cropped_image.dart';

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
          decoration: BoxDecoration(
              color: violet40Color, borderRadius: BorderRadius.circular(averageScreenSize * 0.01)),
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
                  color: violet20Color,
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CustomIcons.gallery_icons, size: averageScreenSize * 0.07, color: violet100Color),
                    SizedBox(height: screenHeight * 0.01),
                    Text('Gallery', style: GoogleFonts.poppins()),
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
                  color: violet20Color,
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CustomIcons.camera_icons, size: averageScreenSize * 0.07, color: violet100Color),
                    SizedBox(height: screenHeight * 0.01),
                    Text('Camara', style: GoogleFonts.poppins()),
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
