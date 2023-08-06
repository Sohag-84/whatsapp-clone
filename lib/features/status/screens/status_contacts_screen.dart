// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/status/controller/chat_controller.dart';
import 'package:whatsapp_clone/models/status_model.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Status>>(
      future: ref.read(statusControllerProvider).getStatus(context: context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loader();
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Status statusData = snapshot.data![index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          statusData.username,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            statusData.profilePic,
                          ),
                          radius: 30,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: dividerColor, indent: 85),
                ],
              );
            },
          );
        }
      },
    );
  }
}
