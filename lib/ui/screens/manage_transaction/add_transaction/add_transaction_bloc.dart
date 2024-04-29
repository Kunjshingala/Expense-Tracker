import 'dart:io';

import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:expense_tracker/services/image_crop_screvice.dart';
import 'package:expense_tracker/services/permission_handle/permission_handle.dart';
import 'package:expense_tracker/ui/common_view/snack_bar_content.dart';
import 'package:expense_tracker/utils/transaction_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../modals/firebase_modal/day_finance_overview_modal.dart';
import '../../../../../../modals/firebase_modal/month_finance_overview_modal.dart';
import '../../../../../../utils/firebase_references.dart';

class AddTransactionBloc {
  final BuildContext context;

  AddTransactionBloc({required this.context}) {
    amountController.text = '0';
  }

  late File file;
  late XFile xFile;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

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

  final categoryListSubject =
      BehaviorSubject<List<TransactionCategoryModal>>.seeded(expenseTransactionCategoryList);
  Stream<List<TransactionCategoryModal>> get getCategoryList => categoryListSubject.stream;
  Function(List<TransactionCategoryModal>) get setCategoryList => categoryListSubject.add;

  final selectedCategorySubject = BehaviorSubject<TransactionCategoryModal?>();
  Stream<TransactionCategoryModal?> get getSelectedCategory => selectedCategorySubject.stream;
  Function(TransactionCategoryModal?) get setSelectedCategory => selectedCategorySubject.add;

  final microTimeSubject = BehaviorSubject<int>.seeded(DateTime.now().microsecondsSinceEpoch);
  Stream<int> get getMicroTime => microTimeSubject.stream;
  Function(int) get setMicroTime => microTimeSubject.add;

  void pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    if (selectedDate != null) {
      debugPrint('selectedDate.microsecondsSinceEpoch---------------------------------->$selectedDate');
      debugPrint(
          'selectedDate.microsecondsSinceEpoch---------------------------------->${selectedDate.microsecondsSinceEpoch}');
      setMicroTime(selectedDate.microsecondsSinceEpoch);

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
    if (!selectedCategorySubject.hasValue) {
      showMySnackBar(message: 'Select Category.', messageType: MessageType.warning);
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      showMySnackBar(message: 'Select Date.', messageType: MessageType.warning);
      return false;
    }

    /// currently address and image and description can be null.
    return true;
  }

  Map<String, dynamic> setModalToMap() {
    late TransactionModal transactionModal;

    final amount = int.parse(amountController.text.trim());
    final transactionType = transactionTypeSubject.value.index;
    final date = dateController.text;
    final category = selectedCategorySubject.value!.id;
    final description = descriptionController.text.trim();
    final location = addressController.text.trim();
    final transactionMode = transactionModeSubject.value.index;

    final transactionId =
        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}-${DateTime.now().timeZoneName}-${DateTime.now().millisecondsSinceEpoch}';

    transactionModal = TransactionModal(
      id: transactionId,
      amount: amount,
      transactionType: transactionType,
      transactionMode: transactionMode,
      date: date,
      time: microTimeSubject.value,
      category: category,
      description: description,
      location: location,
      imageUrl: '',
    );

    return transactionModal.toMap();
  }

  void onComplete() async {
    if (isReadyToComplete()) {
      final transactionId = '${auth.currentUser!.uid}-${DateTime.now().microsecondsSinceEpoch}';

      /// Firebase Realtime Database.
      await addData(transactionId);

      if (fileSubject.hasValue) {
        /// Firebase Storage.
        await addFile(transactionId);
      }

      showMySnackBar(message: 'Transaction Added Successfully.', messageType: MessageType.success);

      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
      debugPrint('onComplete---------------------------------->Complete');
    }
  }

  /// Firebase Storage.
  addFile(String transactionId) async {
    final storageRef = firebaseStorage
        .ref()
        .child(FirebaseStorageRef.users)
        .child(auth.currentUser!.uid)
        .child('$transactionId.jpg');

    try {
      await storageRef.putFile(fileSubject.value!);
      debugPrint('storageRef---------------------------------->Done');
    } on FirebaseException catch (e) {
      debugPrint('---------------------------------->$e');
    } catch (e) {
      debugPrint('---------------------------------->$e');
    }
  }

  /// Firebase Realtime database.
  addData(String transactionId) async {
    final dateList = dateController.text.split(" ");

    final category = selectedCategorySubject.value!.id;
    final transactionType = transactionTypeSubject.value.index;
    final transactionMode = transactionModeSubject.value.index;

    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    /// set data in map
    final map = setModalToMap();

    /// All transaction.
    addDataAtAllTransaction(transactionId: transactionId, rtDatabaseRef: rtDatabaseRef, map: map);

    /// Monthly transaction.
    addDataAtMonthly(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateList: dateList,
    );

    /// Category Summary transaction.
    addDataIntoCategorySummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateList: dateList,
      category: category,
    );

    /// TransactionType Summary transaction.
    addDataIntoTransactionTypeSummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateList: dateList,
      transactionType: transactionType,
    );

    /// TransactionMode Summary transaction.
    addDataIntoTransactionModeSummary(
      transactionId: transactionId,
      rtDatabaseRef: rtDatabaseRef,
      map: map,
      dateList: dateList,
      transactionMode: transactionMode,
    );

    /// Add or Update Day Wise Summary.
    addOrUpdateDataIntoDayFinanceOverviewSummary(
      rtDatabaseRef: rtDatabaseRef,
      dateList: dateList,
      transactionType: transactionType,
    );

    /// Update Whole transaction summary.
    addOrUpdateDataIntoMonthFinanceOverviewSummary(
      rtDatabaseRef: rtDatabaseRef,
      dateList: dateList,
      transactionType: transactionType,
    );

    debugPrint('addData---------------------------------->Done');
  }

  void addDataAtAllTransaction({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
  }) async {
    final allTransactionRef =
        rtDatabaseRef.child(FirebaseRealTimeDatabaseRef.allTransaction).child(transactionId);

    await allTransactionRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
    debugPrint('transactionsRef---------------------------------->Done');
  }

  void addDataAtMonthly({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateList,
  }) async {
    final monthlyDataRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(dateList[0])
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(transactionId);

    await monthlyDataRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addDataIntoCategorySummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateList,
    required int category,
  }) async {
    final categoryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.categories)
        .child('$category')
        .child(transactionId);

    await categoryRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addDataIntoTransactionTypeSummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateList,
    required int transactionType,
  }) async {
    final transactionTypeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferType)
        .child('$transactionType')
        .child(transactionId);

    await transactionTypeRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addDataIntoTransactionModeSummary({
    required String transactionId,
    required DatabaseReference rtDatabaseRef,
    required Map<String, dynamic> map,
    required List<String> dateList,
    required int transactionMode,
  }) async {
    final transactionModeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.transferMode)
        .child('$transactionMode')
        .child(transactionId);

    await transactionModeRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addOrUpdateDataIntoDayFinanceOverviewSummary({
    required DatabaseReference rtDatabaseRef,
    required List<String> dateList,
    required int transactionType,
  }) async {
    late DayFinanceOverviewModal dayFinanceOverviewModal;

    final dayFinanceOverviewSummaryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(dateList[0])
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

    dayFinanceOverviewSummaryRef.set(dayFinanceOverviewModal.toMap()).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar(message: 'Something Went wrong!', messageType: MessageType.failed);
    });
  }

  void addOrUpdateDataIntoMonthFinanceOverviewSummary({
    required DatabaseReference rtDatabaseRef,
    required List<String> dateList,
    required int transactionType,
  }) async {
    late FinanceOverviewModal financeOverviewModal;

    /// get last data from server.
    final financeOverviewSummaryRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateList[1]}-${dateList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    final snapshot = await financeOverviewSummaryRef.get();

    debugPrint(
        'updateDataIntoFinanceOverviewSummary---------------------------------->snapshot.exists = ${snapshot.exists}');

    if (snapshot.exists) {
      final financeOverviewData = snapshot.value;

      Map<String, dynamic> mappedSnapshot = Map.from(financeOverviewData as Map);

      financeOverviewModal = FinanceOverviewModal.fromMap(mappedSnapshot);
    } else {
      financeOverviewModal =
          FinanceOverviewModal(budget: 0, expense: 0, income: 0, balance: 0, isSurpassed: false);
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

    financeOverviewSummaryRef.set(financeOverviewModal.toMap()).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
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
    microTimeSubject.close();
  }
}
