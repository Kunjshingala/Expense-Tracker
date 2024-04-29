import 'dart:io';

import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/firebase_modal/day_finance_overview_modal.dart';
import '../../../../modals/firebase_modal/month_finance_overview_modal.dart';
import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/firebase_references.dart';

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

  final transactionTypeSubject = BehaviorSubject<TransactionType>.seeded(TransactionType.Expense);
  Stream<TransactionType> get getTransactionType => transactionTypeSubject.stream;
  Function(TransactionType) get setTransactionType => transactionTypeSubject.add;

  final transactionModeSubject = BehaviorSubject<TransactionMode>.seeded(TransactionMode.Cash);
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

      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
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
    await updateAtAllTransaction(
        id: oldTransactionModal.id, mainReference: rtDatabaseRef, updatedMap: updatedMap);

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
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });
    } else {
      debugPrint('monthlyDataRef---------------------------------->Date is not same');

      /// remove from old date and add at new date.
      await oldMonthlyDataRef.remove().onError((error, stackTrace) {
        debugPrint('oldMonthlyDataRef---------------------------------->$error');
        debugPrint('oldMonthlyDataRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });

      await newMonthlyDataRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('newMonthlyDataRef---------------------------------->$error');
        debugPrint('newMonthlyDataRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' ==
        '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      await oldCategoryRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldCategoryRef---------------------------------->$error');
        debugPrint('oldCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });
    } else {
      /// remove old category.
      await oldCategoryRef.remove().onError((error, stackTrace) {
        debugPrint('oldCategoryRef---------------------------------->$error');
        debugPrint('oldCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });

      /// add at new date category.
      await updatedCategoryRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedCategoryRef---------------------------------->$error');
        debugPrint('updatedCategoryRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' ==
        '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      await oldTransactionTypeRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldTransactionTypeRef---------------------------------->$error');
        debugPrint('oldTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });
    } else {
      /// remove old transaction type.
      await oldTransactionTypeRef.remove().onError((error, stackTrace) {
        debugPrint('updatedTransactionTypeRef---------------------------------->$error');
        debugPrint('updatedTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });

      /// add at new transaction type.
      await updatedTransactionTypeRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedTransactionTypeRef---------------------------------->$error');
        debugPrint('updatedTransactionTypeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
    if ('${oldDateDataList[1]}-${oldDateDataList[2]}' ==
        '${updatedDateDataList[1]}-${updatedDateDataList[2]}') {
      debugPrint('oldTransactionModeRef---------------------------------->Date Same');

      await oldTransactionModeRef.update(updatedMap).onError((error, stackTrace) {
        debugPrint('oldTransactionModeRef---------------------------------->$error');
        debugPrint('oldTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });

      debugPrint(
          'oldTransactionModeRef---------------------------------->oldTransactionModeRef.update(updatedMap) done');
    } else {
      debugPrint('oldTransactionModeRef---------------------------------->Date is not Same');

      /// remove old transaction type.
      await oldTransactionModeRef.remove().onError((error, stackTrace) {
        debugPrint('oldTransactionModeRef---------------------------------->$error');
        debugPrint('oldTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
      });
      debugPrint(
          'oldTransactionModeRef---------------------------------->oldTransactionModeRef.remove() complete');

      /// add at new transaction type.
      await updatedTransactionModeRef.set(updatedMap).onError((error, stackTrace) {
        debugPrint('updatedTransactionModeRef---------------------------------->$error');
        debugPrint('updatedTransactionModeRef---------------------------------->$stackTrace');
        showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);

    final oldPlaceDayFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(oldDateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    final newPlaceDayFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(updatedDateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    /// update at old place. -------------------------------------------------------------------------------->
    late DayFinanceOverviewModal oldPlaceDayFinanceOverviewModal;

    // get data From Old Place.
    final oldDataSnapshot = await oldPlaceDayFinanceOverviewSummaryRef.get();

    final oldPlaceDayFinanceOverviewData = oldDataSnapshot.value;
    Map<String, dynamic> oldPlaceMappedSnapshot = Map.from(oldPlaceDayFinanceOverviewData as Map);
    oldPlaceDayFinanceOverviewModal = DayFinanceOverviewModal.fromMap(oldPlaceMappedSnapshot);

    int oldPlaceFinanceExpense = oldPlaceDayFinanceOverviewModal.expense;
    int oldPlaceFinanceIncome = oldPlaceDayFinanceOverviewModal.income;

    if (oldTransactionModal.transactionType == 0) {
      oldPlaceFinanceExpense = oldPlaceFinanceExpense - oldTransactionModal.amount;
    } else {
      oldPlaceFinanceExpense = oldPlaceFinanceIncome - oldTransactionModal.amount;
    }

    oldPlaceDayFinanceOverviewModal =
        DayFinanceOverviewModal(expense: oldPlaceFinanceExpense, income: oldPlaceFinanceExpense);

    // update data at Old Place.
    await oldPlaceDayFinanceOverviewSummaryRef
        .set(oldPlaceDayFinanceOverviewModal.toMap())
        .onError((error, stackTrace) {
      debugPrint('oldPlaceDayFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('oldPlaceDayFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });

    /// update at new place. -------------------------------------------------------------------------------->
    late DayFinanceOverviewModal newPlaceDayFinanceOverviewModal;

    // get data From new Place.
    final newDataSnapshot = await newPlaceDayFinanceOverviewSummaryRef.get();

    if (newDataSnapshot.exists) {
      final newPlaceDayFinanceOverviewData = newDataSnapshot.value;
      Map<String, dynamic> newPlaceMappedSnapshot = Map.from(newPlaceDayFinanceOverviewData as Map);
      newPlaceDayFinanceOverviewModal = DayFinanceOverviewModal.fromMap(newPlaceMappedSnapshot);
    } else {
      newPlaceDayFinanceOverviewModal = DayFinanceOverviewModal(expense: 0, income: 0);
    }

    int newPlaceFinanceExpense = newPlaceDayFinanceOverviewModal.expense;
    int newPlaceFinanceIncome = newPlaceDayFinanceOverviewModal.income;

    if (updatedTransactionModal.transactionType == 0) {
      newPlaceFinanceExpense = newPlaceFinanceExpense + updatedTransactionModal.amount;
    } else {
      newPlaceFinanceIncome = newPlaceFinanceIncome + updatedTransactionModal.amount;
    }

    newPlaceDayFinanceOverviewModal =
        DayFinanceOverviewModal(expense: newPlaceFinanceExpense, income: newPlaceFinanceIncome);

    // update data at new Place.
    await newPlaceDayFinanceOverviewSummaryRef
        .set(newPlaceDayFinanceOverviewModal.toMap())
        .onError((error, stackTrace) {
      debugPrint('newPlaceDayFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('newPlaceDayFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
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
    final oldDateDataList = oldTransactionModal.date.split(dateSplitFormat);
    final updatedDateDataList = updatedTransactionModal.date.split(dateSplitFormat);

    final oldPlaceMonthFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${oldDateDataList[1]}-${oldDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    final newPlaceMonthFinanceOverviewSummaryRef = mainReference
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${updatedDateDataList[1]}-${updatedDateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    /// update at old place. start-------------------------------------------------------------------------------->
    late FinanceOverviewModal oldPlaceFinanceOverviewModal;

    final oldPlaceSnapshot = await oldPlaceMonthFinanceOverviewSummaryRef.get();
    final oldPlaceFinanceOverviewData = oldPlaceSnapshot.value;
    Map<String, dynamic> oldPlaceMappedSnapshot = Map.from(oldPlaceFinanceOverviewData as Map);

    oldPlaceFinanceOverviewModal = FinanceOverviewModal.fromMap(oldPlaceMappedSnapshot);

    final oldAmount = oldTransactionModal.amount;

    int oldPlaceBudget = oldPlaceFinanceOverviewModal.budget;
    int oldPlaceExpense = oldPlaceFinanceOverviewModal.expense;
    int oldPlaceIncome = oldPlaceFinanceOverviewModal.income;
    int oldPlaceBalance = oldPlaceFinanceOverviewModal.balance;
    bool oldPlaceIsSurpassed = oldPlaceFinanceOverviewModal.isSurpassed;

    if (oldTransactionModal.transactionType == 0) {
      oldPlaceExpense = oldPlaceExpense - oldAmount;
    } else {
      oldPlaceIncome = oldPlaceIncome - oldAmount;
    }

    if (((oldPlaceBudget + oldPlaceIncome) - oldPlaceExpense) >= 0) {
      oldPlaceIsSurpassed = false;
    } else {
      oldPlaceIsSurpassed = true;
    }

    oldPlaceBalance = (oldPlaceBudget + oldPlaceIncome) - oldPlaceExpense;

    oldPlaceFinanceOverviewModal = FinanceOverviewModal(
      budget: oldPlaceBudget,
      expense: oldPlaceExpense,
      income: oldPlaceIncome,
      balance: oldPlaceBalance,
      isSurpassed: oldPlaceIsSurpassed,
    );

    await oldPlaceMonthFinanceOverviewSummaryRef
        .update(oldPlaceFinanceOverviewModal.toMap())
        .onError((error, stackTrace) {
      debugPrint('oldPlaceMonthFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('oldPlaceMonthFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });

    /// update at old place. done-------------------------------------------------------------------------------->

    /// update at new place. start-------------------------------------------------------------------------------->
    late FinanceOverviewModal newPlaceFinanceOverviewModal;

    final newPlaceSnapshot = await newPlaceMonthFinanceOverviewSummaryRef.get();

    if (newPlaceSnapshot.exists) {
      final newPlaceFinanceOverviewData = newPlaceSnapshot.value;

      Map<String, dynamic> newPlaceMappedSnapshot = Map.from(newPlaceFinanceOverviewData as Map);

      newPlaceFinanceOverviewModal = FinanceOverviewModal.fromMap(newPlaceMappedSnapshot);
    } else {
      newPlaceFinanceOverviewModal =
          FinanceOverviewModal(budget: 0, expense: 0, income: 0, balance: 0, isSurpassed: false);
    }

    final newAmount = updatedTransactionModal.amount;

    int newPlaceBudget = newPlaceFinanceOverviewModal.budget;
    int newPlaceExpense = newPlaceFinanceOverviewModal.expense;
    int newPlaceIncome = newPlaceFinanceOverviewModal.income;
    int newPlaceBalance = newPlaceFinanceOverviewModal.balance;
    bool newPlaceIsSurpassed = newPlaceFinanceOverviewModal.isSurpassed;

    if (updatedTransactionModal.transactionType == 0) {
      newPlaceExpense = newPlaceExpense + newAmount;
    } else {
      newPlaceIncome = newPlaceIncome + newAmount;
    }

    if (((newPlaceBudget + newPlaceIncome) - newPlaceExpense) >= 0) {
      newPlaceIsSurpassed = false;
    } else {
      newPlaceIsSurpassed = true;
    }

    newPlaceBalance = (newPlaceBudget + newPlaceIncome) - newPlaceExpense;

    newPlaceFinanceOverviewModal = FinanceOverviewModal(
      budget: newPlaceBudget,
      expense: newPlaceExpense,
      income: newPlaceIncome,
      balance: newPlaceBalance,
      isSurpassed: newPlaceIsSurpassed,
    );

    await newPlaceMonthFinanceOverviewSummaryRef
        .update(newPlaceFinanceOverviewModal.toMap())
        .onError((error, stackTrace) {
      debugPrint('newPlaceMonthFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('newPlaceMonthFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });

    /// update at new place. done-------------------------------------------------------------------------------->

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
