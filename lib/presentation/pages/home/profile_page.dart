import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/home/components/profile_image.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isLogin.value)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Get.dialog(AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          isLogin.value = false;
                          Fluttertoast.showToast(msg: 'Logout success!');
                          Get.back();
                        },
                        child: const Text('Logout',
                            style: TextStyle(color: Colors.red))),
                  ],
                ));
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfileImage(
              imageSize: 75,
            ),
            const SizedBox(height: 10),
            Text(
              user?.displayName ?? 'Guest',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user?.email ?? 'No email provided',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            Text(
              user?.phoneNumber ?? 'No phone number provided',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Name: ${user?.displayName ?? 'Guest'}'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text('Email: ${user?.email ?? 'No email provided'}'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(
                  'Phone Number: ${user?.phoneNumber ?? 'No phone number provided'}'),
            ),

            // ListTile(
            //   leading: const Icon(Icons.history),
            //   title: const Text('View Activity'),
            //   onTap: () {
            //     // Navigate to activity page
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.security),
            //   title: const Text('Privacy Settings'),
            //   onTap: () {
            //     // Navigate to privacy settings page
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
