import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_classification_result.dart';

class HistoryService {
  static const String _storageKey = 'waste_classification_history';
  // Khởi tạo danh sách trống
  List<WasteClassificationResult> _predictions = [];

  // Xóa constructor và hàm _loadPredictions cũ

  // Hàm load mới, trả về Future để có thể await
  Future<void> loadPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_storageKey);
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      // Gán dữ liệu đã load vào _predictions
      _predictions = decoded.map((item) => WasteClassificationResult.fromJson(item)).toList();
    }
  }

  Future<void> _savePredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_predictions.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  // Get a copy of the predictions
  List<WasteClassificationResult> getPredictions() {
    return List.unmodifiable(_predictions);
  }

  Future<void> addPrediction(WasteClassificationResult prediction) async {
    _predictions.insert(0, prediction);
    await _savePredictions();
  }

  Future<void> removePrediction(int index) async {
    if (index >= 0 && index < _predictions.length) {
      _predictions.removeAt(index);
      await _savePredictions();
    }
  }

  Future<void> clearHistory() async {
    _predictions.clear();
    await _savePredictions();
  }
}