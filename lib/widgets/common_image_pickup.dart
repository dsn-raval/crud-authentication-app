import 'package:flutter/material.dart';

class ImagePickPopup extends StatefulWidget {
  VoidCallback? cameraOnTap;
  VoidCallback? galleryOnTap;
  ImagePickPopup({super.key, this.cameraOnTap, this.galleryOnTap});

  @override
  State<ImagePickPopup> createState() => _ImagePickPopupState();
}

class _ImagePickPopupState extends State<ImagePickPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Choose Image Source"),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.cameraOnTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 30, child: Icon(Icons.camera_alt)),
                    Text("Camera"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.galleryOnTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 30, child: Icon(Icons.image)),
                    Text("Gallery"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
      content: Text("Select the source for your profile picture."),
    );
  }
}
