import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_social_auth/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:twitter_login/twitter_login.dart';

class SignInProvider extends ChangeNotifier {
  bool _isSignedIn = false;

  bool get isSignIn => _isSignedIn;
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FacebookAuth facebookAuth = FacebookAuth.instance;
  TwitterLogin twitterLogin = TwitterLogin(apiKey: Config.apiKey_twitter, apiSecretKey: Config.secretKey_twitter, redirectURI: "socialauth://");
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // hasError,ErrorCode, Provider, uid, Email, name, imageUrl
  bool _hasError = false;

  bool get hasError => _hasError;

  String? _errorCode;

  String? get errorCode => _errorCode;

  String? _provider;

  String? get provider => _provider;

  String? _uid;

  String? get uid => _uid;

  String? _name;

  String? get name => _name;

  String? _email;

  String? get email => _email;

  String? _imageURL;

  String? get imageURL => _imageURL;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      try {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        //sign In With Firebase
        final User userDetails = (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageURL = userDetails.photoURL;
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "You Already Have a Account With Us";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in ";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
            break;
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signInWithTwitter() async {
    final authResult = await twitterLogin.loginV2();
    log(authResult.status.toString(),name: "Status");

    if(authResult.status == TwitterLoginStatus.loggedIn) {
      try {
        AuthCredential credential = TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);
        await firebaseAuth.signInWithCredential(credential);

        final user = authResult.user;

        // save All Data
        log("${firebaseAuth.currentUser!.email}",name: "Email");
        log("${firebaseAuth.currentUser!.phoneNumber}",name: "Email");

        _name = user!.name;
        _email = firebaseAuth.currentUser!.email ?? "demo@gmail.com";
        _imageURL = user.thumbnailImage;
        _uid = user.id.toString();
        _provider = "TWITTER";
        _hasError = false;
        notifyListeners();

      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "You Already Have a Account With Us";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in ";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
            break;
        }
      }
    } else {

      _hasError = true;
      notifyListeners();
    }

  }

  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));
    final profile = jsonDecode(graphResponse.body);
    // log(result.status.toString(),name: "Result Status");

    if (result.status == LoginStatus.success) {
      try {
        OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
        log("${credential}",name: "Cred");

        UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        log("${userCredential.user!.email}",name: "Email");

        _name = profile['name'];
        _email = profile['email'];
        _imageURL = profile['picture']['data']['url'];
        _uid = profile['id'];
        _provider = 'FACEBOOK';
        _hasError = false;
        notifyListeners();

      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode = "You Already Have a Account With Us";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in ";
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
            break;
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future getUserDataFromFireStore(uid) async {
    firebaseFirestore.collection("users").doc(uid).get().then((DocumentSnapshot snapShot) {
      _uid = snapShot['uid'];
      _name = snapShot['name'];
      _email = snapShot['email'];
      _imageURL = snapShot['image_url'];
      _provider = snapShot['provider'];
    });
  }

  Future saveDataToFireStore() async {
    final DocumentReference reference = firebaseFirestore.collection("users").doc(uid);
    await reference.set({
      "uid": _uid,
      "name": _name,
      "email": _email,
      "image_url": _imageURL,
      "provider": _provider,
    });
    notifyListeners();
  }

  Future saveDataToSharePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("name", _name!);
    prefs.setString("email", _email!);
    prefs.setString("uid", _uid!);
    prefs.setString("image_url", _imageURL!);
    prefs.setString("provider", _provider!);
    notifyListeners();
  }

  Future getDataFromSharePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _name = prefs.getString("name");
    _email = prefs.getString("email");
    _uid = prefs.getString("uid");
    _imageURL = prefs.getString("image_url");
    _provider = prefs.getString("provider");

    notifyListeners();
  }

  //check User exist Or Not in Cloud FireStore
  Future<bool> checkUserExist() async {
    DocumentSnapshot snapshot = await firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  //sign Out
  Future signOutGoogle() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();

    // clear all Info from Shared Preferences
    clearStoredData();
  }

  Future signOutFaceBook() async {
    await firebaseAuth.signOut();
    await facebookAuth.logOut();
    _isSignedIn = false;
    notifyListeners();

    // clear all Info from Shared Preferences
    clearStoredData();
  }
  Future signOut() async {
    await firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();

    // clear all Info from Shared Preferences
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void phoneNumberUser(User user,name,email) async {
    _name = name;
    _email = email;
    _imageURL = "null";
    _uid = user.phoneNumber;
    _provider = "PHONE";
    notifyListeners();
  }
}
