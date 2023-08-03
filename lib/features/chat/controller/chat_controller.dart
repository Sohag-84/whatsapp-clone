import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
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
  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String receiverUserId}) {
    /// note that:
    /// ref.read ==> read onetime
    /// ref.watch ==> continuously read
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiverUserId,
            senderUser: value!,
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
    ref
        .read(userDataAuthProvider)
        .whenData((value) => chatRepository.sendFileMessage(
              context: context,
              file: file,
              receiverUserId: receiverUserId,
              senderUserData: value!,
              ref: ref,
              messageEnum: messageEnum,
            ));
  }
}
