import 'package:flutter/material.dart';

import 'colors.dart';
import 'custom_icons.dart';
import 'dimens.dart';

enum TransactionType { expense, income }

/// Note :
///   Expense --> 0
///   Income --> 1

enum TransactionMode { cash, online }

/// Note :
///   Cash --> 0
///   Online --> 1

enum TransactionPeriod { today, month, all }

List<TransactionCategoryModal> expenseTransactionCategoryList = [
  TransactionCategoryModal(
    id: 0,
    label: 'Bills',
    icon: const CategoryIcon(iconData: CustomIcons.bills_icon, id: 0),
  ),
  TransactionCategoryModal(
    id: 1,
    label: 'Food',
    icon: const CategoryIcon(iconData: CustomIcons.food_icons, id: 1),
  ),
  TransactionCategoryModal(
    id: 2,
    label: 'Education',
    icon: const CategoryIcon(iconData: CustomIcons.education_icon, id: 2),
  ),
  TransactionCategoryModal(
    id: 3,
    label: 'Fuel',
    icon: const CategoryIcon(iconData: CustomIcons.fule_icon, id: 3),
  ),
  TransactionCategoryModal(
    id: 4,
    label: 'Groceries',
    icon: const CategoryIcon(iconData: CustomIcons.groceries_icon, id: 4),
  ),
  TransactionCategoryModal(
    id: 5,
    label: 'Health',
    icon: const CategoryIcon(iconData: CustomIcons.health_icon, id: 5),
  ),
  TransactionCategoryModal(
    id: 6,
    label: 'Rent',
    icon: const CategoryIcon(iconData: CustomIcons.rent_icon, id: 6),
  ),
  TransactionCategoryModal(
    id: 7,
    label: 'Investment',
    icon: const CategoryIcon(iconData: CustomIcons.investment_icon, id: 7),
  ),
  TransactionCategoryModal(
    id: 8,
    label: 'Shopping',
    icon: const CategoryIcon(iconData: CustomIcons.shopping_bag_icons, id: 8),
  ),
  TransactionCategoryModal(
    id: 9,
    label: 'Travel',
    icon: const CategoryIcon(iconData: CustomIcons.travel_icon, id: 9),
  ),
  TransactionCategoryModal(
    id: 10,
    label: 'Donation',
    icon: const CategoryIcon(iconData: CustomIcons.donation_icon, id: 10),
  ),
  TransactionCategoryModal(
    id: 11,
    label: 'Lottery',
    icon: const CategoryIcon(iconData: CustomIcons.lottery_icon, id: 11),
  ),
];

List<TransactionCategoryModal> incomeTransactionCategoryList = [
  TransactionCategoryModal(
    id: -1,
    label: 'Salary',
    icon: const CategoryIcon(iconData: CustomIcons.salary_icons_1, id: -1),
  ),
  TransactionCategoryModal(
    id: -2,
    label: 'Loan',
    icon: const CategoryIcon(iconData: CustomIcons.loan_icon, id: -2),
  ),
  TransactionCategoryModal(
    id: -3,
    label: 'Interest',
    icon: const CategoryIcon(iconData: CustomIcons.interest_icon, id: -3),
  ),
  TransactionCategoryModal(
    id: -4,
    label: 'Bonus',
    icon: const CategoryIcon(iconData: CustomIcons.bonus_icon, id: -4),
  ),
  TransactionCategoryModal(
    id: -5,
    label: 'Lottery',
    icon: const CategoryIcon(iconData: CustomIcons.lottery_icon, id: -5),
  ),
];

class TransactionCategoryModal {
  final int id;
  final String label;
  final Widget icon;

  TransactionCategoryModal({required this.id, required this.label, required this.icon});
}

class CategoryIcon extends StatelessWidget {
  final IconData iconData;
  final int id;

  const CategoryIcon({super.key, required this.iconData, required this.id});

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      size: averageScreenSize * 0.045,
      color: getIconColor(id),
    );
  }
}

TransactionCategoryModal getCategoryModalById(int id) {
  /// this method give index of category list.
  if (id >= 0) {
    for (int i = 0; i < expenseTransactionCategoryList.length; i++) {
      if (expenseTransactionCategoryList[i].id == id) {
        return expenseTransactionCategoryList[i];
      }
    }
  } else {
    for (int i = 0; i < incomeTransactionCategoryList.length; i++) {
      if (incomeTransactionCategoryList[i].id == id) {
        return incomeTransactionCategoryList[i];
      }
    }
  }
  return expenseTransactionCategoryList[0];
}

Color getIconColor(int id) {
  if (id == 0) {
    return blue100;
  }
  if (id == 1) {
    return red80;
  }
  if (id == 2) {
    return green100;
  }
  if (id == 3) {
    return black50;
  }
  if (id == 4) {
    return violet60;
  }
  if (id == 5) {
    return red100;
  }
  if (id == 6) {
    return blue60;
  }
  if (id == 7) {
    return yellow80;
  }
  if (id == 8) {
    return yellow100;
  }
  if (id == 9) {
    return violet60;
  }
  if (id == 10) {
    return green80;
  }
  if (id == 11) {
    return blue100;
  }
  if (id == -1) {
    return green100;
  }
  if (id == -2) {
    return violet80;
  }
  if (id == -3) {
    return red80;
  }
  if (id == -4) {
    return green60;
  }
  if (id == -5) {
    return blue100;
  }
  return white100;
}

Color getIconBGColor(int id) {
  if (id == 0) {
    return blue20;
  }
  if (id == 1) {
    return red20;
  }
  if (id == 2) {
    return green20;
  }
  if (id == 3) {
    return white20;
  }
  if (id == 4) {
    return violet20;
  }
  if (id == 5) {
    return red20;
  }
  if (id == 6) {
    return blue20;
  }
  if (id == 7) {
    return yellow20;
  }
  if (id == 8) {
    return yellow20;
  }
  if (id == 9) {
    return violet20;
  }
  if (id == 10) {
    return green20;
  }
  if (id == 11) {
    return blue20;
  }
  if (id == -1) {
    return green20;
  }
  if (id == -2) {
    return violet20;
  }
  if (id == -3) {
    return red20;
  }
  if (id == -4) {
    return green20;
  }
  if (id == -5) {
    return blue20;
  }
  return white20;
}
