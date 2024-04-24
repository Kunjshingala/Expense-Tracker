import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeTodayTabBloc {
  final BuildContext context;

  HomeTodayTabBloc({required this.context}) {
    getTodayTransaction();
  }

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  final transactionListSubject = BehaviorSubject<List<TransactionModal>?>();
  Stream<List<TransactionModal>?> get getTransactionList => transactionListSubject.stream;
  Function(List<TransactionModal>?) get setTransactionList => transactionListSubject.add;

  void getTodayTransaction() async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.allTransaction);

    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    final todayTransactionsRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthly)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(dateDataList[0]);

    final snapshot = await todayTransactionsRef.get();

    if (snapshot.exists) {
      List<TransactionModal> list = [];

      final data = snapshot.children;

      for (var element in data) {
        Map<String, dynamic> mappedSnapshot = Map.from(element.value as Map);
        list.add(TransactionModal.fromMap(mappedSnapshot));
      }

      setTransactionList(list);

      debugPrint('---------------------------------->${list.length}');
    } else {
      setTransactionList([]);
      debugPrint('---------------------------------->No data available.');
    }
  }

  void dispose() {
    transactionListSubject.close();
  }
}
