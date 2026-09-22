import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../modals/firebase_modal/transaction_modal.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import '../screens/manage_transaction/delete_transaction/delete_transaction_bloc.dart';
import 'common_button.dart';
import '../../utils/route.dart';

class DeleteTransactionBottomSheet extends StatefulWidget {
  const DeleteTransactionBottomSheet({super.key, required this.transactionModal});

  final TransactionModal transactionModal;

  @override
  State<DeleteTransactionBottomSheet> createState() => _DeleteTransactionBottomSheetState();
}

class _DeleteTransactionBottomSheetState extends State<DeleteTransactionBottomSheet> {
  final deleteTransactionBloc = DeleteTransactionBloc();

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
                '${languages.deleteTransaction} ?',
                style: GoogleFonts.inter(
                  color: black100,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.0325,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                languages.deleteTransactionConfirmationMsg,
                textAlign: TextAlign.center,
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
                  stream: deleteTransactionBloc.getDeleteTransactionProcessStatus,
                  builder: (context, snapshot) {
                    final isDeleting = snapshot.hasData && snapshot.data!;

                    return CustomButton(
                      onPressed: isDeleting ? null : deleteTransaction,
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.075,
                      child: isDeleting
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

  void deleteTransaction() async {
    final isDeleted = await deleteTransactionBloc.onDelete(widget.transactionModal);

    /// the lists are driven by onValue listeners, so they repaint themselves;
    /// this sheet only has to close. On failure it stays open with the snack
    /// bar shown, so the user can retry.
    if (!isDeleted) return;
    if (!mounted) return;
    closeScreen(context);
  }

  @override
  void dispose() {
    deleteTransactionBloc.dispose();
    super.dispose();
  }
}
