import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io' as Io;
import 'package:image_picker/image_picker.dart';
import 'package:is_app_installed/is_app_installed.dart';
import 'package:whatsapp_sticker_maker/home/controller/Image_edit_page.dart';
import 'package:whatsapp_sticker_maker/home/controller/send_sticker_controller.dart';
import 'package:whatsapp_sticker_maker/home/controller/set_image_controller.dart';
import 'dart:async';
import 'package:whatsapp_sticker_maker/value/my_str.dart';
import '../widget/home_widget.dart';

void showFullImageDialog(
  BuildContext context,
  Io.File imageFile,
  int index,
  HomeViewSetImageController homeViewController,
) {
  final scaffoldContext = context.findRootAncestorStateOfType<ScaffoldState>();

  if (scaffoldContext == null) {
    print("Error: No Scaffold widget found.");
    return;
  }

  showDialog(
    context: scaffoldContext.context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.contain,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 390),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    deleteImagePermanently(index, homeViewController);
                    Get.back();
                    ScaffoldMessenger.of(scaffoldContext.context).showSnackBar(
                      SnackBar(
                        content: Text('Image deleted successfully!'),
                      ),
                    );
                    // Hide the snackbar after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      ScaffoldMessenger.of(scaffoldContext.context)
                          .hideCurrentSnackBar();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 75, 75, 251),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await ImageGallerySaver.saveFile(
                      imageFile.path,
                    );

                    print("Image saved to: $result");
                    Get.back();
                    ScaffoldMessenger.of(scaffoldContext.context).showSnackBar(
                      SnackBar(
                        content: Text('Image saved to gallery!'),
                      ),
                    );
                    // Hide the snackbar after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      ScaffoldMessenger.of(scaffoldContext.context)
                          .hideCurrentSnackBar();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 75, 75, 251),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Save to Gallery'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void deleteImagePermanently(
  int index,
  HomeViewSetImageController homeViewController,
) async {
  final Io.File imageFile = homeViewController.images[index];

  // Delete the actual file from the file system
  if (imageFile.existsSync()) {
    await imageFile.delete();
  }

  homeViewController.images[index] = Io.File("");
  homeViewController.sticker.removeAt(index);
  homeViewController.selectImage.value--;
  homeViewController.isDelete.value = true;
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    //getX
    final HomeViewSetImageController homeViewController =
        Get.put(HomeViewSetImageController());

    final SendStickerController sendStickerController =
        Get.put(SendStickerController());

    var size = MediaQuery.of(context).size;

    Future<void> showDialogForSetImage(index, context) async {
      return showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            // <-- SEE HERE
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          builder: (context) {
            return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              HomeWidget.widgetCameraOrGallery(
                ValueTranslate.usecamera.tr,
                onTap: () async {
                  await homeViewController.picImage(
                      ImageSource.camera, index, context);
                  Get.back();
                },
                Icons.camera_alt,
              ),
              const Divider(
                color: Colors.grey,
              ),
              HomeWidget.widgetCameraOrGallery(
                ValueTranslate.usegalray.tr,
                Icons.image,
                onTap: () async {
                  await homeViewController.picImage(
                      ImageSource.gallery, index, context);
                  Get.back();
                },
              ),
              const Divider(
                color: Colors.grey,
              ),
              index >= 3 && homeViewController.images[index].path.isNotEmpty
                  ? HomeWidget.widgetCameraOrGallery(
                      ValueTranslate.delete.tr,
                      Icons.delete,
                      onTap: () {
                        homeViewController.images[index] = Io.File("");
                        homeViewController.sticker.removeAt(index);
                        homeViewController.selectImage.value--;
                        homeViewController.isDelete.value = true;
                        Get.back();
                      },
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    )
            ]);
          });
    }

    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    Future<void> showAlertDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text("Enter Package Name"),
            content: TextField(
              maxLength: 10,
              controller: homeViewController.textEditingController,
              decoration: InputDecoration(
                filled: true,
                hintText: "Enter text here...",
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Add",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () async {
                  if (homeViewController
                      .textEditingController.text.isNotEmpty) {
                    Get.back();
                    await sendStickerController
                        .installFromAssetsForWhatsApp(context);
                    // Clear the text field after the "Add" button is clicked
                    homeViewController.textEditingController.text = "";
                  } else {
                    HomeWidget.errSnackBar(
                        "Error: Please enter a name", context);
                  }
                },
              ),
            ],
          );
        },
      );
    }

    selectionAppForAddSticker() {
      return Get.defaultDialog(
          title: "WhatsApp",
          backgroundColor: Colors.white,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // HomeWidget.btnWhich(Colors.blue, "Telegram", () async {
              //   Get.back();
              //   await sendStickerController.installFromAssetsForTelegram();
              // }),
              HomeWidget.btnWhich(Colors.greenAccent, "WhatsApp", () async {
                Get.back();
                await showAlertDialog();
              }),
            ],
          ));
    }

    Future<void> _pickImageFromSource(int index, ImageSource source) async {
      await homeViewController.picImage(source, index, context);

      // Check if the image was picked and the navigation conditions are met
      if (homeViewController.images[index].path.isNotEmpty &&
          !homeViewController.w8forImage.value) {
        // Example: Navigate to ImageEditPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditPage(
              imagePath: homeViewController.images[index].path,
              image: homeViewController.images[index],
              onSaveImage: (String imagePath) {},
            ),
          ),
        );
      }
    }

    Future<void> pickAndNavigate(int index) async {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          // Get the theme data
          ThemeData theme = Theme.of(context);
          Color borderColor = Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              color: theme.scaffoldBackgroundColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 75, 75, 251),
                    ),
                    child: Icon(
                      Icons.camera,
                      color: borderColor,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await _pickImageFromSource(index, ImageSource.camera);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 75, 75, 251),
                    ),
                    child: Icon(
                      Icons.image,
                      color: borderColor,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await _pickImageFromSource(index, ImageSource.gallery);
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    widgetImage(index) {
      Color iconColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

      Color borderColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

      return Padding(
        padding: const EdgeInsets.only(right: 8, left: 8, top: 20),
        child: GestureDetector(
          onTap: () {
            if (homeViewController.w8forImage.isFalse) {
              if (homeViewController.images[index].path.isNotEmpty) {
                showFullImageDialog(context, homeViewController.images[index],
                    index, homeViewController);
              } else {
                pickAndNavigate(
                    index); // Call the method for picking and navigating
              }
            }
          },
          child: homeViewController.images[index].path.isEmpty
              ? Container(
                  height: Get.height,
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 75, 75, 251),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 60,
                      color: iconColor,
                    ),
                  ),
                )
              : homeViewController.w8forImage.isTrue &&
                      index == homeViewController.lodProgress.value
                  ? Opacity(
                      opacity: .5,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: CircularProgressIndicator(
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Image.file(
                            homeViewController.images[index],
                            height: 180,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
        ),
      );
    }

    checkImage() async {
      if (homeViewController.selectImage >= 3) {
        await showAlertDialog();
      } else {
        HomeWidget.errSnackBar("Error: Select at least 3 images", context);
      }
    }

    Color borderColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "Homepage",
            style: GoogleFonts.roboto(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          ),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                SizedBox(
                    // height: 10,
                    ),
                Center(
                    child: Container(
                        // height: 30,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 75, 75, 251),
                            border: Border.all(
                              width: 2,
                              color: borderColor,
                            ),
                            borderRadius: BorderRadius.circular(30)),
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            'Pick Minimum 3 images',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        opacity: .5,
                        image: AssetImage(
                          "assets/whatsappback.png",
                        ),
                        fit: BoxFit.cover)),
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  itemCount: homeViewController.images.length,
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 2,
                    crossAxisCount: 2,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return widgetImage(index);
                  },
                ),
              ),
            ),
            homeViewController.w8forImage.value
                ? const Center()
                : Positioned(
                    right: 60,
                    left: 60,
                    bottom: 10,
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Color.fromARGB(255, 75, 75, 251), // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          'Send To Whatsapp',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () async {
                          bool? canInstall =
                              defaultTargetPlatform == TargetPlatform.iOS
                                  ? await IsAppInstalled.isAppInstalled(
                                      "whatsapp://")
                                  : await IsAppInstalled.isAppInstalled(
                                      "com.whatsapp");
                          if (canInstall == true) {
                            await checkImage();
                          } else {
                            HomeWidget.errSnackBar(
                                "Error: WhatsApp not installed", context);
                          }
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
