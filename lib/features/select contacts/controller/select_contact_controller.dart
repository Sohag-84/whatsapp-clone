import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select%20contacts/repository/select_contact_repository.dart';

final getContactsProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(selectContactRepositoryProvider);
  return selectContactRepository.getContacts();
});
