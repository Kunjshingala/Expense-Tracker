import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeAllTabBloc {
  final BuildContext context;

  HomeAllTabBloc({required this.context}) {
    getThisAllTransaction();
  }

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  final transactionListSubject = BehaviorSubject<List<TransactionModal>?>();
  Stream<List<TransactionModal>?> get getTransactionList => transactionListSubject.stream;
  Function(List<TransactionModal>?) get setTransactionList => transactionListSubject.add;

  void getThisAllTransaction() async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.allTransaction);

    final allTransactionsRef = rtDatabaseRef.child(FirebaseRealTimeDatabaseRef.transactions);

    final snapshot = await allTransactionsRef.get();

    if (snapshot.exists) {
      List<TransactionModal> list = [];

      final transactionData = snapshot.children;

      for (var element in transactionData) {
        Map<String, dynamic> mappedSnapshot = Map.from(element.value as Map);
        list.add(TransactionModal.fromMap(mappedSnapshot));
      }

      list.sort(
        (a, b) {
          return a.time.compareTo(b.time);
        },
      );

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
