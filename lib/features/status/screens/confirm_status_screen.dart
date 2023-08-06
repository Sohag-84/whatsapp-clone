// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/colors.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = "/confirm-status-screen";

  final File file;
  const ConfirmStatusScreen({super.key, required this.file});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
