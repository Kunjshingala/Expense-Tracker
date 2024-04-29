import 'dart:io';

import 'package:expense_tracker/services/image_crop_screvice.dart';
import 'package:expense_tracker/services/permission_handle/permission_handle.dart';
import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

class UpdateTransactionBloc {
  final BuildContext context;

  UpdateTransactionBloc({required this.context});

  late File file;
  late XFile xFile;

  final amountController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  final transactionTypeSubject = BehaviorSubject<TransactionType>.seeded(TransactionType.Expense);
  Stream<TransactionType> get getTransactionType => transactionTypeSubject.stream;
  Function(TransactionType) get setTransactionType => transactionTypeSubject.add;

  final transactionModeSubject = BehaviorSubject<TransactionMode>.seeded(TransactionMode.Cash);
  Stream<TransactionMode> get getTransactionMode => transactionModeSubject.stream;
  Function(TransactionMode) get setTransactionMode => transactionModeSubject.add;

  final fileSubject = BehaviorSubject<File?>();
  Stream<File?> get getFile => fileSubject.stream;
  Function(File) get setFile => fileSubject.add;

  void pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    if (selectedDate != null) {
      dateController.text = dateFormat.format(selectedDate);
    }
  }

  captureImage(BuildContext context) async {
    bool camaraPermissionAllowed = await checkCameraPermission();

    if (camaraPermissionAllowed) {
      xFile = (await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100))!;
      file = File(xFile.path);

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        final croppedFile = await cropImage(context, file);
        setFile(croppedFile);
      }
    }
  }

  pickImage(BuildContext context) async {
    bool isStoragePermissionAllowed = await checkStoragePermission();

    if (isStoragePermissionAllowed) {
      xFile = (await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100))!;
      file = File(xFile.path);
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        final croppedFile = await cropImage(context, file);
        setFile(croppedFile);
      }
    }
  }

  clearImage() async {
    fileSubject.value = null;
  }

  bool isReadyToComplete() {
    if (amountController.text.trim().isEmpty) {
      showMySnackBar(message: 'Add Sufficient Amount.', messageType: MessageType.warning);
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      showMySnackBar(message: 'Select Date.', messageType: MessageType.warning);
      return false;
    }

    /// currently address and image and description can be null.
    return true;
  }

  void onComplete() {
    isReadyToComplete();
  }

  void dispose() {
    transactionTypeSubject.close();
    amountController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    transactionModeSubject.close();
    fileSubject.close();
    dateController.dispose();
  }
}
