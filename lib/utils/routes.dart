import 'package:firebase_social_auth/views/login_screen/login_page.dart';
import 'package:firebase_social_auth/views/splash_screen/splash_screen.dart';

import '../../views/home_screen/page/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'appRoutes.dart';

Map<String, Widget Function(BuildContext)> routes = {
  AppRoutes().homePage: (context) => const HomePage(),
  AppRoutes().loginPage: (context) => const LoginPage(),
  AppRoutes().splashPage: (context) => const SplashScreen(),
};
