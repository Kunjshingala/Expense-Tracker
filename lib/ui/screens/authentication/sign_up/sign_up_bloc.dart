import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/subjects.dart';

import '../../../../utils/auth_error_message.dart';
import '../../../../utils/utils.dart';
import '../../../common_view/snack_bar.dart';
import '../../main_home/main_navigation_screen.dart';
import '../../../../utils/route.dart';

class SignUpBloc {
  final BuildContext context;

  SignUpBloc({required this.context});

  static const String tag = "SignUpBloc";

  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleAuthProvider provider = GoogleAuthProvider();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isShowPasswordSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getIsShowPassword => isShowPasswordSubject.stream;

  Function(bool) get setIsShowPassword => isShowPasswordSubject.add;

  final isEmailEligibleSubject = BehaviorSubject<bool>();

  Stream<bool> get getIsEmailEligible => isEmailEligibleSubject.stream;

  Function(bool) get setIsEmailEligible => isEmailEligibleSubject.add;

  final isTermAcceptSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getIsTermAccept => isTermAcceptSubject.stream;

  Function(bool) get setIsTermAccept => isTermAcceptSubject.add;

  bool checkButtonEligible() {
    if (nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        isEmailEligibleSubject.value &&
        passwordController.text.trim().isNotEmpty &&
        isTermAcceptSubject.value) {
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

  void createUserWithEmailPassword() async {
    try {
      logD(tag, message: emailController.text.trim());
      logD(tag, message: passwordController.text.trim());

      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      /// SignOut and Move to Login page.
      if (context.mounted) showMySnackBar(message: languages.loginSuccessfully);

      if (context.mounted) {
        openScreenWithClearPrevious(context, const MainNavigationScreen());
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
  }

  void signInWithGoogle() async {
    try {
      // await auth.signOut();
      //
      // await auth.signInWithProvider(provider);

      await GoogleSignIn.instance.signOut();

      /// Trigger the authentication flow. Throws rather than returning
      /// null when the user backs out; see the GoogleSignInException catch.
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      /// Obtain the auth details from the request. This is a plain getter
      /// now, and carries only the id token.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      /// Create a new credential. Access tokens moved to the separate
      /// authorization client in 7.x, and Firebase only needs one of the
      /// two tokens.
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (context.mounted) {
        openScreenWithClearPrevious(context, const MainNavigationScreen());
      }

      if (context.mounted) {
        openScreenWithClearPrevious(context, const MainNavigationScreen());
      }
    } on GoogleSignInException catch (e) {
      logD(tag, message: '${e.code} ${e.description}');

      /// backing out of the account picker is not an error worth showing.
      if (e.code == GoogleSignInExceptionCode.canceled) return;

      if (context.mounted) showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } on FirebaseAuthException catch (e) {
      logD(tag, message: e.code);
      if (context.mounted) {
        showMySnackBar(message: authErrorMessage(e), messageType: MessageType.failed);
      }
    } catch (e) {
      debugPrint('----> catch (e) ${e.toString()}');
      if (context.mounted) {
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      }
    }
  }

  void dispose() {
    nameController.dispose();
    isShowPasswordSubject.close();
    isEmailEligibleSubject.close();
    isTermAcceptSubject.close();
  }
}

/// Sign Up / create user
// email-already-in-use: Thrown if there already exists an account with the given email address.
// invalid-email: Thrown if the email address is not valid.
// operation-not-allowed: Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
// weak-password: Thrown if the password is not strong enough.

/// Sign in google
// user-disabled: Thrown if the user corresponding to the given email has been disabled.
