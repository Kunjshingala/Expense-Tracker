import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/finance_calculation.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeMonthTabBloc {
  final BuildContext context;

  HomeMonthTabBloc({required this.context});

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  /// see [HomeAllTabBloc] for why the subscription is held rather than
  /// relying on the subject being closed.
  StreamSubscription<DatabaseEvent>? _transactionSubscription;

  final transactionListSubject = BehaviorSubject<List<TransactionModal>?>();
  Stream<List<TransactionModal>?> get getTransactionList => transactionListSubject.stream;
  Function(List<TransactionModal>?) get setTransactionList => transactionListSubject.add;

  getThisMonthTransaction() async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions);

    final monthlyTransactionsRef = rtDatabaseRef
        .child(monthKeyFor(DateTime.now()))
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions);

    // final snapshot = await monthlyTransactionsRef.get();
    //
    // if (snapshot.exists) {
    //   List<TransactionModal> list = [];
    //
    //   log('snapshot---------------------------------->snapshot.ref.key${snapshot.ref.key}');
    //   final monthData = snapshot.children;
    //
    //   for (var days in monthData) {
    //     final daysTransactions = days.child(FirebaseRealTimeDatabaseRef.transactions).children;
    //     for (var transaction in daysTransactions) {
    //       Map<String, dynamic> mappedSnapshot = Map.from(transaction.value as Map);
    //       log('snapshot---------------------------------->days.value $mappedSnapshot}');
    //       list.add(TransactionModal.fromMap(mappedSnapshot));
    //     }
    //   }
    //
    //   setTransactionList(list);
    //
    //   debugPrint('---------------------------------->${list.length}');
    // } else {
    //   setTransactionList([]);
    //   debugPrint('---------------------------------->No data available.');
    // }

    await _transactionSubscription?.cancel();

    _transactionSubscription = monthlyTransactionsRef.onValue.listen((event) {
      List<TransactionModal> list = [];

      final monthData = event.snapshot.children;

      for (var days in monthData) {
        final daysTransactions = days.child(FirebaseRealTimeDatabaseRef.transactions).children;
        for (var transaction in daysTransactions) {
          Map<String, dynamic> mappedSnapshot = Map.from(transaction.value as Map);
          list.add(TransactionModal.fromMap(mappedSnapshot));
        }
      }
      setTransactionList(list);
    });
  }

  void dispose() {
    _transactionSubscription?.cancel();
    transactionListSubject.close();
  }
}
