class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;

    return 'http://localhost:8000/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static const String trendingProducts = '/products/trending';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String avatarUpload = '/auth/avatar';
  static const String avatarDelete = '/auth/avatar';
}
