import 'package:flutter/material.dart';

class Builddetailrow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const Builddetailrow({
    super.key,
    required this.content,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 28,),
        const SizedBox(width: 10,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey
              ),
            ),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            )
          ],
        )
      ],
    );
  }
}
