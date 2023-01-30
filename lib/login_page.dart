import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/register_page.dart';

import 'main.dart';
// firebase auth
import 'package:firebase_auth/firebase_auth.dart';
// google sign in
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final formEmailKey = GlobalKey<FormState>();
  final EmailController = TextEditingController();
  final passwordController = TextEditingController();
  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Card(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Sign in',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: EmailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  } else if (!value.contains('@')) {
                                    return 'Please enter valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                obscureText: obscureText,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    try {
                                      await auth
                                          .signInWithEmailAndPassword(
                                              email: EmailController.text,
                                              password: passwordController.text)
                                          .then((value) async {
                                        Fluttertoast.showToast(
                                            msg: 'Login success',
                                            backgroundColor: Colors.green,
                                            webBgColor: '#00FF00');
                                        // navigate to home page
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyHomePage(
                                                      title: 'Smart Bus',
                                                    )));
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      Fluttertoast.showToast(
                                          msg: e.message.toString());
                                    }
                                  }
                                },
                                child: const Text('Sign in',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            // go to register page
                            TextButton(
                              onPressed: () {
                                // Forgot password dialog
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Forgot password?'),
                                        // input email
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Form(
                                              key: formEmailKey,
                                              child: TextFormField(
                                                // title: 'Email',
                                                controller: EmailController,
                                                decoration:
                                                    const InputDecoration(
                                                  suffixIcon: Icon(Icons.email),
                                                  labelText: 'Enter your email',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter email';
                                                  } else if (!value
                                                      .contains('@')) {
                                                    return 'Please enter valid email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        actions: [
                                          // cancel button
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // check validation
                                              if (!formEmailKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              try {
                                                // send email
                                                FirebaseAuth auth =
                                                    FirebaseAuth.instance;
                                                await auth
                                                    .sendPasswordResetEmail(
                                                        email: EmailController
                                                            .text);
                                                Fluttertoast.showToast(
                                                    msg: 'Email sent');
                                                Navigator.pop(context);
                                                // show already sent dialog
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Email already sent'),
                                                        content: const Text(
                                                            'Please check your email to reset password'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              } on FirebaseAuthException catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: e.message.toString(),
                                                    backgroundColor: Colors.red,
                                                    timeInSecForIosWeb: 3,
                                                    webBgColor:
                                                        '#e74c3c'); // red color
                                              }
                                            },
                                            child: const Text('Send'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Stack(
                              children: [
                                Divider(
                                    // color: Colors.black,
                                    ),
                                Center(
                                    child: Container(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: Text('OR'),
                                  ),
                                  color: Colors.white,
                                )),
                              ],
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueGrey),
                                // minimumSize: MaterialStateProperty.all<Size>(
                                //     Size(100, 50)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterPage()));
                              },
                              child: const Text('Register'),
                            ),
                            ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  foregroundColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.black),
                                ),
                                onPressed: () {},
                                icon: const Icon(Icons.login),
                                label: const Text('Sign in with Google')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
