import '../models/report.dart';
import '../services/server.dart';

extension ReportExtension on Report {
  String get imageUrl => '${Server.serverUrl}/$imgPath';
  String get segImageUrl => '${Server.serverUrl}/$segImagePath';
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(int.tryParse(id) ?? 0);
}
