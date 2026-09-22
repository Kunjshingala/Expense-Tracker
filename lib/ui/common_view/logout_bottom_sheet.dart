import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/colors.dart';
import '../../utils/constant.dart';
import '../screens/splash/splash_screen.dart';
import 'common_button.dart';
import 'snack_bar.dart';
import '../../utils/route.dart';

class LogoutBottomSheet extends StatefulWidget {
  const LogoutBottomSheet({super.key});

  @override
  State<LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  final auth = FirebaseAuth.instance;

  final logoutProcessStatusSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getLogoutProcessStatus => logoutProcessStatusSubject.stream;

  Function(bool) get setLogoutProcessStatus => logoutProcessStatusSubject.add;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.3,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: white100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(averageScreenSize * 0.03),
          topRight: Radius.circular(averageScreenSize * 0.03),
        ),
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.0005,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: screenWidth * 0.1,
            height: averageScreenSize * 0.008,
            decoration: BoxDecoration(
              color: violet40,
              borderRadius: BorderRadius.circular(averageScreenSize * 0.01),
            ),
          ),
          Column(
            children: [
              Text(
                '${languages.logout} ?',
                style: GoogleFonts.inter(
                  color: black100,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.0325,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                languages.logoutConfirmationMsg,
                style: GoogleFonts.inter(
                  color: white0,
                  fontWeight: FontWeight.w500,
                  fontSize: averageScreenSize * 0.0275,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomButton(
                width: screenWidth * 0.4,
                height: screenHeight * 0.075,
                btnColor: violet20,
                onPressed: () {
                  closeScreen(context);
                },
                child: Text(
                  languages.no,
                  style: GoogleFonts.inter(
                    color: violet100,
                    fontWeight: FontWeight.w600,
                    fontSize: averageScreenSize * 0.03,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints.expand(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.075,
                ),
                child: StreamBuilder<bool>(
                  stream: getLogoutProcessStatus,
                  builder: (context, snapshot) {
                    return CustomButton(
                      onPressed: snapshot.hasData && snapshot.data! ? null : logoutUser,
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.075,
                      child: snapshot.hasData && snapshot.data!
                          ? CircularProgressIndicator(
                              color: white80,
                              backgroundColor: violet100,
                              strokeWidth: screenWidth * 0.005,
                            )
                          : Text(
                              languages.yes,
                              style: GoogleFonts.inter(
                                color: white80,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.03,
                              ),
                            ),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    logoutProcessStatusSubject.close();
    super.dispose();
  }

  void logoutUser() async {
    debugPrint('--------------------------------------------------------------------> logoutUser() Called');
    setLogoutProcessStatus(true);
    try {
      /// Sign Out
      await auth.signOut();
      await Future.delayed(const Duration(seconds: 3));

      /// show snack bar
      showMySnackBar(message: languages.logoutSuccessfully);

      /// Push to splash screen

      openScreenWithReplacePreviousWithoutNavBar(
        navigatorKey.currentState!.context,
        const SplashScreen(),
      );
    } on FirebaseException catch (e) {
      debugPrint('----------------------------------> on FirebaseException catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } catch (e) {
      debugPrint('----------------------------------> catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    }

    setLogoutProcessStatus(false);
  }
}
