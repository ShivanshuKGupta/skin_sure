import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_singleton.dart';
import 'report.dart';
import 'reports_screen.dart';
import 'server.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CameraController controller;
  Report? report;
  bool imageSent = false;

  @override
  void initState() {
    controller = CameraController(
      cameraSingleton.cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
            Material(child: Text('Please allow camera permission')),
          ],
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            iconSize: 35,
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ReportsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.file_copy_rounded),
          ),
        ],
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: report?.label != null
            ? Text(
                'Classified as ${report!.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : imageSent || report != null
                ? (report?.segImageUrl == null
                    ? const CircularProgressIndicator()
                    : Image.network(
                        '${Server.serverUrl}/${report!.segImageUrl!}'))
                : CameraPreview(
                    controller,
                    child: Center(
                      child: Container(
                        height: width / 2,
                        width: width / 2,
                        decoration: const BoxDecoration(
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: Colors.white30,
                              width: 2,
                            ),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: report != null
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
                    log('Sending Report');
                    try {
                      report = await server.classifyImage(report!);
                      log('Report Sent');
                    } catch (e) {
                      log(e.toString());
                      report = null;
                    }
                    setState(() {
                      imageSent = false;
                    });
                  },
                  color: Colors.green,
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton(
                onPressed: () async {
                  log('Taking Picture. Say Cheeze');
                  final image = await controller.takePicture();
                  log('Picture Taken');
                  try {
                    setState(() {
                      imageSent = true;
                    });
                    report = await server.segmentImage(image);
                    log('We got this report: ${report?.toJson()}');
                    setState(() {
                      imageSent = false;
                    });
                  } catch (e) {
                    log(e.toString());
                  }
                },
                backgroundColor: Colors.black38,
                shape: const CircleBorder(),
                elevation: 0,
                foregroundColor: Colors.white,
                child: const Icon(
                  Icons.camera_outlined,
                  size: 50,
                ),
              ),
            ),
    );
  }
}
