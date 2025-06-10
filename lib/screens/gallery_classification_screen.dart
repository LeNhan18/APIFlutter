import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/waste_classification_service.dart';
import '../services/history_service.dart';
import '../models/waste_classification_result.dart';
import 'package:flutter/cupertino.dart';

class GalleryClassificationScreen extends StatefulWidget {
  const GalleryClassificationScreen({super.key});

  @override
  State<GalleryClassificationScreen> createState() => _GalleryClassificationScreenState();
}

class _GalleryClassificationScreenState extends State<GalleryClassificationScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  final WasteClassificationService _classificationService = WasteClassificationService();
  WasteClassificationResult? _classificationResult;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showHistory = false;
  List<WasteClassificationResult> _predictions = [];
  final HistoryService _historyService = HistoryService();
  bool _isHistoryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  void _loadPredictions() {
    setState(() {
      _predictions = _historyService.getPredictions();
    });
  }
  Future<void> _loadHistory() async {
    await _historyService.loadPredictions(); // Await cho đến khi dữ liệu được tải
    if (mounted) {
      setState(() {
        _predictions = _historyService.getPredictions();
        _isHistoryLoading = false; // Cập nhật trạng thái loading
      });
    }
  }
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _classificationResult = null;
          _errorMessage = null;
          _isLoading = true;
          _showHistory = false;
        });

        try {
          final results = await _classificationService.classifyImage(bytes, image.name);
          if (mounted) {
            setState(() {
              _classificationResult = results.isNotEmpty ? results.first : null;
              if (_classificationResult != null) {
                _historyService.addPrediction(_classificationResult!);
                _loadPredictions();
                _loadHistory();
              }
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
        title: const Text('Phân loại ảnh có sẵn', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.photo_library : Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
                if (_showHistory) {
                  _loadPredictions();
                }
              });
            },
          ),
        ],
      ),
      body: _showHistory
          ? _buildHistoryView()
          : _buildClassificationView(),
    );
  }

  Widget _buildHistoryView() {
    if (_predictions.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có lịch sử dự đoán nào',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _predictions.length,
      itemBuilder: (context, index) {
        final prediction = _predictions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Icon(
              prediction.isRecyclable ? Icons.recycling : Icons.delete_outline,
              color: prediction.isRecyclable ? Colors.green : Colors.red,
              size: 40,
            ),
            title: Text(
              prediction.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Độ tin cậy: ${(prediction.categoryConfidence * 100).toStringAsFixed(1)}%\n'
              'Thời gian: ${prediction.timestamp.toString()}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _historyService.removePrediction(index);
                _loadPredictions();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassificationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Chọn ảnh từ thư viện'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_imageBytes != null) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_imageBytes!, height: 300, fit: BoxFit.cover)),
          const SizedBox(height: 24),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),

          if (_classificationResult != null && !_isLoading)
            Card(
               elevation: 4,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               child: ListTile(
                 title: Text(_classificationResult!.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                 subtitle: Text(
                   'Độ tin cậy: ${(_classificationResult!.categoryConfidence * 100).toStringAsFixed(1)}%',
                   style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w500),
                 ),
                 leading: Icon(
                   _classificationResult!.isRecyclable ? Icons.recycling : Icons.delete_outline,
                   color: _classificationResult!.isRecyclable ? Colors.green : Colors.red,
                   size: 40,
                 ),
               ),
             ),
          
          if (!_isLoading && _imageBytes != null && _classificationResult == null && _errorMessage == null)
            const Center(child: Text('Không thể phân loại đối tượng trong ảnh.')),
        ],
      ),
    );
  }
}
