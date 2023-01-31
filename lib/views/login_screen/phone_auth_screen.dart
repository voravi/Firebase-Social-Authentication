import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_social_auth/providers/internet_provider.dart';
import 'package:firebase_social_auth/providers/sign_in_provider.dart';
import 'package:firebase_social_auth/utils/next_screen.dart';
import 'package:firebase_social_auth/utils/snack_bar.dart';
import 'package:firebase_social_auth/views/home_screen/page/home_screen.dart';
import 'package:firebase_social_auth/views/login_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            nextScreenReplace(context, const LoginPage());
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlutterLogo(
                  size: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Phone Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Name Cannot be empty";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: Icon(Icons.account_circle),
                    hintText: "Adam Smith",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email Address Cannot be empty";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: Icon(Icons.mail),
                    hintText: "example@gmail.com",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: phoneController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Phone Cannot be empty";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: Icon(Icons.phone),
                    hintText: "+1-1234567890",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    login(context, phoneController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future login(BuildContext context, String phone) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackBar(context, "Check Your internet connection", Colors.redAccent);
    } else {
      if (formKey.currentState!.validate()) {
        FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (AuthCredential credential) async {
            await FirebaseAuth.instance.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException exception) {
            openSnackBar(context, exception.toString(), Colors.redAccent);
          },
          codeSent: (String verificationId, int? forceResendingToken) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Enter Code"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: otpCodeController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: Icon(Icons.code),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        final code = otpCodeController.text.trim();
                        AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                        User user = (await FirebaseAuth.instance.signInWithCredential(authCredential)).user!;
                        // save the values
                        sp.phoneNumberUser(user, nameController.text, emailController.text);

                        // checking User exist or Not
                        sp.checkUserExist().then(
                              (value) async {
                            if (value == true) {
                              // user exist
                              await sp.getUserDataFromFireStore(sp.uid).then(
                                    (value) => sp.saveDataToSharePreference().then(
                                      (value) => sp.setSignIn().then(
                                        (value) {

                                      nextScreenReplace(context, const HomePage());
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
                                          nextScreenReplace(context, const HomePage());
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                      child: Text("Submit"),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Cancle"),
                    ),
                  ],
                );
              },
            );
          },
          codeAutoRetrievalTimeout: (String val) {},
        );
      }
    }
  }
}
