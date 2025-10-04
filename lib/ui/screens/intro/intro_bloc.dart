import 'package:rxdart/rxdart.dart';

class IntroBloc {
  final pageIndexSubject = BehaviorSubject<int>.seeded(0);

  void dispose() {
    pageIndexSubject.close();
  }
}
