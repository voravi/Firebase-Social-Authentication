import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_social_auth/providers/internet_provider.dart';
import 'package:firebase_social_auth/providers/sign_in_provider.dart';
import 'package:firebase_social_auth/utils/next_screen.dart';
import 'package:firebase_social_auth/utils/snack_bar.dart';
import 'package:firebase_social_auth/views/home_screen/page/home_screen.dart';
import 'package:firebase_social_auth/views/login_screen/phone_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:provider/provider.dart';
import '../../utils/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  RoundedLoadingButtonController faceBookController = RoundedLoadingButtonController();
  RoundedLoadingButtonController twitterController = RoundedLoadingButtonController();
  RoundedLoadingButtonController phoneAuthController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 90, bottom: 30),
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlutterLogo(
                      size: 90,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Welcome to FlutterFirebase",
                      style: TextStyle(fontSize: 23, color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Learn Authentication with Provider",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.redAccent,
                    successColor: Colors.redAccent,
                    controller: googleController,
                    onPressed: () {
                      handleGoogleSignIn();
                    },
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Sign in with Google",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.blue,
                    successColor: Colors.blue,
                    controller: faceBookController,
                    onPressed: () {
                      handleFacebookSignIn();
                    },
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.facebook,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Sign in with Facebook",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.lightBlue,
                    successColor: Colors.lightBlue,
                    controller: twitterController,
                    onPressed: () {
                      handleTwitterSignIn();
                    },
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.twitter,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Continue with Twitter",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RoundedLoadingButton(
                    width: MediaQuery.of(context).size.width * 0.80,
                    elevation: 0,
                    borderRadius: 25,
                    color: Colors.black,
                    successColor: Colors.black,
                    controller: phoneAuthController,
                    onPressed: () {
                      nextScreenReplace(context,const PhoneAuthScreen());
                      phoneAuthController.reset();
                    },
                    child: Wrap(
                      children: const [
                        Icon(
                          FontAwesomeIcons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Sign in with Phone",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future handleTwitterSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check Your Internet Connection", Colors.redAccent);
      twitterController.reset();
    } else {
      await sp.signInWithTwitter().then(
            (value) {
          if (sp.hasError == true) {
            openSnackBar(context, sp.errorCode.toString(), Colors.redAccent);
            twitterController.reset();
          } else {
            //checking User Exist Or not
            sp.checkUserExist().then(
                  (value) async {
                if (value == true) {
                  // user exist
                  await sp.getUserDataFromFireStore(sp.uid).then(
                        (value) => sp.saveDataToSharePreference().then(
                          (value) => sp.setSignIn().then(
                            (value) {
                          twitterController.success();
                          handleAfterSignIn();
                        },
                      ),
                    ),
                  );
                } else {
                  //user don't exist
                  await sp.saveDataToFireStore().then(
                        (value) => sp.saveDataToSharePreference().then(
                          (value) => sp.setSignIn().then(
                            (value) {
                          twitterController.success();
                          handleAfterSignIn();
                        },
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      );
    }
  }

  // handing google Sign-In
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check Your Internet Connection", Colors.redAccent);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then(
        (value) {
          if (sp.hasError == true) {
            openSnackBar(context, sp.errorCode.toString(), Colors.redAccent);
            googleController.reset();
          } else {
            //checking User Exist Or not
            sp.checkUserExist().then(
              (value) async {
                if (value == true) {
                  // user exist
                  await sp.getUserDataFromFireStore(sp.uid).then(
                        (value) => sp.saveDataToSharePreference().then(
                              (value) => sp.setSignIn().then(
                                    (value) {
                                      googleController.success();
                                      handleAfterSignIn();
                                    },
                                  ),
                            ),
                      );
                } else {
                  //user don't exist
                  await sp.saveDataToFireStore().then(
                        (value) => sp.saveDataToSharePreference().then(
                              (value) => sp.setSignIn().then(
                                (value) {
                                  googleController.success();
                                  handleAfterSignIn();
                                },
                              ),
                            ),
                      );
                }
              },
            );
          }
        },
      );
    }
  }

  //handling Facebook Sign-In
  Future handleFacebookSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check Your Internet Connection", Colors.redAccent);
      faceBookController.reset();
    } else {
      await sp.signInWithFacebook().then(
            (value) {
          if (sp.hasError == true) {
            openSnackBar(context, sp.errorCode.toString(), Colors.redAccent);
            log("Error is Here",name: "Error");
            faceBookController.reset();
          } else {
            //checking User Exist Or not
            sp.checkUserExist().then(
                  (value) async {
                if (value == true) {
                  // user exist
                  await sp.getUserDataFromFireStore(sp.uid).then(
                        (value) => sp.saveDataToSharePreference().then(
                          (value) => sp.setSignIn().then(
                            (value) {
                          faceBookController.success();
                          handleAfterSignIn();
                        },
                      ),
                    ),
                  );
                } else {
                  //user don't exist
                  await sp.saveDataToFireStore().then(
                        (value) => sp.saveDataToSharePreference().then(
                          (value) => sp.setSignIn().then(
                            (value) {
                              faceBookController.success();
                          handleAfterSignIn();
                        },
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      );
    }
  }

  handleAfterSignIn() async {
    Future.delayed(Duration(milliseconds: 200)).then(
      (value) {
        nextScreenReplace(context, const HomePage());
      },
    );
  }
}
