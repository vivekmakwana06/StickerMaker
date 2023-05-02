import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telegram_stickers_import/sticker.dart';
import 'package:telegram_stickers_import/sticker_data.dart';
import 'package:telegram_stickers_import/sticker_set.dart';
import 'package:telegram_stickers_import/telegram_stickers_import.dart';
import 'package:whatsapp_sticker_maker/home/controller/set_image_controller.dart';
import 'package:whatsapp_stickers_exporter/whatsapp_stickers_exporter.dart';

import '../../service/service.dart';

class SendStickerController extends GetxController {
  GetStorage getStorage = GetStorage();

//getX
  var homeViewController = Get.find<HomeViewSetImageController>();

  Future installFromAssetsForTelegram() async {
    await _copyAssets();
    List<Sticker> stickers = [];
    for (int i = 0; i < homeViewController.sticker.length; i++) {
      stickers.add(
        Sticker(
            data: await _stickerData(homeViewController.sticker[i], i),
            emojis: ["☕"]),
      );
    }

    final stickerSet = StickerSet(
      software: "My app",
      isAnimated: false,
      stickers: stickers,
    );
    inspect(stickerSet);
    await TelegramStickersImport.import(stickerSet);
  }

  Future installFromAssetsForWhatsApp(context) async {
    if (homeViewController.sticker.isEmpty) throw Error();
    List<List<String>> stickerSet = [];

    for (int i = 0; i < homeViewController.sticker.length; i++) {
      stickerSet.add(
        [
          WhatsappStickerImage.fromFile(homeViewController.sticker[i]).path,
          '☕'
        ],
      );
    }
    String trayImage;
    if (TargetPlatform.iOS == defaultTargetPlatform) {
      var resize96 = await homeViewController.reSizeImage(
          96, homeViewController.images[0]);
      trayImage = WhatsappStickerImage.fromFile(
        resize96.path,
      ).path;
    } else {
      trayImage = WhatsappStickerImage.fromFile(
        homeViewController.sticker[0],
      ).path;
    }

    var exporter = WhatsappStickersExporter();
    try {
      // log(sticker[0].path);
      log("send .........................................");

      await exporter.addStickerPack(
          homeViewController.textEditingController.text, //identifier
          homeViewController.textEditingController.text, //name
          homeViewController.textEditingController.text, //publisher
          trayImage, //trayImage
          "", //publisherWebsite
          "", //privacyPolicyWebsite
          "", //licenseAgreementWebsite
          false, //animatedStickerPack
          stickerSet);
      resetApp();
    } catch (e) {
      inspect(e);
      resetApp();
    }
  }

  Future<StickerData> _stickerData(String name, index) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final directory = await getTemporaryDirectory();

      return StickerData.android(
          "${directory.path}/${TelegramStickersImport.androidImportFolderName}/${name.split("app_flutter/")[1]}");
    } else {
      ByteData data = await rootBundle.load(homeViewController.sticker[index]);
      return StickerData.iOS(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    }
  }

  Future<void> _copyAssets() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final directory = await getTemporaryDirectory();
      Directory(
        "${directory.path}/${TelegramStickersImport.androidImportFolderName}",
      ).createSync();

      for (int i = 0; i < homeViewController.sticker.length; i++) {
        File(
          homeViewController.sticker[i],
        ).copySync(
            "${directory.path}/${TelegramStickersImport.androidImportFolderName}/${homeViewController.sticker[i].split("app_flutter/")[1]}");
      }
    }
  }

  resetApp() async {
    BuildContext contexts = Get.context!;
    await Get.deleteAll(force: true);
    // ignore: use_build_context_synchronously
    Phoenix.rebirth(contexts);
    Get.reset();
    Get.put(MatrialAppService());
  }

  setLangueg(lan) async {
    if (lan == "fa") {
      if (getStorage.read("langueg") == "fa") {
        await getStorage.write("langueg", "en");

        await resetApp();
      }
    } else {
      if (getStorage.read("langueg") == "en" ||
          getStorage.read("langueg") == null) {
        await getStorage.write("langueg", "fa");

        await resetApp();
      }
    }
  }
}
