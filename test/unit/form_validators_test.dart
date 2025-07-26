import 'package:flutter_test/flutter_test.dart';
import 'package:team_up/core/utils/form_validators.dart';

void main() {
  group('FormValidators Tests', () {
    group('required validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.required(null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.required('');
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro personalizada', () {
        final result = FormValidators.required(
          null,
          errorMessage: 'Campo obrigatório',
        );
        expect(result, 'Campo obrigatório');
      });

      test('deve retornar null para valor válido', () {
        final result = FormValidators.required('valor válido');
        expect(result, null);
      });
    });

    group('email validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.email(null);
        expect(result, 'Email é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.email('');
        expect(result, 'Email é obrigatório');
      });

      test('deve retornar erro para email inválido', () {
        final result = FormValidators.email('email_invalido');
        expect(result, 'Email inválido');
      });

      test('deve retornar erro para email sem @', () {
        final result = FormValidators.email('emailexample.com');
        expect(result, 'Email inválido');
      });

      test('deve retornar erro para email sem domínio', () {
        final result = FormValidators.email('email@');
        expect(result, 'Email inválido');
      });

      test('deve retornar null para email válido', () {
        final result = FormValidators.email('user@example.com');
        expect(result, null);
      });

      test('deve retornar null para email com subdominios', () {
        final result = FormValidators.email('user@mail.example.com');
        expect(result, null);
      });

      test('deve retornar null para email com números', () {
        final result = FormValidators.email('user123@example123.com');
        expect(result, null);
      });

      test('deve retornar null para email com hífen', () {
        final result = FormValidators.email('user-name@ex-ample.com');
        expect(result, null);
      });
    });

    group('fullName validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.fullName(null);
        expect(result, 'Nome completo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.fullName('');
        expect(result, 'Nome completo é obrigatório');
      });

      test('deve retornar erro para apenas uma palavra', () {
        final result = FormValidators.fullName('João');
        expect(result, 'Digite seu nome e sobrenome');
      });

      test('deve retornar erro para nome com apenas espaços', () {
        final result = FormValidators.fullName('   João   ');
        expect(result, 'Digite seu nome e sobrenome');
      });

      test('deve retornar null para nome completo válido', () {
        final result = FormValidators.fullName('João Silva');
        expect(result, null);
      });

      test('deve retornar null para nome com três palavras', () {
        final result = FormValidators.fullName('João da Silva');
        expect(result, null);
      });

      test('deve retornar null para nome com múltiplas palavras', () {
        final result = FormValidators.fullName('João Carlos da Silva Santos');
        expect(result, null);
      });
    });

    group('password validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.password(null);
        expect(result, 'Senha é obrigatória');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.password('');
        expect(result, 'Senha é obrigatória');
      });

      test('deve retornar erro para senha muito curta (padrão)', () {
        final result = FormValidators.password('123');
        expect(result, 'Senha deve ter pelo menos 6 caracteres');
      });

      test('deve retornar erro para senha muito curta (personalizada)', () {
        final result = FormValidators.password('123', minLength: 8);
        expect(result, 'Senha deve ter pelo menos 8 caracteres');
      });

      test('deve retornar null para senha válida (padrão)', () {
        final result = FormValidators.password('123456');
        expect(result, null);
      });

      test('deve retornar null para senha válida (personalizada)', () {
        final result = FormValidators.password('12345678', minLength: 8);
        expect(result, null);
      });

      test('deve retornar null para senha com caracteres especiais', () {
        final result = FormValidators.password('password123!@#');
        expect(result, null);
      });
    });

    group('confirmPassword validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.confirmPassword(null, 'password123');
        expect(result, 'Confirmação de senha é obrigatória');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.confirmPassword('', 'password123');
        expect(result, 'Confirmação de senha é obrigatória');
      });

      test('deve retornar erro para senhas diferentes', () {
        final result = FormValidators.confirmPassword(
          'password456',
          'password123',
        );
        expect(result, 'Senhas não coincidem');
      });

      test('deve retornar null para senhas iguais', () {
        final result = FormValidators.confirmPassword(
          'password123',
          'password123',
        );
        expect(result, null);
      });

      test(
        'deve retornar null para senhas iguais com caracteres especiais',
        () {
          final result = FormValidators.confirmPassword(
            'pass@123!',
            'pass@123!',
          );
          expect(result, null);
        },
      );
    });

    group('minLength validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.minLength(null, 5);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.minLength('', 5);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string muito curta', () {
        final result = FormValidators.minLength('abc', 5);
        expect(result, 'Campo deve ter pelo menos 5 caracteres');
      });

      test('deve retornar erro personalizada', () {
        final result = FormValidators.minLength(
          'abc',
          5,
          errorMessage: 'Mínimo 5 caracteres',
        );
        expect(result, 'Mínimo 5 caracteres');
      });

      test('deve retornar null para string válida', () {
        final result = FormValidators.minLength('abcde', 5);
        expect(result, null);
      });

      test('deve retornar null para string maior que mínimo', () {
        final result = FormValidators.minLength('abcdefg', 5);
        expect(result, null);
      });
    });

    group('maxLength validator', () {
      test('deve retornar null para valor nulo', () {
        final result = FormValidators.maxLength(null, 5);
        expect(result, null);
      });

      test('deve retornar null para string vazia', () {
        final result = FormValidators.maxLength('', 5);
        expect(result, null);
      });

      test('deve retornar erro para string muito longa', () {
        final result = FormValidators.maxLength('abcdef', 5);
        expect(result, 'Campo deve ter no máximo 5 caracteres');
      });

      test('deve retornar erro personalizada', () {
        final result = FormValidators.maxLength(
          'abcdef',
          5,
          errorMessage: 'Máximo 5 caracteres',
        );
        expect(result, 'Máximo 5 caracteres');
      });

      test('deve retornar null para string válida', () {
        final result = FormValidators.maxLength('abcde', 5);
        expect(result, null);
      });

      test('deve retornar null para string menor que máximo', () {
        final result = FormValidators.maxLength('abc', 5);
        expect(result, null);
      });
    });

    group('integer validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.integer(null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.integer('');
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string não numérica', () {
        final result = FormValidators.integer('abc');
        expect(result, 'Campo deve ser um número inteiro válido');
      });

      test('deve retornar erro para número decimal', () {
        final result = FormValidators.integer('12.5');
        expect(result, 'Campo deve ser um número inteiro válido');
      });

      test('deve retornar erro personalizada', () {
        final result = FormValidators.integer(
          'abc',
          errorMessage: 'Número inválido',
        );
        expect(result, 'Número inválido');
      });

      test('deve retornar null para inteiro válido', () {
        final result = FormValidators.integer('123');
        expect(result, null);
      });

      test('deve retornar null para inteiro negativo', () {
        final result = FormValidators.integer('-123');
        expect(result, null);
      });
    });

    group('decimal validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.decimal(null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.decimal('');
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string não numérica', () {
        final result = FormValidators.decimal('abc');
        expect(result, 'Campo deve ser um número válido');
      });

      test('deve retornar erro personalizada', () {
        final result = FormValidators.decimal(
          'abc',
          errorMessage: 'Número inválido',
        );
        expect(result, 'Número inválido');
      });

      test('deve retornar null para inteiro válido', () {
        final result = FormValidators.decimal('123');
        expect(result, null);
      });

      test('deve retornar null para decimal válido', () {
        final result = FormValidators.decimal('123.45');
        expect(result, null);
      });

      test('deve retornar null para decimal negativo', () {
        final result = FormValidators.decimal('-123.45');
        expect(result, null);
      });
    });

    group('url validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.url(null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.url('');
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para URL inválida', () {
        final result = FormValidators.url('url_invalida');
        expect(result, 'Campo deve ser uma URL válida');
      });

      test('deve retornar erro para URL sem protocolo', () {
        final result = FormValidators.url('www.example.com');
        expect(result, 'Campo deve ser uma URL válida');
      });

      test('deve retornar null para URL HTTP válida', () {
        final result = FormValidators.url('http://www.example.com');
        expect(result, null);
      });

      test('deve retornar null para URL HTTPS válida', () {
        final result = FormValidators.url('https://www.example.com');
        expect(result, null);
      });

      test('deve retornar null para URL com path', () {
        final result = FormValidators.url(
          'https://www.example.com/path/to/page',
        );
        expect(result, null);
      });

      test('deve retornar null para URL com query parameters', () {
        final result = FormValidators.url(
          'https://www.example.com?param=value',
        );
        expect(result, null);
      });
    });

    group('phone validator', () {
      test('deve retornar erro para valor nulo', () {
        final result = FormValidators.phone(null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para string vazia', () {
        final result = FormValidators.phone('');
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro para telefone muito curto', () {
        final result = FormValidators.phone('123456789');
        expect(result, 'Telefone deve ter 10 ou 11 dígitos');
      });

      test('deve retornar erro para telefone muito longo', () {
        final result = FormValidators.phone('123456789012');
        expect(result, 'Telefone deve ter 10 ou 11 dígitos');
      });

      test('deve retornar null para telefone fixo (10 dígitos)', () {
        final result = FormValidators.phone('1234567890');
        expect(result, null);
      });

      test('deve retornar null para celular (11 dígitos)', () {
        final result = FormValidators.phone('12345678901');
        expect(result, null);
      });

      test('deve retornar null para telefone com formatação', () {
        final result = FormValidators.phone('(12) 3456-7890');
        expect(result, null);
      });

      test('deve retornar null para celular com formatação', () {
        final result = FormValidators.phone('(12) 99999-9999');
        expect(result, null);
      });
    });

    group('combine validator', () {
      test('deve retornar erro do primeiro validator que falhou', () {
        final validators = [
          (String? value) => FormValidators.required(value),
          (String? value) => FormValidators.email(value),
        ];

        final result = FormValidators.combine(validators, null);
        expect(result, 'Este campo é obrigatório');
      });

      test('deve retornar erro do segundo validator', () {
        final validators = [
          (String? value) => FormValidators.required(value),
          (String? value) => FormValidators.email(value),
        ];

        final result = FormValidators.combine(validators, 'email_invalido');
        expect(result, 'Email inválido');
      });

      test('deve retornar null quando todos os validators passaram', () {
        final validators = [
          (String? value) => FormValidators.required(value),
          (String? value) => FormValidators.email(value),
        ];

        final result = FormValidators.combine(validators, 'user@example.com');
        expect(result, null);
      });

      test('deve funcionar com lista vazia de validators', () {
        final validators = <String? Function(String?)>[];
        final result = FormValidators.combine(validators, 'qualquer_valor');
        expect(result, null);
      });
    });
  });
}
