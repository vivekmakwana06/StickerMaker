import 'dart:io';
import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
// Io.File webpImage = Io.File(result.path);
void main() {
  runApp(
    const MaterialApp(
      home: ImageEditorExample(),
    ),
  );
}

class ImageEditorExample extends StatefulWidget {
  const ImageEditorExample({
    Key? key,
  }) : super(key: key);

  @override
  createState() => _ImageEditorExampleState();
}

class _ImageEditorExampleState extends State<ImageEditorExample> {
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    // Load a default image from assets
    loadAsset("image.jpg");
  }

  void loadAsset(String name) async {
    var data = await rootBundle.load('assets/$name');
    setState(() => imageData = data.buffer.asUint8List());
  }

  void loadImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Load the picked image
      setState(() {
        imageData = File(pickedFile.path).readAsBytesSync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ImageEditor Example"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageData != null) Image.memory(imageData!),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text("Single image editor"),
            onPressed: () async {
              var editedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageEditor(
                    image: imageData,
                  ),
                ),
              );

              // Replace with edited image
              if (editedImage != null) {
                setState(() {
                  imageData = editedImage;
                });
              }
            },
          ),
          ElevatedButton(
            child: const Text("Load Image from Gallery"),
            onPressed: () {
              loadImageFromGallery();
            },
          ),
        ],
      ),
    );
  }
}
