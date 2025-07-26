import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../../l10n/app_localizations.dart';

class JobInfoService {
  static const List<String> _jobTitlesEn = [
    'Frontend Developer',
    'Backend Developer',
    'UX/UI Designer',
    'Product Manager',
    'DevOps Engineer',
    'Data Scientist',
    'QA Engineer',
    'Tech Lead',
  ];

  static const List<String> _jobTitlesPt = [
    'Desenvolvedor Frontend',
    'Desenvolvedor Backend',
    'Designer UX/UI',
    'Gerente de Produto',
    'Engenheiro DevOps',
    'Cientista de Dados',
    'Engenheiro QA',
    'Tech Lead',
  ];

  static const List<String> _departmentsEn = [
    'Technology',
    'Product',
    'Design',
    'Engineering',
    'Data',
    'Quality',
  ];

  static const List<String> _departmentsPt = [
    'Tecnologia',
    'Produto',
    'Design',
    'Engenharia',
    'Dados',
    'Qualidade',
  ];
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

  static String generateJobTitleWithoutContext(
    int userId, {
    bool isPortuguese = true,
  }) {
    final jobTitles = isPortuguese ? _jobTitlesPt : _jobTitlesEn;
    final jobIndex = userId % jobTitles.length;
    return jobTitles[jobIndex];
  }

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

  static String generateDepartmentWithoutContext(
    int userId, {
    bool isPortuguese = true,
  }) {
    final departments = isPortuguese ? _departmentsPt : _departmentsEn;
    final deptIndex = userId % departments.length;
    return departments[deptIndex];
  }

  static String generateJobInfo(BuildContext context, int userId) {
    final jobTitle = generateJobTitle(context, userId);
    final department = generateDepartment(context, userId);
    return '$jobTitle - $department';
  }

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

  static String generateBio(String firstName) {
    final faker = Faker();
    return faker.lorem.sentences(2).join(' ');
  }
}
