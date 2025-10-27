import 'package:flutter_test/flutter_test.dart';
import 'package:health_tracker_reports/core/error/exceptions.dart';

void main() {
  test('AppException toString returns message', () {
    const exception = ValidationException('Invalid');
    expect(exception.toString(), 'Invalid');
  });

  test('ServerException includes status code in toString', () {
    const exception = ServerException('Failed', statusCode: 500);
    expect(exception.toString(), 'ServerException (500): Failed');
  });

  test('ServerException without status code omits parentheses', () {
    const exception = ServerException('Oops');
    expect(exception.toString(), 'ServerException: Oops');
  });
}
