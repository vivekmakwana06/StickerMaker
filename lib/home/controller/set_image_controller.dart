import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'dart:io' as Io;
import 'package:image/image.dart' as I;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeViewSetImageController extends GetxController {
  final images = [
    Io.File(""),
    Io.File(""),
    Io.File(""),
  ].obs;

  Rx<bool> w8forImage = false.obs;
  final checkImagePath = false.obs;
  final isDelete = false.obs;
  String mimType = "";
  Rx<int> lodProgress = 0.obs;
  final selectImage = 0.obs;
  List<String> sticker = [];
  TextEditingController textEditingController = TextEditingController();

  picImage(source, int inedx) async {
    w8forImage.value = true;

    if (images[inedx].path.isNotEmpty) {
      checkImagePath.value = true;
    }

    final image = await ImagePicker().pickImage(
      source: source,
    );

    if (image == null) {
      w8forImage.value = false;
      return;
    }
    if (source == ImageSource.gallery) {
      mimType = image.path.split("cache/")[1].split(".")[1];
      log(mimType);
    }

    if (mimType == "gif" && source == ImageSource.gallery) {
      w8forImage.value = false;

      return;
    }
    CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.png,
        maxHeight: 512,
        maxWidth: 512,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
    if (cropped == null) {
      w8forImage.value = false;
      return;
    }
    final imageRec = Io.File(cropped.path);

    images[inedx] = imageRec;
    if (!checkImagePath.value && !isDelete.value) {
      selectImage.value++;
      if (selectImage.value > 2 && images.length < 9) {
        images.add(Io.File(""));
      }
    }

    checkImagePath.value = isDelete.value = false;
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      sticker.add(await compressIamgeToWebp(images[inedx]));
      w8forImage.value = false;
    });
  }

  compressIamgeToWebp(Io.File file) async {
    try {
      if (mimType == "gif") {}

      //   w8forImage.value = false;

      //   return webpImage.path;
      // } else {
      final tmpDir = (await getApplicationDocumentsDirectory()).path;

      var reSize = await reSizeImage(512, file);

      final target =
          '$tmpDir/${DateTime.now().millisecondsSinceEpoch}_almas.webp';
      final result = await FlutterImageCompress.compressAndGetFile(
        reSize.path,
        target,
        minHeight: 512,
        minWidth: 512,
        format: CompressFormat.webp,
        quality: 10,
      );

      if (result == null) {
        log("null");
        w8forImage.value = false;
      } else {
        Io.File webpImage = FileImage(result).file;
        var decodedImage =
            await decodeImageFromList(webpImage.readAsBytesSync());
        log(decodedImage.width.toString());
        log(decodedImage.height.toString());
        return webpImage.path;
      }
    }
    //}
    catch (e) {
      log(e.toString());
      w8forImage.value = false;
    }
  }

  reSizeImage(size, Io.File file) async {
    final tmpDir = (await getApplicationDocumentsDirectory()).path;
    I.Image? image = I.decodeImage(Io.File(file.path).readAsBytesSync());
    I.Image thumbnail = I.copyResize(
      image!,
      width: size,
      height: size,
    );

    Io.File fileResultTo512;
    // Save the thumbnail as a PNG.

    // if (mimType == "gif") {
    //   fileResultTo512 = await Io.File(
    //     '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.webp',
    //   ).writeAsBytes(I.encodeGif(thumbnail));

    //   if (kDebugMode) {
    //     print(
    //         "size this ....................................!!!${fileResultTo512.lengthSync() / 1000}");
    //   }
    // }
    // else {
    fileResultTo512 =
        Io.File('$tmpDir/${DateTime.now().millisecondsSinceEpoch}.png')
          ..writeAsBytesSync(I.encodePng(thumbnail));
    // }

    return fileResultTo512;
  }
}
