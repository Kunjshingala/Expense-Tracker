import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:expense_tracker/ui/common_view/main_eleveted_button.dart';
import 'package:expense_tracker/ui/screens/manage_transaction/update_transaction/update_transaction_bloc.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/custom_icons.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../services/permission_handle/permission_handle.dart';
import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../common_view/attachment_bottom_sheet.dart';

class UpdateTransactionScreen extends StatefulWidget {
  const UpdateTransactionScreen({super.key, required this.transactionModal});
  final TransactionModal transactionModal;

  @override
  State<UpdateTransactionScreen> createState() => _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState extends State<UpdateTransactionScreen> {
  late UpdateTransactionBloc updateTransactionBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    updateTransactionBloc = UpdateTransactionBloc(context: context);
    updateTransactionBloc.setLastData(widget.transactionModal);
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
              backgroundColor: snapshot.data == TransactionType.expense ? red100Color : green100Color,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: screenWidth * 0.03),
                  child: Icon(
                    CustomIcons.arrow_left_icons,
                    color: light100Color,
                    size: averageScreenSize * 0.06,
                    weight: 1,
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                'Update Transaction',
                style: GoogleFonts.inter(
                  color: light100Color,
                  fontWeight: FontWeight.w600,
                  fontSize: averageScreenSize * 0.035,
                ),
              ),
            ),
            backgroundColor: snapshot.data == TransactionType.expense ? red100Color : green100Color,
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
                        'How much?',
                        style: GoogleFonts.inter(
                          color: light80Color,
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
                              color: light80Color,
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
                              cursorColor: light100Color,
                              style: GoogleFonts.inter(
                                color: light80Color,
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
                        color: light100Color,
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
                                  value: snapTransactionType.data,
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
                                    color: dark50Color,
                                    fontSize: averageScreenSize * 0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  isDense: true,
                                  dropdownColor: light100Color,
                                  icon: Icon(
                                    CustomIcons.arrow_down_icons,
                                    color: light20Color,
                                    size: averageScreenSize * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: light40Color),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: light40Color),
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
                                border: Border.all(color: light40Color),
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
                                      color: dark50Color,
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
                                  value: snapTransactionMode.data,
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
                                    color: dark50Color,
                                    fontSize: averageScreenSize * 0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  isDense: true,
                                  dropdownColor: light100Color,
                                  icon: Icon(
                                    CustomIcons.arrow_down_icons,
                                    color: light20Color,
                                    size: averageScreenSize * 0.04,
                                  ),
                                  decoration: InputDecoration(
                                    constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: light40Color),
                                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: light40Color),
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
                                color: dark50Color,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              cursorColor: light0Color,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: 'Select Date',
                                hintStyle: GoogleFonts.inter(
                                  color: light0Color,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
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
                                color: dark50Color,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              cursorColor: light0Color,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: 'Description',
                                hintStyle: GoogleFonts.inter(
                                  color: light0Color,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            TextFormField(
                              readOnly: true,
                              controller: updateTransactionBloc.addressController,
                              style: GoogleFonts.inter(
                                color: dark50Color,
                                fontSize: averageScreenSize * 0.03,
                                fontWeight: FontWeight.w400,
                              ),
                              onTap: () {
                                getLocationPermission();
                              },
                              cursorColor: light0Color,
                              decoration: InputDecoration(
                                constraints: BoxConstraints.expand(height: screenHeight * 0.08),
                                hintText: 'Address',
                                hintStyle: GoogleFonts.inter(
                                  color: light0Color,
                                  fontSize: averageScreenSize * 0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: light40Color),
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
                                                border: Border.all(
                                                    color: dark75Color, width: averageScreenSize * 0.001),
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
                                                  color: const Color(0xff000000).withOpacity(0.32),
                                                ),
                                                child: Icon(
                                                  CustomIcons.close_icons,
                                                  color: light100Color,
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
                                                  border: Border.all(
                                                      color: dark75Color, width: averageScreenSize * 0.001),
                                                  borderRadius:
                                                      BorderRadius.circular(averageScreenSize * 0.02),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(averageScreenSize * 0.02),
                                                  child: widget.transactionModal.imageUrl != null
                                                      ? Image.network(
                                                          widget.transactionModal.imageUrl!,
                                                          width: averageScreenSize * 0.2,
                                                          height: averageScreenSize * 0.2,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Text(
                                                          'NO Image Added',
                                                          style: GoogleFonts.inter(
                                                            color: dark75Color,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              fit: FlexFit.loose,
                                              child: DottedBorder(
                                                dashPattern: [averageScreenSize * 0.011],
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(averageScreenSize * 0.03),
                                                color: light20Color,
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
                                                        height: screenHeight * 0.07,
                                                        width: screenWidth * 0.4),
                                                    alignment: AlignmentDirectional.center,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          CustomIcons.attachment_icons,
                                                          color: light0Color,
                                                          size: averageScreenSize * 0.05,
                                                        ),
                                                        SizedBox(width: screenWidth * 0.03),
                                                        Text(
                                                          widget.transactionModal.imageUrl != null
                                                              ? 'Update'
                                                              : 'Add',
                                                          style: GoogleFonts.inter(
                                                            color: light0Color,
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
                                  return CustomElevatedButton(
                                    width: screenWidth * 0.9,
                                    height: screenHeight * 0.07,
                                    borderRadius: averageScreenSize * 0.03,
                                    color: violet100Color,
                                    onPressed: () {
                                      if (snapshot.hasData && !(snapshot.data!)) {
                                        updateTransactionBloc.onComplete(widget.transactionModal);
                                      }
                                    },
                                    child: snapshot.hasData && !(snapshot.data!)
                                        ? Text(
                                            'Update',
                                            style: GoogleFonts.inter(
                                              color: light80Color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: averageScreenSize * 0.025,
                                            ),
                                          )
                                        : CircularProgressIndicator(
                                            color: light100Color,
                                            backgroundColor: violet100Color,
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
    // TODO: implement dispose
    super.dispose();
    updateTransactionBloc.dispose();
  }
}
