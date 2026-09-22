import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../utils/colors.dart';
import '../../../../../utils/dimens.dart';
import '../../../../common_view/common_button.dart';
import '../../../../common_view/snack_bar.dart';
import '../../../../../utils/route.dart';

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({
    super.key,
    required this.editNameController,
    required this.getChangeNameProcessStatus,
    required this.setChangeNameProcessStatus,
  });

  final TextEditingController editNameController;
  final Stream<bool> getChangeNameProcessStatus;
  final Function(bool) setChangeNameProcessStatus;

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  @override
  void didChangeDependencies() {
    getName();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Change Name',
        style: GoogleFonts.inter(
          color: black100,
          fontWeight: FontWeight.w600,
          fontSize: averageScreenSize * 0.045,
        ),
      ),
      backgroundColor: white100,
      surfaceTintColor: white100,
      alignment: AlignmentDirectional.center,
      titlePadding: EdgeInsetsDirectional.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: screenWidth * 0.15,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: screenWidth * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: widget.editNameController,
              style: GoogleFonts.inter(
                color: black50,
                fontSize: averageScreenSize * 0.025,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: white20),
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: white20),
                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            StreamBuilder<bool>(
              stream: widget.getChangeNameProcessStatus,
              builder: (context, snapshot) {
                return CustomButton(
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.06,
                  onPressed: snapshot.hasData && !(snapshot.data!) ? changeName : null,
                  child: snapshot.hasData && !(snapshot.data!)
                      ? Text(
                          'Change',
                          style: GoogleFonts.inter(
                            color: white80,
                            fontWeight: FontWeight.w600,
                            fontSize: averageScreenSize * 0.025,
                          ),
                        )
                      : CircularProgressIndicator(
                          color: white100,
                          backgroundColor: violet100,
                          strokeWidth: screenWidth * 0.005,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void getName() {
    final authCurrentUser = FirebaseAuth.instance.currentUser!;
    String name = authCurrentUser.displayName ?? '';
    widget.editNameController.text = name;
  }

  changeName() async {
    final authCurrentUser = FirebaseAuth.instance.currentUser;

    final name = widget.editNameController.text;
    if (name.isEmpty) {
      showMySnackBar(message: 'Enter Valid Name.', messageType: MessageType.warning);
    } else if (name.length > 8) {
      showMySnackBar(message: 'Name should be less than 8 word.', messageType: MessageType.warning);
    } else if (name.length > 3) {
      widget.setChangeNameProcessStatus(true);

      try {
        await authCurrentUser!.updateDisplayName(name);
      } on FirebaseException catch (e) {
        debugPrint('---------------------------------->$e');
        widget.setChangeNameProcessStatus(false);
      } catch (e) {
        debugPrint('---------------------------------->$e');
        showMySnackBar(message: 'SomeThing went wrong.', messageType: MessageType.failed);
        widget.setChangeNameProcessStatus(false);
      }

      widget.setChangeNameProcessStatus(false);
    }
    if (context.mounted) closeScreen(context);
  }
}
