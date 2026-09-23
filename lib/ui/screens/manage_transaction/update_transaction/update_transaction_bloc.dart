import 'dart:io';

import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/firebase_references.dart';
import '../../../../utils/transaction_data.dart';
import '../../../../utils/transaction_writes.dart';
import '../../../common_view/snack_bar.dart';
import '../../../../utils/route.dart';

class UpdateTransactionBloc {
  final BuildContext context;

  UpdateTransactionBloc({required this.context});

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  final amountController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  final updateTransactionProcessStatusSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getUpdateTransactionProcessStatus => updateTransactionProcessStatusSubject.stream;

  Function(bool) get setUpdateTransactionProcessStatus => updateTransactionProcessStatusSubject.add;

  final transactionTypeSubject = BehaviorSubject<TransactionType>.seeded(TransactionType.expense);

  Stream<TransactionType> get getTransactionType => transactionTypeSubject.stream;

  Function(TransactionType) get setTransactionType => transactionTypeSubject.add;

  final transactionModeSubject = BehaviorSubject<TransactionMode>.seeded(TransactionMode.cash);

  Stream<TransactionMode> get getTransactionMode => transactionModeSubject.stream;

  Function(TransactionMode) get setTransactionMode => transactionModeSubject.add;

  final fileSubject = BehaviorSubject<File?>();

  Stream<File?> get getFile => fileSubject.stream;

  Function(File?) get setFile => fileSubject.add;

  void setLastData(TransactionModal transactionModal) {
    amountController.text = transactionModal.amount.toString();
    setTransactionType(TransactionType.values[transactionModal.transactionType]);

    /// category and image already set directly.

    setTransactionMode(TransactionMode.values[transactionModal.transactionMode]);
    dateController.text = transactionModal.date;
    descriptionController.text = transactionModal.description ?? '';
    addressController.text = transactionModal.location ?? '';
  }

  void pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      dateController.text = dateFormat.format(selectedDate);
    }
  }

  clearImage() async {
    fileSubject.value = null;
  }

  bool isReadyToComplete() {
    if (int.parse(amountController.text.trim()) <= 0) {
      showMySnackBar(message: languages.amountValidationMsg, messageType: MessageType.warning);
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      showMySnackBar(message: '${languages.selectDate}.', messageType: MessageType.warning);
      return false;
    }

    /// currently address and image and description can be null.
    return true;
  }

  void onComplete(TransactionModal oldTransactionModal) async {
    if (!isReadyToComplete()) return;

    setUpdateTransactionProcessStatus(true);

    try {
      /// new file selected then replace the stored file, else keep the old url.
      final fileUrl = fileSubject.hasValue
          ? await deleteAndAddFile(transactionId: oldTransactionModal.id)
          : oldTransactionModal.imageUrl;

      final updatedTransactionModal = setDataIntoModal(oldTransactionModal, fileUrl);

      await updateData(
        oldTransactionModal: oldTransactionModal,
        updatedTransactionModal: updatedTransactionModal,
      );

      if (context.mounted) closeScreen(context);
      debugPrint('onComplete---------------------------------->Complete');
    } on FirebaseException catch (e) {
      debugPrint('onComplete----------------------------------> on FirebaseException catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } catch (e) {
      debugPrint('onComplete----------------------------------> catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } finally {
      setUpdateTransactionProcessStatus(false);
    }
  }

  /// Firebase Storage.
  Future<String?> deleteAndAddFile({required String transactionId}) async {
    final storageRef = firebaseStorage
        .ref()
        .child(FirebaseStorageRef.users)
        .child(auth.currentUser!.uid)
        .child(transactionId)
        .child('$transactionId.jpg');

    /// remove old file.
    try {
      await storageRef.delete();
      debugPrint('storageRef---------------------------------->file deleted successfully');
    } on FirebaseException catch (e) {
      debugPrint('---------------------------------->$e');
    } catch (e) {
      debugPrint('---------------------------------->$e');
    }

    ///  add new file.
    try {
      TaskSnapshot taskSnapshot = await storageRef.putFile(fileSubject.value!);
      debugPrint('storageRef---------------------------------->${await taskSnapshot.ref.getDownloadURL()}');
      return await taskSnapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('---------------------------------->$e');
    } catch (e) {
      debugPrint('---------------------------------->$e');
    }
    return null;
  }

  TransactionModal setDataIntoModal(TransactionModal oldTransactionModal, String? fileUrl) {
    final amount = int.parse(amountController.text.trim());
    final transactionType = transactionTypeSubject.value.index;
    final category = oldTransactionModal.category;
    final transactionMode = transactionModeSubject.value.index;
    final date = dateController.text;
    final description = descriptionController.text.trim();
    final location = addressController.text.trim();
    final url = fileUrl;

    TransactionModal updatedTransactionModal = TransactionModal(
      id: oldTransactionModal.id,
      amount: amount,
      transactionType: transactionType,
      transactionMode: transactionMode,
      date: date,
      time: oldTransactionModal.time,
      category: category,
      description: description,
      location: location,
      imageUrl: url,
    );

    return updatedTransactionModal;
  }

  /// Firebase realtime database.
  ///
  /// One atomic write for the whole edit. A single edit can move the
  /// transaction between day, month, category, type and mode buckets at once;
  /// building it as one update means the records and the totals can never
  /// disagree, whichever of those changed.
  ///
  /// The totals move by the difference between the old and new transaction,
  /// written as server-side increments, so an edit landing at the same moment
  /// as another write cannot overwrite it.
  Future<void> updateData({
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
  }) async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    await rtDatabaseRef.update(
      transactionWriteUpdates(
        previous: oldTransactionModal,
        next: updatedTransactionModal,
      ),
    );

    debugPrint('updateData---------------------------------->Done');
  }

  void dispose() {
    transactionTypeSubject.close();
    amountController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    transactionModeSubject.close();
    fileSubject.close();
    dateController.dispose();
    updateTransactionProcessStatusSubject.close();
  }
}
