import 'dart:developer';
import 'dart:io';
import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../globals.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../services/tf_service.dart';
import '../utils/label_utils.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skin Sure',
                  style: TextStyle(
                    fontSize: 30,
                    color: darkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'This app is missing a lot of features and is not ready for production use.',
                  style: TextStyle(
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '\n\nThis app serves as a PoC (proof of concept), demonstrating the development of deep learning models (on-device and off-device) for classifying mole images as malignant(cancerous) and non-malignant(non-cancerous).',
                  style: TextStyle(
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                    onPressed: () async {
                      /// Pick Image from server
                      // final image =
                      //     await ImagePicker().pickImage(source: ImageSource.gallery);
                      // if (image == null) {
                      //   return;
                      // }
                      // final imageBytes = await image.readAsBytes();

                      /// Pick Image from Gallery
                      final picker = ImagePicker();
                      final image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image == null) {
                        print('No image selected');
                        return;
                      }
                      final input = await File(image.path).readAsBytes();

                      /// Classification
                      final probabilities = await ImageClassifier.classifyImage(
                        imageBytes: input,
                        modelAssetPath:
                            ImageClassifier.mobileNetV2ModelAssetPath,
                      );
                      log('probabilities: $probabilities');

                      /// Probablities to label
                      final label =
                          probabilities.indexOf(probabilities.reduce(max));
                      showMsg(
                          'Classified as ${labelFullForms.keys.toList()[label]}');
                    },
                    child: const Text('Classify using MobileNet v2'),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Server Settings',
                    style: TextStyle(
                      fontSize: 20,
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: TextEditingController(text: Server.serverUrl),
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      labelText: 'Server Address',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            Server.serverUrl = Server.defaultServerUrl;
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ),
                    onChanged: (value) {
                      Server.serverUrl = value.trim().replaceAll(' ', '');
                      // removing trailing slash
                      while (Server.serverUrl.endsWith('/')) {
                        Server.serverUrl = Server.serverUrl
                            .substring(0, Server.serverUrl.length - 1);
                      }
                    },
                    onEditingComplete: () async {
                      try {
                        await server.getReports();
                        showMsg('Server address updated successfully');
                      } catch (e) {
                        log(e.toString());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
