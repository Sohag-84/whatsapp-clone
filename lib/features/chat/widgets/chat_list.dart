// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/models/message.dart';

import 'my_message_card.dart';
import 'sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverUserid;
  const ChatList({Key? key, required this.receiverUserid}) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  ///to reply message
  void onMessageSwipe({
    required String message,
    required bool isMe,
    required MessageEnum messageEnum,
  }) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(message, isMe, messageEnum),
        );
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref
          .read(chatControllerProvider)
          .chatStream(receiverUserId: widget.receiverUserid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loader();
        }

        ///for auto scrolling
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat('h:mm a').format(messageData.timeSent);

            if (!messageData.isSeen &&
                messageData.receiverId ==
                    FirebaseAuth.instance.currentUser!.uid) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                    context: context,
                    receiverUserId: widget.receiverUserid,
                    messageId: messageData.messageId,
                  );
            }

            if (messageData.senderId ==
                FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text.toString(),
                date: timeSent.toString(),
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onLeftSwipe: () => onMessageSwipe(
                  message: messageData.text,
                  isMe: true,
                  messageEnum: messageData.type,
                ),
                isSeen: messageData.isSeen,
              );
            }
            return SenderMessageCard(
              message: messageData.text.toString(),
              date: timeSent.toString(),
              type: messageData.type,
              repliedText: messageData.repliedMessage,
              username: messageData.repliedTo,
              repliedMessageType: messageData.repliedMessageType,
              onRightSwipe: () => onMessageSwipe(
                message: messageData.text,
                isMe: false,
                messageEnum: messageData.type,
              ),
            );
          },
        );
      },
    );
  }
}
