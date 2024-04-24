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
      setMicroTime(selectedDate.microsecondsSinceEpoch);

      dateController.text = dateFormat.format(selectedDate);
    }
  }

  void getCroppedFile() {}

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
      showMySnackBar('Add Sufficient Amount.', MessageType.warning);
      return false;
    }
    if (!selectedCategorySubject.hasValue) {
      showMySnackBar('Select Category.', MessageType.warning);
      return false;
    }
    if (dateController.text.trim().isEmpty) {
      showMySnackBar('Select Date.', MessageType.warning);
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
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    final transactionType = transactionTypeSubject.value.index;
    final transactionMode = transactionModeSubject.value.index;
    final dateList = dateController.text.split(" ");
    final category = selectedCategorySubject.value!.id;

    /// set data in map
    final map = setModalToMap();

    /// All transaction Ref.
    final transactionsRef =
        rtDatabaseRef.child(FirebaseRealTimeDatabaseRef.transactions).child(transactionId);

    await transactionsRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar('Something Went wrong!', MessageType.failed);
    });
    debugPrint('transactionsRef---------------------------------->Done');

    ///Month Wise Ref.
    final monthRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthly)
        // .child(FirebaseRealTimeDatabaseRef.history)
        .child('${dateList[1]}-${dateList[2]}')
        .child(dateList[0])
        .child(transactionId);

    await monthRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar('Something Went wrong!', MessageType.failed);
    });
    debugPrint('monthRef---------------------------------->Done');

    /// category Wise Ref.
    final categoryRef =
        rtDatabaseRef.child(FirebaseRealTimeDatabaseRef.categories).child('$category').child(transactionId);

    await categoryRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar('Something Went wrong!', MessageType.failed);
    });
    debugPrint('categoryRef---------------------------------->Done');

    /// TransferMode Ref.
    final transferModeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.transferMode)
        .child('$transactionMode')
        .child(transactionId);

    await transferModeRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar('Something Went wrong!', MessageType.failed);
    });
    debugPrint('transferModeRef---------------------------------->Done');

    /// TransferType Ref.
    final transferTypeRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.transferType)
        .child('$transactionType')
        .child(transactionId);

    await transferTypeRef.set(map).onError((error, stackTrace) {
      debugPrint('---------------------------------->$error');
      debugPrint('---------------------------------->$stackTrace');
      showMySnackBar('Something Went wrong!', MessageType.failed);
    });
    debugPrint('transferTypeRef---------------------------------->Done');
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

      if (context.mounted) Navigator.pop(context);
    }
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
