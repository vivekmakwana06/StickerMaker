import 'dart:io';

import 'package:flutter/material.dart';

class EditingScreen extends StatelessWidget {
  final String editedImagePath;

  EditingScreen(this.editedImagePath) {
    print("EditingScreen created with path: $editedImagePath");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing Screen'),
      ),
      body: Center(
        child: Image.file(File(editedImagePath)),
      ),
    );
  }
}
