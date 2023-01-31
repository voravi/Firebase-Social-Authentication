import 'package:firebase_social_auth/providers/sign_in_provider.dart';
import 'package:firebase_social_auth/utils/next_screen.dart';
import 'package:firebase_social_auth/views/login_screen/login_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharePreference();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: (sp.imageURL == null) ? null : NetworkImage("${sp.imageURL}"),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Welcome ${sp.name}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${sp.email}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${sp.uid}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("PROVIDER: "),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "${sp.provider}".toUpperCase(),
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (sp.provider == "GOOGLE") {
                  sp.signOutGoogle();
                } else if(sp.provider == "FACEBOOK") {
                  sp.signOutFaceBook();
                } else if(sp.provider == "TWITTER") {
                  sp.signOut();
                } else {
                  sp.signOut();
                }
                nextScreenReplace(context, const LoginPage());
              },
              child: Text(
                "SIGNOUT",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
