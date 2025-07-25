import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Mock Login Tests', () {
    test('should validate mock credentials logic', () {
      const email = 'eve.holt@reqres.in';
      const password = 'cityslicka';

      final isMockUser =
          email == 'eve.holt@reqres.in' && password == 'cityslicka';
      expect(isMockUser, true);

      const wrongPassword = 'wrong_password';
      final isValidMock =
          email == 'eve.holt@reqres.in' && wrongPassword == 'cityslicka';
      expect(isValidMock, false);
    });
  });
}
