import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'screen_signup.dart';
import 'util/database.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({Key? key}) : super(key: key);

  @override
  _ScreenLoginState createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email, _password;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print(user);

        if (this.mounted) Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
  }

  login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
          email: _email!, password: _password!);

      if (user.additionalUserInfo!.isNewUser) {
        await Database.addUser(user.user!);
      }
    } catch (e) {
      print(e);
    }
  }

  navigateToSignUp() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ScreenSignUp()));
  }

  Future<UserCredential> googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);

        if (user.additionalUserInfo!.isNewUser) {
          await Database.addUser(user.user!);
        }

        await Navigator.pushReplacementNamed(context, "/");

        return user;
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else
      throw StateError('Sign in Aborted');
  }

  Future<UserCredential?> googleSignInWeb() async {
    GoogleAuthProvider authProvider = GoogleAuthProvider();

    UserCredential? googleUser;

    try {
      googleUser = await _auth.signInWithPopup(authProvider);

      if (googleUser != null) {
        if (googleUser.additionalUserInfo!.isNewUser) {
          await Database.addUser(googleUser.user!);
        }

        await Navigator.pushReplacementNamed(context, "/");
      }
    } catch (e) {
      print(e);
    }
    return googleUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                    validator: (input) {
                      if (input!.isEmpty) return 'Enter Email';
                    },
                    decoration: InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    onSaved: (input) => _email = input),
                TextFormField(
                    validator: (input) {
                      if (input!.length < 6)
                        return 'Provide Minimum 6 Character';
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    onSaved: (input) => _password = input),
                ElevatedButton(
                  onPressed: login,
                  child: Text('LOGIN'),
                ),
                GestureDetector(
                  child: Text('Create an Account?'),
                  onTap: navigateToSignUp,
                ),
                SignInButton(Buttons.Google,
                    text: "Sign In with Google",
                    onPressed: kIsWeb ? googleSignInWeb : googleSignIn)
              ],
            ),
          ),
        ));
  }
}
