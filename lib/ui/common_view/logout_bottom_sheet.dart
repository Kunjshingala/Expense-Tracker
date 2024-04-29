import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/colors.dart';
import '../../utils/dimens.dart';
import '../screens/splash/splash_screen.dart';
import 'main_eleveted_button.dart';

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
        color: light100Color,
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
              color: violet40Color,
              borderRadius: BorderRadius.circular(averageScreenSize * 0.01),
            ),
          ),
          Column(
            children: [
              Text(
                'Logout?',
                style: GoogleFonts.inter(
                  color: dark100Color,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.0325,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                'Are you sure do you wanna logout?',
                style: GoogleFonts.inter(
                  color: light0Color,
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
              CustomElevatedButton(
                width: screenWidth * 0.4,
                height: screenHeight * 0.075,
                borderRadius: averageScreenSize * 0.03,
                color: violet20Color,
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: Text(
                  'No',
                  style: GoogleFonts.inter(
                    color: violet100Color,
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
                    return CustomElevatedButton(
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.075,
                      borderRadius: averageScreenSize * 0.03,
                      color: violet100Color,
                      onPressed: snapshot.hasData && snapshot.data! ? null : logoutUser,
                      child: snapshot.hasData && snapshot.data!
                          ? CircularProgressIndicator(
                              color: light80Color,
                              backgroundColor: violet100Color,
                              strokeWidth: screenWidth * 0.005,
                            )
                          : Text(
                              'Yes',
                              style: GoogleFonts.inter(
                                color: light80Color,
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
    // TODO: implement dispose
    super.dispose();
    logoutProcessStatusSubject.close();
  }

  void logoutUser() async {
    debugPrint('--------------------------------------------------------------------> logoutUser() Called');
    setLogoutProcessStatus(true);
    try {
      /// Sign Out
      await auth.signOut();
      await Future.delayed(const Duration(seconds: 3));

      /// show snack bar
      showMySnackBar(message: 'Logout successfully', messageType: MessageType.success);

      /// Push to splash screen

      pushReplacementWithoutNavBar(
        navigatorKey.currentState!.context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } on FirebaseException catch (e) {
      debugPrint('----------------------------------> on FirebaseException catch (e) $e');
      showMySnackBar(message: 'Something went wrong', messageType: MessageType.failed);
    } catch (e) {
      debugPrint('----------------------------------> catch (e) $e');
      showMySnackBar(message: 'Something went wrong', messageType: MessageType.failed);
    }

    setLogoutProcessStatus(false);
  }
}
