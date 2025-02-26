import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String icon;

  const SocialLoginButton({super.key, 
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, height: 24),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
