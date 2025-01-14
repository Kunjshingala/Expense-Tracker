import 'dart:io';

import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../modals/firebase_modal/day_finance_overview_modal.dart';
import '../../../../../../modals/firebase_modal/month_finance_overview_modal.dart';
import '../../../../../../utils/firebase_references.dart';
import '../../../../utils/constant.dart';

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
      showMySnackBar(message: 'Add Sufficient Amount.', messageType: MessageType.warning);
      return false;
    }
    if (!selectedCategorySubject.hasValue) {
      showMySnackBar(message: 'Select Category.', messageType: MessageType.warning);
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      showMySnackBar(message: 'Select Date.', messageType: MessageType.warning);
      return false;
    }

    /// currently address, image and description can be null.

    return true;
  }

  void onComplete() async {
    if (isReadyToComplete()) {
      setAddTransactionProcessStatus(true);

      String? fileUrl;
      final transactionId = '${auth.currentUser!.uid}-${DateTime.now().microsecondsSinceEpoch}';

      /// Firebase Storage.
      if (fileSubject.hasValue) {
        fileUrl = await addFile(transactionId);
      }

      /// set data in map.
      TransactionModal transactionModal = setDataIntoModal(transactionId, fileUrl);

      /// map of modal.
      Map<String, dynamic> map = transactionModal.toMap();

      /// Firebase Realtime Database.
      await addData(transactionId, map);

      showMySnackBar(message: 'Transaction Added Successfully.', messageType: MessageType.success);

      setAddTransactionProcessStatus(false);

      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
      debugPrint('onComplete---------------------------------->Complete');
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
  addData(String transactionId, Map<String, dynamic> map) async {
    final dateDataList = dateController.text.split(dateSplitFormat);

    final category = selectedCategorySubject.value!.id;
    final transactionType = transactionTypeSubject.value.index;
    final transactionMode = transactionModeSubject.value.index;

    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    /// All transaction.
    addDataAtAllTransaction(transactionId: transactionId, rtDatabaseRef: rtDatabaseRef, map: map);

    /// Monthly transaction.
    addDataAtMonthly(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateDataList: dateDataList,
    );

    /// Category Summary transaction.
    addDataIntoCategorySummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateDataList: dateDataList,
      category: category,
    );

    /// TransactionType Summary transaction.
    addDataIntoTransactionTypeSummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateDataList: dateDataList,
      transactionType: transactionType,
    );

    /// TransactionMode Summary transaction.
    addDataIntoTransactionModeSummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateDataList: dateDataList,
      transactionMode: transactionMode,
    );

    /// Add or Update Day Wise Summary.
    addOrUpdateDataIntoDayFinanceOverviewSummary(
      rtDatabaseRef: rtDatabaseRef,
      dateDataList: dateDataList,
      transactionType: transactionType,
    );

    /// Add or Update Month Wise Summary.
    addOrUpdateDataIntoMonthFinanceOverviewSummary(
      rtDatabaseRef: rtDatabaseRef,
      dateDataList: dateDataList,
      transactionType: transactionType,
    );

    debugPrint('addData---------------------------------->Done');
  }

  void addDataAtAllTransaction({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
  }) async {
    final allTransactionRef = rtDatabaseRef.child(FirebaseRealTimeDatabaseRef.allTransaction).child(transactionId);

    await allTransactionRef.set(map).onError((error, stackTrace) {
      debugPrint('allTransactionRef---------------------------------->$error');
      debugPrint('allTransactionRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
    debugPrint('transactionsRef---------------------------------->Done');
  }

  void addDataAtMonthly({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateDataList,
  }) async {
    final monthlyDataRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(dateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(transactionId);

    await monthlyDataRef.set(map).onError((error, stackTrace) {
      debugPrint('monthlyDataRef---------------------------------->$error');
      debugPrint('monthlyDataRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
    debugPrint('monthlyDataRef---------------------------------->Done');
  }

  void addDataIntoCategorySummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateDataList,
    required int category,
  }) async {
    final categoryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.categories)
        .child('$category')
        .child(transactionId);

    await categoryRef.set(map).onError((error, stackTrace) {
      debugPrint('categoryRef---------------------------------->$error');
      debugPrint('categoryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addDataIntoTransactionTypeSummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateDataList,
    required int transactionType,
  }) async {
    final transactionTypeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferType)
        .child('$transactionType')
        .child(transactionId);

    await transactionTypeRef.set(map).onError((error, stackTrace) {
      debugPrint('transactionTypeRef---------------------------------->$error');
      debugPrint('transactionTypeRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addDataIntoTransactionModeSummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateDataList,
    required int transactionMode,
  }) async {
    final transactionModeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferMode)
        .child('$transactionMode')
        .child(transactionId);

    await transactionModeRef.set(map).onError((error, stackTrace) {
      debugPrint('transactionModeRef---------------------------------->$error');
      debugPrint('transactionModeRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addOrUpdateDataIntoDayFinanceOverviewSummary({
    required DatabaseReference rtDatabaseRef,
    required List<String> dateDataList,
    required int transactionType,
  }) async {
    late DayFinanceOverviewModal dayFinanceOverviewModal;

    final dayFinanceOverviewSummaryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(dateDataList[0])
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    /// get last updated data.
    final snapshot = await dayFinanceOverviewSummaryRef.get();

    if (snapshot.exists) {
      final dayFinanceOverviewData = snapshot.value;

      Map<String, dynamic> mappedSnapshot = Map.from(dayFinanceOverviewData as Map);

      dayFinanceOverviewModal = DayFinanceOverviewModal.fromMap(mappedSnapshot);
    } else {
      dayFinanceOverviewModal = DayFinanceOverviewModal(expense: 0, income: 0);
    }

    /// update with new data.
    final amount = int.parse(amountController.text.trim());

    int expense = dayFinanceOverviewModal.expense;
    int income = dayFinanceOverviewModal.income;

    if (transactionType == 0) {
      expense = expense + amount;
    } else {
      income = income + amount;
    }

    dayFinanceOverviewModal = DayFinanceOverviewModal(expense: expense, income: income);

    await dayFinanceOverviewSummaryRef.set(dayFinanceOverviewModal.toMap()).onError((error, stackTrace) {
      debugPrint('dayFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('dayFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addOrUpdateDataIntoMonthFinanceOverviewSummary({
    required DatabaseReference rtDatabaseRef,
    required List<String> dateDataList,
    required int transactionType,
  }) async {
    late FinanceOverviewModal financeOverviewModal;

    /// get last data from server.
    final monthFinanceOverviewSummaryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    final snapshot = await monthFinanceOverviewSummaryRef.get();

    debugPrint(
        'updateDataIntoFinanceOverviewSummary---------------------------------->snapshot.exists = ${snapshot.exists}');

    if (snapshot.exists) {
      final financeOverviewData = snapshot.value;

      Map<String, dynamic> mappedSnapshot = Map.from(financeOverviewData as Map);

      financeOverviewModal = FinanceOverviewModal.fromMap(mappedSnapshot);
    } else {
      financeOverviewModal = FinanceOverviewModal(budget: 0, expense: 0, income: 0, balance: 0, isSurpassed: false);
    }

    /// update with new data.
    final amount = int.parse(amountController.text.trim());

    int budget = financeOverviewModal.budget;
    int expense = financeOverviewModal.expense;
    int income = financeOverviewModal.income;
    int balance = financeOverviewModal.balance;
    bool isSurpassed = financeOverviewModal.isSurpassed;

    if (transactionType == 0) {
      expense = expense + amount;
    } else {
      income = income + amount;
    }

    if (((budget + income) - expense) >= 0) {
      isSurpassed = false;
    } else {
      isSurpassed = true;
    }

    balance = (budget + income) - expense;

    financeOverviewModal = FinanceOverviewModal(
      budget: budget,
      expense: expense,
      income: income,
      balance: balance,
      isSurpassed: isSurpassed,
    );

    debugPrint('---------------------------------->${financeOverviewModal.budget}');
    debugPrint('---------------------------------->${financeOverviewModal.expense}');
    debugPrint('---------------------------------->${financeOverviewModal.income}');
    debugPrint('---------------------------------->${financeOverviewModal.isSurpassed}');

    await monthFinanceOverviewSummaryRef.update(financeOverviewModal.toMap()).onError((error, stackTrace) {
      debugPrint('monthFinanceOverviewSummaryRef---------------------------------->$error');
      debugPrint('monthFinanceOverviewSummaryRef---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
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
