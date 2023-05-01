import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io' as Io;
import 'package:image_picker/image_picker.dart';
import 'package:is_app_installed/is_app_installed.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:whatsapp_sticker_maker/home/controller/send_sticker_controller.dart';
import 'package:whatsapp_sticker_maker/home/controller/set_image_controller.dart';
import 'dart:async';
import 'package:whatsapp_sticker_maker/value/my_str.dart';
import '../widget/home_widget.dart';

// ignore: must_be_immutable
class HomeView extends StatelessWidget {
  //getX
  HomeViewSetImageController homeViewController =
      Get.put(HomeViewSetImageController());

  SendStickerController sendStickerController =
      Get.put(SendStickerController());
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    errSnackBar(String str) {
      return showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: str,
        ),
      );
    }

    Future<void> showAlertDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // <-- SEE HERE
            backgroundColor: Theme.of(context).cardColor,
            title: Text(ValueTranslate.setName.tr),
            content: TextField(
              maxLength: 10,
              controller: homeViewController.textEditingController,
              decoration: InputDecoration(
                filled: true,
                hintText: ValueTranslate.textFild.tr,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  ValueTranslate.addbtn.tr,
                  style: const TextStyle(color: Colors.black),
                ),
                onPressed: () async {
                  if (homeViewController
                      .textEditingController.text.isNotEmpty) {
                    Get.back();
                    await sendStickerController
                        .installFromAssetsForWhatsApp(context);
                  } else {
                    errSnackBar(ValueTranslate.errName.tr);
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
          title: ValueTranslate.which.tr,
          backgroundColor: Colors.white,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HomeWidget.btnWhich(Colors.blue, ValueTranslate.telegram.tr,
                  () async {
                Get.back();

                await sendStickerController.installFromAssetsForTelegram();
              }),
              HomeWidget.btnWhich(
                  Colors.greenAccent, ValueTranslate.whatsApp.tr, () async {
                Get.back();
                await showAlertDialog();
              }),
            ],
          ));
    }

    checkImage() {
      if (homeViewController.selectImage >= 3) {
        selectionAppForAddSticker();
      } else {
        errSnackBar(ValueTranslate.errImage.tr);
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.grey,
        leading: PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                  onTap: () => sendStickerController.setLangueg("fa"),
                  child: const Text('English')),
              PopupMenuItem(
                  onTap: () => sendStickerController.setLangueg("en"),
                  child: const Text('فارسی')),
            ];
          },
        ),
        title: Text(ValueTranslate.titleText.tr),
        centerTitle: true,
      ),
      body: Obx(
        () => Stack(
          children: [
            Container(
              width: Get.width,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      opacity: .5,
                      image: AssetImage(
                        "assets/whatsappback.png",
                      ),
                      fit: BoxFit.fill)),
              child: bodyGridView(),
              height: Get.height,
            ),
            homeViewController.w8forImage.value
                ? const Center()
                : Positioned(
                    right: 10,
                    left: 10,
                    bottom: 10,
                    child: ElevatedButton(
                      style: const ButtonStyle(),
                      child: Text(
                        ValueTranslate.btnNavText.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        bool? cannInstall = TargetPlatform.iOS ==
                                defaultTargetPlatform
                            ? await IsAppInstalled.isAppInstalled("whatsapp://")
                            : await IsAppInstalled.isAppInstalled(
                                "com.whatsapp");
                        if (cannInstall == true) {
                          checkImage();
                        } else {
                          errSnackBar(ValueTranslate.install.tr);
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  widgetImage(index, context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 20),
      child: GestureDetector(
          onTap: () {
            if (homeViewController.w8forImage.isFalse) {
              showDialogForSetImage(index, context);
              homeViewController.lodProgress = index;
            } else {}
          },
          child: homeViewController.images[index].path.isEmpty
              ? DottedBorder(
                  color: Colors.black,
                  strokeWidth: 2,
                  dashPattern: const [10, 10],
                  radius: const Radius.circular(10),
                  borderType: BorderType.RRect,
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.black54,
                      )),
                )
              : homeViewController.w8forImage.isTrue &&
                      index == homeViewController.lodProgress
                  ? Opacity(
                      opacity: .5,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image:
                                  FileImage(homeViewController.images[index]),
                              fit: BoxFit.fill,
                            )),
                        child: const Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(homeViewController.images[index]),
                            fit: BoxFit.fill,
                          )),
                    )),
    );
  }

  bodyGridView() {
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: homeViewController.images.length,
      // shrinkWrap: false,
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 2,
        crossAxisCount: 3,
        crossAxisSpacing: 0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return widgetImage(index, context);
      },
    );
  }

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
                await homeViewController.picImage(ImageSource.camera, index);
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
                await homeViewController.picImage(ImageSource.gallery, index);
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
}
