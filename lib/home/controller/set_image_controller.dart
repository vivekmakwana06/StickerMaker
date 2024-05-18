import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_photo_editor/flutter_photo_editor.dart';
import 'package:get/get.dart';
import 'dart:io' as Io;
import 'package:image/image.dart' as I;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_sticker_maker/home/widget/home_widget.dart';
import '../../value/my_str.dart';

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

  Future<String> getApplicationDocumentsDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Method to save image to local file system
  Future<void> saveImageToLocalFile(XFile imageFile, int index) async {
    final appDir = await getApplicationDocumentsDirectoryPath();
    final fileName = 'image_$index.png'; // You can customize the file name

    final localImagePath = '$appDir/$fileName';

    await Io.File(imageFile.path!).copy(localImagePath);

    images[index] = Io.File(localImagePath);
  }

  // Method to load images from local file system
  Future<void> loadImagesFromLocalFiles() async {
    final appDir = await getApplicationDocumentsDirectoryPath();

    for (int i = 0; i < images.length; i++) {
      final fileName =
          'image_$i.png'; // Assuming you used the same naming convention
      final localImagePath = '$appDir/$fileName';

      if (Io.File(localImagePath).existsSync()) {
        images[i] = Io.File(localImagePath);
      }
    }
  }

  picImage(
    source,
    int index,
    context,
  ) async {
    w8forImage.value = true;

    if (images[index].path.isNotEmpty) {
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
      HomeWidget.errSnackBar(ValueTranslate.notGifErr.tr, context);

      return;
    }

    await saveImageToLocalFile(XFile(image.path!), index);

    if (!checkImagePath.value && !isDelete.value) {
      selectImage.value++;
      if (selectImage.value > 2 && images.length < 9) {
        images.add(Io.File(""));
      }
    }

    checkImagePath.value = isDelete.value = false;
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      String editedImagePath = await _editAndSaveImage(index);

      if (editedImagePath.isNotEmpty) {
        sticker.add(await compressIamgeToWebp(Io.File(editedImagePath)));
      }

      w8forImage.value = false;
    });
  }

  Future<String> _editAndSaveImage(int index) async {
    if (images[index].path.isNotEmpty) {
      bool isEditingComplete =
          await FlutterPhotoEditor().editImage(images[index].path);

      if (isEditingComplete) {
        String editedImagePath =
            images[index].path; // Get the edited image path

        // Generate a unique filename for the edited image
        final appDocDir = await getApplicationDocumentsDirectory();
        final fileName =
            "edited_image_${DateTime.now().millisecondsSinceEpoch}.webp";
        final savedImagePath = "${appDocDir.path}/$fileName";

        // Save the edited image to a new file
        await File(editedImagePath).copy(savedImagePath);

        print("Saved edited image at: $savedImagePath");

        // Update the path of the edited image
        images[index] = Io.File(savedImagePath);
        update(); // Update the UI

        return savedImagePath; // Return the edited image path
      } else {
        print("Error editing image");
        return "";
      }
    }
    return "";
  }

  Future<void> _saveEditedImage(String editedImagePath, int index) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final fileName = "edited_image_$index.webp";
      final savedImagePath = "${appDocDir.path}/$fileName";

      await File(editedImagePath).copy(savedImagePath);

      print("Saved edited image at: $savedImagePath");

      // Update the path of the edited image
      images[index] = Io.File(savedImagePath);
      update(); // Update the UI

      // Perform any additional actions after saving the edited image
      // For example, navigate to the next screen or update UI
    } catch (e) {
      print("Error saving edited image: $e");
    }
  }

  void updateEditedImagePath(String editedImagePath, int index) {
    if (editedImagePath.isNotEmpty) {
      images[index] = Io.File(editedImagePath);
      update(); // Notify the UI that the data has changed
    }
  }

  compressIamgeToWebp(Io.File file) async {
    try {
      if (mimType == "gif") {}

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
        Io.File webpImage = Io.File(result.path);
        var decodedImage =
            await decodeImageFromList(webpImage.readAsBytesSync());
        log(decodedImage.width.toString());
        log(decodedImage.height.toString());
        return webpImage.path;
      }
    } catch (e) {
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

    fileResultTo512 =
        Io.File('$tmpDir/${DateTime.now().millisecondsSinceEpoch}.png')
          ..writeAsBytesSync(I.encodePng(thumbnail));

    return fileResultTo512;
  }
}
