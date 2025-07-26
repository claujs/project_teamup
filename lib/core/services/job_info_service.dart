import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../../l10n/app_localizations.dart';

/// Serviço responsável por gerar informações de trabalho baseadas no ID do usuário
/// Remove a lógica de negócio das views
class JobInfoService {
  /// Gera um cargo determinístico baseado no ID do usuário
  static String generateJobTitle(BuildContext context, int userId) {
    final l10n = AppLocalizations.of(context)!;
    final jobTitles = [
      l10n.jobTitleFrontend,
      l10n.jobTitleBackend,
      l10n.jobTitleUxUi,
      l10n.jobTitleProductManager,
      l10n.jobTitleDevOps,
      l10n.jobTitleDataScientist,
      l10n.jobTitleQa,
      l10n.jobTitleTechLead,
    ];

    final jobIndex = userId % jobTitles.length;
    return jobTitles[jobIndex];
  }

  /// Gera um departamento determinístico baseado no ID do usuário
  static String generateDepartment(BuildContext context, int userId) {
    final l10n = AppLocalizations.of(context)!;
    final departments = [
      l10n.departmentTech,
      l10n.departmentProduct,
      l10n.departmentDesign,
      l10n.departmentEngineering,
      l10n.departmentData,
      l10n.departmentQuality,
    ];

    final deptIndex = userId % departments.length;
    return departments[deptIndex];
  }

  /// Gera informações completas de trabalho (cargo - departamento)
  static String generateJobInfo(BuildContext context, int userId) {
    final jobTitle = generateJobTitle(context, userId);
    final department = generateDepartment(context, userId);
    return '$jobTitle - $department';
  }

  /// Gera uma localização determinística baseada no ID do usuário
  static String generateLocation(int userId) {
    const locations = [
      'São Paulo, SP',
      'Rio de Janeiro, RJ',
      'Belo Horizonte, MG',
      'Porto Alegre, RS',
      'Brasília, DF',
      'Salvador, BA',
      'Fortaleza, CE',
      'Recife, PE',
      'Curitiba, PR',
      'Florianópolis, SC',
    ];

    final locationIndex = userId % locations.length;
    return locations[locationIndex];
  }

  /// Gera uma biografia usando Faker
  static String generateBio(String firstName) {
    final faker = Faker();
    return faker.lorem.sentences(2).join(' ');
  }
}
