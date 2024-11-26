import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

import 'report.dart';

class Server {
  Server._();

  static const serverUrl = 'http://192.168.52.2:3000';
  static const segmentUrl = '$serverUrl/segment';
  static const classifyUrl = '$serverUrl/classify';
  static const reportsUrl = '$serverUrl/public/reports.json';

  Future<Report> segmentImage(XFile image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(segmentUrl),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
    ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully for segmentation!');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }

      final responseData = await response.stream.bytesToString();
      return Report.fromJson(json.decode(responseData)['report']);
    } catch (e) {
      print('Error uploading image: $e');
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
      return Report.fromJson(json.decode(response.body)['report']);
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
