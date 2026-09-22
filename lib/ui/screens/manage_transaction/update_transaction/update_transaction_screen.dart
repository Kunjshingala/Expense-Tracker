import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../services/permission_handle/permission_handle.dart';
import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_icons.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/transaction_data.dart';
import '../../../common_view/attachment_bottom_sheet.dart';
import '../../../common_view/common_button.dart';
import 'update_transaction_bloc.dart';
import '../../../../utils/route.dart';

class UpdateTransactionScreen extends StatefulWidget {
  const UpdateTransactionScreen({super.key, required this.transactionModal});

  final TransactionModal transactionModal;

  @override
  State<UpdateTransactionScreen> createState() => _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  late UpdateTransactionBloc updateTransactionBloc;

  @override
  void didChangeDependencies() {
    updateTransactionBloc = UpdateTransactionBloc(context: context);
    // Todo: Add this at bloc
    updateTransactionBloc.setLastData(widget.transactionModal);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactionType>(
        stream: updateTransactionBloc.getTransactionType,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: screenWidth * 0.12,
              toolbarHeight: screenHeight * 0.065,
              backgroundColor: snapshot.data == TransactionType.expense ? red100 : green100,
              leading: GestureDetector(
                onTap: () {
                  closeScreen(context);
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: screenWidth * 0.03),
                  child: Icon(
                    CustomIcons.arrow_left_icons,
                    color: white100,
                    size: averageScreenSize * 0.06,
                    weight: 1,
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                languages.updateTransaction,
                style: GoogleFonts.inter(
                  color: white100,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.035,
                ),
              ),
            ),
            backgroundColor: snapshot.data == TransactionType.expense ? red100 : green100,
            body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: screenHeight - (screenHeight * 0.1),
                width: screenWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05),
                      child: Text(
                        languages.howMuch,
                        style: GoogleFonts.inter(
                          color: white80,
                          fontSize: averageScreenSize * 0.025,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '\$',
                            style: GoogleFonts.inter(
                              color: white80,
                              fontWeight: FontWeight.w600,
                              fontSize: averageScreenSize * 0.1,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          SizedBox(
                            width: screenWidth * 0.75,
                            child: TextFormField(
                              controller: updateTransactionBloc.amountController,
                              keyboardType: TextInputType.number,
                              cursorColor: white100,
                              style: GoogleFonts.inter(
                                color: white80,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.1,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsetsDirectional.zero,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      height: screenHeight * 0.7,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: white100,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(averageScreenSize * 0.05),
                          topRight: Radius.circular(averageScreenSize * 0.05),
                        ),
                      ),
                      padding: EdgeInsetsDirectional.symmetric(
                        vertical: screenHeight * 0.03,
                        horizontal: screenWidth * 0.04,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            StreamBuilder<TransactionType>(
                              stream: updateTransactionBloc.getTransactionType,
                              builder: (context, snapTransactionType) {
                                return DropdownButtonFormField(
                                  initialValue: snapTransactionType.data,
                                  items: TransactionType.values
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    updateTransactionBloc.setTransactionType(value!);
                                  },
                                  style: GoogleFonts.inter(
                                    color: black50,
                                    fontSize: averageScreenSize * 0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  isDense: true,
                                  dropdownColor: white100,
                                  icon: Icon(
                                    CustomIcons.arrow_down_icons,
                                    color: white20,
                                    size: averageScreenSize * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: white40),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: white40),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Container(
                              height: screenHeight * 0.08,
                              decoration: BoxDecoration(
                                border: Border.all(color: white40),
                                borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                              ),
                              padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.03),
                              child: Row(
                                children: [
                                  getCategoryModalById(widget.transactionModal.category).icon,
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    getCategoryModalById(widget.transactionModal.category).label,
                                    style: GoogleFonts.inter(
                                      color: black50,
                                      fontSize: averageScreenSize * 0.03,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            StreamBuilder<TransactionMode>(
                              stream: updateTransactionBloc.getTransactionMode,
                              builder: (context, snapTransactionMode) {
                                return DropdownButtonFormField(
                                  initialValue: snapTransactionMode.data,
                                  items: TransactionMode.values
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    updateTransactionBloc.setTransactionMode(value!);
                                  },
                                  style: GoogleFonts.inter(
                                    color: black50,
                                    fontSize: averageScreenSize * 0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  isDense: true,
                                  dropdownColor: white100,
                                  icon: Icon(
                                    CustomIcons.arrow_down_icons,
                                    color: white20,
                                    size: averageScreenSize * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: white40),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: white40),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextFormField(
                              readOnly: true,
                              controller: updateTransactionBloc.dateController,
                              style: GoogleFonts.inter(
                                color: black50,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              cursorColor: white0,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: languages.selectDate,
                                hintStyle: GoogleFonts.inter(
                                  color: white0,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                              ),
                              onTap: () async {
                                updateTransactionBloc.pickDate();
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextFormField(
                              controller: updateTransactionBloc.descriptionController,
                              style: GoogleFonts.inter(
                                color: black50,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              cursorColor: white0,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: languages.description,
                                hintStyle: GoogleFonts.inter(
                                  color: white0,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextFormField(
                              readOnly: true,
                              controller: updateTransactionBloc.addressController,
                              style: GoogleFonts.inter(
                                color: black50,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              onTap: () {
                                getLocationPermission();
                              },
                              cursorColor: white0,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: languages.address,
                                hintStyle: GoogleFonts.inter(
                                  color: white0,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: white40),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: StreamBuilder<File?>(
                                    stream: updateTransactionBloc.getFile,
                                    builder: (context, fileSnapshot) {
                                      if (fileSnapshot.hasData) {
                                        return Stack(
                                          alignment: AlignmentDirectional.topEnd,
                                          children: [
                                            Container(
                                              padding: EdgeInsetsDirectional.all(averageScreenSize * 0.01),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: black75, width: averageScreenSize * 0.001),
                                                borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                                child: Image.file(
                                                  fileSnapshot.data!,
                                                  width: averageScreenSize * 0.2,
                                                  height: averageScreenSize * 0.2,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                updateTransactionBloc.clearImage();
                                                debugPrint(
                                                    '---------------------------------->${updateTransactionBloc.fileSubject.value}');
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(0xff000000).withValues(alpha: 0.32),
                                                ),
                                                child: Icon(
                                                  CustomIcons.close_icons,
                                                  color: white100,
                                                  size: averageScreenSize * 0.045,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: Container(
                                                padding: EdgeInsetsDirectional.all(averageScreenSize * 0.01),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: black75, width: averageScreenSize * 0.001),
                                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                                  child: widget.transactionModal.imageUrl != null
                                                      ? Image.network(
                                                          widget.transactionModal.imageUrl!,
                                                          width: averageScreenSize * 0.2,
                                                          height: averageScreenSize * 0.2,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Text(
                                                          languages.noImageAdded,
                                                          style: GoogleFonts.inter(
                                                            color: black75,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: DottedBorder(
                                                options: RoundedRectDottedBorderOptions(
                                                  dashPattern: [averageScreenSize * 0.011],
                                                  radius: Radius.circular(averageScreenSize * 0.03),
                                                  color: white20,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      constraints: BoxConstraints.expand(
                                                          width: screenWidth, height: screenHeight * 0.25),
                                                      builder: (context) => AttachmentBottomSheet(
                                                        setFile: updateTransactionBloc.setFile,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    constraints: BoxConstraints.expand(
                                                        height: screenHeight * 0.07, width: screenWidth * 0.4),
                                                    alignment: AlignmentDirectional.center,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          CustomIcons.attachment_icons,
                                                          color: white0,
                                                          size: averageScreenSize * 0.05,
                                                        ),
                                                        SizedBox(width: screenWidth * 0.03),
                                                        Text(
                                                          widget.transactionModal.imageUrl != null
                                                              ? languages.update
                                                              : languages.add,
                                                          style: GoogleFonts.inter(
                                                            color: white0,
                                                            fontSize: averageScreenSize * 0.03,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            StreamBuilder<bool>(
                                stream: updateTransactionBloc.getUpdateTransactionProcessStatus,
                                builder: (context, snapshot) {
                                  return CustomButton(
                                    width: screenWidth * 0.9,
                                    height: screenHeight * 0.07,
                                    onPressed: () {
                                      if (snapshot.hasData && !(snapshot.data!)) {
                                        updateTransactionBloc.onComplete(widget.transactionModal);
                                      }
                                    },
                                    child: snapshot.hasData && !(snapshot.data!)
                                        ? Text(
                                            languages.update,
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
                                }),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    updateTransactionBloc.dispose();
    super.dispose();
  }
}
