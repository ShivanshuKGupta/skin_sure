import 'package:flutter/material.dart';

import '../extensions/report_extension.dart';
import '../models/report.dart';
import '../services/server.dart';
import '../widgets/report_tile.dart';
import 'camera_screen.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
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
                return const Center(child: Text('No Reports Yet!'));
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CameraScreen()));
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
