// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/call/screens/call_screen.dart';
import 'package:whatsapp_clone/models/call.dart';
import 'package:whatsapp_clone/models/group.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('call').doc(auth.currentUser!.uid).snapshots();

  ///for make a call
  void makeCall({
    required BuildContext context,
    required Call senderCallData,
    required Call receiverCallData,
  }) async {
    try {
      ///document for sender
      await firestore
          .collection("call")
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      ///document for receiver
      await firestore
          .collection("call")
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: senderCallData.callerId,
            call: senderCallData,
            isGroupChat: false,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  ///for make group call
  void makeGroupCall({
    required BuildContext context,
    required Call senderCallData,
    required Call receiverCallData,
  }) async {
    try {
      ///document for sender
      await firestore
          .collection("call")
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      ///get group data first
      var groupSnapshot = await firestore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();

      GroupModel groupModel = GroupModel.fromMap(groupSnapshot.data()!);

      for (var id in groupModel.membersUid) {
        ///document for receiver
        await firestore
            .collection("call")
            .doc(id)
            .set(receiverCallData.toMap());
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            channelId: senderCallData.callerId,
            call: senderCallData,
            isGroupChat: true,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  ///for end call
  void endCall({
    required BuildContext context,
    required String callerId,
    required String receiverId,
  }) async {
    try {
      ///delete document after the end call from the sender side
      await firestore.collection("call").doc(callerId).delete();

      ///delete document after the end call from the receiver side
      await firestore.collection("call").doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  ///for end call
  void endGroupCall({
    required BuildContext context,
    required String callerId,
    required String receiverId,
  }) async {
    try {
      ///delete document after the end call from the sender side
      await firestore.collection("call").doc(callerId).delete();

      ///get group data first
      var groupSnapshot =
          await firestore.collection('groups').doc(receiverId).get();

      GroupModel groupModel = GroupModel.fromMap(groupSnapshot.data()!);
      for (var id in groupModel.membersUid) {
        ///delete document after the end call from the receiver side
        await firestore.collection("call").doc(id).delete();
      }

      ///delete document after the end call from the receiver side
      await firestore.collection("call").doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
