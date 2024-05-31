import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/login_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/widget/primary_btn.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:flutter/material.dart';

class ConfirmationPage extends StatefulWidget {
  final String email;
  final String password;
  void Function(String, String) loginAction;

  ConfirmationPage(
      {Key? key,
      required this.email,
      required this.password,
      required this.loginAction})
      : super(key: key);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  late TextEditingController codeController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Your Email',
                style: TextStyle(fontSize: 24.0),
              ),
              const SizedBox(height: 20.0),
              Text(
                'A confirmation code has been sent to ${widget.email}. '
                'Please enter the code below:',
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Confirmation code',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: screenWidth,
                height: 40,
                child: FilledButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ))),
                  onPressed: () =>
                      confirmCode(widget.email, codeController.text),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmCode(String email, String code) async {
    if (await AWSServices().confirm(email, code)) {
      Navigator.pop(context); // Dangerously use context across async gap
      widget.loginAction(email, widget.password);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please try again",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
