import 'package:injectable/injectable.dart';

abstract class Clock {
  DateTime now();
}

@LazySingleton(as: Clock)
class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}
