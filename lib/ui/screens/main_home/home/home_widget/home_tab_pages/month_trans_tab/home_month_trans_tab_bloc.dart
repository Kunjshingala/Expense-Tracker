import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeMonthTabBloc {
  final BuildContext context;

  HomeMonthTabBloc({required this.context});

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

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

    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    final monthlyTransactionsRef = rtDatabaseRef
        .child('${dateDataList[1]}-${dateDataList[2]}')
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

    final monthDataStream = monthlyTransactionsRef.onValue;

    monthDataStream.listen((event) {
      List<TransactionModal> list = [];

      final monthData = event.snapshot.children;

      for (var days in monthData) {
        final daysTransactions = days.child(FirebaseRealTimeDatabaseRef.transactions).children;
        for (var transaction in daysTransactions) {
          Map<String, dynamic> mappedSnapshot = Map.from(transaction.value as Map);
          log('snapshot---------------------------------->days.value $mappedSnapshot}');
          list.add(TransactionModal.fromMap(mappedSnapshot));
        }
      }
      setTransactionList(list);
    });
  }

  void dispose() {
    transactionListSubject.close();
  }
}
