// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/models/message.dart';

import '../../../widgets/my_message_card.dart';
import '../../../widgets/sender_message_card.dart';

class ChatList extends ConsumerWidget {
  final String receiverUserid;
  const ChatList({Key? key, required this.receiverUserid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Message>>(
        stream: ref
            .read(chatControllerProvider)
            .chatStream(receiverUserId: receiverUserid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loader();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              var timeSent = DateFormat('h:mm a').format(messageData.timeSent);
              if (messageData.senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return MyMessageCard(
                  message: messageData.text.toString(),
                  date: timeSent.toString(),
                );
              }
              return SenderMessageCard(
                message: messageData.text.toString(),
                date: timeSent.toString(),
              );
            },
          );
        });
  }
}
