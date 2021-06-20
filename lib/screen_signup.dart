import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScreenSignUp extends StatefulWidget {
  const ScreenSignUp({Key? key}) : super(key: key);

  @override
  _ScreenSignUpState createState() => _ScreenSignUpState();
}

class _ScreenSignUpState extends State<ScreenSignUp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _name, _email, _password;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  signUp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: _email!, password: _password!);

      await _auth.currentUser!.updateDisplayName(_name);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                    validator: (input) {
                      if (input!.isEmpty) return 'Enter Name';
                    },
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onSaved: (input) => _name = input),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signUp,
                  child: Text('SignUp'),
                ),
              ],
            ),
          ),
        ));
  }
}
