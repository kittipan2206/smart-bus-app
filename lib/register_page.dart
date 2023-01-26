import 'package:flutter/material.dart';
// firebase auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
// flutter toast
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_bus/main.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final EmailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  var obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                        Text('Driver Name',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text('Contact Details',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        Divider(),
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
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: TextFormField(
                        //     controller: phoneController,
                        //     decoration: const InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       labelText: 'Phone',
                        //     ),
                        //     validator: (value) {
                        //       if (value == null || value.isEmpty) {
                        //         return 'Please enter phone';
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: TextFormField(
                        //     controller: addressController,
                        //     decoration: const InputDecoration(
                        //       border: OutlineInputBorder(),
                        //       labelText: 'Address',
                        //     ),
                        //     validator: (value) {
                        //       if (value == null || value.isEmpty) {
                        //         return 'Please enter address';
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // register user
                                try {
                                  FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: EmailController.text,
                                          password: passwordController.text)
                                      .then((value) {
                                    // set user data
                                    value.user!.updateDisplayName(
                                        '${firstNameController.text} ${lastNameController.text}');

                                    // show toast
                                    Fluttertoast.showToast(
                                        msg: 'Register success',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    // // navigate to login page
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
                                  });
                                } on FirebaseAuthException catch (e) {
                                  // show toast
                                  Fluttertoast.showToast(
                                      msg: e.message.toString(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
