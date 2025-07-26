class AppConstants {
  static const String appName = 'TeamUp';
  static const String baseUrl = 'https://reqres.in/api';

  static const String usersEndpoint = '/users';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';

  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String cachedUsersKey = 'cached_users';
  static const String cachedPostsKey = 'cached_posts';

  static const int defaultPageSize = 6;

  static const Duration cacheValidDuration = Duration(hours: 24);
}
