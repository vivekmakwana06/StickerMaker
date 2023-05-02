import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  static errSnackBar(String str, context) {
    return showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: str,
      ),
    );
  }
}
