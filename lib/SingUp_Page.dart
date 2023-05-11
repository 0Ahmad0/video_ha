import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter_cam/LogIn.dart";
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Sing Up")),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  validator: (input) {
                    if (input!.trim().isEmpty || !input.isEmail) {
                      return 'Provide an email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text('Email'),
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (input) => _email = input!,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  validator: (input) {
                    if (input!.trim().isEmpty || input!.length < 6) {
                      return 'Longer password please';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      label: Text('Password'),
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _isPassword = !_isPassword);
                        },
                        icon: Icon(_isPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      )),
                  onSaved: (input) => _password = input!,
                  obscureText: _isPassword,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: signUp,
                  child: Text('Sign up'),
                ),
              ],
            ),
          )),
    );
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } catch (e) {
        print(e);
      }
    }
  }
}
