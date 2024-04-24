import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeMonthTabBloc {
  final BuildContext context;

  HomeMonthTabBloc({required this.context}) {
    getThisMonthTransaction();
  }

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  final transactionListSubject = BehaviorSubject<List<TransactionModal>?>();
  Stream<List<TransactionModal>?> get getTransactionList => transactionListSubject.stream;
  Function(List<TransactionModal>?) get setTransactionList => transactionListSubject.add;

  void getThisMonthTransaction() async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.allTransaction);

    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    final monthlyTransactionsRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthly)
        .child('${dateDataList[1]}-${dateDataList[2]}');

    final snapshot = await monthlyTransactionsRef.get();

    if (snapshot.exists) {
      List<TransactionModal> list = [];

      final monthData = snapshot.children;

      for (var days in monthData) {
        for (var transaction in days.children) {
          /// Show only 10 entries.
          if (list.length <= 10) {
            Map<String, dynamic> mappedSnapshot = Map.from(transaction.value as Map);
            list.add(TransactionModal.fromMap(mappedSnapshot));
          } else {
            break;
          }
        }
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
