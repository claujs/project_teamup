import 'package:flutter_test/flutter_test.dart';
import 'package:team_up/core/utils/form_validators.dart';

void main() {
  group('Register Screen - Validação de Formulário', () {
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
    });

    group('Validação de Nome Completo', () {
      test('deve aceitar nome completo válido', () {
        final result = FormValidators.fullName('João Silva');
        expect(result, isNull);
      });

      test('deve rejeitar nome simples', () {
        final result = FormValidators.fullName('João');
        expect(result, isNotNull);
        expect(result, contains('nome e sobrenome'));
      });

      test('deve rejeitar nome vazio', () {
        final result = FormValidators.fullName('');
        expect(result, isNotNull);
        expect(result, contains('obrigatório'));
      });

      test('deve rejeitar nome nulo', () {
        final result = FormValidators.fullName(null);
        expect(result, isNotNull);
        expect(result, contains('obrigatório'));
      });

      test('deve aceitar nomes com três palavras', () {
        final result = FormValidators.fullName('João da Silva');
        expect(result, isNull);
      });

      test('deve aceitar nomes compostos', () {
        final result = FormValidators.fullName(
          'Maria José da Conceição Santos',
        );
        expect(result, isNull);
      });

      test('deve tratar espaços extras corretamente', () {
        final result = FormValidators.fullName('   João   ');
        expect(
          result,
          isNotNull,
          reason: 'Nome com apenas espaços deve ser inválido',
        );
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

      test('deve aceitar senha no limite mínimo', () {
        final result = FormValidators.password('123456');
        expect(result, isNull);
      });

      test('deve aceitar senha com caracteres especiais', () {
        final result = FormValidators.password('minha@senha123!');
        expect(result, isNull);
      });
    });

    group('Validação de Confirmação de Senha', () {
      test('deve aceitar senhas iguais', () {
        const password = 'minhasenha123';
        final result = FormValidators.confirmPassword(password, password);
        expect(result, isNull);
      });

      test('deve rejeitar senhas diferentes', () {
        const password = 'minhasenha123';
        const confirmPassword = 'outrasenha456';
        final result = FormValidators.confirmPassword(
          confirmPassword,
          password,
        );
        expect(result, isNotNull);
        expect(result, contains('não coincidem'));
      });

      test('deve rejeitar confirmação vazia', () {
        const password = 'minhasenha123';
        final result = FormValidators.confirmPassword('', password);
        expect(result, isNotNull);
        expect(result, contains('obrigatória'));
      });

      test('deve rejeitar confirmação nula', () {
        const password = 'minhasenha123';
        final result = FormValidators.confirmPassword(null, password);
        expect(result, isNotNull);
        expect(result, contains('obrigatória'));
      });

      test('deve ser case-sensitive', () {
        const password = 'MinhaSeNhA123';
        const confirmPassword = 'minhasenha123';
        final result = FormValidators.confirmPassword(
          confirmPassword,
          password,
        );
        expect(
          result,
          isNotNull,
          reason: 'Senhas com case diferente devem ser diferentes',
        );
      });

      test('deve validar caracteres especiais identicamente', () {
        const password = 'senha@123!#\$%';
        final result = FormValidators.confirmPassword(password, password);
        expect(result, isNull);
      });
    });

    group('Validação de Formulário Completo', () {
      test('deve validar todos os campos para cadastro válido', () {
        // Dados válidos
        const email = 'usuario@empresa.com';
        const fullName = 'João Silva Santos';
        const password = 'minhasenha123';
        const confirmPassword = 'minhasenha123';

        // Validações
        final emailResult = FormValidators.email(email);
        final nameResult = FormValidators.fullName(fullName);
        final passwordResult = FormValidators.password(password);
        final confirmResult = FormValidators.confirmPassword(
          confirmPassword,
          password,
        );

        // Verificações
        expect(emailResult, isNull, reason: 'Email deve ser válido');
        expect(nameResult, isNull, reason: 'Nome deve ser válido');
        expect(passwordResult, isNull, reason: 'Senha deve ser válida');
        expect(confirmResult, isNull, reason: 'Confirmação deve ser válida');

        // Simulação de submissão
        final canSubmit = [
          emailResult,
          nameResult,
          passwordResult,
          confirmResult,
        ].every((result) => result == null);
        expect(canSubmit, true, reason: 'Formulário deve permitir submissão');
      });

      test('deve bloquear cadastro com dados inválidos', () {
        // Dados inválidos
        const email = 'email_sem_arroba';
        const fullName = 'João'; // Apenas um nome
        const password = '123'; // Muito curta
        const confirmPassword = '456'; // Diferente

        // Validações
        final emailResult = FormValidators.email(email);
        final nameResult = FormValidators.fullName(fullName);
        final passwordResult = FormValidators.password(password);
        final confirmResult = FormValidators.confirmPassword(
          confirmPassword,
          password,
        );

        // Verificações - todos devem falhar
        expect(emailResult, isNotNull, reason: 'Email deve ser inválido');
        expect(nameResult, isNotNull, reason: 'Nome deve ser inválido');
        expect(passwordResult, isNotNull, reason: 'Senha deve ser inválida');
        expect(
          confirmResult,
          isNotNull,
          reason: 'Confirmação deve ser inválida',
        );

        // Simulação de bloqueio
        final canSubmit = [
          emailResult,
          nameResult,
          passwordResult,
          confirmResult,
        ].every((result) => result == null);
        expect(canSubmit, false, reason: 'Formulário deve bloquear submissão');
      });

      test('deve validar parcialmente com alguns campos válidos', () {
        // Dados mistos
        const email = 'usuario@empresa.com'; // Válido
        const fullName = 'Maria'; // Inválido - só um nome
        const password = 'senhasegura123'; // Válido
        const confirmPassword = 'senhasegura123'; // Válido

        // Validações
        final emailResult = FormValidators.email(email);
        final nameResult = FormValidators.fullName(fullName);
        final passwordResult = FormValidators.password(password);
        final confirmResult = FormValidators.confirmPassword(
          confirmPassword,
          password,
        );

        // Verificações específicas
        expect(emailResult, isNull, reason: 'Email deve ser válido');
        expect(nameResult, isNotNull, reason: 'Nome deve ser inválido');
        expect(passwordResult, isNull, reason: 'Senha deve ser válida');
        expect(confirmResult, isNull, reason: 'Confirmação deve ser válida');

        // Deve bloquear por causa do nome inválido
        final canSubmit = [
          emailResult,
          nameResult,
          passwordResult,
          confirmResult,
        ].every((result) => result == null);
        expect(
          canSubmit,
          false,
          reason: 'Formulário deve bloquear por nome inválido',
        );
      });
    });

    group('Casos de Uso Específicos', () {
      test('deve aceitar nomes com acentos e caracteres especiais', () {
        final nomes = [
          'João José',
          'María Fernández',
          'José da Silva',
          'Ana-Maria Santos',
          "D'Angelo Ribeiro",
          'François Müller',
        ];

        for (final nome in nomes) {
          final result = FormValidators.fullName(nome);
          expect(result, isNull, reason: 'Nome "$nome" deve ser válido');
        }
      });

      test('deve aceitar emails de diferentes domínios', () {
        final emails = [
          'user@gmail.com',
          'test@company.com.br',
          'admin@sub.domain.org',
          'user.tag@example.co.uk',
          'user.name@company-name.info',
        ];

        for (final email in emails) {
          final result = FormValidators.email(email);
          expect(result, isNull, reason: 'Email "$email" deve ser válido');
        }
      });

      test('deve aceitar senhas com diferentes padrões', () {
        final senhas = [
          'senha123',
          'PASSWORD456',
          'MinhaSenha@123',
          'senha_com_underscores',
          'senha-com-hifens',
          'senha com espaços',
          '123456789012345', // Só números
          'abcdefghijklmnop', // Só letras
        ];

        for (final senha in senhas) {
          final result = FormValidators.password(senha);
          expect(result, isNull, reason: 'Senha "$senha" deve ser válida');
        }
      });
    });

    group('Validação Sequencial (Simulando Digitação)', () {
      test('deve validar email durante digitação', () {
        final steps = [
          {'input': '', 'valid': false, 'reason': 'Campo vazio'},
          {'input': 'u', 'valid': false, 'reason': 'Muito curto'},
          {'input': 'user', 'valid': false, 'reason': 'Sem @'},
          {'input': 'user@', 'valid': false, 'reason': 'Sem domínio'},
          {
            'input': 'user@test',
            'valid': false,
            'reason': 'Domínio incompleto',
          },
          {'input': 'user@test.', 'valid': false, 'reason': 'Sem TLD'},
          {'input': 'user@test.com', 'valid': true, 'reason': 'Email completo'},
        ];

        for (final step in steps) {
          final input = step['input'] as String;
          final shouldBeValid = step['valid'] as bool;
          final reason = step['reason'] as String;

          final result = FormValidators.email(input);
          if (shouldBeValid) {
            expect(
              result,
              isNull,
              reason: 'Passo "$reason": "$input" deveria ser válido',
            );
          } else {
            expect(
              result,
              isNotNull,
              reason: 'Passo "$reason": "$input" deveria ser inválido',
            );
          }
        }
      });

      test('deve validar nome completo durante digitação', () {
        final steps = [
          {'input': '', 'valid': false, 'reason': 'Campo vazio'},
          {'input': 'J', 'valid': false, 'reason': 'Uma letra'},
          {'input': 'João', 'valid': false, 'reason': 'Só primeiro nome'},
          {'input': 'João ', 'valid': false, 'reason': 'Espaço sem sobrenome'},
          {
            'input': 'João S',
            'valid': true,
            'reason': 'Nome e inicial do sobrenome',
          },
          {'input': 'João Silva', 'valid': true, 'reason': 'Nome completo'},
        ];

        for (final step in steps) {
          final input = step['input'] as String;
          final shouldBeValid = step['valid'] as bool;
          final reason = step['reason'] as String;

          final result = FormValidators.fullName(input);
          if (shouldBeValid) {
            expect(
              result,
              isNull,
              reason: 'Passo "$reason": "$input" deveria ser válido',
            );
          } else {
            expect(
              result,
              isNotNull,
              reason: 'Passo "$reason": "$input" deveria ser inválido',
            );
          }
        }
      });
    });

    group('Performance', () {
      test('deve validar rapidamente grandes volumes de dados', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          FormValidators.email('user$i@test.com');
          FormValidators.fullName('Nome$i Sobrenome$i');
          FormValidators.password('password$i');
          FormValidators.confirmPassword('password$i', 'password$i');
        }

        stopwatch.stop();
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason: 'Validação deve ser rápida mesmo com muitos dados',
        );
      });
    });
  });

  group('Register Screen - Fluxos de Negócio', () {
    test('deve simular fluxo de cadastro bem-sucedido', () {
      // Simula preenchimento sequencial do formulário
      const userData = {
        'email': 'novo.usuario@empresa.com',
        'fullName': 'Novo Usuário Silva',
        'password': 'minhasenhasegura123',
        'confirmPassword': 'minhasenhasegura123',
      };

      // Validação individual de cada campo
      final validations = <String, String?>{
        'email': FormValidators.email(userData['email']),
        'fullName': FormValidators.fullName(userData['fullName']),
        'password': FormValidators.password(userData['password']),
        'confirmPassword': FormValidators.confirmPassword(
          userData['confirmPassword'],
          userData['password']!,
        ),
      };

      // Verifica se todas as validações passaram
      validations.forEach((field, error) {
        expect(error, isNull, reason: 'Campo $field deve ser válido');
      });

      // Simula que todos os dados estão prontos para envio
      final allValid = validations.values.every((error) => error == null);
      expect(
        allValid,
        true,
        reason: 'Todos os campos devem estar válidos para cadastro',
      );
    });

    test('deve bloquear cadastro com senha fraca', () {
      const userData = {
        'email': 'usuario@test.com',
        'fullName': 'Usuário Teste',
        'password': '123', // Senha muito fraca
        'confirmPassword': '123',
      };

      final passwordValidation = FormValidators.password(userData['password']);
      final confirmValidation = FormValidators.confirmPassword(
        userData['confirmPassword'],
        userData['password']!,
      );

      expect(
        passwordValidation,
        isNotNull,
        reason: 'Senha fraca deve ser rejeitada',
      );
      // A confirmação pode passar se for igual, mas a senha principal falha

      final canRegister =
          passwordValidation == null && confirmValidation == null;
      expect(
        canRegister,
        false,
        reason: 'Cadastro deve ser bloqueado com senha fraca',
      );
    });

    test('deve detectar inconsistência na confirmação de senha', () {
      const userData = {
        'email': 'usuario@test.com',
        'fullName': 'Usuário Teste',
        'password': 'senhaforte123',
        'confirmPassword': 'senhadiferente456',
      };

      final passwordValidation = FormValidators.password(userData['password']);
      final confirmValidation = FormValidators.confirmPassword(
        userData['confirmPassword'],
        userData['password']!,
      );

      expect(passwordValidation, isNull, reason: 'Senha deve ser válida');
      expect(confirmValidation, isNotNull, reason: 'Confirmação deve falhar');
      expect(
        confirmValidation,
        contains('não coincidem'),
        reason: 'Deve indicar que senhas não coincidem',
      );
    });

    test('deve validar dados empresariais típicos', () {
      // Casos comuns em ambiente empresarial
      final testCases = [
        {
          'name': 'CEO com nome composto',
          'email': 'ceo@empresa.com.br',
          'fullName': 'Maria da Silva Santos',
          'shouldPass': true,
        },
        {
          'name': 'Funcionário com email corporativo',
          'email': 'joao.silva@departamento.empresa.org',
          'fullName': 'João Silva',
          'shouldPass': true,
        },
        {
          'name': 'Consultor externo',
          'email': 'consultor@consultoria-externa.co.uk',
          'fullName': 'Carlos Eduardo Fernandes',
          'shouldPass': true,
        },
        {
          'name': 'Nome com caracteres especiais',
          'email': 'maria@empresa.com',
          'fullName': "D'Angelo O'Connor",
          'shouldPass': true,
        },
      ];

      for (final testCase in testCases) {
        final email = testCase['email'] as String;
        final fullName = testCase['fullName'] as String;
        final shouldPass = testCase['shouldPass'] as bool;
        final caseName = testCase['name'] as String;

        final emailResult = FormValidators.email(email);
        final nameResult = FormValidators.fullName(fullName);

        if (shouldPass) {
          expect(
            emailResult,
            isNull,
            reason: 'Caso "$caseName": email deve ser válido',
          );
          expect(
            nameResult,
            isNull,
            reason: 'Caso "$caseName": nome deve ser válido',
          );
        } else {
          final hasError = emailResult != null || nameResult != null;
          expect(
            hasError,
            true,
            reason: 'Caso "$caseName": deve ter algum erro',
          );
        }
      }
    });
  });
}
