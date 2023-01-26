import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
// import firebase auth
import "package:firebase_auth/firebase_auth.dart";

class DriverPage extends StatefulWidget {
  const DriverPage({Key? key}) : super(key: key);

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver'),
      ),
      body: const Center(
        child: Text('Driver'),
      ),
    );
  }
}
