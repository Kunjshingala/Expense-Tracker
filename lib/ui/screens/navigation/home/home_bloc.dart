import 'package:expense_tracker/modals/firebase_modal/transaction_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/local_modal/home_chart_data_modal.dart';
import '../../../../utils/firebase_references.dart';
import '../../../../utils/transaction_data.dart';

class HomeBloc {
  final BuildContext context;

  HomeBloc({required this.context}) {
    /// get basic details, like UserName, DateTime and Gratitude .
    getBasicDetails();
    getMonthlyDataForChart();
  }

  late TabController tabController;

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  final chartDataListSubject = BehaviorSubject<List<List<HomeChartDataModal>>>();
  Stream<List<List<HomeChartDataModal>>> get getChartDataList => chartDataListSubject.stream;
  Function(List<List<HomeChartDataModal>>) get setChartDataList => chartDataListSubject.add;

  late String currentUserName;
  late String currentGratitude;
  late String currentDay;
  late String currentMonth;
  late String currentYear;
  late String currentDate;
  late String userName;

  getBasicDetails() {
    currentUserName = (auth.currentUser!.displayName != null && auth.currentUser!.displayName!.isNotEmpty)
        ? auth.currentUser!.displayName!
        : 'Xyz ';

    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = currentDate.split(' ');

    currentDay = dateDataList[0];
    currentMonth = dateDataList[1];
    currentYear = dateDataList[2];
  }

  /// For Chart
  void getMonthlyDataForChart() {
    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    List<TransactionModal> list = [];

    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.allTransaction);

    /// this Month Ref.
    final transactionsRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthly)
        .child('${dateDataList[1]}-${dateDataList[2]}');

    final monthlyDataStream = transactionsRef.onValue;

    monthlyDataStream.listen((event) {
      final monthData = event.snapshot.children;

      for (var days in monthData) {
        for (var transaction in days.children) {
          Map<String, dynamic> mappedSnapshot = Map.from(transaction.value as Map);
          list.add(TransactionModal.fromMap(mappedSnapshot));
        }
      }

      list.sort(
        (a, b) {
          return a.time.compareTo(b.time);
        },
      );

      /// set data for chart
      addDataInChartList(list);
    }).onError((e) {
      debugPrint('---------------------------------->$e');
    });
  }

  addDataInChartList(List<TransactionModal> list) {
    List<HomeChartDataModal> expenseChartDataList = [];
    List<HomeChartDataModal> incomeChartDataList = [];

    for (var element in list) {
      debugPrint(
          'TransactionList---------------------------------->${element.amount},${element.transactionType == 0 ? TransactionType.Expense.name : TransactionType.Income.name}');
    }

    for (var element in list) {
      int date = int.parse(element.date.split(' ')[0]);
      int amount = element.amount;

      /// transaction type Expense->0 Income->1.
      if (element.transactionType == 0) {
        expenseChartDataList.add(HomeChartDataModal(date, amount));
      } else {
        incomeChartDataList.add(HomeChartDataModal(date, amount));
      }
    }

    debugPrint('---------------------------------->');
    for (var element in expenseChartDataList) {
      debugPrint('expenseChartDataList---------------------------------->${element.x}-${element.y}');
    }

    debugPrint('---------------------------------->');
    for (var element in incomeChartDataList) {
      debugPrint('incomeChartDataList---------------------------------->${element.x}-${element.y}');
    }

    setChartDataList([expenseChartDataList, incomeChartDataList]);
  }

  void dispose() {
    chartDataListSubject.close();
  }
}
