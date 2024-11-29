import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../extensions/report_extension.dart';
import '../models/report.dart';
import '../screens/report_screen.dart';
import '../utils/extensions/datetime_extension.dart';
import '../utils/extensions/string_extension.dart';
import '../utils/label_utils.dart';
import 'overlayed_images.dart';

class ReportTile extends StatefulWidget {
  final Report report;

  const ReportTile({required this.report, super.key});

  @override
  State<ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  late Report report = widget.report;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportScreen(
                report: report,
              ),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: OverlayedImages(
                  tag: report.id,
                  imageSrc: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: report.imageUrl,
                  ),
                  imageDest: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: report.segImageUrl,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        labelFullForms[report.label]?.toPascalCase() ?? 'NaN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${report.createdAt.amPmTime} | ${report.createdAt.toMonthString()}',
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
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
