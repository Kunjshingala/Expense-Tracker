class HomeChartDataModal {
  HomeChartDataModal(this.x, this.y);
  final int x;
  int y;
}

class HomeGraphSpineSeriesListModal {
  final List<HomeChartDataModal> expensesDataList;
  final List<HomeChartDataModal> incomeDataList;

  HomeGraphSpineSeriesListModal({required this.expensesDataList, required this.incomeDataList});
}
