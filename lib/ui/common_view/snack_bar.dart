import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors.dart';
import '../../utils/constant.dart';

// warning -->  yellow
// success --> green
// failed --> red

enum MessageType { warning, success, failed }

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
    switch (messageType) {
      case MessageType.warning:
        return black100;
      case MessageType.success:
        return white100;
      case MessageType.failed:
        return white100;
    }
  }
}

Color? getSnackBarBGColor(MessageType messageType) {
  switch (messageType) {
    case MessageType.warning:
      return yellow80;
    case MessageType.success:
      return green80;
    case MessageType.failed:
      return red80;
  }
}

void showMySnackBar({required String message, MessageType messageType = MessageType.success}) {
  scaffoldMessengerKey.currentState?.clearSnackBars();
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      backgroundColor: getSnackBarBGColor(messageType),
      content: SnackBarContent(message: message, messageType: messageType),
    ),
  );
}
