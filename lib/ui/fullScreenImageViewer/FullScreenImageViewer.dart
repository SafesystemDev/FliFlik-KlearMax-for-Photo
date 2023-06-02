import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final File? imageFile;

  const FullScreenImageViewer({Key? key, required this.imageUrl, this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white), systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          color: Colors.black,
          child: Hero(
            tag: imageUrl,
            child: PhotoView(
              imageProvider: imageFile == null ? NetworkImage(imageUrl) : Image.file(imageFile!).image,
            ),
          ),
        ));
  }
}
