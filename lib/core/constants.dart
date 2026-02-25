class AppConstants {
  const AppConstants._();

  static const String appName = 'Scroll';
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'cached_user';

  static const double bannerExpandedHeight = 220;
  static const double pinnedTabBarHeight = 52;

  static const List<String> productTabs = [
    'All',
    'Men',
    'Women',
  ];

  static const List<String> menCategories = [
    "men's clothing",
  ];

  static const List<String> womenCategories = [
    "women's clothing",
  ];
}
