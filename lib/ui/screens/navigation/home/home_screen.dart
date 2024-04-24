import 'package:expense_tracker/ui/common_view/main_eleveted_button.dart';
import 'package:expense_tracker/ui/screens/navigation/home/home_bloc.dart';
import 'package:expense_tracker/ui/screens/navigation/home/home_widget/home_tab_pages/month_trans_tab/home_month_trans_tab_pages.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../modals/local_modal/home_chart_data_modal.dart';
import '../../../../utils/custom_icons.dart';
import 'home_widget/home_tab_pages/all_trans_tab/home_all_trans_tab_pages.dart';
import 'home_widget/home_tab_pages/today_trans_tab/home_today_trans_tab_pages.dart';
import 'manage_transaction/add_transaction/add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late HomeBloc homeBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('--------initState--------->called');
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    homeBloc = HomeBloc(context: context);

    homeBloc.tabController = TabController(length: 3, vsync: this);
    debugPrint('--------didChangeDependencies--------->called');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('--------build--------->called');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffFFF6E5),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, ${homeBloc.currentUserName}',
                  style: GoogleFonts.inter(
                    color: dark75Color,
                    fontWeight: FontWeight.w500,
                    fontSize: averageScreenSize * 0.035,
                  ),
                ),
                Text(
                  homeBloc.currentDate,
                  style: GoogleFonts.inter(
                    color: dark50Color,
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
                    const Color(0xffFFF6E5),
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
                                'Monthly Budget',
                                style: GoogleFonts.inter(
                                  color: light0Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.025,
                                ),
                              ),
                              Text(
                                '4100',
                                style: GoogleFonts.inter(
                                  color: dark75Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.05,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Remain Budget',
                                style: GoogleFonts.inter(
                                  color: light0Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.025,
                                ),
                              ),
                              Text(
                                '3100',
                                style: GoogleFonts.inter(
                                  color: green60Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.05,
                                ),
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
                                color: green100Color,
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
                                          maxWidth: averageScreenSize * 0.07,
                                          maxHeight: averageScreenSize * 0.07),
                                      decoration: BoxDecoration(
                                        color: light100Color,
                                        borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      child: Icon(
                                        CustomIcons.income_icons,
                                        color: green100Color,
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
                                          color: light80Color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: averageScreenSize * 0.0225,
                                        ),
                                      ),
                                      Text(
                                        '\$2.0 k',
                                        style: GoogleFonts.inter(
                                          color: light80Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: averageScreenSize * 0.03,
                                        ),
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
                                color: red100Color,
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
                                          maxWidth: averageScreenSize * 0.07,
                                          maxHeight: averageScreenSize * 0.07),
                                      decoration: BoxDecoration(
                                        color: light100Color,
                                        borderRadius: BorderRadius.circular(averageScreenSize * 0.02),
                                      ),
                                      alignment: AlignmentDirectional.center,
                                      child: Icon(
                                        CustomIcons.expense_icons,
                                        color: red100Color,
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
                                        'Expenses',
                                        style: GoogleFonts.inter(
                                          color: light80Color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: averageScreenSize * 0.0225,
                                        ),
                                      ),
                                      Text(
                                        '\$3.0 k',
                                        style: GoogleFonts.inter(
                                          color: light80Color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: averageScreenSize * 0.03,
                                        ),
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
                      'Spend Frequency',
                      style: GoogleFonts.inter(
                        color: dark75Color,
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
                    child: StreamBuilder<List<List<HomeChartDataModal>>>(
                      stream: homeBloc.getChartDataList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SfCartesianChart(
                            title: ChartTitle(
                              alignment: ChartAlignment.far,
                              text: '${homeBloc.currentMonth}/${homeBloc.currentYear}',
                              textStyle: GoogleFonts.inter(
                                color: violet80Color,
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
                                color: violet20Color,
                              ),
                              labelRotation: -90,
                              labelStyle: GoogleFonts.inter(
                                color: violet80Color,
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
                                color: violet20Color,
                              ),
                              labelStyle: GoogleFonts.inter(
                                color: violet80Color,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.0125,
                              ),
                            ),
                            series: [
                              SplineSeries(
                                dataSource: snapshot.data?.first,
                                xValueMapper: (datum, index) => datum.x,
                                yValueMapper: (datum, index) => datum.y,
                                color: red100Color,
                                width: averageScreenSize * 0.0025,
                                cardinalSplineTension: 0.1,
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  width: averageScreenSize * 0.0075,
                                  height: averageScreenSize * 0.0075,
                                  color: violet100Color,
                                ),
                              ),
                              SplineSeries(
                                dataSource: snapshot.data![1],
                                xValueMapper: (datum, index) => datum.x,
                                yValueMapper: (datum, index) => datum.y,
                                color: green100Color,
                                width: averageScreenSize * 0.0025,
                                cardinalSplineTension: 0.1,
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                  width: averageScreenSize * 0.0075,
                                  height: averageScreenSize * 0.0075,
                                  color: violet100Color,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return LoadingAnimationWidget.beat(
                            size: averageScreenSize * 0.05,
                            color: violet80Color,
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
                              color: yellow100Color,
                              fontWeight: FontWeight.w700,
                              fontSize: averageScreenSize * 0.025,
                            ),
                            unselectedLabelStyle: GoogleFonts.inter(
                              color: light0Color,
                              fontWeight: FontWeight.w500,
                              fontSize: averageScreenSize * 0.025,
                            ),
                            indicator: NavBarDecoration(
                              shape: BoxShape.rectangle,
                              color: yellow20Color,
                              borderRadius: BorderRadius.circular(averageScreenSize * 0.05),
                            ),
                            onTap: (value) {},
                            tabs: [
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: const Text('Today'),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: const Text('Month'),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  width: screenWidth * 0.3,
                                  alignment: AlignmentDirectional.center,
                                  child: const Text('All'),
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
                              'Recent Transaction',
                              style: GoogleFonts.inter(
                                color: dark75Color,
                                fontWeight: FontWeight.w600,
                                fontSize: averageScreenSize * 0.03,
                              ),
                            ),
                            CustomElevatedButton(
                              width: screenWidth * 0.225,
                              height: screenHeight * 0.045,
                              borderRadius: averageScreenSize * 0.03,
                              color: violet20Color,
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: GoogleFonts.inter(
                                  color: violet100Color,
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
      floatingActionButton: GestureDetector(
        onTap: () {
          pushWithoutNavBar(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(
            minWidth: averageScreenSize * 0.1,
            maxWidth: averageScreenSize * 0.1,
            minHeight: averageScreenSize * 0.1,
            maxHeight: averageScreenSize * 0.1,
          ),
          decoration: BoxDecoration(
            color: violet20Color,
            borderRadius: BorderRadius.circular(averageScreenSize * 0.04),
          ),
          child: Icon(
            CustomIcons.add_icon,
            color: violet100Color,
            size: averageScreenSize * 0.02,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('--------dispose--------->called');
    // TODO: implement dispose
    super.dispose();
    homeBloc.dispose();
  }
}
