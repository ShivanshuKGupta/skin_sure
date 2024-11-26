import 'package:camera/camera.dart';

class CameraSingleton {
  CameraSingleton._();

  List<CameraDescription> cameras = [];
  Future<List<CameraDescription>> getCameras() async {
    return cameras = await availableCameras();
  }
}

final cameraSingleton = CameraSingleton._();
