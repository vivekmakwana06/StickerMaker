import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sticker_maker/functions.dart';
import 'package:whatsapp_sticker_maker/home/controller/Image_edit_page.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_model.dart';
import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;

class ImageEditProvider extends ChangeNotifier {
  final MethodChannel _channel =
      const MethodChannel('aven.flutter.dev/cropper');

  final LocalStorage storage = LocalStorage('sticker_app');
  // final ImagePicker _picker = ImagePicker();

  String? imagePath;
  String? croppedFilePath;

  ImageModel imageModel = ImageModel();

  List<ImageData> imageList = [];
  List<ImageData> selectedImageList = [];
  Rx<Uint8List?> val = Rx<Uint8List?>(null);
  dynamic resizedImage;
  dynamic trayImage;
  dynamic mainImage;

  setVal(Uint8List? value) {
    val.value = value;
    notifyListeners();
  }
  

  Future<Uint8List> getImageBytes() async {
    // Replace this with your actual logic to get image bytes
    // For example, if you store image bytes in a Uint8List variable, return that variable
    // If you load the image from a file, use the appropriate method
    // For now, returning an empty Uint8List as a placeholder
    return Uint8List(0);
  }

  Widget buildImageSizedBox(BuildContext context) {
    return Container(
      child: Image.memory(
        context.watch<ImageEditProvider>().val.value ?? Uint8List(0),
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> saveScreenshot(Uint8List screenshot) async {
    // Save the screenshot using your existing logic
    // For example, you can save it to a file or upload it to a server
    // Update the necessary state or perform any additional actions

    // Example: Save to a file
    final directory = await getApplicationDocumentsDirectory();
    final screenshotFile = File('${directory.path}/screenshot.webp');
    await screenshotFile.writeAsBytes(screenshot);

    print('Screenshot saved to: ${screenshotFile.path}');
    // Perform any other actions needed after saving the screenshot
  }

  void showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Background successfully removed!'),
      ),
    );
  }

  void showFailureSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool isLoading = false;
  File? _image; // Make sure to declare _image as a File type

  // Define a setState method if required
  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  Uint8List convertWebPtoPNG(Uint8List webPImageData) {
    img.Image? webPImage = img.decodeWebP(webPImageData);
    if (webPImage != null) {
      img.Image pngImage = img.copyResize(
        webPImage,
        width: webPImage.width,
        height: webPImage.height,
      );
      return Uint8List.fromList(img.encodePng(pngImage));
    } else {
      throw Exception('Failed to decode the WebP image');
    }
  }

  Future<void> removeBackground(BuildContext context, String imagePath) async {
    final apiKey = 'qxy22LQrkXLgEkvEYjfhkrdc';

    try {
      setState(() {
        isLoading = true; // Show the loader
      });

      if (imagePath != null) {
        final file = File(imagePath);
        if (file.existsSync()) {
          _image = file;
          final response = await http.post(
            Uri.parse('https://api.remove.bg/v1.0/removebg'),
            headers: {'X-Api-Key': apiKey},
            body: {
              'image_file_b64': base64Encode(await _image!.readAsBytes()),
            },
          );

          if (response.statusCode == 200) {
            final contentType = response.headers['content-type'];
            if (contentType != null && contentType.contains('image/png')) {
              // Get the directory for storing the edited image
              final directory = await getApplicationDocumentsDirectory();
              final editedImageFile =
                  File('${directory.path}/edited_image.webp');

              // Save the edited image to the file
              await editedImageFile.writeAsBytes(response.bodyBytes);

              // Display the edited image
              setState(() async {
                val = Rx<Uint8List?>((await editedImageFile.readAsBytes()));
              });

              print('Edited image saved to: ${editedImageFile.path}');
              showSuccessSnackbar(context);
            } else {
              // Handle unexpected response content type
              print('Unexpected Content Type: $contentType');
              showFailureSnackbar(
                  context, 'Unexpected Content Type: $contentType');
            }
          } else {
            // Handle API error here
            print('API Error: ${response.statusCode}');
            print('API Response: ${response.body}');
            showFailureSnackbar(context, 'API Error: ${response.statusCode}');
          }
        } else {
          print('Image file does not exist.');
          showFailureSnackbar(context, 'Image file does not exist.');
        }
      } else {
        print('Image path is null.');
        showFailureSnackbar(context, 'Image path is null.');
      }
    } catch (e) {
      print('Error while removing background: $e');
      showFailureSnackbar(context, 'Error while removing background: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide the loader
      });
    }
  }

  clearSelectedList() {
    imageList.forEach((element) {
      element.setFalse();
    });
    notifyListeners();
  }

  selectDeletedData(int index, bool val) {
    p("SELECTED IMAGE DATA", val);
    if (imageList.isNotEmpty) {
      imageList[index].isDeleted = val;
      notifyListeners();
    }
  }

  Future<void> deleteData(int index) async {
    if (imageList.isNotEmpty) {
      imageList.removeAt(index);
      imageModel.data = imageList;
      await storage.setItem('images', imageModel.toJson());
      notifyListeners();
    }
  }

  Future<void> setSelected(int index, bool val) async {
    if (selectedImageList.length < 30) {
      imageList[index].isSelected = val;
      if (val) {
        selectedImageList.add(imageList[index]);
      } else {
        selectedImageList.remove(selectedImageList.firstWhere(
            (element) => element.imagePath == imageList[index].imagePath));
      }
    }

    p("Selected image list length", selectedImageList.length);
    notifyListeners();
  }

  Future<void> cutImage(String imagePath, dynamic imgByte) async {
    final result = await compressImage(imgByte, 2,
        minWidth: 512, minHeight: 512, quality: 80);

    if (result != null && result.value != null) {
      try {
        Map<String, dynamic> map = {"data": result.value}; // Extract value here
        await _channel.invokeMethod('goIntent', map).then((value) {
          if (value != null) {
            if (value is List<int>) {
              val = Rx<Uint8List?>(Uint8List.fromList(value));
              log(value.toString());
              notifyListeners();
            } else {
              print('Cutting process did not return a valid data type.');
            }
          } else {
            print('Cutting process did not return any data.');
          }
        });
      } on PlatformException catch (e) {
        print("invoke method error: $e");
      }
    } else {
      print('Image compression failed or result.value is null.');
    }
  }

  Future<void> resizeImage(dynamic imgByte) async {
    Map<dynamic, Uint8List> map = {"data": imgByte};
    try {
      await _channel.invokeMethod('resize', map).then((value) {
        resizedImage = value;
        resizedImage = Uint8List.fromList(resizedImage);
        log(value.toString());
        p("RESIZED", resizedImage);
      });
      notifyListeners();
    } on PlatformException catch (e) {
      print("invoke method catch: $e");
    }
  }

  Future<File?> createTrayImage(String path) async {
    p("CREATE TRAY", path);
    File? file = File(path);
    var imgByte = await file.readAsBytes();
    Map<dynamic, Uint8List> map = {"data": imgByte};
    try {
      await _channel.invokeMethod('trayImage', map).then((value) async {
        trayImage = value;
        trayImage =
            Uint8List.fromList(trayImage.value); // Accessing value property
        log(value.toString());
        p("trayImage", val);
        final result = await compressImage(trayImage, 2,
            minWidth: 96, minHeight: 96, quality: 5);
        final buffer = result.value!.buffer; // Accessing value property
        Directory tempDir = await getApplicationDocumentsDirectory();
        String tempPath = tempDir.path;
        var filePath = tempPath +
            '/tray${DateTime.now().minute}${DateTime.now().microsecond}.png';
        File file = await File(filePath).writeAsBytes(buffer.asUint8List(
            result.value!.offsetInBytes,
            result.value!.lengthInBytes)); // Accessing value property
        p("TTTRAR", file);
        return file;
      });
    } on PlatformException catch (e) {
      print("invoke method catch: $e");
    }
    return null;
  }

  Future<void> imageCropSquare(String path, dynamic image,
      {File? file, bool isEdit = false}) async {
    final buffer = image?.buffer ?? Uint8List(0).buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + '/file_01.png';

    await File(filePath)
        .writeAsBytes(buffer.asUint8List(0, buffer.lengthInBytes));

    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file?.path ?? '',
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      croppedFilePath = croppedFile?.path;
      val = await croppedFile?.readAsBytes() as Rx<Uint8List?>;
      if (croppedFile != null && isEdit == false) {
        Get.to(() => ImageEditPage(
              imagePath: croppedFilePath,
              image: file,
              onSaveImage: (String imagePath) {},
            ));
      }
    } catch (e) {
      print("eeeeeeeeeeee$e");
    }
    notifyListeners();
  }

  Future<Rx<Uint8List?>> compressImage(dynamic data, int type,
      {required int minHeight,
      required int minWidth,
      required int quality}) async {
    if (data == null) {
      // Handle the case where data is null
      return Rx<Uint8List?>(Uint8List(0));
    }

    // Ensure the received data is Uint8List
    Uint8List inputData = data.value ?? Uint8List(0);

    // Perform image compression based on the specified type
    try {
      Uint8List compressedData;
      if (type == 1) {
        // Compression for webp format
        compressedData = await FlutterImageCompress.compressWithList(
          inputData,
          minHeight: minHeight,
          minWidth: minWidth,
          quality: quality,
          format: CompressFormat.webp,
        );
      } else {
        // Compression for other formats (e.g., png)
        compressedData = await FlutterImageCompress.compressWithList(
          inputData,
          minHeight: minHeight,
          minWidth: minWidth,
          quality: quality,
          format: CompressFormat.png,
        );
      }

      // Create a new instance of Rx<Uint8List?> and set its value
      final compressedRx = Rx<Uint8List?>(compressedData);
      return compressedRx;
    } catch (e) {
      print('Error during image compression: $e');
      // Handle the error, you can provide a fallback or show an error message
      // For now, returning the original image data
      return Rx<Uint8List?>(inputData);
    }
  }

  Future<File> createWebpFile(dynamic result) async {
    final buffer = result.value.buffer; // Accessing the value property here
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath +
        '/${DateTime.now().minute}${DateTime.now().microsecond}.webp';
    return await File(filePath).writeAsBytes(buffer.asUint8List(
        result.value.offsetInBytes, result.value.lengthInBytes));
  }

  Future<void> getImageList() async {
    await storage.ready;
    if (imageList.isEmpty) {
      var items = await storage.getItem('images');
      if (items != null) {
        imageModel = ImageModel.fromJson(items);
        imageList = imageModel.data ?? [];
      }
      p("GET ITEMSSS", items.toString());
    }
    notifyListeners();
  }
}
