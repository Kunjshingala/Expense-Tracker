import 'package:expense_tracker/ui/screens/navigation/home/home_widget/home_tab_pages/month_trans_tab/home_month_trans_tab_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../../../../utils/colors.dart';
import '../../../../../../../utils/dimens.dart';
import '../../../../../../../utils/transaction_data.dart';

class HomeMonthTabPage extends StatefulWidget {
  const HomeMonthTabPage({super.key});

  @override
  State<HomeMonthTabPage> createState() => _HomeMonthTabPageState();
}

class _HomeMonthTabPageState extends State<HomeMonthTabPage> {
  late HomeMonthTabBloc homeMonthTabBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    homeMonthTabBloc = HomeMonthTabBloc(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.5,
      child: StreamBuilder<List<TransactionModal>?>(
        stream: homeMonthTabBloc.getTransactionList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            debugPrint('---------------------------------->snapshot.hasData');
            if (snapshot.data!.isEmpty) {
              return Container(
                alignment: AlignmentDirectional.center,
                child: Text(
                  'No Transaction has been \ndone in this month!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: dark50Color,
                    fontWeight: FontWeight.w500,
                    fontSize: averageScreenSize * 0.025,
                  ),
                ),
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final transactionModal = snapshot.data![index];
                  return Container(
                    decoration: BoxDecoration(
                      color: light40Color,
                      borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                    ),
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: averageScreenSize * 0.08,
                          height: averageScreenSize * 0.08,
                          decoration: BoxDecoration(
                            color: getIconBGColor(snapshot.data![index].category),
                            borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                          ),
                          child: getCategoryModalById(transactionModal.category).icon,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getCategoryModalById(transactionModal.category).label,
                                    style: GoogleFonts.inter(
                                      color: dark50Color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: averageScreenSize * 0.03,
                                    ),
                                  ),
                                  Text(
                                    transactionModal.transactionType == TransactionType.Expense.index
                                        ? '-${transactionModal.amount}'
                                        : '+${transactionModal.amount}',
                                    style: GoogleFonts.inter(
                                      color: transactionModal.transactionType == TransactionType.Expense.index
                                          ? red100Color
                                          : green100Color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: averageScreenSize * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      transactionModal.description,
                                      style: GoogleFonts.inter(
                                        color: light0Color,
                                        fontWeight: FontWeight.w500,
                                        fontSize: averageScreenSize * 0.025,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      transactionModal.date,
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.inter(
                                        color: light0Color,
                                        fontWeight: FontWeight.w500,
                                        fontSize: averageScreenSize * 0.025,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: screenHeight * 0.01);
                },
              );
            }
          } else {
            debugPrint('---------------------------------->Else ');
            return Container(
              alignment: AlignmentDirectional.center,
              child: LoadingAnimationWidget.staggeredDotsWave(
                size: averageScreenSize * 0.06,
                color: violet80Color,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    homeMonthTabBloc.dispose();
  }
}
