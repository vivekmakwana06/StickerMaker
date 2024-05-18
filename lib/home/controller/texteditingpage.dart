import 'dart:io' as Io;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/image_editing_provider.dart';
import 'package:whatsapp_sticker_maker/home/controller/my_app_bar.dart';
import 'package:whatsapp_sticker_maker/home/controller/text.dart';

class PaintImagePage1 extends StatefulWidget {
  final Uint8List? image;

  const PaintImagePage1({
    Key? key,
    this.image,
  }) : super(key: key);

  @override
  State<PaintImagePage1> createState() => _PaintImagePageState();
}

class _PaintImagePageState extends State<PaintImagePage1> {
  final _boundaryKey = GlobalKey();
  String _text = '';
  final TextEditingController _textEditingController = TextEditingController();
  List<Offset> textPositions = [];
  final GlobalKey _globalKey = GlobalKey();
  List<Widget> textWidgets = [];

  void _openTextEditor({
    String? text,
    double? size,
    Color? color,
    int? index,
    Offset? position,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextEditorImage(
          initialText: text ?? '',
          initialSize: size ?? 24,
          initialColor: color ?? Colors.black,
          onTextEdited: (editedText) {
            // Callback function to handle edited text
            if (index != null) {
              // Update existing text
              setState(() {
                textWidgets[index] = Positioned(
                  top: position?.dy ?? 150,
                  left: position?.dx ?? 150,
                  child: GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (index != null) {
                                      setState(() {
                                        textWidgets.removeAt(index);
                                        textPositions.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    onTap: () {
                      _openTextEditor(
                        text: editedText,
                        size: size,
                        color: color,
                        position: position,
                        index: index,
                      );
                    },
                    child: Text(
                      editedText,
                      style: TextStyle(fontSize: size ?? 24, color: color),
                    ),
                  ),
                );
              });
            } else {
              // Add new text
              double imageSize = 500;
              double initialX = size != null ? size / 2 : imageSize / 2;
              double initialY = size != null ? size / 2 : imageSize / 2;

              setState(() {
                int newIndex = textWidgets.length;
                textWidgets.add(
                  Positioned(
                    top: position?.dy ?? initialY,
                    left: position?.dx ?? initialX,
                    child: GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              child: Wrap(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                    title: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (newIndex != null) {
                                        setState(() {
                                          textWidgets.removeAt(newIndex);
                                          textPositions.removeAt(newIndex);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      onTap: () {
                        _openTextEditor(
                          text: editedText,
                          size: size,
                          color: color,
                          position: textPositions[newIndex],
                          index: newIndex,
                        );
                      },
                      child: Text(
                        editedText,
                        style: TextStyle(fontSize: size ?? 24, color: color),
                      ),
                    ),
                  ),
                );
                textPositions.add(Offset(initialX, initialY));
              });
            }
          },
        ),
      ),
    );

    if (result != null && result is TextLayerData) {
      TextLayerData textData = result;
      setState(() {
        int newIndex = textWidgets.length;
        textWidgets.add(
          Positioned(
            top: textData.position.dy,
            left: textData.position.dx,
            child: GestureDetector(
              onLongPress: () {
                showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                            title: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              if (newIndex != null) {
                                setState(() {
                                  textWidgets.removeAt(newIndex);
                                  textPositions.removeAt(newIndex);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              onTap: () {
                _openTextEditor(
                  text: textData.text,
                  size: textData.size,
                  color: textData.color,
                  position: textData.position,
                  index: newIndex,
                );
              },
              child: Text(
                textData.text,
                style:
                    TextStyle(fontSize: textData.size, color: textData.color),
              ),
            ),
          ),
        );
        textPositions.add(textData.position);
      });
    }
  }

  Future<Uint8List?> captureScreenshot() async {
    try {
      // Wait for the widget tree to be fully built
      await Future.delayed(Duration.zero);

      // Use RenderRepaintBoundary directly
      final boundary = _globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final pngBytes = byteData.buffer.asUint8List();
        return pngBytes;
      }

      return null;
    } catch (e) {
      print('Error capturing screenshot: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? Color.fromARGB(255, 60, 60, 61) : Colors.white,
      appBar: MyAppBar(
        title: 'Text Editing Page',
        onPressed: () async {
          final screenshot = await captureScreenshot();
          if (screenshot != null) {
            try {
              // Save the screenshot using ImageEditProvider
              await context
                  .read<ImageEditProvider>()
                  .saveScreenshot(screenshot);

              // Navigate back to the previous page with the captured screenshot
              Navigator.pop(context, screenshot);
            } catch (e) {
              print('Error saving screenshot: $e');
              // Handle error if necessary
            }
          } else {
            print('Error capturing screenshot.');
            // Handle error if necessary
          }
        },
        textColor: isDarkMode ? Colors.white : Colors.black,
        buttonTextColor: Colors.red,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () => _openTextEditor(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 75, 75, 251),
                ),
              ),
              child: Text(
                'Open Text Editor',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
                constraints: BoxConstraints.expand(),
                child: RepaintBoundary(
                  key: _globalKey,
                  child: GestureDetector(
                    child: Stack(
                      children: [
                        if (widget.image != null)
                          Align(
                            alignment: Alignment.center,
                            child: Image.memory(
                              widget.image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ...textWidgets.asMap().entries.map((entry) {
                          int index = entry.key;
                          Widget widget = entry.value;
                          return Positioned(
                            top: textPositions[index].dy,
                            left: textPositions[index].dx,
                            child: Draggable(
                              feedback: widget,
                              childWhenDragging: Container(),
                              onDragEnd: (details) {
                                setState(() {
                                  textPositions[index] = Offset(
                                      details.offset.dx, details.offset.dy);
                                });
                              },
                              child: LongPressDraggable(
                                feedback: Material(
                                  child: widget,
                                ),
                                child: DragTarget(
                                  builder: (BuildContext context,
                                      List<Object?> candidateData,
                                      List<dynamic> rejectedData) {
                                    return widget;
                                  },
                                  onAccept: (data) {
                                    // Perform any action on accepting the dragged item
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
