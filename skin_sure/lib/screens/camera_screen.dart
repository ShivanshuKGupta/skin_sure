import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../extensions/report_extension.dart';
import '../globals.dart';
import '../models/report.dart';
import '../services/camera_singleton.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../utils/image_utils.dart';
import '../widgets/overlayed_images.dart';
import 'report_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  Report? report;
  bool imageSent = false;

  double zoomLevel = 0;
  double maxZoomLevel = 10;
  double minZoomLevel = 0;

  Offset scaleStart = Offset.zero;

  @override
  void initState() {
    controller = CameraController(
      cameraSingleton.cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    initializeController();

    super.initState();
  }

  Future<void> initializeController() async {
    try {
      await controller.initialize();
    } catch (e) {
      showError(e.toString());
      return;
    }
    maxZoomLevel = await controller.getMaxZoomLevel();
    minZoomLevel = await controller.getMinZoomLevel();
    zoomLevel = minZoomLevel;
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return CameraPermissionNotAllowedWidget(
        controller: controller,
        onPermissionAllowed: () {
          if (!mounted) return;
          setState(() {});
        },
      );
    }

    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: imageSent || report != null
            ? report?.segImagePath == null
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      Text(
                        'Please wait while we extract the mole...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                : OverlayedImages(
                    imageSrc: Image.network(report!.imageUrl),
                    imageDest: Image.network(report!.segImageUrl),
                  )
            : GestureDetector(
                onTap: () {},
                onTapUp: (details) async {
                  // final x = details.localPosition.dx / width;
                  // await controller.setFocusPoint(details.localPosition);
                },
                onScaleUpdate: (details) async {
                  final zoom = zoomLevel + (details.scale - 1) / 5;
                  if (zoom < minZoomLevel || zoom > maxZoomLevel) {
                    return;
                  }
                  controller.setZoomLevel(zoom);
                  setState(() {
                    zoomLevel = zoom;
                  });
                },
                child: Stack(
                  children: [
                    Center(
                      child: CameraPreview(controller),
                    ),
                    Positioned.fill(
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.black45,
                          BlendMode.srcOut,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: height,
                              width: width,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.01),
                              ),
                            ),
                            Center(
                              child: Container(
                                height: width / 2,
                                width: width / 2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 100,
                      right: 40,
                      left: 40,
                      child: Text(
                        'Please take your photo in proper lighting and focus on the mole',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Camera Flip Button
                    if (cameraSingleton.cameras.length > 1)
                      Positioned(
                        top: 20,
                        right: 10,
                        child: IconButton(
                          onPressed: () async {
                            controller = CameraController(
                              controller.cameraId.toString() ==
                                      cameraSingleton.cameras[1].name
                                  ? cameraSingleton.cameras[0]
                                  : cameraSingleton.cameras[1],
                              ResolutionPreset.max,
                              enableAudio: false,
                            );
                            log('Camera ID: ${controller.cameraId} | cameraSingleton.cameras[0].name: ${cameraSingleton.cameras[0].name} | cameraSingleton.cameras[1].name: ${cameraSingleton.cameras[1].name}');
                            await initializeController();
                            setState(() {});
                          },
                          color: Colors.white,
                          iconSize: 40,
                          icon: const Icon(
                            Icons.flip_camera_ios_rounded,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: report != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  iconSize: 40,
                  onPressed: () {
                    setState(() {
                      report = null;
                      imageSent = false;
                    });
                  },
                  color: Colors.red,
                  icon: const Icon(Icons.close_rounded),
                ),
                IconButton(
                  iconSize: 40,
                  onPressed: () async {
                    showMsg('Please wait whlie we classify the mole...');
                    try {
                      report = await server.classifyImage(report!);
                      if (report != null && appContext.mounted) {
                        showMsg('Mole classified as ${report?.label}');
                        await Navigator.of(appContext).push(
                          MaterialPageRoute(
                            builder: (context) => ReportScreen(
                              report: report!,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      showError(e.toString());
                      report = null;
                    }
                    setState(() {
                      imageSent = false;
                      report = null;
                    });
                  },
                  color: Colors.green,
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: zoomLevel,
                    max: maxZoomLevel,
                    min: minZoomLevel,
                    onChanged: (zoom) async {
                      await controller.setZoomLevel(zoom);
                      setState(() {
                        zoomLevel = zoom;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        color: Colors.white,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 50,
                        ),
                      ),
                      IconButton(
                        onPressed: takePicture,
                        color: Colors.white,
                        icon: const Icon(
                          Icons.camera_outlined,
                          size: 50,
                        ),
                      ),
                      IconButton(
                        iconSize: 40,
                        onPressed: () async {
                          await controller.setFlashMode(
                            controller.value.flashMode == FlashMode.off
                                ? FlashMode.torch
                                : FlashMode.off,
                          );
                          setState(() {});
                        },
                        icon: Icon(
                          controller.value.flashMode == FlashMode.off
                              ? Icons.flash_off_rounded
                              : Icons.flash_on_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void takePicture() async {
    final image = await controller.takePicture();
    if (await checkImageBlur(File(image.path))) {
      showError('Image is blurred. Please take a clear image');
      return;
    }
    final croppedImage = await cropImage(image);
    controller.setZoomLevel(zoomLevel);
    if (croppedImage == null) {
      return;
    }
    showMsg('Please wait while we extract the mole...');
    try {
      setState(() {
        imageSent = true;
      });
      report = await server.segmentImage(croppedImage.path);
      setState(() {
        imageSent = false;
      });
    } catch (e) {
      showError(e.toString());
    }
  }
}

/// Screen to show when camera permission is not allowed
class CameraPermissionNotAllowedWidget extends StatelessWidget {
  const CameraPermissionNotAllowedWidget({
    required this.controller,
    required this.onPermissionAllowed,
    super.key,
  });

  final CameraController controller;
  final VoidCallback onPermissionAllowed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Camera permission not allowed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await controller.initialize();
                } catch (e) {
                  showError(e.toString());
                  showMsg('Please allow camera permission in Settings!');
                  return;
                }
                final cameras = await availableCameras();
                cameraSingleton.cameras = cameras;
                onPermissionAllowed();
              },
              child: const Text('Allow Camera Permission'),
            ),
          ],
        ),
      ),
    );
  }
}