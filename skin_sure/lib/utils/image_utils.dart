import 'dart:io';

import 'package:blur_detection/blur_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<CroppedFile?> cropImage(XFile imageFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    uiSettings: [
      AndroidUiSettings(
        cropStyle: CropStyle.rectangle,
        initAspectRatio: CropAspectRatioPreset.square,
        toolbarTitle: 'Crop to the mole',
        backgroundColor: Colors.black,
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
      ),
    ],
  );

  return croppedFile;
}

Future<bool> checkImageBlur(File file) async {
  return await BlurDetectionService.isImageBlurred(file);
}
