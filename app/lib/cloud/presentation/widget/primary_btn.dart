import 'package:flutter/material.dart';


class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({Key? key, required this.btnText, required this.btnFun})
      : super(key: key);
  final String btnText;
  final Function btnFun;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => btnFun(),
      style: getBtnStyle(context),
      child: Text(btnText),
    );
  }

  getBtnStyle(context) => ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20) / 2),
      backgroundColor: Colors.white,
      fixedSize: Size(MediaQuery.of(context).size.width - 40, 55),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
}