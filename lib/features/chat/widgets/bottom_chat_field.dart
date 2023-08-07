// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/message_reply_preview.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiverUserid;
  final bool isGroupChat;
  const BottomChatField({
    super.key,
    required this.receiverUserid,
    required this.isGroupChat,
  });

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShownSendButton = false;
  final msgController = TextEditingController();
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  ///for audio message
  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShownSendButton) {
      ref.read(chatControllerProvider).sendTextMessage(
            context: context,
            text: msgController.text.trim(),
            receiverUserId: widget.receiverUserid,
            isGroupChat: widget.isGroupChat,
          );
      setState(() {
        msgController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();

        ///after stop the recording we should to send it
        sendFileMessage(file: File(path), messageEnum: MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage({required File file, required MessageEnum messageEnum}) {
    ref.read(chatControllerProvider).sendFileMessage(
          context: context,
          file: file,
          receiverUserId: widget.receiverUserid,
          messageEnum: messageEnum,
          isGroupChat: widget.isGroupChat,
        );
  }

  ///to pick image
  void selectImage() async {
    File? image = await pickImageFromGallery(context: context);
    if (image != null) {
      sendFileMessage(file: image, messageEnum: MessageEnum.image);
    }
  }

  ///to pick video
  void selectVideo() async {
    File? video = await pickVideoFromGallery(context: context);
    if (video != null) {
      sendFileMessage(file: video, messageEnum: MessageEnum.video);
    }
  }

  ///to pick GIF
  void selectGIF() async {
    GiphyGif? gif = await pickGIF(
      context: context,
    );
    if (gif != null) {
      ref.read(chatControllerProvider).sendGIFMessage(
            context: context,
            gifUrl: gif.url,
            receiverUserId: widget.receiverUserid,
            isGroupChat: widget.isGroupChat,
          );
    }
  }

  /// to hide emoji keyboard
  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  /// to show emoji keyboard
  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  ///--> if keyboard is open then emoji will be hide
  ///--> if emoji is open then keyboard will be hide
  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    msgController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);

    ///if the messageReply is null its show isShowMessageReply = false
    ///if isShowMessageReply is null we won't show that container
    ///otherwise we show a container
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? MessageReplyPreview() : SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: msgController,
                focusNode: focusNode,
                onChanged: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() {
                      isShownSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShownSendButton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: toggleEmojiKeyboardContainer,
                          icon: Icon(
                            Icons.emoji_emotions,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectGIF,
                          icon: Icon(
                            Icons.gif,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 8,
                right: 2,
                left: 2,
              ),
              child: CircleAvatar(
                backgroundColor: Color(0xFF128C7E),
                radius: 20,
                child: InkWell(
                  onTap: sendTextMessage,
                  child: Icon(
                    isShownSendButton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      msgController.text = msgController.text + emoji.emoji;
                    });
                    if (!isShownSendButton) {
                      setState(() {
                        isShownSendButton = true;
                      });
                    }
                  }),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
