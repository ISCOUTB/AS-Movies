import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/discover_page.dart';
import '../pages/categories_page.dart';
import '../pages/search_page.dart';
import '../pages/profile_page.dart';
import '../login.dart';
import '../main.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String categories = '/categories';
  static const String search = '/search';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    main: (context) => const MainScreen(),
    home: (context) => HomePage(),
    discover: (context) => DiscoverPage(),
    categories: (context) => CategoriesPage(),
    search: (context) => SearchPage(),
    profile: (context) => ProfilePage(),
  };
}
