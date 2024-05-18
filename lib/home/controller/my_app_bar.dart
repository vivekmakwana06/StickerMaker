import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? buttonText;
  final Function()? onPressed;
  final double? fontSize;
  final Color? textColor;
  final Widget? buttonChild;
  const MyAppBar({
    Key? key,
    this.title,
    this.onPressed,
    this.fontSize,
    this.buttonText,
    this.textColor,
    this.buttonChild,
    required Color buttonTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title ?? "App",
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: fontSize ?? 18,
            fontWeight: FontWeight.w900,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
      elevation: 0,
      actions: onPressed == null
          ? null
          : [
              TextButton(
                onPressed: onPressed,
                child: buttonChild ??
                    Text(buttonText ?? "Save",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 18,
                            color: textColor ?? Colors.red,
                          ),
                        )),
              )
            ],
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.lato(
        textStyle: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
