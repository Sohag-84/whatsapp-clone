import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/group/repository/group_repository.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);
  return GroupController(groupRepository: groupRepository, ref: ref);
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({required this.groupRepository, required this.ref});

  void createGroup({
    required BuildContext context,
    required String groupName,
    required File groupProfile,
    required List<Contact> selectedContact,
  }) {
    groupRepository.createGroup(
      context: context,
      groupName: groupName,
      groupPic: groupProfile,
      selectedContact: selectedContact,
    );
  }
}
