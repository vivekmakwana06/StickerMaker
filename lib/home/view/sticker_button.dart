import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class StickerButton extends StatelessWidget {
  final VoidCallback onPressed;

  StickerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DottedBorder(
        color: Colors.black,
        strokeWidth: 2,
        dashPattern: const [10, 10],
        radius: const Radius.circular(10),
        borderType: BorderType.RRect,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

