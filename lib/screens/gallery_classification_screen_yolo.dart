import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/yolo_detection_result.dart';
import '../services/yolo_classification_service.dart';

class GalleryClassificationScreenYolo extends StatefulWidget {
  const GalleryClassificationScreenYolo({super.key});

  @override
  State<GalleryClassificationScreenYolo> createState() =>
      _GalleryClassificationScreenYoloState();
}

class _GalleryClassificationScreenYoloState
    extends State<GalleryClassificationScreenYolo> {
  Uint8List? _imageBytes;
  ui.Image? _imageInfo;
  List<YoloDetectionResult> _detections = [];
  bool _isLoading = false;
  String? _errorMessage;

  final YoloClassificationService _classificationService =
  YoloClassificationService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndClassifyImage() async {
    try {
      final XFile? imageFile = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (imageFile == null) return;

      final bytes = await imageFile.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);

      setState(() {
        _imageBytes = bytes;
        _imageInfo = decodedImage;
        _detections = [];
        _errorMessage = null;
        _isLoading = true;
      });

      try {
        final results = await _classificationService.classifyImage(bytes);
        if (mounted) {
          setState(() {
            _detections = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Lỗi khi phân loại ảnh: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi chọn ảnh: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân loại bằng YOLOv8',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndClassifyImage,
              icon: const Icon(Icons.photo),
              label: const Text('Chọn ảnh để phân loại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
            if (_imageBytes != null && _imageInfo != null)
              FittedBox(
                child: SizedBox(
                  width: _imageInfo!.width.toDouble(),
                  height: _imageInfo!.height.toDouble(),
                  child: Stack(
                    children: [
                      Image.memory(_imageBytes!),
                      // Vẽ các bounding box lên trên ảnh
                      ..._detections.map((detection) {
                        return Positioned(
                          left: detection.boundingBox.x1,
                          top: detection.boundingBox.y1,
                          width: detection.boundingBox.x2 -
                              detection.boundingBox.x1,
                          height: detection.boundingBox.y2 -
                              detection.boundingBox.y1,
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.red, width: 2),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                color: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  '${detection.className} (${(detection.confidence * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            if (!_isLoading && _imageBytes != null && _detections.isEmpty && _errorMessage == null)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Không phát hiện được đối tượng nào.'),
              )),
          ],
        ),
      ),
    );
  }
}