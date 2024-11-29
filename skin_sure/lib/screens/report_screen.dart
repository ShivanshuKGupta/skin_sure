import 'package:flutter/material.dart';

import '../extensions/report_extension.dart';
import '../models/report.dart';
import '../services/notification_service.dart';
import '../services/server.dart';
import '../utils/extensions/string_extension.dart';
import '../utils/label_utils.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(report.label?.toUpperCase() ?? 'Report'),
        actions: [
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
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
          InteractiveViewer(
            child: OverlayedImages(
              tag: report.id,
              imageSrc: Image.network(report.imageUrl),
              imageDest: Image.network(report.segImageUrl),
            ),
          ),
          const Divider(),
          Text(
            labelFullForms[report.label]?.toPascalCase() ??
                'Not yet classified yet.',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const Divider(),
          Text(
            report.suggestions ?? 'No suggestions yet.',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
