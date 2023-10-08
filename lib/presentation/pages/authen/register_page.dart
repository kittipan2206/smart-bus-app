import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// firebase auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/model/bus_model.dart';
// flutter toast
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_bus/presentation/pages/home/components/profile_image.dart';
import 'package:smart_bus/presentation/pages/home/controller/bus_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  var obscureText = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String role = 'user';
  // String licensePlate = '';
  final RxList<BusModel> _busList = <BusModel>[].obs;
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
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Register',
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
                            const Text('Driver Name',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const Divider(),
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

                            const Divider(),
                            const Text('Contact Details',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  } else if (value.length < 10) {
                                    return 'Please enter valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
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
                            // select role user or driver default user dropdown
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Role',
                                ),
                                value: 'user',
                                onChanged: (value) {
                                  setState(() {
                                    role = value.toString();
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: 'user',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.black,
                                        ),
                                        Text('User'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'driver',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.directions_bus_rounded,
                                          color: Colors.black,
                                        ),
                                        Text('Driver'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (role == 'driver')
                              // add bus model
                              addBus(_busList),

                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    // register user
                                    Get.defaultDialog(
                                      barrierDismissible: false,
                                      title: 'Registering',
                                      content: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    try {
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                              email: emailController.text,
                                              password: passwordController.text)
                                          .then((value) async {
                                        // set user data
                                        await value.user!.updateDisplayName(
                                            '${firstNameController.text} ${lastNameController.text}');

                                        value.user!.sendEmailVerification();

                                        await _firestore
                                            .collection('users')
                                            .doc(value.user!.uid)
                                            .set({
                                          'roles': role,
                                          // if (role == 'driver')
                                          // 'licensePlate': licensePlate,
                                        });

                                        // await _firestore
                                        //     .collection('bus_data')
                                        //     .doc()
                                        //     .set({
                                        //   'owner': value.user!.uid,
                                        //   'bus_stop_line': '',

                                        // add multiple bus
                                        for (var bus in _busList) {
                                          await _firestore
                                              .collection('bus_data')
                                              .doc()
                                              .set({
                                            'owner': value.user!.uid,
                                            'bus_stop_line':
                                                int.parse(bus.busStopLine),
                                            'name': bus.name,
                                            'LP': bus.licensePlate,
                                          });
                                        }

                                        // show toast
                                        Fluttertoast.showToast(
                                            msg: 'Register success',
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);

                                        // login
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text)
                                            .then((value) {
                                          isLogin.value = true;
                                          user.value = value.user;
                                        });

                                        if (isLogin.value) {
                                          // listen to user info
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.value!.uid)
                                              .snapshots()
                                              .listen((event) {
                                            userInfo.value = event.data()!;
                                          });
                                        }

                                        Get.back();

                                        Get.defaultDialog(
                                          barrierDismissible: false,
                                          title: 'Profile Image',
                                          content: Column(
                                            children: [
                                              const Text(
                                                  'Please set your profile image'),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ProfileImage(
                                                imageSize: 60,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Obx(() => ElevatedButton(
                                                    onPressed: () async {
                                                      // remove image
                                                      // await _removeImage();
                                                      Get.back();
                                                      Get.back();
                                                      Get.back();
                                                    },
                                                    child: user.value!
                                                                .photoURL !=
                                                            null
                                                        ? const Text('Go Home')
                                                        : const Text('Skip'),
                                                  )),
                                            ],
                                          ),
                                        );
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      // show toast
                                      Get.back();
                                      Fluttertoast.showToast(
                                          msg: e.message.toString(),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                    // Get.back();
                                  }
                                },
                                child: const Text('Register',
                                    style: TextStyle(fontSize: 20)),
                              ),
                            ),
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

Column addBus(List<BusModel> busList) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      // add bus button
      ElevatedButton(
          onPressed: () {
            addBusDialog(rawBusList: busList);
          },
          child: const Text('Add Bus')),
      const Text('You can also add bus later',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () =>
              // listtile
              ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: busList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Expanded(
                    child: Text(
                  busList[index].name!,
                  overflow: TextOverflow.ellipsis,
                )),
                subtitle: Expanded(
                    child: Text(
                  busList[index].licensePlate!,
                  overflow: TextOverflow.ellipsis,
                )),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        addBusDialog(bus: busList[index], rawBusList: busList);
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () {
                        busList.removeWhere(
                            (element) => element.id == busList[index].id);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

void addBusDialog({BusModel? bus, required List<BusModel> rawBusList}) {
  // add bus name, license plate, line
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  String busStopLine = '';
  BusController busController = Get.put(BusController());
  final GlobalKey<FormState> formKeyBus = GlobalKey<FormState>();
  if (bus != null) {
    busNameController.text = bus.name!;
    licensePlateController.text = bus.licensePlate!;
    // _busStopLine = bus.busStopLine!;
  }
  Get.defaultDialog(
      title: 'Add Bus',
      content: Form(
        key: formKeyBus,
        child: Column(
          children: [
            TextFormField(
              controller: busNameController,
              decoration: const InputDecoration(
                labelText: 'Bus Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bus name';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Bus Stop Line',
                ),
                // value: _busStopLine,

                onChanged: (value) {
                  busStopLine = value.toString();
                },
                items: [
                  ...busController.busLineList.map((e) {
                    return DropdownMenuItem(
                      value: e['Id'],
                      child: Text(e['name']),
                    );
                  }).toList()
                ]),
            ElevatedButton(
                onPressed: () {
                  if (formKeyBus.currentState!.validate()) {
                    if (busStopLine == '') {
                      Fluttertoast.showToast(
                          msg: 'Please select bus stop line',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    }
                    if (bus != null) {
                      // delete old bus
                      rawBusList.removeWhere((element) =>
                          element.licensePlate == bus.licensePlate);
                      rawBusList.add(BusModel(
                        id: bus.id,
                        name: busNameController.text,
                        licensePlate: licensePlateController.text,
                        busStopLine: busStopLine,
                        // owner: user.value!.uid,
                        status: false,
                        onward: false,
                      ));
                      FirebaseFirestore.instance
                          .collection('bus_data')
                          .doc(bus.id)
                          .update({
                        'name': busNameController.text,
                        'LP': licensePlateController.text,
                        'bus_stop_line': int.parse(busStopLine),
                      });
                    } else {
                      rawBusList.add(BusModel(
                        id: '',
                        name: busNameController.text,
                        licensePlate: licensePlateController.text,
                        busStopLine: busStopLine,
                        // owner: user.value!.uid,
                        status: false,
                        onward: false,
                      ));
                      FirebaseFirestore.instance.collection('bus_data').add({
                        'name': busNameController.text,
                        'LP': licensePlateController.text,
                        'bus_stop_line': int.parse(busStopLine),
                        'owner': user.value!.uid,
                      }).then((value) {
                        // update document id
                        FirebaseFirestore.instance
                            .collection('bus_data')
                            .doc(value.id)
                            .update({
                          'documentId': value.id,
                        });
                      });
                    }
                  }
                  Get.back();
                },
                child: Text(bus == null ? 'Add' : 'Update')),
          ],
        ),
      ));
}
