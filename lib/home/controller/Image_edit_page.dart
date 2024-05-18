import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/edit_tool_menu.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_editing_provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_paint_page.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_sticker_page.dart';
import 'package:whatsapp_sticker_maker/home/controller/texteditingpage.dart';
import 'package:whatsapp_sticker_maker/home/controller/tool_menu_item.dart';
import 'package:whatsapp_sticker_maker/main.dart';
import 'package:photo_view/photo_view.dart';

typedef SaveImageCallback = void Function(String imagePath);

class ImageEditPage extends StatefulWidget {
  final String? imagePath;
  final Io.File? image;
  final SaveImageCallback onSaveImage;

  const ImageEditPage(
      {Key? key, this.imagePath, this.image, required this.onSaveImage})
      : super(key: key);

  @override
  State<ImageEditPage> createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {
  final GlobalKey _boundaryKey = GlobalKey();
  Future<void> saveImageAndReturn() async {
    // Call the callback function to save the edited image
    widget.onSaveImage(widget.imagePath!);

    // Navigate back to the HomeView page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? Color.fromARGB(255, 60, 60, 61) : Colors.white;
    final size = MediaQuery.of(context).size;
    return Consumer<ImageEditProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor:
            isDarkMode ? Color.fromARGB(255, 60, 60, 61) : Colors.white,
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
        floatingActionButton: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 75, 75, 251),
                onPressed: () {
                  saveImageAndReturn();
                },
                child: Text(
                  'Save',
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          return SizedBox(
            width: size.width,
            child: Column(
              children: [
                Spacer(),
                buildImageSizedBox(size, provider),
                Spacer(),
                EditToolMenu(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    ToolMenuItem(
                      iconData: Icons.image_aspect_ratio,
                      title: "Cut",
                      onTap: () async {
                        if (widget.imagePath != null) {
                          await provider.cutImage(
                              widget.imagePath!, provider.val);
                        }
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    // ToolMenuItem(
                    //   iconData: Icons.remove_circle,
                    //   title: "Remove bg",
                    //   onTap: () async {
                    //     if (widget.imagePath != null) {
                    //       await provider.removeBackground(
                    //           context, widget.imagePath!);
                    //     }
                    //   },
                    // ),
                    ToolMenuItem(
                      iconData: Icons.text_fields,
                      title: "Text",
                      onTap: () async {
                        _openTextEditor();
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ToolMenuItem(
                      iconData: Icons.color_lens_outlined,
                      title: "Paint",
                      onTap: () async {
                        Get.to(() => PaintImagePage(image: provider.val.value));
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ToolMenuItem(
                      iconData: Icons.insert_emoticon,
                      title: "Add Sticker",
                      onTap: () async {
                        Get.to(() => ImageStickerPage(val: provider.val.value));
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  SizedBox buildImageSizedBox(Size size, ImageEditProvider provider) {
    return SizedBox(
      height: 500,
      width: 500,
      child: RepaintBoundary(
        key: _boundaryKey, // Ensure the key is assigned to RepaintBoundary
        child: provider.val?.value != null
            ? Image.memory(provider.val!.value!)
            : Image.file(widget.image!),
      ),
    );
  }

  void _openTextEditor() async {
    // Load image data from File
    List<int> imageBytes = await widget.image!.readAsBytes();
    Uint8List imageUint8List = Uint8List.fromList(imageBytes);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaintImagePage1(image: imageUint8List),
      ),
    );

    // Handle result if needed (e.g., update UI based on the result)
    if (result != null && result is Uint8List) {
      // Do something with the captured screenshot (result)
    }
  }
}
