import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

ImageLoder({
  required String url,
  BoxFit fit = BoxFit.cover,
  double? height,
  double? width,
}) {
  return Image.network(
    url.split(' ')[0],
    fit: fit,
    height: height,
    width: width,
    errorBuilder: (context, error, stackTrace) {
      print(error);
      return Icon(Icons.image_not_supported_outlined);
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Center(
        child: SkeletonItem(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black,
          ),
        ),
      );
    },
  );
}
