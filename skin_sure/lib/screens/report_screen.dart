import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../extensions/report_extension.dart';
import '../globals.dart';
import '../models/chat/chat.dart';
import '../models/report.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../utils/extensions/string_extension.dart';
import '../utils/label_utils.dart';
import '../widgets/overlayed_images.dart';
import 'chat/chat_screen.dart';

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
                  await Future.delayed(const Duration(milliseconds: 500));
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
          ],
        ),
      ),
      floatingActionButton: report == null
          ? null
          : ElevatedButton.icon(
              onPressed: navigateToChatScreen,
              label: const Text('Need more help?'),
              icon: const Icon(Icons.question_answer_rounded),
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
      Future.delayed(const Duration(milliseconds: 100), () async {
        setState(() {
          classifiying = false;
        });
        await classifyImage();
        await navigateToChatScreen();
      });
    }
  }

  Future<void> classifyImage() async {
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

  Future<void> navigateToChatScreen() async {
    // report = await server.getSuggestions(report!.id);
    // setState(() {});
    report!.chat ??= ChatData(messages: [], title: 'Get more help');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ChatScreen(
          report: report!,
        );
      }),
    );
  }
}
