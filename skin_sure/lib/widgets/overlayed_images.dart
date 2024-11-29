import 'package:flutter/material.dart';

/// To show only the common parts between two images.
/// Images with black pixels will become transparent.
class OverlayedImages extends StatelessWidget {
  final Widget imageSrc;
  final Widget imageDest;

  const OverlayedImages({
    required this.imageSrc,
    required this.imageDest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        imageDest,
        Opacity(opacity: 0.5, child: imageSrc),
      ],
    );
  }
}
