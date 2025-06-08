import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/waste_classification_service.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;
  final WasteClassificationService _classificationService = WasteClassificationService();
  WasteClassificationResult? _classificationResult; // Chỉ cần 1 kết quả
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (!status.isGranted) return;
    }
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startStreaming();
      }
    } on CameraException catch (e) {
      print('Lỗi khởi tạo camera: ${e.code}');
    }
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_controller == null || !_controller!.value.isInitialized || _isProcessingFrame) return;
      setState(() => _isProcessingFrame = true);
      try {
        final image = await _controller!.takePicture();
        final imageBytes = await image.readAsBytes();
        final results = await _classificationService.classifyImage(imageBytes, image.name);
        if (mounted) {
          setState(() {
            _classificationResult = results.isNotEmpty ? results.first : null;
          });
        }
      } catch (e) {
        print('Lỗi xử lý khung hình: $e');
      } finally {
        if (mounted) setState(() => _isProcessingFrame = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân loại thời gian thực', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_isProcessingFrame) const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (_classificationResult != null && !_isProcessingFrame)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: (_classificationResult!.isRecyclable ? Colors.green : Colors.red).withOpacity(0.8),
                child: Text(
                  '${_classificationResult!.category.toUpperCase()} (${(_classificationResult!.categoryConfidence * 100).toStringAsFixed(0)}%)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
