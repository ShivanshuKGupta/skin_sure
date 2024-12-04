import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../extensions/report_extension.dart';
import '../globals.dart';
import '../models/report.dart';
import '../services/server.dart';
import '../utils/image_utils.dart';
import '../widgets/report_tile.dart';
import 'camera_screen.dart';
import 'drawer.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Report>> future = server.getReports();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            future = server.getReports();
          });
        },
        child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                log('Error: ${snapshot.error}', name: 'HomeScreen');
                return ListView(
                  children: [
                    SizedBox(
                      height: height - MediaQuery.of(context).padding.top - 100,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          'Error Fetching Reports!\nMaybe you\'re fetching from a wrong server or are offline',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                log('Error: ${snapshot.error} | data: ${snapshot.data}',
                    name: 'HomeScreen');
                return ListView(
                  children: [
                    SizedBox(
                      height: height - MediaQuery.of(context).padding.top - 100,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          'No Reports Yet!',
                          style: TextStyle(color: Colors.grey, fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                );
              }
              List<Report> reports = snapshot.data!;
              reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ReportTile(report: report);
                },
              );
            }),
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CameraScreen()));
                setState(() {
                  future = server.getReports();
                });
              },
              child: const Icon(Icons.photo_camera_outlined),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'gallery',
              onPressed: () async {
                final picker = ImagePicker();
                final image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image == null) {
                  print('No image selected');
                  return;
                }
                // if (await checkImageBlur(File(image.path))) {
                //   showError('Image is blurry.\nPlease take a clear image');
                //   return;
                // }
                final croppedImage = await cropImage(image);
                if (croppedImage == null) {
                  return;
                }
                if (context.mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(
                        image: File(croppedImage.path),
                      ),
                    ),
                  );
                  setState(() {
                    future = server.getReports();
                  });
                }
              },
              child: const Icon(Icons.image_search_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
