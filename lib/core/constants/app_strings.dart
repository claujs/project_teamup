class AppStrings {
  // App Info
  static const String appName = 'TeamUp';
  static const String appSlogan = 'Conecte-se com sua equipe';

  // Auth Screen Texts
  static const String loginTitle = 'TeamUp';
  static const String loginSubtitle = 'Conecte-se com sua equipe';
  static const String registerTitle = 'Criar Conta';
  static const String registerSubtitle = 'Junte-se à nossa equipe';

  // Form Labels
  static const String emailLabel = 'E-mail';
  static const String passwordLabel = 'Senha';
  static const String fullNameLabel = 'Nome Completo';
  static const String confirmPasswordLabel = 'Confirmar Senha';

  // Form Hints
  static const String emailHint = 'Digite seu e-mail';
  static const String passwordHint = 'Digite sua senha';
  static const String fullNameHint = 'Digite seu nome completo';
  static const String confirmPasswordHint = 'Digite sua senha novamente';

  // Validation Messages
  static const String emailRequired = 'Por favor, digite seu e-mail';
  static const String emailInvalid = 'Por favor, digite um e-mail válido';
  static const String passwordRequired = 'Por favor, digite sua senha';
  static const String fullNameRequired = 'Por favor, digite seu nome completo';
  static const String confirmPasswordRequired = 'Por favor, confirme sua senha';
  static const String passwordMismatch = 'As senhas não coincidem';
  static const String fullNameFormat = 'Por favor, digite seu nome e sobrenome';
  static const String passwordMinLength =
      'A senha deve ter pelo menos 6 caracteres';

  // Buttons
  static const String loginButton = 'Entrar';
  static const String registerButton = 'Criar Conta';
  static const String cancelButton = 'Cancelar';
  static const String confirmButton = 'Confirmar';
  static const String tryAgainButton = 'Tentar novamente';
  static const String logoutButton = 'Sair';

  // Navigation
  static const String feedTab = 'Feed';
  static const String teamTab = 'Equipe';
  static const String favoritesTab = 'Favoritos';

  // Auth Actions
  static const String noAccountQuestion = 'Não tem uma conta? ';
  static const String createAccountAction = 'Crie uma...';
  static const String hasAccountQuestion = 'Já tem uma conta? ';
  static const String loginAction = 'Faça login';

  // Credentials
  static const String savedCredentials = 'Credenciais salvas';
  static const String credentialsCleared = 'Credenciais salvas removidas';
  static const String invalidCredentials =
      'Credenciais inválidas. Cadastre-se primeiro ou use as credenciais de demonstração.';
  static const String userAlreadyExists =
      'Usuário já cadastrado com este e-mail';

  // Loading Messages
  static const String loadingPosts = 'Carregando posts...';
  static const String loadingTeam = 'Carregando equipe...';
  static const String loadingUsers = 'Carregando usuários...';
  static const String startingConversation = 'Iniciando conversa...';
  static const String connecting = 'Conectando...';

  // Error Messages for Users
  static const String errorLoadingTeam = 'Erro ao carregar equipe';

  // Status Messages
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String now = 'Agora';

  // Posts and Comments
  static const String noPostsFound = 'Nenhum post encontrado';
  static const String comments = 'Comentários:';
  static const String writeComment = 'Escreva um comentário...';
  static const String sharedBy = 'Compartilhado por';
  static const String onTeamUp = 'no TeamUp';
  static const String teamUpPost = 'Post do TeamUp';

  // Favorites
  static const String noFavoritesAdded = 'Nenhum favorito adicionado.';

  // Chat
  static const String typeMessage = 'Digite uma mensagem...';
  static const String videoCallInDevelopment =
      'Chamada de vídeo em desenvolvimento';
  static const String voiceCallInDevelopment =
      'Chamada de voz em desenvolvimento';

  // Logout Dialog
  static const String logoutTitle = 'Sair';
  static const String logoutConfirmation =
      'Tem certeza que deseja sair da aplicação?';

  // Error Messages
  static const String errorLoadingPosts = 'Erro ao carregar posts';
  static const String errorMessage = 'Erro';
  static const String genericError = 'Ocorreu um erro';

  // Time Format
  static const String hoursAgo = 'h atrás';
  static const String minutesAgo = 'm atrás';
  static const String minutesShort = 'min';
  static const String hoursShort = 'h';

  // Demo Credentials
  static const String demoEmail = 'eve.holt@reqres.in';
  static const String demoPassword = 'cityslicka';
  static const String demoToken = 'demo_user_token';
  static const String demoUserId = 'demo_user';
  static const String demoFirstName = 'Eve';
  static const String demoLastName = 'Holt';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String cachedUsersKey = 'cached_users';
  static const String cachedPostsKey = 'cached_posts';
  static const String favoritesKey = 'favorites_users';
  static const String usersBoxName = 'registered_users';
  static const String credentialsBoxName = 'saved_credentials';
  static const String credentialsKey = 'user_credentials';
  static const String localeKey = 'app_locale';

  // Local Token
  static const String localUserToken = 'local_user_token';

  // Date Format
  static const String dateFormat = 'dd/MM/yyyy';

  // Job Titles
  static const List<String> jobTitles = [
    'Desenvolvedor Frontend',
    'Desenvolvedor Backend',
    'Designer UX/UI',
    'Product Manager',
    'DevOps Engineer',
    'Data Scientist',
    'QA Engineer',
    'Tech Lead',
  ];

  // Departments
  static const List<String> departments = [
    'Tecnologia',
    'Produto',
    'Design',
    'Engenharia',
    'Dados',
    'Qualidade',
  ];

  // User Detail Screen
  static const String profile = 'Perfil';
  static const String errorLoadingProfile = 'Erro ao carregar perfil';
  static const String back = 'Voltar';
  static const String userNotFound = 'Usuário não encontrado';
  static const String emailTitle = 'E-mail';
  static const String departmentTitle = 'Departamento';
  static const String locationTitle = 'Localização';
  static const String aboutTitle = 'Sobre';
  static const String chatAction = 'Conversar';
  static const String callAction = 'Ligar';
  static const String featureInDevelopment =
      'Funcionalidade em desenvolvimento';
}
