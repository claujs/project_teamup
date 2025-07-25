import 'package:flutter_test/flutter_test.dart';
import 'package:team_up/features/users/domain/entities/user.dart';

void main() {
  group('User Entity Tests', () {
    test('should create a user with all required fields', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
      );

      expect(user.id, equals(1));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
      expect(user.avatar, equals('https://example.com/avatar.jpg'));
    });

    test('should create a user with optional fields', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
        position: 'Developer',
        department: 'IT',
        bio: 'A passionate developer',
      );

      expect(user.position, equals('Developer'));
      expect(user.department, equals('IT'));
      expect(user.bio, equals('A passionate developer'));
    });

    test('should have correct fullName extension', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
      );

      expect(user.fullName, equals('John Doe'));
    });

    test('should serialize to and from JSON correctly', () {
      const user = User(
        id: 1,
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      expect(userFromJson, equals(user));
      expect(json['id'], equals(1));
      expect(json['email'], equals('test@example.com'));
      final firstName = json['first_name'] ?? json['firstName'];
      final lastName = json['last_name'] ?? json['lastName'];
      expect(firstName, equals('John'));
      expect(lastName, equals('Doe'));
    });
  });
}
