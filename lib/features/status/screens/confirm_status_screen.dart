// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/features/status/controller/chat_controller.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = "/confirm-status-screen";

  final File file;
  const ConfirmStatusScreen({super.key, required this.file});

  void addStatus({required BuildContext context, required WidgetRef ref}) {
    ref.read(statusControllerProvider).addStatus(context: context, file: file);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => addStatus(context: context, ref: ref),
        child: Icon(
          Icons.done,
          color: Colors.white,
        ),
        backgroundColor: tabColor,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
    );
  }
}
