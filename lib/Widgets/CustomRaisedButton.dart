import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {

  final String buttonText;
  final Color buttonColor;
  final VoidCallback onpress;
  const CustomRaisedButton({
    Key key,@required this.buttonText,@required this.buttonColor,@required this.onpress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 20,
            offset:
            Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: buttonColor,
        textColor: Colors.white,
        onPressed: onpress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10.0, vertical: 15),
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}