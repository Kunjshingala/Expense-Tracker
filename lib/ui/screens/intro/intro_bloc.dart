import 'package:rxdart/rxdart.dart';

class IntroBloc {
  final pageIndexSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get getPageIndex => pageIndexSubject.stream;
  Function(int) get setPageIndex => pageIndexSubject.add;

  void dispose() {
    pageIndexSubject.close();
  }
}
