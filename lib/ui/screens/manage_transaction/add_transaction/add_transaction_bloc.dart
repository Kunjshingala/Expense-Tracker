import 'dart:io';

import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../utils/firebase_references.dart';
import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/transaction_data.dart';
import '../../../../utils/transaction_writes.dart';
import '../../../common_view/snack_bar.dart';
import '../../../../utils/route.dart';

class AddTransactionBloc {
  final BuildContext context;

  AddTransactionBloc({required this.context}) {
    amountController.text = '0';
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  final amountController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  final addTransactionProcessStatusSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getAddTransactionProcessStatus => addTransactionProcessStatusSubject.stream;

  Function(bool) get setAddTransactionProcessStatus => addTransactionProcessStatusSubject.add;

  final transactionTypeSubject = BehaviorSubject<TransactionType>.seeded(TransactionType.expense);

  Stream<TransactionType> get getTransactionType => transactionTypeSubject.stream;

  Function(TransactionType) get setTransactionType => transactionTypeSubject.add;

  final transactionModeSubject = BehaviorSubject<TransactionMode>.seeded(TransactionMode.cash);

  Stream<TransactionMode> get getTransactionMode => transactionModeSubject.stream;

  Function(TransactionMode) get setTransactionMode => transactionModeSubject.add;

  final fileSubject = BehaviorSubject<File?>();

  Stream<File?> get getFile => fileSubject.stream;

  Function(File?) get setFile => fileSubject.add;

  final categoryListSubject = BehaviorSubject<List<TransactionCategoryModal>>.seeded(expenseTransactionCategoryList);

  Stream<List<TransactionCategoryModal>> get getCategoryList => categoryListSubject.stream;

  Function(List<TransactionCategoryModal>) get setCategoryList => categoryListSubject.add;

  final selectedCategorySubject = BehaviorSubject<TransactionCategoryModal?>();

  Stream<TransactionCategoryModal?> get getSelectedCategory => selectedCategorySubject.stream;

  Function(TransactionCategoryModal?) get setSelectedCategory => selectedCategorySubject.add;

  void pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      debugPrint('selectedDate.microsecondsSinceEpoch---------------------------------->$selectedDate');

      dateController.text = dateFormat.format(selectedDate);
    }
  }

  clearImage() {
    fileSubject.value = null;
  }

  bool isReadyToComplete() {
    if (int.parse(amountController.text.trim()) <= 0) {
      showMySnackBar(message: languages.amountValidationMsg, messageType: MessageType.warning);
      return false;
    }
    if (!selectedCategorySubject.hasValue) {
      showMySnackBar(message: '${languages.selectCategory}.', messageType: MessageType.warning);
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      showMySnackBar(message: '${languages.selectDate}.', messageType: MessageType.warning);
      return false;
    }

    /// currently address, image and description can be null.

    return true;
  }

  void onComplete() async {
    if (!isReadyToComplete()) return;

    setAddTransactionProcessStatus(true);

    final transactionId = '${auth.currentUser!.uid}-${DateTime.now().microsecondsSinceEpoch}';

    try {
      /// Firebase Storage.
      final fileUrl = fileSubject.hasValue ? await addFile(transactionId) : null;

      /// Firebase Realtime Database.
      await addData(setDataIntoModal(transactionId, fileUrl));

      /// only once the write has landed, so the user is never told a
      /// transaction was saved that is still in flight or that failed.
      showMySnackBar(message: '${languages.transactionAddedSuccessfully}.');

      if (context.mounted) closeScreen(context);
      debugPrint('onComplete---------------------------------->Complete');
    } on FirebaseException catch (e) {
      debugPrint('onComplete----------------------------------> on FirebaseException catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } catch (e) {
      debugPrint('onComplete----------------------------------> catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    } finally {
      setAddTransactionProcessStatus(false);
    }
  }

  /// Firebase Storage.
  Future<String?> addFile(String transactionId) async {
    final storageRef = firebaseStorage
        .ref()
        .child(FirebaseStorageRef.users)
        .child(auth.currentUser!.uid)
        .child(transactionId)
        .child('$transactionId.jpg');

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

  TransactionModal setDataIntoModal(String transactionId, String? url) {
    late TransactionModal transactionModal;

    final amount = int.parse(amountController.text.trim());
    final transactionType = transactionTypeSubject.value.index;
    final date = dateController.text;
    final category = selectedCategorySubject.value!.id;
    final description = descriptionController.text.trim();
    final location = addressController.text.trim();
    final transactionMode = transactionModeSubject.value.index;

    transactionModal = TransactionModal(
      id: transactionId,
      amount: amount,
      transactionType: transactionType,
      transactionMode: transactionMode,
      date: date,
      time: DateTime.now().microsecondsSinceEpoch,
      category: category,
      description: description,
      location: location,
      imageUrl: url,
    );

    return transactionModal;
  }

  /// Firebase Realtime database.
  ///
  /// One atomic write: the five records and the two running totals land
  /// together, so a killed app or a dropped connection can never leave the
  /// transaction counted in one place and missing from another.
  ///
  /// The totals go in as server-side increments, so a second transaction
  /// written at the same moment cannot overwrite this one's contribution.
  Future<void> addData(TransactionModal transaction) async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    await rtDatabaseRef.update(transactionWriteUpdates(next: transaction));

    debugPrint('addData---------------------------------->Done');
  }

  void dispose() {
    transactionTypeSubject.close();
    amountController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    transactionModeSubject.close();
    fileSubject.close();
    categoryListSubject.close();
    selectedCategorySubject.close();
    dateController.dispose();
    addTransactionProcessStatusSubject.close();
  }
}
