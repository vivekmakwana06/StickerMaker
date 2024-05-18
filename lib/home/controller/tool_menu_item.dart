import 'package:flutter/material.dart';
import 'package:whatsapp_sticker_maker/textstyle.dart';

class ToolMenuItem extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? iconData;
  final String? title;

  const ToolMenuItem({Key? key, this.onTap, this.iconData, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final titleColor =
        isDarkMode ? Colors.black : Colors.black; // Change the order of colors

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(
              iconData ?? Icons.add_a_photo,
              color: Color.fromARGB(255, 75, 75, 251),
            ),
            FittedBox(
              child: Text(
                "$title",
                style: TextStyles.mcLarenStyle.copyWith(
                  fontSize: 12,
                  color: titleColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
