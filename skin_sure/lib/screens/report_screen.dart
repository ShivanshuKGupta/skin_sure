import 'dart:developer';

import 'package:flutter/material.dart';

import '../extensions/report_extension.dart';
import '../models/report.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../widgets/overlayed_images.dart';

class ReportScreen extends StatefulWidget {
  final Report report;
  const ReportScreen({required this.report, super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Report report = widget.report;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    log('report.imageUrl = ${report.imageUrl}');
    return Scaffold(
      appBar: AppBar(
        title: Text(report.createdAt.toString()),
        actions: [
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            )
          else
            IconButton(
              onPressed: () async {
                try {
                  setState(() {
                    loading = true;
                  });
                  report = await server.classifyImage(report);
                  setState(() {});
                  showMsg('Re-classified as ${report.label}');
                } catch (e) {
                  showError('Error: $e');
                }
                setState(() {
                  loading = false;
                });
              },
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: Column(
        children: [
          OverlayedImages(
            imageSrc: Image.network(report.imageUrl),
            imageDest: Image.network(report.segImageUrl),
          ),
          const Divider(),
          Text(report.label ?? 'Not yet classified yet.'),
          const Divider(),
          Text(report.suggestions ?? 'No suggestions yet.'),
        ],
      ),
    );
  }
}
