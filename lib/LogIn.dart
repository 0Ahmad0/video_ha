import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cam/pages/CategoryScreen.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Log In"),
      ),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    label: Text('Email'),
                  ), // for the enter space
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
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      label: Text('Password'),
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
                  onPressed: signIn,
                  child: Text('Sign in'),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _email.trim(), password: _password.trim()));
        //FirebaseUser user = result.user;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CategoryScreen()));
      } catch (e) {
        print(e);
      }
    }
  }
}
