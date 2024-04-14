import 'package:flutter/material.dart';
import 'package:mrping/db/auth/securestorage.dart';
import 'package:mrping/screens/adminpage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AdminPin extends StatefulWidget {
  const AdminPin({super.key});

  @override
  State<AdminPin> createState() => _AdminPinState();
}

class _AdminPinState extends State<AdminPin> {
  final TextEditingController pinController = TextEditingController(); 
  final storage = SecureStorage.instance;
  bool isInvalid = false;

  Future<void> validatePIN(String currentText) async {
    final pin = await storage.read(key: "pin");
    if(pin == currentText){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            const AdminPage()
        ),
      );
    }
    else{
      setState(() {
        isInvalid = true;
      });
    }
  }

  Future<void> initStorage() async {
    if(await storage.read(key: "pin") == null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            CreatePIN(parentContext: context),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initStorage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            Form(
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: pinController,
                obscureText: true,
                obscuringCharacter: '*',
                onCompleted: (value){
                  validatePIN(value);
                  pinController.clear();
                },
              )
            ),
            Center(
              child: Text(
                isInvalid ? "Invalid PIN" : "",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
            )
          ] 
        ),
      ),
    );
  }
}

class CreatePIN extends StatelessWidget {
  CreatePIN({super.key, required this.parentContext});
  final TextEditingController firstPinController = TextEditingController(); 
  final TextEditingController secondPinController = TextEditingController(); 
  final storage = SecureStorage.instance;
  final BuildContext parentContext;

  void validatePIN(){
    storage.delete(key: "pin");
    if(firstPinController.text.length == 4 && firstPinController.text == secondPinController.text){
      storage.write(key: "pin", value: firstPinController.text);
      Navigator.pop(parentContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PIN'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            const Text(
              "Enter PIN Twice",
              style: TextStyle(
                  fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: firstPinController,
              )
            ),
            const SizedBox(height: 40),
            Form(
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: secondPinController,
              )
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: (){
                validatePIN();
              },
              child: const Text("Create"))
          ]
        ),
      ),
    );
  }
}
