import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../utils/auth_error_message.dart';
import '../../../../../utils/utils.dart';
import '../../../../common_view/snack_bar.dart';
import 'forgot_password_email_sent_screen.dart';

class ForgotPasswordBloc {
  static const String tag = "ForgotPasswordBloc";

  final BuildContext context;

  ForgotPasswordBloc({required this.context});

  final FirebaseAuth auth = FirebaseAuth.instance;

  final emailController = TextEditingController();

  final isEmailEligibleSubject = BehaviorSubject<bool>();

  Stream<bool> get getIsEmailEligible => isEmailEligibleSubject.stream;

  Function(bool) get setIsEmailEligible => isEmailEligibleSubject.add;

  bool checkButtonEligible() {
    if (emailController.text.trim().isNotEmpty && isEmailEligibleSubject.value) {
      return true;
    } else {
      return false;
    }
  }

  void emailValidate(String emailText) {
    String value =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = RegExp(value);

    setIsEmailEligible(regExp.hasMatch(emailText));
  }

  void sendResetPassEmail() async {
    final isReadyToSend = checkButtonEligible();

    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());

      if (context.mounted) {
        if (context.mounted) {
          showMySnackBar(message: languages.sentSuccessfully);
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordEmailSentScreen(email: emailController.text.trim())),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      logD(tag, message: e.code);
      if (context.mounted) {
        showMySnackBar(message: authErrorMessage(e), messageType: MessageType.failed);
      }
    } catch (e) {
      if (context.mounted) {
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      }
    }

    if (isReadyToSend) {
    } else {
      if (context.mounted) {
        showMySnackBar(message: languages.fieldValidationMsg, messageType: MessageType.warning);
      }
    }
  }

  void dispose() {
    emailController.dispose();
    isEmailEligibleSubject.close();
  }
}
