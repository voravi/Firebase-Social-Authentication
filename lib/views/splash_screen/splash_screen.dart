import 'dart:async';

import 'package:firebase_social_auth/views/home_screen/page/home_screen.dart';
import 'package:firebase_social_auth/views/login_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sign_in_provider.dart';
import '../../utils/config.dart';
import '../../utils/next_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    final sp = context.read<SignInProvider>();
    super.initState();
    Timer(Duration(seconds: 2), () {
      sp.isSignIn == false
          ? nextScreen(context,const LoginPage())
          : nextScreen(context,const HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FlutterLogo(size: 150),
        ),
      ),
    );
  }
}
