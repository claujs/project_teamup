import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'TeamUp'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se com sua equipe'**
  String get appSlogan;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get registerButton;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'TeamUp'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se com sua equipe'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Junte-se à nossa equipe'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get dontHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Credenciais inválidas'**
  String get invalidCredentials;

  /// No description provided for @userAlreadyExists.
  ///
  /// In pt, this message translates to:
  /// **'Usuário já existe'**
  String get userAlreadyExists;

  /// No description provided for @registrationSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro realizado com sucesso'**
  String get registrationSuccess;

  /// No description provided for @feed.
  ///
  /// In pt, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @users.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get users;

  /// No description provided for @favorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @searchUsers.
  ///
  /// In pt, this message translates to:
  /// **'Buscar usuários...'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum usuário encontrado'**
  String get noUsersFound;

  /// No description provided for @noPosts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum post encontrado'**
  String get noPosts;

  /// No description provided for @noFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum favorito adicionado'**
  String get noFavorites;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @loadingUsers.
  ///
  /// In pt, this message translates to:
  /// **'Carregando usuários...'**
  String get loadingUsers;

  /// No description provided for @loadingPosts.
  ///
  /// In pt, this message translates to:
  /// **'Carregando posts...'**
  String get loadingPosts;

  /// No description provided for @loadingProfile.
  ///
  /// In pt, this message translates to:
  /// **'Carregando perfil...'**
  String get loadingProfile;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @refresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get refresh;

  /// No description provided for @addToFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar aos Favoritos'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos Favoritos'**
  String get removeFromFavorites;

  /// No description provided for @viewProfile.
  ///
  /// In pt, this message translates to:
  /// **'Ver Perfil'**
  String get viewProfile;

  /// No description provided for @sendMessage.
  ///
  /// In pt, this message translates to:
  /// **'Enviar Mensagem'**
  String get sendMessage;

  /// No description provided for @jobTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cargo'**
  String get jobTitle;

  /// No description provided for @department.
  ///
  /// In pt, this message translates to:
  /// **'Departamento'**
  String get department;

  /// No description provided for @biography.
  ///
  /// In pt, this message translates to:
  /// **'Biografia'**
  String get biography;

  /// No description provided for @joined.
  ///
  /// In pt, this message translates to:
  /// **'Entrou em'**
  String get joined;

  /// No description provided for @online.
  ///
  /// In pt, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In pt, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @like.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In pt, this message translates to:
  /// **'Comentar'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @comments.
  ///
  /// In pt, this message translates to:
  /// **'Comentários'**
  String get comments;

  /// No description provided for @writeComment.
  ///
  /// In pt, this message translates to:
  /// **'Escrever comentário...'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get send;

  /// No description provided for @chat.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @typeMessage.
  ///
  /// In pt, this message translates to:
  /// **'Digite uma mensagem...'**
  String get typeMessage;

  /// No description provided for @noInternetConnection.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a internet'**
  String get noInternetConnection;

  /// No description provided for @workingOffline.
  ///
  /// In pt, this message translates to:
  /// **'Trabalhando offline'**
  String get workingOffline;

  /// No description provided for @connectionRestored.
  ///
  /// In pt, this message translates to:
  /// **'Conexão restaurada'**
  String get connectionRestored;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @fullNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome Completo'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Senha'**
  String get confirmPasswordLabel;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu e-mail'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha'**
  String get passwordHint;

  /// No description provided for @fullNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu nome completo'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha novamente'**
  String get confirmPasswordHint;

  /// No description provided for @emailRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite seu e-mail'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite um e-mail válido'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite sua senha'**
  String get passwordRequired;

  /// No description provided for @fullNameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite seu nome completo'**
  String get fullNameRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme sua senha'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem'**
  String get passwordMismatch;

  /// No description provided for @fullNameFormat.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite seu nome e sobrenome'**
  String get fullNameFormat;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @cancelButton.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirmButton;

  /// No description provided for @tryAgainButton.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgainButton;

  /// No description provided for @logoutButton.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logoutButton;

  /// No description provided for @feedTab.
  ///
  /// In pt, this message translates to:
  /// **'Feed'**
  String get feedTab;

  /// No description provided for @teamTab.
  ///
  /// In pt, this message translates to:
  /// **'Equipe'**
  String get teamTab;

  /// No description provided for @favoritesTab.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favoritesTab;

  /// No description provided for @noAccountQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta? '**
  String get noAccountQuestion;

  /// No description provided for @createAccountAction.
  ///
  /// In pt, this message translates to:
  /// **'Crie uma...'**
  String get createAccountAction;

  /// No description provided for @hasAccountQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta? '**
  String get hasAccountQuestion;

  /// No description provided for @loginAction.
  ///
  /// In pt, this message translates to:
  /// **'Faça login'**
  String get loginAction;

  /// No description provided for @savedCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Credenciais salvas'**
  String get savedCredentials;

  /// No description provided for @credentialsCleared.
  ///
  /// In pt, this message translates to:
  /// **'Credenciais salvas removidas'**
  String get credentialsCleared;

  /// No description provided for @invalidCredentialsDetailed.
  ///
  /// In pt, this message translates to:
  /// **'Credenciais inválidas. Cadastre-se primeiro ou use as credenciais de demonstração.'**
  String get invalidCredentialsDetailed;

  /// No description provided for @userAlreadyExistsDetailed.
  ///
  /// In pt, this message translates to:
  /// **'Usuário já cadastrado com este e-mail'**
  String get userAlreadyExistsDetailed;

  /// No description provided for @loadingTeam.
  ///
  /// In pt, this message translates to:
  /// **'Carregando equipe...'**
  String get loadingTeam;

  /// No description provided for @startingConversation.
  ///
  /// In pt, this message translates to:
  /// **'Iniciando conversa...'**
  String get startingConversation;

  /// No description provided for @connecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando...'**
  String get connecting;

  /// No description provided for @errorLoadingTeam.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar equipe'**
  String get errorLoadingTeam;

  /// No description provided for @now.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get now;

  /// No description provided for @noPostsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum post encontrado'**
  String get noPostsFound;

  /// No description provided for @commentsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Comentários:'**
  String get commentsLabel;

  /// No description provided for @writeCommentHint.
  ///
  /// In pt, this message translates to:
  /// **'Escreva um comentário...'**
  String get writeCommentHint;

  /// No description provided for @sharedBy.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhado por'**
  String get sharedBy;

  /// No description provided for @onTeamUp.
  ///
  /// In pt, this message translates to:
  /// **'no TeamUp'**
  String get onTeamUp;

  /// No description provided for @teamUpPost.
  ///
  /// In pt, this message translates to:
  /// **'Post do TeamUp'**
  String get teamUpPost;

  /// No description provided for @noFavoritesAdded.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum favorito adicionado.'**
  String get noFavoritesAdded;

  /// No description provided for @videoCallInDevelopment.
  ///
  /// In pt, this message translates to:
  /// **'Chamada de vídeo em desenvolvimento'**
  String get videoCallInDevelopment;

  /// No description provided for @voiceCallInDevelopment.
  ///
  /// In pt, this message translates to:
  /// **'Chamada de voz em desenvolvimento'**
  String get voiceCallInDevelopment;

  /// No description provided for @logoutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair da aplicação?'**
  String get logoutConfirmation;

  /// No description provided for @errorLoadingPosts.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar posts'**
  String get errorLoadingPosts;

  /// No description provided for @errorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get errorMessage;

  /// No description provided for @genericError.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro'**
  String get genericError;

  /// No description provided for @hoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'h atrás'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'m atrás'**
  String get minutesAgo;

  /// No description provided for @minutesShort.
  ///
  /// In pt, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @hoursShort.
  ///
  /// In pt, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar perfil'**
  String get errorLoadingProfile;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @userNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Usuário não encontrado'**
  String get userNotFound;

  /// No description provided for @emailTitle.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailTitle;

  /// No description provided for @departmentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Departamento'**
  String get departmentTitle;

  /// No description provided for @locationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get locationTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get aboutTitle;

  /// No description provided for @chatAction.
  ///
  /// In pt, this message translates to:
  /// **'Conversar'**
  String get chatAction;

  /// No description provided for @callAction.
  ///
  /// In pt, this message translates to:
  /// **'Ligar'**
  String get callAction;

  /// No description provided for @featureInDevelopment.
  ///
  /// In pt, this message translates to:
  /// **'Funcionalidade em desenvolvimento'**
  String get featureInDevelopment;

  /// No description provided for @jobTitleFrontend.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvedor Frontend'**
  String get jobTitleFrontend;

  /// No description provided for @jobTitleBackend.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvedor Backend'**
  String get jobTitleBackend;

  /// No description provided for @jobTitleUxUi.
  ///
  /// In pt, this message translates to:
  /// **'Designer UX/UI'**
  String get jobTitleUxUi;

  /// No description provided for @jobTitleProductManager.
  ///
  /// In pt, this message translates to:
  /// **'Product Manager'**
  String get jobTitleProductManager;

  /// No description provided for @jobTitleDevOps.
  ///
  /// In pt, this message translates to:
  /// **'DevOps Engineer'**
  String get jobTitleDevOps;

  /// No description provided for @jobTitleDataScientist.
  ///
  /// In pt, this message translates to:
  /// **'Data Scientist'**
  String get jobTitleDataScientist;

  /// No description provided for @jobTitleQa.
  ///
  /// In pt, this message translates to:
  /// **'QA Engineer'**
  String get jobTitleQa;

  /// No description provided for @jobTitleTechLead.
  ///
  /// In pt, this message translates to:
  /// **'Tech Lead'**
  String get jobTitleTechLead;

  /// No description provided for @departmentTech.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologia'**
  String get departmentTech;

  /// No description provided for @departmentProduct.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get departmentProduct;

  /// No description provided for @departmentDesign.
  ///
  /// In pt, this message translates to:
  /// **'Design'**
  String get departmentDesign;

  /// No description provided for @departmentEngineering.
  ///
  /// In pt, this message translates to:
  /// **'Engenharia'**
  String get departmentEngineering;

  /// No description provided for @departmentData.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get departmentData;

  /// No description provided for @departmentQuality.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade'**
  String get departmentQuality;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @position.
  ///
  /// In pt, this message translates to:
  /// **'Cargo'**
  String get position;

  /// No description provided for @advancedFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtro Avançado'**
  String get advancedFilter;

  /// No description provided for @searchByName.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome...'**
  String get searchByName;

  /// No description provided for @searchByEmail.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por email...'**
  String get searchByEmail;

  /// No description provided for @searchByDepartment.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por departamento...'**
  String get searchByDepartment;

  /// No description provided for @searchByPosition.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por cargo...'**
  String get searchByPosition;

  /// No description provided for @clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get apply;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
