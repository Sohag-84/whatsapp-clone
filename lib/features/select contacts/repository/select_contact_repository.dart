// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';

final selectContactRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

///to show all contact list from user device
class SelectContactRepository {
  final FirebaseFirestore firestore;
  SelectContactRepository({required this.firestore});

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    ///note that
    ///withProperties -> must be true
    ///otherwise it will print empty string
    ///if it is true it will give contacts number
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  ///for select contact from the contact list
  void selectContact(
      {required BuildContext context, required Contact selectedContact}) async {
    try {
      var userCollection = await firestore.collection("users").get();
      bool isFound = false;
      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());

        /// space replace with empty string. like " " ==> ""
        String selectedPhoneNumber =
            selectedContact.phones[0].number.replaceAll(" ", "");

        ///check selected number are register or not.
        /// if select number found in the firebase database
        /// that means this user is register.
        if (selectedPhoneNumber == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(context, MobileChatScreen.routeName,
          arguments: {
            'name':userData.name,
            'uid':userData.uid,
          },);
        }
        print("==> ==> $selectedPhoneNumber <== <==");
      }
      if (!isFound) {
        showSnackBar(
          context: context,
          content: "This number doesn't exits on this app",
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
