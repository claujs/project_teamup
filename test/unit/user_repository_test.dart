import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:team_up/core/errors/failures.dart';
import 'package:team_up/core/network/api_client.dart';
import 'package:team_up/core/network/network_info.dart';
import 'package:team_up/core/storage/local_storage.dart';
import 'package:team_up/features/users/data/repositories/user_repository_impl.dart';
import 'package:team_up/features/users/domain/entities/advanced_filter.dart';
import 'package:team_up/features/users/domain/entities/user.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([ApiClient, NetworkInfo, LocalStorage, Dio])
void main() {
  late UserRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockNetworkInfo mockNetworkInfo;
  late MockLocalStorage mockLocalStorage;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockNetworkInfo = MockNetworkInfo();
    mockLocalStorage = MockLocalStorage();
    mockDio = MockDio();

    when(mockApiClient.dio).thenReturn(mockDio);

    // Mock padrão para localStorage sempre retornar sucesso no save
    when(mockLocalStorage.saveObject(any, any)).thenAnswer((_) async {});

    repository = UserRepositoryImpl(
      apiClient: mockApiClient,
      networkInfo: mockNetworkInfo,
      localStorage: mockLocalStorage,
    );
  });

  // Dados de teste
  const testUsers = [
    User(
      id: 1,
      email: 'john.doe@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatar: 'https://example.com/avatar1.jpg',
      position: 'Developer',
      department: 'Engineering',
    ),
    User(
      id: 2,
      email: 'jane.smith@example.com',
      firstName: 'Jane',
      lastName: 'Smith',
      avatar: 'https://example.com/avatar2.jpg',
      position: 'Designer',
      department: 'Design',
    ),
    User(
      id: 3,
      email: 'bob.wilson@example.com',
      firstName: 'Bob',
      lastName: 'Wilson',
      avatar: 'https://example.com/avatar3.jpg',
      position: 'Manager',
      department: 'Engineering',
    ),
  ];

  group('UserRepository - Search Users Tests', () {
    group('searchUsers', () {
      test(
        'deve retornar usuários filtrados por nome quando conectado',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          // Act
          final result = await repository.searchUsers('John');

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(users.length, 1);
              expect(users.first.firstName, 'John');
            },
          );
        },
      );

      test(
        'deve retornar usuários filtrados por email quando conectado',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          // Act
          final result = await repository.searchUsers('jane.smith');

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(users.length, 1);
              expect(users.first.email, contains('jane.smith'));
            },
          );
        },
      );

      test(
        'deve retornar lista vazia quando nenhum usuário corresponde',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          // Act
          final result = await repository.searchUsers('inexistente');

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(users.length, 0);
            },
          );
        },
      );

      test(
        'deve retornar múltiplos usuários quando há correspondência parcial',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          // Act
          final result = await repository.searchUsers('example.com');

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(
                users.length,
                3,
              ); // Todos os usuários têm email com example.com
            },
          );
        },
      );

      test('deve ignorar maiúsculas e minúsculas na busca', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        // Act
        final result = await repository.searchUsers('JOHN');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.firstName, 'John');
          },
        );
      });

      test('deve retornar falha quando ocorre erro de servidor', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Server error',
          ),
        );

        // Act
        final result = await repository.searchUsers('John');

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Server error'));
        }, (users) => fail('Expected failure, got success'));
      });
    });

    group('searchUsersAdvanced', () {
      test(
        'deve retornar todos os usuários quando filtro está vazio',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          const emptyFilter = AdvancedFilter();

          // Act
          final result = await repository.searchUsersAdvanced(emptyFilter);

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(users.length, 3);
            },
          );
        },
      );

      test('deve filtrar por nome quando especificado', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        const filter = AdvancedFilter(name: 'John');

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.fullName, contains('John'));
          },
        );
      });

      test('deve filtrar por email quando especificado', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        const filter = AdvancedFilter(email: 'jane.smith');

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.email, contains('jane.smith'));
          },
        );
      });

      test('deve combinar múltiplos filtros (AND)', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        const filter = AdvancedFilter(name: 'John', email: 'john.doe');

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.firstName, 'John');
            expect(users.first.email, contains('john.doe'));
          },
        );
      });

      test(
        'deve retornar lista vazia quando combinação de filtros não tem correspondência',
        () async {
          // Arrange
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
          when(
            mockDio.get(any, queryParameters: anyNamed('queryParameters')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'data': testUsers.map((u) => u.toJson()).toList(),
                'page': 1,
                'per_page': 6,
                'total_pages': 1,
                'total': 3,
              },
            ),
          );

          const filter = AdvancedFilter(
            name: 'John',
            email: 'jane.smith', // Combinação impossível
          );

          // Act
          final result = await repository.searchUsersAdvanced(filter);

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Expected success, got failure: $failure'),
            (users) {
              expect(users.length, 0);
            },
          );
        },
      );

      test('deve ignorar campos vazios no filtro', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        const filter = AdvancedFilter(
          name: 'John',
          email: '', // Campo vazio deve ser ignorado
          department: '   ', // Somente espaços também deve ser ignorado
        );

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.firstName, 'John');
          },
        );
      });

      test('deve ignorar maiúsculas e minúsculas nos filtros', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'data': testUsers.map((u) => u.toJson()).toList(),
              'page': 1,
              'per_page': 6,
              'total_pages': 1,
              'total': 3,
            },
          ),
        );

        const filter = AdvancedFilter(name: 'JOHN', email: 'EXAMPLE.COM');

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (users) {
            expect(users.length, 1);
            expect(users.first.firstName, 'John');
          },
        );
      });

      test('deve retornar falha quando ocorre erro de servidor', () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockDio.get(any, queryParameters: anyNamed('queryParameters')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Server error',
          ),
        );

        const filter = AdvancedFilter(name: 'John');

        // Act
        final result = await repository.searchUsersAdvanced(filter);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Server error'));
        }, (users) => fail('Expected failure, got success'));
      });
    });

    group('AdvancedFilter extensions', () {
      test(
        'isEmpty deve retornar true quando todos os campos estão vazios',
        () {
          const filter = AdvancedFilter();
          expect(filter.isEmpty, true);
        },
      );

      test(
        'isEmpty deve retornar true quando todos os campos são strings vazias',
        () {
          const filter = AdvancedFilter(
            name: '',
            email: '   ',
            department: null,
            position: '',
          );
          expect(filter.isEmpty, true);
        },
      );

      test(
        'isEmpty deve retornar false quando pelo menos um campo tem valor',
        () {
          const filter = AdvancedFilter(name: 'John');
          expect(filter.isEmpty, false);
        },
      );

      test(
        'isSimpleNameFilter deve retornar true quando só o nome está preenchido',
        () {
          const filter = AdvancedFilter(name: 'John');
          expect(filter.isSimpleNameFilter, true);
        },
      );

      test(
        'isSimpleNameFilter deve retornar false quando outros campos estão preenchidos',
        () {
          const filter = AdvancedFilter(
            name: 'John',
            email: 'john@example.com',
          );
          expect(filter.isSimpleNameFilter, false);
        },
      );
    });
  });
}
