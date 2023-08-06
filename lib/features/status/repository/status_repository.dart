import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repositories/common_firbase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/status_model.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus({
    required BuildContext context,
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            ref: "/status/$statusId$uid",
            file: statusImage,
          );

      ///for list of contacts
      List<Contact> contacts = [];

      ///note that
      ///withProperties -> must be true
      ///otherwise it will print empty string
      ///if it is true it will give contacts number
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      ///List of contact for who can see your status
      List<String> uidWhoCanSee = [];
      for (int i = 0; i < contacts.length; i++) {
        var userDataFirebase = await firestore
            .collection("users")
            .where(
              "phoneNumber",
              isEqualTo: contacts[i].phones[0].number.replaceAll(" ", ""),
            )
            .get();
        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
      }

      List<String> statusImageUrlList = [];

      ///now check user status already exits or not
      ///fetched only status which status are create 24 hours ago
      var statusesSnapshot = await firestore
          .collection("status")
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();

      ///if status already posted
      ///another post will be add in the previous list
      ///otherwise show only one image or status
      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrlList = status.photoUrl;

        ///add new status image url
        statusImageUrlList.add(imageUrl);

        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update(
          {'photoUrl': statusImageUrlList},
        );
        return;
      } else {
        ///user only added first time status on their phone
        statusImageUrlList = [imageUrl];
      }
      Status status = Status(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrlList,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      ///now store the status in the firebase
      firestore.collection("status").doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  ///get status
  Future<List<Status>> getStatus({required BuildContext context}) async {
    List<Status> statusData = [];
    try {
      ///for list of contacts
      ///note that
      ///withProperties -> must be true
      ///otherwise it will print empty string
      ///if it is true it will give contacts number
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      ///fetched only status which status are created 24 hours ago
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await firestore
            .collection("status")
            .where(
              "phoneNumber",
              isEqualTo: contacts[i].phones[0].number.replaceAll(" ", ""),
            )
            .where(
              'createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch,
            )
            .get();

        ///whose saved your contact only those person can
        ///show the status/stories
        for (var tempData in statusesSnapshot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }
}
