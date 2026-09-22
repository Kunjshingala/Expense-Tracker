import 'dart:io';

import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/finance_calculation.dart';
import '../../../../utils/finance_overview_reader.dart';
import '../../../../utils/firebase_references.dart';
import '../../../../utils/transaction_data.dart';
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
    if (isReadyToComplete()) {
      setUpdateTransactionProcessStatus(true);

      String? fileUrl;

      /// new file selected then delete old file and get url else set old url.
      if (fileSubject.hasValue) {
        /// new file selected then delete file and add new file
        fileUrl = await deleteAndAddFile(transactionId: oldTransactionModal.id);
      } else {
        /// there is not any new file.
        fileUrl = oldTransactionModal.imageUrl;
      }

      /// get updated modal.
      TransactionModal updatedTransactionModal = setDataIntoModal(oldTransactionModal, fileUrl);

      /// get Updated map from updated modal
      final updatedMap = updatedTransactionModal.toMap();

      /// delete old data and add updated data.
      await updateData(
        oldTransactionModal: oldTransactionModal,
        updatedTransactionModal: updatedTransactionModal,
        updatedMap: updatedMap,
      );

      setUpdateTransactionProcessStatus(false);

      if (context.mounted) closeScreen(context);
      debugPrint('onComplete---------------------------------->Complete');
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
  updateData({
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    /// All transaction.
    await updateAtAllTransaction(id: oldTransactionModal.id, mainReference: rtDatabaseRef, updatedMap: updatedMap);

    /// Monthly transaction.
    await updateAtMonthly(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );

    /// Category
    await updateDataIntoCategorySummary(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );

    /// Transaction type
    await updateDataIntoTransactionTypeSummary(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );

    /// Transaction mode
    await updateDataIntoTransactionModeSummary(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );

    /// Day Wise Summary.
    await updateDataIntoDayFinanceOverviewSummary(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );

    /// Month Wise Summary.
    await updateDataIntoMonthFinanceOverviewSummary(
      id: oldTransactionModal.id,
      mainReference: rtDatabaseRef,
      oldTransactionModal: oldTransactionModal,
      updatedTransactionModal: updatedTransactionModal,
      updatedMap: updatedMap,
    );
  }

  updateAtAllTransaction({
    required String id,
    required DatabaseReference mainReference,
    required Map<String, dynamic> updatedMap,
  }) async {
    final allTransactionRef = mainReference.child(FirebaseRealTimeDatabaseRef.allTransaction).child(id);

    await allTransactionRef.update(updatedMap).onError((error, stackTrace) {
      debugPrint('allTransactionRef---------------------------------->$error');
      debugPrint('allTransactionRef---------------------------------->$stackTrace');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    });

    debugPrint('updateAtAllTransaction---------------------------------->Done');
  }

  updateAtMonthly({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);

    final oldMonthlyDataRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(oldDateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(id);

    final newMonthlyDataRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(updatedDateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(id);

    if (oldTransactionModal.date == updatedTransactionModal.date) {
      debugPrint('monthlyDataRef---------------------------------->Date same');

      /// just update at that date.
      await oldMonthlyDataRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldMonthlyDataRef---------------------------------->$error');
        debugPrint('oldMonthlyDataRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    } else {
      debugPrint('monthlyDataRef---------------------------------->Date is not same');

      /// remove from old date and add at new date.
      await oldMonthlyDataRef.remove().onError((error, stackTrace) {
        debugPrint('oldMonthlyDataRef---------------------------------->$error');
        debugPrint('oldMonthlyDataRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });

      await newMonthlyDataRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('newMonthlyDataRef---------------------------------->$error');
        debugPrint('newMonthlyDataRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    }

    debugPrint('updateAtMonthly---------------------------------->Done');
  }

  updateDataIntoCategorySummary({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);
    final oldCategory = oldTransactionModal.category;
    final updatedCategory = updatedTransactionModal.category;

    final oldCategoryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.categories)
        .child('$oldCategory')
        .child(id);

    final updatedCategoryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.categories)
        .child('$updatedCategory')
        .child(id);

    /// month change then remove and add else just update.
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' == '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      await oldCategoryRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldCategoryRef---------------------------------->$error');
        debugPrint('oldCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    } else {
      /// remove old category.
      await oldCategoryRef.remove().onError((error, stackTrace) {
        debugPrint('oldCategoryRef---------------------------------->$error');
        debugPrint('oldCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });

      /// add at new date category.
      await updatedCategoryRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedCategoryRef---------------------------------->$error');
        debugPrint('updatedCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    }

    debugPrint('updateDataIntoCategorySummary---------------------------------->Done');
  }

  updateDataIntoTransactionTypeSummary({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);
    final oldTransactionType = oldTransactionModal.transactionType;
    final updatedTransactionType = updatedTransactionModal.transactionType;

    final oldTransactionTypeRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferType)
        .child('$oldTransactionType')
        .child(id);

    final updatedTransactionTypeRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferType)
        .child('$updatedTransactionType')
        .child(id);

    /// month change then remove and add else just update.
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' == '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      await oldTransactionTypeRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldTransactionTypeRef---------------------------------->$error');
        debugPrint('oldTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    } else {
      /// remove old transaction type.
      await oldTransactionTypeRef.remove().onError((error, stackTrace) {
        debugPrint('updatedTransactionTypeRef---------------------------------->$error');
        debugPrint('updatedTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });

      /// add at new transaction type.
      await updatedTransactionTypeRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedTransactionTypeRef---------------------------------->$error');
        debugPrint('updatedTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
    }

    debugPrint('updateDataIntoTransactionTypeSummary---------------------------------->Done');
  }

  updateDataIntoTransactionModeSummary({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);
    final oldTransactionMode = oldTransactionModal.transactionMode;
    final updatedTransactionMode = updatedTransactionModal.transactionMode;

    final oldTransactionModeRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferMode)
        .child('$oldTransactionMode')
        .child(id);

    final updatedTransactionModeRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferMode)
        .child('$updatedTransactionMode')
        .child(id);

    /// month change then remove and add else just update.
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' == '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      debugPrint('oldTransactionModeRef---------------------------------->Date Same');

      await oldTransactionModeRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldTransactionModeRef---------------------------------->$error');
        debugPrint('oldTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });

      debugPrint(
          'oldTransactionModeRef---------------------------------->oldTransactionModeRef.update(updatedMap) done');
    } else {
      debugPrint('oldTransactionModeRef---------------------------------->Date is not Same');

      /// remove old transaction type.
      await oldTransactionModeRef.remove().onError((error, stackTrace) {
        debugPrint('oldTransactionModeRef---------------------------------->$error');
        debugPrint('oldTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
      debugPrint('oldTransactionModeRef---------------------------------->oldTransactionModeRef.remove() complete');

      /// add at new transaction type.
      await updatedTransactionModeRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedTransactionModeRef---------------------------------->$error');
        debugPrint('updatedTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      });
      debugPrint('oldTransactionModeRef---------------------------------->Date is not Same');
    }

    debugPrint(
        'updateDataIntoTransactionModeSummary---------------------------------->updatedTransactionModeRef.set(updatedMap) complete');
  }

  updateDataIntoDayFinanceOverviewSummary({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDate = parseTransactionDate(oldTransactionModal.date);
    final updatedDate = parseTransactionDate(updatedTransactionModal.date);

    final oldPlaceDayFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(oldDate.monthKey)
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(oldDate.day)
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    final newPlaceDayFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(updatedDate.monthKey)
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(updatedDate.day)
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    /// take the old transaction back out of the day it used to sit in.
    final oldPlaceOverview = await readDayFinanceOverview(oldPlaceDayFinanceOverviewSummaryRef);

    await oldPlaceDayFinanceOverviewSummaryRef
        .set(dayOverviewAfterRemoving(oldPlaceOverview, oldTransactionModal).toMap())
        .onError((error, stackTrace) {
      debugPrint('oldPlaceDayFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('oldPlaceDayFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    });

    /// count the updated transaction towards the day it now belongs to. Read
    /// after the write above so a same-day edit sees the subtraction.
    final newPlaceOverview = await readDayFinanceOverview(newPlaceDayFinanceOverviewSummaryRef);

    await newPlaceDayFinanceOverviewSummaryRef
        .set(dayOverviewAfterAdding(newPlaceOverview, updatedTransactionModal).toMap())
        .onError((error, stackTrace) {
      debugPrint('newPlaceDayFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('newPlaceDayFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    });

    debugPrint('updateDataIntoDayFinanceOverviewSummary---------------------------------->Done');
  }

  updateDataIntoMonthFinanceOverviewSummary({
    required String id,
    required DatabaseReference mainReference,
    required TransactionModal oldTransactionModal,
    required TransactionModal updatedTransactionModal,
    required Map<String, dynamic> updatedMap,
  }) async {
    final oldDate = parseTransactionDate(oldTransactionModal.date);
    final updatedDate = parseTransactionDate(updatedTransactionModal.date);

    final oldPlaceMonthFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(oldDate.monthKey)
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    final newPlaceMonthFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(updatedDate.monthKey)
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    /// take the old transaction back out of the month it used to sit in.
    final oldPlaceOverview = await readMonthFinanceOverview(oldPlaceMonthFinanceOverviewSummaryRef);

    await oldPlaceMonthFinanceOverviewSummaryRef
        .update(monthOverviewAfterRemoving(oldPlaceOverview, oldTransactionModal).toMap())
        .onError((error, stackTrace) {
      debugPrint('oldPlaceMonthFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('oldPlaceMonthFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    });

    /// count the updated transaction towards the month it now belongs to. Read
    /// after the write above so a same-month edit sees the subtraction.
    final newPlaceOverview = await readMonthFinanceOverview(newPlaceMonthFinanceOverviewSummaryRef);

    await newPlaceMonthFinanceOverviewSummaryRef
        .update(monthOverviewAfterAdding(newPlaceOverview, updatedTransactionModal).toMap())
        .onError((error, stackTrace) {
      debugPrint('newPlaceMonthFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('newPlaceMonthFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
    });

    debugPrint('updateDataIntoMonthFinanceOverviewSummary---------------------------------->Done');
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
