import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/chat_contact.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});

  _saveDataToContactsSubCollection({
    required UserModel senderUserData,
    required UserModel receiverUserData,
    required String text,
    required DateTime timeSent,
    required String receiverUserId,
  }) async {
    ///1.-->contact chat sub-collection hint
    ///to solve stream data error
    ///1-> request sent==>users --> receiver user id ==>chats(collection name)--> current user id --> set data
    ///2-> request sent==>users --> current user id ==>chats(collection name)--> receiver user id --> set data
    ///1-->this will help us to see message
    ///2--> this helps others to see message

    /// note that: ==> auth.currentUser!.uid --> means sender id
    ///--> --> --> --> --> --> ==> ==> --> --> --> --> --> -->

    ///first create receiver user id:-->helps receiver to show sender msg
    ///1-> request sent==>users --> receiver user id ==>chats(collection name)--> current user id --> set data
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection("users")
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(receiverChatContact.toMap());

    ///now create current user id: --> opposite of receiver
    ///2-> request sent==>users --> current user id ==>chats(collection name)--> receiver user id --> set data
    var senderChatContact = ChatContact(
      name: receiverUserData.name,
      profilePic: receiverUserData.profilePic,
      contactId: receiverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .set(senderChatContact.toMap());
  }

  /// after save chat sub-collection now we need to save data in message sub-collection
  void _saveMessageToMessageSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String receiverUsername,
    required MessageEnum messageType,
  }) async {
    ///2--> message sub-collection
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );

    /// -->to show message from sender side
    ///users-->sender id-->chats(collection)-->receiver id-->messages(collection name)--> message id-->store user sending message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('message')
        .doc(messageId)
        .set(message.toMap());

    /// -->to show message in receiver side
    ///users-->receiver id-->chats(collection)-->sender id-->messages(collection name)--> message id-->store user sending message
    await firestore
        .collection('users')
        .doc(receiverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('message')
        .doc(messageId)
        .set(message.toMap());
  }

  ///store message folder:
  ///users-->sender id-->receiver id-->messages(collection name)--> message id-->store user sending message
  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserModel senderUser,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel receiverUserData;

      var userDataMap =
          await firestore.collection('users').doc(receiverUserId).get();
      receiverUserData = UserModel.fromMap(userDataMap.data()!);

      ///create message id:
      var messageId = const Uuid().v1();

      ///save data in two collection
      ///1.-->contact chat sub-collection
      ///hints for number one collection:
      ///users --> receiver user id ==>chats(collection name)--> current user id --> set data
      ///2. --> message sub-collection
      ///hints for number two collection:
      ///users-->sender id-->receiver id-->messages(collection name)--> message id-->store user sending message
      ///--> --> --> --> --> --> ==> ==> --> --> --> --> --> -->

      ///we should to save data in contact sub-collection
      ///1.-->contact chat sub-collection
      _saveDataToContactsSubCollection(
        senderUserData: senderUser,
        receiverUserData: receiverUserData,
        text: text,
        timeSent: timeSent,
        receiverUserId: receiverUserId,
      );

      ///now we should to save data in message sub-collection
      ///1.-->message sub-collection

      _saveMessageToMessageSubCollection(
        receiverUserId: receiverUserId,
        text: text,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUser.name,
        receiverUsername: receiverUserData.name,
        messageType: MessageEnum.text,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
