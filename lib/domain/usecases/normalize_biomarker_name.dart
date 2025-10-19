import 'package:injectable/injectable.dart';

@lazySingleton
class NormalizeBiomarkerName {
  String call(String name) {
    // Placeholder implementation
    return name.trim().toLowerCase();
  }
}