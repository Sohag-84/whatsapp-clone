// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/repositories/common_firbase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_information_screen.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/screens/mobile_layout_screen.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  ///to get current user
  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection("users").doc(auth.currentUser?.uid).get();
    UserModel? userModel;
    if (userData.data() != null) {
      userModel = UserModel.fromMap(userData.data()!);
    }
    return userModel;
  }

  void signInWithPhone(
      {required BuildContext context, required String phoneNumber}) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          Navigator.pushNamed(context, OTPScreen.routeName,
              arguments: verificationId);
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(
        context: context,
        content: e.message.toString(),
      );
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message.toString());
    }
  }

  ///note that:
  ///user will be allow to keep the profile photo default if they want
  ///and also select image from gallery
  ///that way File is nullable
  void saveUserDataToFirebase(
      {required BuildContext context,
      required String name,
      required File? profilePic,
      required ProviderRef providerRef}) async {
    try {
      String uid = auth.currentUser!.uid;

      ///default profile photo
      String photoUrl =
          "https://gweb-research-imagen.web.app/compositional/An%20oil%20painting%20of%20a%20British%20Shorthair%20cat%20wearing%20a%20cowboy%20hat%20and%20red%20shirt%20skateboarding%20on%20a%20beach./1_.jpeg";
      if (profilePic != null) {
        photoUrl = await providerRef
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              ref: "profilePic/$uid",
              file: profilePic,
            );
      }
      UserModel userModel = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber.toString(),
        groupId: [],
      );
      await firestore.collection("users").doc(uid).set(userModel.toMap());

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MobileLayoutScreen()),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  /// to check user online or offline
  Stream<UserModel> userData({required String userId}) {
    return firestore.collection("users").doc(userId).snapshots().map(
          (event) => UserModel.fromMap(event.data()!),
        );
  }

  /// set user status:
  /// --> to set user online offline
  void setUserState({required bool isOnline}) async {
    await firestore.collection("users").doc(auth.currentUser!.uid).update({
      "isOnline": isOnline,
    });
  }
}
