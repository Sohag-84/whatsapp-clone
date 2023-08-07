// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-information';
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> {
  File? image;
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context: context);
    setState(() {});
  }

  /// to store user data
  void storeUserData() async {
    String name = nameController.text.trim();
    if (name.trim().isNotEmpty) {
      ref.read(authControllerProvider).saveDataToFirebase(
            context: context,
            name: name,
            profilePic: image,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  image == null

                      ///default profile photo
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: AssetImage("assets/profile.jpeg"),
                        )

                      ///selected profile photo
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: FileImage(image!),
                        ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: Icon(Icons.add_a_photo, size: 30),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: size.width * 0.85,
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: storeUserData,
                    icon: Icon(Icons.done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
