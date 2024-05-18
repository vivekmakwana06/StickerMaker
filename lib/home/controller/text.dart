import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'color_picker.dart';

class TextEditorImage extends StatefulWidget {
  final String initialText;
  final double initialSize;
  final Color initialColor;
  final void Function(String editedText) onTextEdited;

  const TextEditorImage({
    Key? key,
    required this.initialText,
    required this.initialSize,
    required this.initialColor,
    required this.onTextEdited,
  }) : super(key: key);

  @override
  _TextEditorImageState createState() => _TextEditorImageState();
}

class _TextEditorImageState extends State<TextEditorImage> {
  TextEditingController name = TextEditingController();
  Color currentColor = Colors.white;
  double slider = 32.0;
  TextAlign align = TextAlign.left;

  @override
  void initState() {
    super.initState();
    name.text = widget.initialText;
    currentColor = widget.initialColor;
    slider = widget.initialSize;
    align = TextAlign.left;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.alignLeft,
                  color: align == TextAlign.left
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.left;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignCenter,
                  color: align == TextAlign.center
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.center;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignRight,
                  color: align == TextAlign.right
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.right;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(
                  context,
                  TextLayerData(
                    text: name.text,
                    color: currentColor,
                    size: slider.toDouble(),
                    position: Offset(150, 150),
                  ),
                );
              },
              color: Colors.white,
              padding: const EdgeInsets.all(15),
            )
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: size.height / 2.2,
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                      hintText: ('Insert Your Message'),
                      hintStyle: const TextStyle(color: Colors.white),
                      alignLabelWithHint: true,
                    ),
                    scrollPadding: const EdgeInsets.all(20.0),
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 99999,
                    style: TextStyle(
                      color: currentColor,
                    ),
                    autofocus: true,
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      //   SizedBox(height: 20.0),
                      Text(
                        ('Slider Color'),
                      ),
                      //   SizedBox(height: 10.0),
                      Row(children: [
                        Expanded(
                          child: BarColorPicker(
                            width: 300,
                            thumbColor: Colors.white,
                            cornerRadius: 10,
                            pickMode: PickMode.color,
                            colorListener: (int value) {
                              setState(() {
                                currentColor = Color(value);
                              });
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            ('Reset'),
                          ),
                        ),
                      ]),
                      //   SizedBox(height: 20.0),
                      Text(
                        ('Slider White Black Color'),
                      ),
                      //   SizedBox(height: 10.0),
                      Row(children: [
                        Expanded(
                          child: BarColorPicker(
                            width: 300,
                            thumbColor: Colors.white,
                            cornerRadius: 10,
                            pickMode: PickMode.grey,
                            colorListener: (int value) {
                              setState(() {
                                currentColor = Color(value);
                              });
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            ('Reset'),
                          ),
                        )
                      ]),
                      Container(
                        color: Colors.black,
                        child: Column(
                          children: [
                            const SizedBox(height: 10.0),
                            Center(
                              child: Text(
                                ('Size Adjust').toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.grey,
                                value: slider,
                                min: 0.0,
                                max: 100.0,
                                onChangeEnd: (v) {
                                  setState(() {
                                    slider = v;
                                  });
                                },
                                onChanged: (v) {
                                  setState(() {
                                    slider = v;
                                  });
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class TextLayerData {
  final String text;
  final Color color;
  final double size;
  final Offset position;

  TextLayerData({
    required this.text,
    required this.color,
    required this.size,
    required this.position,
  });
}
