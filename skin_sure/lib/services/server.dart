import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/report.dart';

class Server {
  Server._();

  static const defaultServerUrl = !kDebugMode
      ? 'https://wds1cg8m-3000.inc1.devtunnels.ms'
      : 'http://192.168.150.64:3000';
  static String serverUrl = defaultServerUrl;
  static String get segmentUrl => '$serverUrl/segment';
  static String get classifyUrl => '$serverUrl/classify';
  static String get reportsUrl => '$serverUrl/public/reports.json';
  static String get deleteUrl => '$serverUrl/delete-report';

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
      headers: {'Content-Type': 'application/json'},
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

  Future<void> deleteReport(Report report) async {
    final response = await http.post(
      Uri.parse(deleteUrl),
      body: json.encode(report.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw ('Failed to delete report. Status code: ${response.statusCode}');
    }
  }
}

final server = Server._();
