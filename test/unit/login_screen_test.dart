import 'package:flutter_test/flutter_test.dart';
import 'package:team_up/core/utils/form_validators.dart';

void main() {
  group('Login Screen - Validação de Formulário', () {
    group('Validação de Email', () {
      test('deve aceitar email válido', () {
        final result = FormValidators.email('usuario@example.com');
        expect(result, isNull);
      });

      test('deve rejeitar email inválido', () {
        final result = FormValidators.email('email_invalido');
        expect(result, isNotNull);
        expect(result, contains('inválido'));
      });

      test('deve rejeitar email vazio', () {
        final result = FormValidators.email('');
        expect(result, isNotNull);
        expect(result, contains('obrigatório'));
      });

      test('deve rejeitar email nulo', () {
        final result = FormValidators.email(null);
        expect(result, isNotNull);
        expect(result, contains('obrigatório'));
      });

      test('deve aceitar emails com subdomínios', () {
        final result = FormValidators.email('user@mail.empresa.com.br');
        expect(result, isNull);
      });

      test('deve aceitar emails com números e hífens', () {
        final result = FormValidators.email('user-123@empresa-teste.com');
        expect(result, isNull);
      });
    });

    group('Validação de Senha', () {
      test('deve aceitar senha válida', () {
        final result = FormValidators.password('minhasenha123');
        expect(result, isNull);
      });

      test('deve rejeitar senha muito curta', () {
        final result = FormValidators.password('123');
        expect(result, isNotNull);
        expect(result, contains('6 caracteres'));
      });

      test('deve rejeitar senha vazia', () {
        final result = FormValidators.password('');
        expect(result, isNotNull);
        expect(result, contains('obrigatória'));
      });

      test('deve rejeitar senha nula', () {
        final result = FormValidators.password(null);
        expect(result, isNotNull);
        expect(result, contains('obrigatória'));
      });

      test('deve aceitar senha com caracteres especiais', () {
        final result = FormValidators.password('senha@123!');
        expect(result, isNull);
      });

      test('deve aceitar senha com tamanho mínimo exato', () {
        final result = FormValidators.password('123456');
        expect(result, isNull);
      });

      test('deve permitir configurar tamanho mínimo personalizado', () {
        final result = FormValidators.password('1234567', minLength: 8);
        expect(result, isNotNull);
        expect(result, contains('8 caracteres'));

        final validResult = FormValidators.password('12345678', minLength: 8);
        expect(validResult, isNull);
      });
    });

    group('Combinação de Validadores', () {
      test('deve validar email e senha em conjunto', () {
        // Simula validação de um formulário de login completo
        final emailResult = FormValidators.email('usuario@test.com');
        final passwordResult = FormValidators.password('senha123');

        expect(emailResult, isNull);
        expect(passwordResult, isNull);
      });

      test('deve falhar se email inválido mesmo com senha válida', () {
        final emailResult = FormValidators.email('email_inválido');
        final passwordResult = FormValidators.password('senha123');

        expect(emailResult, isNotNull);
        expect(passwordResult, isNull);
      });

      test('deve falhar se senha inválida mesmo com email válido', () {
        final emailResult = FormValidators.email('usuario@test.com');
        final passwordResult = FormValidators.password('123');

        expect(emailResult, isNull);
        expect(passwordResult, isNotNull);
      });

      test('deve usar validator combine para validar múltiplos campos', () {
        final validators = [
          (String? value) => FormValidators.required(value),
          (String? value) => FormValidators.email(value),
        ];

        // Teste com email válido
        final validResult = FormValidators.combine(validators, 'user@test.com');
        expect(validResult, isNull);

        // Teste com email inválido
        final invalidResult = FormValidators.combine(
          validators,
          'email_inválido',
        );
        expect(invalidResult, isNotNull);

        // Teste com campo vazio
        final emptyResult = FormValidators.combine(validators, '');
        expect(emptyResult, isNotNull);
        expect(emptyResult, contains('obrigatório'));
      });
    });

    group('Casos Extremos', () {
      test('deve lidar com strings muito longas', () {
        final longEmail = '${'a' * 100}@${'example' * 10}.com';
        final result = FormValidators.email(longEmail);
        expect(result, isNull); // Email tecnicamente válido
      });

      test('deve lidar com caracteres especiais em email', () {
        final specialEmail = 'user-name@example.com';
        final result = FormValidators.email(specialEmail);
        expect(result, isNull);
      });

      test('deve rejeitar emails com espaços', () {
        final emailWithSpaces = 'user name@example.com';
        final result = FormValidators.email(emailWithSpaces);
        expect(result, isNotNull);
      });

      test('deve aceitar senhas com espaços', () {
        final passwordWithSpaces = 'minha senha secreta';
        final result = FormValidators.password(passwordWithSpaces);
        expect(result, isNull);
      });

      test('deve aceitar senha com emojis', () {
        final passwordWithEmojis = 'senha123😀🔐';
        final result = FormValidators.password(passwordWithEmojis);
        expect(result, isNull);
      });
    });

    group('Mensagens de Erro Personalizadas', () {
      test('deve usar mensagem personalizada para campo obrigatório', () {
        final result = FormValidators.required(
          null,
          errorMessage: 'Este campo deve ser preenchido',
        );
        expect(result, 'Este campo deve ser preenchido');
      });

      test('deve usar mensagem padrão quando não especificada', () {
        final result = FormValidators.required(null);
        expect(result, 'Este campo é obrigatório');
      });
    });

    group('Performance e Eficiência', () {
      test('deve validar rapidamente com entradas válidas', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          FormValidators.email('user$i@example.com');
          FormValidators.password('password$i');
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Deve ser rápido
      });

      test('deve validar rapidamente com entradas inválidas', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          FormValidators.email('invalid_email_$i');
          FormValidators.password('123');
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Deve ser rápido
      });
    });
  });

  group('Login Screen - Lógica de Negócio', () {
    test('deve simular fluxo de login válido', () {
      // Dados de entrada
      const email = 'usuario@empresa.com';
      const password = 'minhasenha123';

      // Validação
      final emailValidation = FormValidators.email(email);
      final passwordValidation = FormValidators.password(password);

      // Verificações
      expect(emailValidation, isNull, reason: 'Email deve ser válido');
      expect(passwordValidation, isNull, reason: 'Senha deve ser válida');

      // Simula que o formulário seria enviado
      final canSubmit = emailValidation == null && passwordValidation == null;
      expect(canSubmit, true, reason: 'Formulário deve permitir submissão');
    });

    test('deve bloquear login com dados inválidos', () {
      // Dados inválidos
      const email = 'email_sem_arroba';
      const password = '123';

      // Validação
      final emailValidation = FormValidators.email(email);
      final passwordValidation = FormValidators.password(password);

      // Verificações
      expect(emailValidation, isNotNull, reason: 'Email deve ser inválido');
      expect(passwordValidation, isNotNull, reason: 'Senha deve ser inválida');

      // Simula que o formulário seria bloqueado
      final canSubmit = emailValidation == null && passwordValidation == null;
      expect(canSubmit, false, reason: 'Formulário deve bloquear submissão');
    });

    test('deve validar campos um por vez', () {
      // Teste sequencial como aconteceria na UI
      final steps = [
        {'field': 'email', 'value': '', 'shouldPass': false},
        {'field': 'email', 'value': 'user@', 'shouldPass': false},
        {'field': 'email', 'value': 'user@test.com', 'shouldPass': true},
        {'field': 'password', 'value': '', 'shouldPass': false},
        {'field': 'password', 'value': '123', 'shouldPass': false},
        {'field': 'password', 'value': 'validpassword', 'shouldPass': true},
      ];

      for (final step in steps) {
        final field = step['field'] as String;
        final value = step['value'] as String;
        final shouldPass = step['shouldPass'] as bool;

        String? result;
        if (field == 'email') {
          result = FormValidators.email(value);
        } else if (field == 'password') {
          result = FormValidators.password(value);
        }

        if (shouldPass) {
          expect(
            result,
            isNull,
            reason: '$field com valor "$value" deveria ser válido',
          );
        } else {
          expect(
            result,
            isNotNull,
            reason: '$field com valor "$value" deveria ser inválido',
          );
        }
      }
    });
  });
}
