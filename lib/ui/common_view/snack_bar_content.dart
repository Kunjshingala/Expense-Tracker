import 'package:expense_tracker/utils/constant.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';

class SnackBarContent extends StatelessWidget {
  const SnackBarContent({super.key, required this.message, required this.messageType});

  final String message;
  final MessageType messageType;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.inter(
        color: getTextColor(messageType),
        fontWeight: FontWeight.w400,
        fontSize: averageScreenSize * 0.025,
      ),
    );
  }

  Color? getTextColor(MessageType messageType) {
    if (messageType == MessageType.warning) {
      return dark100Color;
    }
    if (messageType == MessageType.success) {
      return light100Color;
    }
    if (messageType == MessageType.failed) {
      return light100Color;
    }
    return null;
  }
}

enum MessageType { warning, success, failed }

void showMySnackBar({required String message, required MessageType messageType}) {
  scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      backgroundColor: getSnackBarBGColor(messageType),
      content: SnackBarContent(message: message, messageType: messageType),
    ),
  );
}

Color? getSnackBarBGColor(MessageType messageType) {
  if (messageType == MessageType.warning) {
    return yellow80Color;
  }
  if (messageType == MessageType.success) {
    return green80Color;
  }
  if (messageType == MessageType.failed) {
    return red80Color;
  }
  return null;
}

// warning -->  yellow
// success --> green
// failed --> red
