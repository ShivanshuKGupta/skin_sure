import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/report.dart';

class Server {
  Server._();

  static const serverUrl = 'http://192.168.150.64:3000';
  static const segmentUrl = '$serverUrl/segment';
  static const classifyUrl = '$serverUrl/classify';
  static const reportsUrl = '$serverUrl/public/reports.json';

  Future<Report> segmentImage(String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(segmentUrl),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imagePath,
    ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        log('Image uploaded successfully for segmentation!');
      } else {
        log('Failed to upload image. Status code: ${response.statusCode}');
      }

      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData) as Map;
      return Report.fromJson(data['report']);
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    }
  }

  Future<Report> classifyImage(Report report) async {
    final response = await http.post(
      Uri.parse(classifyUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(report.toJson()),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map;
      return Report.fromJson(data['report']);
    } else {
      throw ('Failed to classify image. Status code: ${response.statusCode}');
    }
  }

  Future<List<Report>> getReports() async {
    final response = await http.get(Uri.parse(reportsUrl));
    if (response.statusCode == 200) {
      final reports = json.decode(response.body) as Map;
      return reports.entries
          .map((entry) => Report.fromJson(entry.value))
          .toList();
    } else {
      throw ('Failed to load reports. Status code: ${response.statusCode}');
    }
  }
}

final server = Server._();
