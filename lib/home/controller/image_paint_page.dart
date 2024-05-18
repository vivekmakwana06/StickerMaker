import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_painter/image_painter.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_editing_provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/my_app_bar.dart';

class PaintImagePage extends StatefulWidget {
  final image;
  const PaintImagePage({Key? key, this.image}) : super(key: key);

  @override
  State<PaintImagePage> createState() => _PaintImagePageState();
}

class _PaintImagePageState extends State<PaintImagePage> {
  final _imageKey = GlobalKey<ImagePainterState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        onPressed: () async {
          Uint8List? byteArray = await _imageKey.currentState?.exportImage();
          await context.read<ImageEditProvider>().setVal(byteArray);
          Get.back();
        },
        buttonTextColor: Colors.red,
      ),
      body: SafeArea(
        child: ImagePainter.memory(
          widget.image!,
          key: _imageKey,
          scalable: true,
          initialStrokeWidth: 2,
          textDelegate: TextDelegate(),
          initialColor: Colors.green,
          initialPaintMode: PaintMode.line,
        ),
      ),
    );
  }
}
