import 'package:flutter/material.dart';

class BuildInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  const BuildInfoRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor,size: 20,),
        const SizedBox(width: 8,),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: iconColor == Colors.green ? Colors.black : Colors.grey.shade700
          ),
        )
      ],
    );
  }
}
