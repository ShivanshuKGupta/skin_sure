import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../extensions/report_extension.dart';
import '../globals.dart';
import '../models/report.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../utils/extensions/string_extension.dart';
import '../utils/label_utils.dart';
import '../widgets/overlayed_images.dart';

class ReportScreen extends StatefulWidget {
  final Report? report;
  final File? image;
  const ReportScreen({
    super.key,
    this.report,
    this.image,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Report? report;
  bool classifiying = false;

  @override
  void initState() {
    super.initState();
    report = widget.report;

    /// If image is not classified yet, we will send to be classified as soon as
    /// possible using the image
    if (report == null) {
      if (widget.image == null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          showError('Image is required to classify');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
      extractMole(widget.image!); // This will also classify the image
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final loadingWidget = SizedBox(
      width: double.infinity,
      height: height / 3,
    ).animate(onComplete: (c) => c.repeat()).shimmer(
      colors: [
        Colors.transparent.withOpacity(0.5),
        Colors.black.withOpacity(0.01),
        Colors.transparent.withOpacity(0.5),
      ],
      duration: const Duration(milliseconds: 1500),
    );

    Widget segImage = report?.segImagePath == null
        ? loadingWidget
        : Image.network(report!.segImageUrl);
    if (classifiying) {
      segImage = segImage
          .animate(
        target: classifiying ? 0 : 1,
        onComplete: (c) => classifiying ? c.repeat() : null,
      )
          .shimmer(
        colors: [
          Colors.transparent.withOpacity(0.5),
          Colors.black.withOpacity(0.01),
          Colors.transparent.withOpacity(0.5),
        ],
        duration: const Duration(milliseconds: 1500),
      );
    }

    Widget srcImage = (widget.image != null
        ? Image.file(File(widget.image!.path))
        : loadingWidget);
    if (classifiying) {
      srcImage = srcImage
          .animate(
        target: classifiying ? 0 : 1,
        onComplete: (c) => classifiying ? c.repeat() : null,
      )
          .shimmer(
        colors: [
          Colors.transparent.withOpacity(0.5),
          Colors.black.withOpacity(0.01),
          Colors.transparent.withOpacity(0.5),
        ],
        duration: const Duration(milliseconds: 1500),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(report == null ? 'Extracting mole...' : 'Report'),
        actions: [
          if (report != null)
            IconButton(
              onPressed: () async {
                if (report == null) return;
                try {
                  final response = await showConfirmDialog(
                    title: 'Delete Report?',
                    content: 'Are you sure you want to delete this report?',
                  );
                  if (response != true) return;
                  await server.deleteReport(report!);
                  showMsg('Report deleted successfully');
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  showError('Error deleting report: $e');
                }
              },
              color: colorScheme.error,
              icon: const Icon(Icons.delete_rounded),
            ),
          if (report != null)
            ElevatedButton.icon(
              onPressed: classifiying
                  ? null
                  : () {
                      classifyImage();
                    },
              label: const Text('Re-classify'),
              icon: classifiying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InteractiveViewer(
              child: OverlayedImages(
                tag: report?.id ?? 'loading...',
                imageSrc: report?.imgPath == null
                    ? srcImage
                    : Image.network(report!.imageUrl),
                imageDest: segImage,
              ),
            ),
            const Divider(),
            Text(
              '${labelFullForms[report?.label]?.toPascalCase() ?? 'Not yet classified yet.'}${cancerous(report?.label ?? '') ? ' (Cancerous)' : ''}',
              style: TextStyle(
                color: cancerous(report?.label ?? '')
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            Markdown(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: colorScheme.onSurface),
                listBullet: TextStyle(color: colorScheme.onSurface),
              ),
              data: report?.suggestions ?? 'No suggestions yet.',
            ),
          ],
        ),
      ),
    );
  }

  void extractMole(File image) async {
    log('Extracting mole from image: ${image.path}');
    setState(() {
      classifiying = true;
    });
    if (report != null) {
      showError('Report already segmented');
      return;
    }

    /// Extract mole from image
    try {
      report = await server.segmentImage(image.path);
    } catch (e) {
      showError('Error extracting mole: $e');
    }

    /// After check if report lable is null, if yes then classify image

    if (report!.label == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          classifiying = false;
        });
        classifyImage();
      });
    }
  }

  void classifyImage() async {
    log('Classifying image: ${report!.id}');
    setState(() {
      classifiying = true;
    });

    /// Classify image
    try {
      report = await server.classifyImage(report!);
    } catch (e) {
      showError('Error classifying image: $e');
    }

    setState(() {
      classifiying = false;
    });
  }
}

// class ReportScreen extends StatefulWidget {
//   final Report? report;
//   final XFile? image;
//   const ReportScreen({
//     required this.report,
//     required this.image,
//     super.key,
//   });
//   @override
//   State<ReportScreen> createState() => _ReportScreenState();
// }
// class _ReportScreenState extends State<ReportScreen> {
//   Report? report = widget.report;
//   bool loading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(report.label?.toUpperCase() ?? 'Report'),
//         actions: [
//           if (loading)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           else
//             IconButton(
//               onPressed: () async {
//                 try {
//                   setState(() {
//                     loading = true;
//                   });
//                   report = await server.classifyImage(report);
//                   setState(() {});
//                   showMsg('Re-classified as ${report.label}');
//                 } catch (e) {
//                   showError('Error: $e');
//                 }
//                 setState(() {
//                   loading = false;
//                 });
//               },
//               icon: const Icon(Icons.refresh),
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           InteractiveViewer(
//             child: OverlayedImages(
//               tag: report.id,
//               imageSrc: Image.network(report.imageUrl),
//               imageDest: Image.network(report.segImageUrl),
//             ),
//           ),
//           const Divider(),
//           Text(
//             labelFullForms[report.label]?.toPascalCase() ??
//                 'Not yet classified yet.',
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//           ),
//           const Divider(),
//           Text(
//             report.suggestions ?? 'No suggestions yet.',
//             style: const TextStyle(
//               color: Colors.white,
//             ),
//           ),
//           if (kDebugMode)
//             ElevatedButton(
//               onPressed: () async {
//                 /// Pick Image from server
//                 // final image =
//                 //     await ImagePicker().pickImage(source: ImageSource.gallery);
//                 // if (image == null) {
//                 //   return;
//                 // }
//                 // final imageBytes = await image.readAsBytes();
//                 /// Pick Image from Gallery
//                 final picker = ImagePicker();
//                 final image =
//                     await picker.pickImage(source: ImageSource.gallery);
//                 if (image == null) {
//                   print('No image selected');
//                   return;
//                 }
//                 final input = await File(image.path).readAsBytes();
//                 /// Classification
//                 final probabilities = await ImageClassifier.classifyImage(
//                   imageBytes: input,
//                   modelAssetPath: ImageClassifier.mobileNetV2ModelAssetPath,
//                 );
//                 /// Probablities to label
//                 final label = probabilities.indexOf(probabilities.reduce(max));
//                 showMsg('Classified as ${labelFullForms.keys.toList()[label]}');
//               },
//               child: const Text('Classify using MobileNet v2'),
//             ),
//         ],
//       ),
//     );
//   }
// }
