class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;

    // Default: Android emulator localhost
    return 'http://10.0.2.2:8000/api';
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
}
