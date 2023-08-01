// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/common/widgets/custom_button.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = "/login-screen";
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  ///important information
  ///Provider ref --> Interact/communicate provider with provider
  ///Widget ref -->  Makes widget interact/communicate with provider

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref.read(authControllerProvider).signInWithPhone(
            context: context,
            phoneNumber: "+${country!.phoneCode}$phoneNumber",
          );
    } else {
      showSnackBar(context: context, content: "Fill out all the field");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Enter your phone number"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text("WhatsApp will need to verify your phone number."),
                SizedBox(height: 10),
                TextButton(
                  onPressed: pickCountry,
                  child: Text("Pick Country"),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    if (country != null) Text("+${country!.phoneCode}"),
                    SizedBox(width: 10),
                    SizedBox(
                      width: size.width * 0.7,
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(hintText: "phone number"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            SizedBox(
              width: 100,
              child: CustomButton(
                onPressed: sendPhoneNumber,
                text: "NEXT",
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
