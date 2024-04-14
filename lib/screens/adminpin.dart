import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';

class AdminPin extends StatelessWidget {
  AdminPin ({super.key});
  final TextEditingController pinController = TextEditingController();  

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Pinput(
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        validator: (pin) {
          if (pin == '2224') return null;

          /// Text will be displayed under the Pinput
          return 'Pin is incorrect';
        },
      )
    );
  }
}
