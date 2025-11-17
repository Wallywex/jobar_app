import 'package:flutter/material.dart';

class Buildtextfield extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final int maxLines;
  final TextInputType keyBoard;
  
  
  const Buildtextfield({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.label,
    required this.validator,
    required this.maxLines,
    required this.keyBoard
    
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize:  14,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        SizedBox(height: 8,),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyBoard,
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(icon, color: Colors.grey.shade500,),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green, width: 2)
            ),
          ),
        )
      ],
    );
  }
}
