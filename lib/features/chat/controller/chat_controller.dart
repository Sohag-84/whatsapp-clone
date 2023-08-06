import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/repositories/chat_repository.dart';
import 'package:whatsapp_clone/models/chat_contact.dart';
import 'package:whatsapp_clone/models/message.dart';

final chatControllerProvider = Provider(
  (ref) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return ChatController(chatRepository: chatRepository, ref: ref);
  },
);

class ChatController {
  final ChatRepository chatRepository;
  final ProviderRef ref;

  ChatController({required this.chatRepository, required this.ref});

  ///to get chat contact list
  Stream<List<ChatContact>> chatContacts() {
    return chatRepository.getChatContacts();
  }

  ///to get chat message list
  Stream<List<Message>> chatStream({required String receiverUserId}) {
    return chatRepository.getChatStream(receiverUserId: receiverUserId);
  }

  ///For send send message
  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
  }) {
    /// note that:
    /// ref.read ==> read onetime
    /// ref.watch ==> continuously read

    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
          ),
        );
  }

  ///For file message like-->audio,video,gif etc
  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required MessageEnum messageEnum,
  }) {
    final messageReply = ref.read(messageReplyProvider);
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              receiverUserId: receiverUserId,
              senderUserData: value!,
              ref: ref,
              messageEnum: messageEnum,
              messageReply: messageReply,
            ));
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String receiverUserId,
  }) {
    final messageReply = ref.read(messageReplyProvider);

    /// we have to convert url:
    ///Main url==> https://giphy.com/gifs/happy-dinosally-dino-ehxq3SFXUxvtK2qDFs to==>
    ///converted Url ==> https://i.giphy.com/media/ehxq3SFXUxvtK2qDFs/200.gif
    ///if you don't convert the gif message url you can't show the gif message
    int gifUrlPartIndex = gifUrl.lastIndexOf("-") + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = "https://i.giphy.com/media/$gifUrlPart/200.gif";
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendGIFMessage(
            context: context,
            gifUrl: newGifUrl,
            receiverUserId: receiverUserId,
            senderUser: value!,
            messageReply: messageReply,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  ///for message seen functionality
  void setChatMessageSeen({
    required BuildContext context,
    required String receiverUserId,
    required String messageId,
  }) {
    chatRepository.setChatMessageSeen(
      context: context,
      receiverUserId: receiverUserId,
      messageId: messageId,
    );
  }
}
