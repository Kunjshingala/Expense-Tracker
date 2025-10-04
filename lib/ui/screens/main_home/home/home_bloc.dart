import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/firebase_modal/day_finance_overview_modal.dart';
import '../../../../modals/firebase_modal/month_finance_overview_modal.dart';
import '../../../../modals/local_modal/home_chart_data_modal.dart';
import '../../../../utils/firebase_references.dart';

class HomeBloc {
  final BuildContext context;

  HomeBloc({required this.context}) {
    /// get basic details, like UserName, DateTime and Gratitude .
    getBasicDetails();
    getMonthlyDataForChart();
    getBudgetSummary();
  }

  late TabController tabController;

  late FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;

  final chartDataListSubject = BehaviorSubject<HomeGraphSpineSeriesListModal>();
  Stream<HomeGraphSpineSeriesListModal> get getChartDataList => chartDataListSubject.stream;
  Function(HomeGraphSpineSeriesListModal) get setChartDataList => chartDataListSubject.add;

  final financeOverviewSubject = BehaviorSubject<FinanceOverviewModal>();
  Stream<FinanceOverviewModal> get getFinanceOverview => financeOverviewSubject.stream;
  Function(FinanceOverviewModal) get setFinanceOverview => financeOverviewSubject.add;

  late String currentUserName;
  late String currentGratitude;
  late String currentDay;
  late String currentMonth;
  late String currentYear;
  late String currentDate;
  late String greeting;

  void getBasicDetails() {
    currentUserName = (auth.currentUser!.displayName != null && auth.currentUser!.displayName!.isNotEmpty)
        ? auth.currentUser!.displayName!
        : 'Xyz ';

    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = currentDate.split(' ');

    /// Date.
    currentDay = dateDataList[0];
    currentMonth = dateDataList[1];
    currentYear = dateDataList[2];

    /// Greeting.
    var hour = DateTime.now().hour;
    debugPrint('getGreeting---------------------------------->$hour');
    if (hour <= 11) {
      greeting = 'Good Morning';
    }
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    }
    if (hour >= 17) {
      greeting = 'Good Evening';
    }
  }

  /// For Transaction Summary (Monthly budget, Remain Budget, Expenses, Income)
  void getBudgetSummary() async {
    late FinanceOverviewModal financeOverviewModal;

    /// get last data from server.
    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    final financeOverviewSummaryRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    final financeOverviewStream = financeOverviewSummaryRef.onValue;

    financeOverviewStream.listen((event) {
      if (event.snapshot.exists) {
        debugPrint('financeOverviewStream---------------------------------->${event.snapshot}');
        debugPrint('financeOverviewStream---------------------------------->${event.snapshot.value}');
        debugPrint('financeOverviewStream---------------------------------->${event.snapshot.children}');

        final financeOverviewData = event.snapshot.value;

        Map<String, dynamic> mappedSnapshot = Map.from(financeOverviewData as Map);

        financeOverviewModal = FinanceOverviewModal.fromMap(mappedSnapshot);

        debugPrint('financeOverviewStream---------------------------------->$financeOverviewModal');
      } else {
        financeOverviewModal =
            FinanceOverviewModal(budget: 0, expense: 0, income: 0, balance: 0, isSurpassed: false);
      }
      setFinanceOverview(financeOverviewModal);
    });
  }

  /// For Chart
  void getMonthlyDataForChart() {
    String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
    final dateDataList = date.split(' ');

    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions)
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions);

    /// this Month transaction Ref.
    final transactionsRef = rtDatabaseRef
        .child('${dateDataList[1]}-${dateDataList[2]}')
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions);

    final daysDataStream = transactionsRef.onValue;

    daysDataStream.listen((event) {
      List<HomeChartDataModal> expenseChartDataList = [];
      List<HomeChartDataModal> incomeChartDataList = [];

      final daysData = event.snapshot.children;

      for (var daysElement in daysData) {
        daysElement
            .child(FirebaseRealTimeDatabaseRef.daySummary)
            .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

        int date = int.parse(daysElement.key!);

        final dayFinanceOverviewData =
            daysElement.child(FirebaseRealTimeDatabaseRef.dayFinanceOverview).value;

        if (dayFinanceOverviewData != null) {
          Map<String, dynamic> mappedSnapshot = Map.from(dayFinanceOverviewData as Map);

          DayFinanceOverviewModal dayFinanceOverviewModal = DayFinanceOverviewModal.fromMap(mappedSnapshot);

          if (dayFinanceOverviewModal.expense > 0) {
            expenseChartDataList.add(HomeChartDataModal(date, dayFinanceOverviewModal.expense));
          }
          if (dayFinanceOverviewModal.income > 0) {
            incomeChartDataList.add(HomeChartDataModal(date, dayFinanceOverviewModal.income));
          }
        }

        debugPrint('-------------------------------------------------------------------->');
      }

      setChartDataList(
        HomeGraphSpineSeriesListModal(
            expensesDataList: expenseChartDataList, incomeDataList: incomeChartDataList),
      );
    }).onError((e) {
      debugPrint('---------------------------------->$e');
    });
  }

  void dispose() {
    chartDataListSubject.close();
    financeOverviewSubject.close();
  }
}
