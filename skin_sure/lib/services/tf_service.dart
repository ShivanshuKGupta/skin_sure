import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassifier {
  static const String mobileNetV2ModelAssetPath = 'assets/models/model.tflite';

  static Future<List<double>> classifyImage({
    required final String modelAssetPath,
    required final Uint8List imageBytes,
  }) async {
    // Load and preprocess image
    final input = imageToByteListFloat32(imageBytes, 224, 224, 3);
    final output = List<List<double>>.filled(1, List.filled(7, 0.0));

    try {
      // Load TFLite model
      final interpreter = await Interpreter.fromAsset(modelAssetPath);
      interpreter.run(input, output);
      interpreter.close();

      print('Model output: ${output[0]}');
      return output[0];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Uint8List imageToByteListFloat32(
      Uint8List imageBytes, int width, int height, int channels) {
    final convertedBytes = Float32List(1 * width * height * channels);
    for (var i = 0; i < width * height; i++) {
      final pixel = imageBytes.sublist(i * channels, (i + 1) * channels);
      for (var channel = 0; channel < channels; channel++) {
        convertedBytes[i * channels + channel] = pixel[channel] / 255.0;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
