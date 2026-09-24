import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/firebase_references.dart';

class HomeAllTabBloc {
  final BuildContext context;

  HomeAllTabBloc({required this.context});

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  /// held so the Firebase listener can be detached when the tab goes away.
  /// Closing the subject alone leaves the listener attached, still syncing and
  /// still pushing events into a closed subject.
  StreamSubscription<DatabaseEvent>? _transactionSubscription;

  final transactionListSubject = BehaviorSubject<List<TransactionModal>?>();
  Stream<List<TransactionModal>?> get getTransactionList => transactionListSubject.stream;
  Function(List<TransactionModal>?) get setTransactionList => transactionListSubject.add;

  /// how many of the most recent transactions this tab keeps live. Without a
  /// limit, every add re-downloads the user's entire transaction history to
  /// every subscribed client — full payloads, images and all — which grows
  /// without bound as the account ages.
  static const _recentTransactionLimit = 100;

  getThisAllTransaction() async {
    /// Main Ref.
    final allTransactionDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(FirebaseRealTimeDatabaseRef.allTransaction);

    await _transactionSubscription?.cancel();

    final recentTransactionsQuery =
        allTransactionDatabaseRef.orderByChild('time').limitToLast(_recentTransactionLimit);

    _transactionSubscription = recentTransactionsQuery.onValue.listen((event) {
      List<TransactionModal> list = [];

      final transactionData = event.snapshot.children;

      for (var element in transactionData) {
        Map<String, dynamic> mappedSnapshot = Map.from(element.value as Map);
        list.add(TransactionModal.fromMap(mappedSnapshot));
      }

      /// newest first — a transaction feed reads top-down by recency, and the
      /// query above returns oldest-of-the-window first.
      list.sort((a, b) => b.time.compareTo(a.time));

      setTransactionList(list);
    });
  }

  void dispose() {
    _transactionSubscription?.cancel();
    transactionListSubject.close();
  }
}
