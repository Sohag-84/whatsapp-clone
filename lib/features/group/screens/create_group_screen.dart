// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/group/controller/group_controller.dart';
import 'package:whatsapp_clone/features/group/widgets/select_contacts_group.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = "/create-group-screen";
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController groupNameController = TextEditingController();

  void selectImage() async {
    image = await pickImageFromGallery(context: context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
            context: context,
            groupName: groupNameController.text.trim(),
            groupProfile: image!,
            selectedContact: ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: tabColor,
        child: Icon(Icons.done, color: Colors.white),
      ),
      appBar: AppBar(
        title: Text("Create Group"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  hintText: "Enter Group name",
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(8),
              child: Text(
                "Select Contacts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SelectContactsGroup()
          ],
        ),
      ),
    );
  }
}
