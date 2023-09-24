import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_bus/common/style/app_colors.dart';
import 'package:smart_bus/globals.dart';
import 'package:smart_bus/presentation/pages/home/image_viewer_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage({Key? key, this.imageSize}) : super(key: key);
  final double? imageSize;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: source);
      if (selectedImage != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: selectedImage.path,
          cropStyle: CropStyle.circle,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: Get.context!,
            ),
          ],
        );
        // File file = File(selectedImage.path);
        await _uploadImageToFirebase(File(croppedFile!.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImageToFirebase(File file) async {
    try {
      final String filePath = 'userImages/${user.value!.uid}/profileImage.jpg';

      // Uploading the image to Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(file);

      RxDouble progress = 0.0.obs;

      // Showing CircularProgressIndicator
      Get.dialog(AlertDialog(
        title: const Text('Uploading image...'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress.value != 0.0)
                  Text('${progress.value.toStringAsFixed(2)} %'),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                    value: progress.value / 100, color: AppColors.orange)
              ],
            )),
      ));

      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
        switch (taskSnapshot.state) {
          case TaskState.running:
            progress.value = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            break;
          case TaskState.success:
            final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

            // Updating the user's photoURL in Firebase Authentication
            await user.value!.updatePhotoURL(downloadUrl);
            await user.value!.reload();
            user.value = FirebaseAuth.instance.currentUser;
            Get.back();
            break;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error uploading image: $e');
      print('Error uploading image: $e');
    }
  }

  Future<void> _removeImage() async {
    try {
      final String filePath = 'userImages/${user.value!.uid}/profileImage.jpg';

      // Deleting the image from Firebase Storage
      final Reference ref = FirebaseStorage.instance.ref().child(filePath);
      await ref.delete();

      // Updating the user's photoURL in Firebase Authentication
      await user.value!.updatePhotoURL(null);
      await user.value!.reload();
      user.value = FirebaseAuth.instance.currentUser;
      Fluttertoast.showToast(msg: 'Image removed successfully!');
      Get.back();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error removing image: $e');
      print('Error removing image: $e');
    }
  }
  // final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return isLogin.value
          ? GestureDetector(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Change profile image'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.value!.photoURL != null)
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('View image'),
                            onTap: () {
                              Get.to(() => ImageViewerPage(
                                  imageUrl: user.value!.photoURL!));
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Camera'),
                          onTap: () {
                            _pickImage(ImageSource.camera);
                            // Get.back();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text('Gallery'),
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                            // Get.back();
                          },
                        ),
                        if (user.value!.photoURL != null)
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Remove current image'),
                            onTap: () {
                              _removeImage();
                              // Get.back();
                              // _removeImage();
                            },
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text('Cancel')),
                    ],
                  ),
                );
              },
              child: Obx(() => CircleAvatar(
                    radius: imageSize ?? 30,
                    backgroundImage: user.value!.photoURL != null
                        ? NetworkImage(user.value!.photoURL!)
                        : const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: imageSize != null ? imageSize! / 4 : 10,
                        backgroundColor: Colors.orange,
                        child: Icon(
                          Icons.edit,
                          size: imageSize != null ? imageSize! / 4 : 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
            )
          : CircleAvatar(
              radius: imageSize ?? 30,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            );
    });
  }
}
