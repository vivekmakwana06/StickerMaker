import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/send_sticker_controller.dart';

class HomeWidget {
  HomeWidget._();
  static SendStickerController sendStickerController =
      Get.find<SendStickerController>();

  static btnWhich(color, text, onPressed) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: color)));
  }

  static widgetCameraOrGallery(str, icon, {void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
          onTap: onTap,
          title: Text(str),
          trailing: Icon(
            icon,
            size: 30,
          )),
    );
  }
}
