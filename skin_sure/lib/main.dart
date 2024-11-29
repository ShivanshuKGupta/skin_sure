import 'package:flutter/material.dart';

import 'app.dart';
import 'services/camera_singleton.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cameraSingleton.getCameras();
  runApp(const App());
}
