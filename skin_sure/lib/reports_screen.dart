import 'package:flutter/material.dart';

import 'server.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final future = server.getReports();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('No Reports Yet!'));
            }
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text(DateTime.fromMillisecondsSinceEpoch(
                          int.tryParse(report.id) ?? 0)
                      .toIso8601String()),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      '${Server.serverUrl}/public/${report.id}.jpg',
                    ),
                  ),
                  subtitle: Text(report.label ?? 'Not classified yet'),
                );
              },
            );
          }),
    );
  }
}
