import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/screen/login_screen.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/presentation/widget/primary_btn.dart';
import 'package:capstone_project_2024_s1_team_14_neox/cloud/services/aws_cognito.dart';
import 'package:flutter/material.dart';

class ConfirmationPage extends StatefulWidget {
  final String email;
  final String password;
  void Function(String, String) loginAction;

  ConfirmationPage({Key? key, required this.email, required this.password, required this.loginAction}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Your Email',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              'A confirmation code has been sent to ${widget.email}. '
              'Please enter the code below:',
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Confirmation Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            PrimaryBtn(
              btnText: 'Confirm',
              btnFun: () => confirmCode(widget.email, codeController.text),
            ),
          ],
        ),
      ),
    );
  }

  void confirmCode(String email, String code) async {
    if (await AWSServices().confirm(email, code)) {
      Navigator.pop(context); // Dangerously use context across async gap
      widget.loginAction(email, widget.password);
    }
  }
}
