import '../constants/app_strings.dart';

/// Classe utilitária contendo validators para formulários que podem ser
/// usados globalmente em todo o projeto
class FormValidators {
  FormValidators._();

  /// Validator genérico para campos obrigatórios
  static String? required(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }
    return null;
  }

  /// Validator para email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }

    return null;
  }

  /// Validator para nome completo (deve ter pelo menos 2 palavras)
  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fullNameRequired;
    }

    if (value.trim().split(' ').length < 2) {
      return AppStrings.fullNameFormat;
    }

    return null;
  }

  /// Validator para password
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value.length < minLength) {
      return AppStrings.passwordMinLength;
    }

    return null;
  }

  /// Validator para confirmação de password
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }

    if (value != originalPassword) {
      return AppStrings.passwordMismatch;
    }

    return null;
  }

  /// Validator para campos de texto com tamanho mínimo personalizado
  static String? minLength(String? value, int min, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }

    if (value.length < min) {
      return errorMessage ?? 'Campo deve ter pelo menos $min caracteres';
    }

    return null;
  }

  /// Validator para campos de texto com tamanho máximo personalizado
  static String? maxLength(String? value, int max, {String? errorMessage}) {
    if (value != null && value.length > max) {
      return errorMessage ?? 'Campo deve ter no máximo $max caracteres';
    }

    return null;
  }

  /// Validator para números inteiros
  static String? integer(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }

    if (int.tryParse(value) == null) {
      return errorMessage ?? 'Campo deve ser um número inteiro válido';
    }

    return null;
  }

  /// Validator para números decimais
  static String? decimal(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }

    if (double.tryParse(value) == null) {
      return errorMessage ?? 'Campo deve ser um número válido';
    }

    return null;
  }

  /// Validator para URLs
  static String? url(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return errorMessage ?? 'Campo deve ser uma URL válida';
    }

    return null;
  }

  /// Validator para telefone (formato brasileiro)
  static String? phone(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Este campo é obrigatório';
    }

    // Remove todos os caracteres não numéricos
    final numbersOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 10 ou 11 dígitos (com ou sem DDD)
    if (numbersOnly.length < 10 || numbersOnly.length > 11) {
      return errorMessage ?? 'Telefone deve ter 10 ou 11 dígitos';
    }

    return null;
  }

  /// Combina múltiplos validators
  static String? combine(
    List<String? Function(String?)> validators,
    String? value,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
