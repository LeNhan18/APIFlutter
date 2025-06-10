
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/yolo_detection_result.dart';
import '../services/yolo_classification_service.dart';
import 'dart:async';

class CameraScreenYolo extends StatefulWidget {
  const CameraScreenYolo({super.key});

  @override
  State<CameraScreenYolo> createState() => _CameraScreenYoloState();
}

class _CameraScreenYoloState extends State<CameraScreenYolo> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessingFrame = false;
  final YoloClassificationService _classificationService = YoloClassificationService();
  List<YoloDetectionResult> _detections = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Xin quyền truy cập camera
    if (!kIsWeb) {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        print("Quyền truy cập camera bị từ chối");
        return;
      }
    }
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("Không tìm thấy camera");
        return;
      }
      _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startStreaming(); // Bắt đầu gửi frame để xử lý
      }
    } on CameraException catch (e) {
      print('Lỗi khởi tạo camera: $e');
    }
  }

  void _startStreaming() {
    // Gửi ảnh mỗi 2 giây để phân loại
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_controller == null || !_controller!.value.isInitialized || _isProcessingFrame) return;

      setState(() => _isProcessingFrame = true);

      try {
        final image = await _controller!.takePicture();
        final imageBytes = await image.readAsBytes();

        // Gọi service YOLOv8
        final results = await _classificationService.classifyImage(imageBytes);

        if (mounted) {
          setState(() {
            _detections = results;
          });
        }
      } catch (e) {
        print('Lỗi xử lý khung hình YOLO: $e');
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
        title: const Text('Phân loại YOLOv8 thời gian thực', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_isProcessingFrame) const Center(child: CircularProgressIndicator(color: Colors.white)),
          // Hiển thị kết quả
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.all(16.0),
              child: _buildDetectionsList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetectionsList() {
    if (_detections.isEmpty && !_isProcessingFrame) {
      return const Text(
        'Hướng camera vào đối tượng...',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16),
      );
    }
    // Tạo một chuỗi từ danh sách các đối tượng phát hiện được
    final resultText = _detections
        .map((d) => '${d.className} (${(d.confidence * 100).toStringAsFixed(0)}%)')
        .join(', ');

    return Text(
      resultText,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}