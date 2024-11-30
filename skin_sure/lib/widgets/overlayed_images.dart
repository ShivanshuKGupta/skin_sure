import 'package:flutter/material.dart';

/// To show only the common parts between two images.
/// Images with black pixels will become transparent.
class OverlayedImages extends StatelessWidget {
  final Widget imageSrc;
  final Widget? imageDest;
  final String tag;

  const OverlayedImages({
    required this.tag,
    required this.imageDest,
    required this.imageSrc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Stack(
        children: [
          if (imageDest != null) imageDest!,
          if (imageDest == null)
            imageSrc
          else
            Opacity(opacity: 0.5, child: imageSrc),
        ],
      ),
    );
  }
}
