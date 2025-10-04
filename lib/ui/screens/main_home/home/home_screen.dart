import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../main.dart';
import '../../../../modals/firebase_modal/month_finance_overview_modal.dart';
import '../../../../modals/local_modal/home_chart_data_modal.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_icons.dart';
import '../../../../utils/dimens.dart';
import '../../../common_view/common_button.dart';
import 'home_bloc.dart';
import 'home_widget/home_tab_pages/all_trans_tab/home_all_trans_tab_pages.dart';
import 'home_widget/home_tab_pages/month_trans_tab/home_month_trans_tab_pages.dart';
import 'home_widget/home_tab_pages/today_trans_tab/home_today_trans_tab_pages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late HomeBloc homeBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    homeBloc = HomeBloc(context: context);
    // Todo: Add this at bloc
    homeBloc.tabController = TabController(length: 3, vsync: this);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    homeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: homeAppBarColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${homeBloc.greeting}, ${homeBloc.currentUserName}',
                  style: GoogleFonts.inter(
                    color: black75,
                    fontWeight: FontWeight.w500,
                    fontSize: averageScreenSize * 0.035,
                  ),
                ),
                Text(
                  homeBloc.currentDate,
                  style: GoogleFonts.inter(
                    color: black50,
                    fontWeight: FontWeight.w400,
                    fontSize: averageScreenSize * 0.0275,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    homeAppBarColor,
                    const Color(0xffF8EDD8).withOpacity(0.0),
                  ],
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: screenWidth, minWidth: screenWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: screenHeight * 0.025),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languages.monthlyBudget,
                                style: GoogleFonts.inter(
                                  color: white0,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.025,
                                ),
                              ),
                              StreamBuilder<FinanceOverviewModal>(
                                stream: homeBloc.getFinanceOverview,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data?.budget ?? 0}',
                                      style: GoogleFonts.inter(
                                        color: black75,
                                        fontWeight: FontWeight.w500,
                                        fontSize: averageScreenSize * 0.05,
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: screenHeight * 0.05,
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: black50,
                                        size: averageScreenSize * 0.03,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languages.totalBalance,
                                style: GoogleFonts.inter(
                                  color: white0,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.025,
                                ),
                              ),
                              StreamBuilder<FinanceOverviewModal>(
                                stream: homeBloc.getFinanceOverview,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data?.balance ?? 0}',
                                      style: GoogleFonts.inter(
                                        color: snapshot.data!.balance > 0 ? green60 : red60,
                                        fontWeight: FontWeight.w500,
                                        fontSize: averageScreenSize * 0.05,
                                      ),
                                    );
                                  } else {
                                    return SizedBox(
                                      height: screenHeight * 0.05,
                                      child: LoadingAnimationWidget.hexagonDots(
                                        color: black50,
                                        size: averageScreenSize * 0.03,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Material(
                            elevation: averageScreenSize * 0.005,
                            borderRadius: BorderRadius.circular(averageScreenSize * 0.035),
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: screenHeight * 0.1,
                                maxHeight: screenHeight * 0.1,
                                minWidth: screenWidth * 0.4,
                                maxWidth: screenWidth * 0.4,
                              ),
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: green100,
                                borderRadius: BorderRadius.circular(averageScreenSize * 0.035),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Material(
                                    elevation: averageScreenSize * 0.002,
                                    borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: averageScreenSize * 0.07, maxHeight: averageScreenSize * 0.07),
                                      decoration: BoxDecoration(
                                        color: white100,
                                        borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      child: Icon(
                                        CustomIcons.income_icons,
                                        color: green100,
                                        size: averageScreenSize * 0.05,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        'Income',
                                        style: GoogleFonts.inter(
                                          color: white80,
                                          fontWeight: FontWeight.w500,
                                          fontSize: averageScreenSize * 0.0225,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '\$',
                                            style: GoogleFonts.inter(
                                              color: white80,
                                              fontWeight: FontWeight.w600,
                                              fontSize: averageScreenSize * 0.03,
                                            ),
                                          ),
                                          StreamBuilder<FinanceOverviewModal>(
                                            stream: homeBloc.getFinanceOverview,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  '${snapshot.data!.income}',
                                                  style: GoogleFonts.inter(
                                                    color: white80,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: averageScreenSize * 0.03,
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  height: screenHeight * 0.05,
                                                  padding: EdgeInsetsDirectional.only(start: screenWidth * 0.02),
                                                  child: LoadingAnimationWidget.halfTriangleDot(
                                                    color: white80,
                                                    size: averageScreenSize * 0.025,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Material(
                            elevation: averageScreenSize * 0.005,
                            borderRadius: BorderRadius.circular(averageScreenSize * 0.035),
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: screenHeight * 0.1,
                                maxHeight: screenHeight * 0.1,
                                minWidth: screenWidth * 0.4,
                                maxWidth: screenWidth * 0.4,
                              ),
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenHeight * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: red100,
                                borderRadius: BorderRadius.circular(averageScreenSize * 0.035),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Material(
                                    elevation: averageScreenSize * 0.002,
                                    borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: averageScreenSize * 0.07, maxHeight: averageScreenSize * 0.07),
                                      decoration: BoxDecoration(
                                        color: white100,
                                        borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      child: Icon(
                                        CustomIcons.expense_icons,
                                        color: red100,
                                        size: averageScreenSize * 0.05,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        languages.expense,
                                        style: GoogleFonts.inter(
                                          color: white80,
                                          fontWeight: FontWeight.w500,
                                          fontSize: averageScreenSize * 0.0225,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '\$',
                                            style: GoogleFonts.inter(
                                              color: white80,
                                              fontWeight: FontWeight.w600,
                                              fontSize: averageScreenSize * 0.03,
                                            ),
                                          ),
                                          StreamBuilder<FinanceOverviewModal>(
                                            stream: homeBloc.getFinanceOverview,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  '${snapshot.data!.expense}',
                                                  style: GoogleFonts.inter(
                                                    color: white80,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: averageScreenSize * 0.03,
                                                  ),
                                                );
                                              } else {
                                                return Container(
                                                  height: screenHeight * 0.05,
                                                  padding: EdgeInsetsDirectional.only(start: screenWidth * 0.02),
                                                  child: LoadingAnimationWidget.halfTriangleDot(
                                                    color: white80,
                                                    size: averageScreenSize * 0.025,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.020),
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05),
                    child: Text(
                      languages.spendFrequency,
                      style: GoogleFonts.inter(
                        color: black75,
                        fontWeight: FontWeight.w600,
                        fontSize: averageScreenSize * 0.03,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.03),
                    constraints: BoxConstraints(
                      maxWidth: screenWidth,
                      minWidth: screenWidth,
                      maxHeight: screenHeight * 0.3,
                      minHeight: screenHeight * 0.3,
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: StreamBuilder<HomeGraphSpineSeriesListModal>(
                      stream: homeBloc.getChartDataList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SfCartesianChart(
                            title: ChartTitle(
                              alignment: ChartAlignment.far,
                              text: '${homeBloc.currentMonth}/${homeBloc.currentYear}',
                              textStyle: GoogleFonts.inter(
                                color: violet80,
                                fontWeight: FontWeight.w500,
                                fontSize: averageScreenSize * 0.02,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            primaryXAxis: NumericAxis(
                              minimum: 0,
                              maximum: 31,
                              desiredIntervals: 31,
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: MajorGridLines(
                                // width: averageScreenSize * 0.0025,
                                width: averageScreenSize * 0.001,
                                color: violet20,
                              ),
                              labelRotation: -90,
                              labelStyle: GoogleFonts.inter(
                                color: violet80,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.015,
                                height: averageScreenSize * 0.0021,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0,
                              labelFormat: '\${value}',
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: MajorGridLines(
                                // width: averageScreenSize * 0.0025,
                                width: averageScreenSize * 0.0025,
                                color: violet20,
                              ),
                              labelStyle: GoogleFonts.inter(
                                color: violet80,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.0125,
                              ),
                            ),
                            series: [
                              SplineSeries(
                                dataSource: snapshot.data!.expensesDataList,
                                xValueMapper: (datum, index) => datum.x,
                                yValueMapper: (datum, index) => datum.y,
                                color: red100,
                                width: averageScreenSize * 0.0025,
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  width: averageScreenSize * 0.0075,
                                  height: averageScreenSize * 0.0075,
                                  color: violet100,
                                ),
                              ),
                              SplineSeries(
                                dataSource: snapshot.data!.incomeDataList,
                                xValueMapper: (datum, index) => datum.x,
                                yValueMapper: (datum, index) => datum.y,
                                color: green100,
                                width: averageScreenSize * 0.0025,
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  width: averageScreenSize * 0.0075,
                                  height: averageScreenSize * 0.0075,
                                  color: violet100,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return LoadingAnimationWidget.beat(
                            size: averageScreenSize * 0.05,
                            color: violet80,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Padding(
                    padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Tabbar
                        SizedBox(
                          height: screenHeight * 0.05,
                          child: TabBar(
                            controller: homeBloc.tabController,
                            dividerHeight: 0,
                            splashFactory: NoSplash.splashFactory,
                            labelStyle: GoogleFonts.inter(
                              color: yellow100,
                              fontWeight: FontWeight.w700,
                              fontSize: averageScreenSize * 0.025,
                            ),
                            unselectedLabelStyle: GoogleFonts.inter(
                              color: white0,
                              fontWeight: FontWeight.w500,
                              fontSize: averageScreenSize * 0.025,
                            ),
                            indicator: NavBarDecoration(
                              shape: BoxShape.rectangle,
                              color: yellow20,
                              borderRadius: BorderRadius.circular(averageScreenSize * 0.05),
                            ),
                            onTap: (value) {},
                            tabs: [
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: Text(languages.today),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: Text(languages.month),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: Text(languages.all),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languages.recentTransaction,
                              style: GoogleFonts.inter(
                                color: black75,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.03,
                              ),
                            ),
                            CustomButton(
                              width: screenWidth * 0.225,
                              height: screenHeight * 0.045,
                              btnColor: violet20,
                              onPressed: () {},
                              child: Text(
                                languages.seeAll,
                                style: GoogleFonts.inter(
                                  color: violet100,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.025,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        /// Tab bar View
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight * 0.5),
                          child: TabBarView(
                            controller: homeBloc.tabController,
                            children: const [
                              HomeTodayTabPage(),
                              HomeMonthTabPage(),
                              HomeAllTabPage(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
