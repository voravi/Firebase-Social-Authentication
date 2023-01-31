import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_social_auth/providers/internet_provider.dart';
import 'package:firebase_social_auth/providers/sign_in_provider.dart';
import 'package:provider/provider.dart';
import '/utils/appRoutes.dart';
import '/utils/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignInProvider()),
        ChangeNotifierProvider(create: (context) => InternetProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Authentication App",
        //home: HomePage(),
        initialRoute: AppRoutes().splashPage,
        routes: routes,
      ),
    );
  }
}
