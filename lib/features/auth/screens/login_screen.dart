// ignore_for_file: prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/colors.dart';
import 'package:whatsapp_clone/common/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login-screen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
            SizedBox(height: size.height * 0.6),
            SizedBox(
              width: 100,
              child: CustomButton(
                onPressed: () {},
                text: "NEXT",
              ),
            )
          ],
        ),
      ),
    );
  }
}
