import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Tự động chọn đúng địa chỉ IP dựa trên nền tảng
String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://localhost:8000';
}

class WasteClassificationResult {
  // Đưa các trường cũ quay trở lại để khớp với API Python
  final bool isRecyclable;
  final double recyclableConfidence;
  final String category;
  final double categoryConfidence;
  // Xóa trường bbox vì API hiện tại không cung cấp
  
  WasteClassificationResult({
    required this.isRecyclable,
    required this.recyclableConfidence,
    required this.category,
    required this.categoryConfidence,
  });

  factory WasteClassificationResult.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return defaultValue;
    }

    return WasteClassificationResult(
      // API Python trả về 'recyclable' và 'recyclableConfidence'
      isRecyclable: json['recyclable'] ?? false,
      recyclableConfidence: _toDouble(json['recyclableConfidence']),
      category: json['category'] ?? 'Unknown',
      categoryConfidence: _toDouble(json['categoryConfidence']),
    );
  }
}

class ClassificationResponse {
  final List<WasteClassificationResult> results;
  final String message;

  ClassificationResponse({required this.results, required this.message});

  factory ClassificationResponse.fromJson(Map<String, dynamic> json) {
    var resultsList = json['results'] as List? ?? [];
    List<WasteClassificationResult> parsedResults = resultsList
        .map((i) => WasteClassificationResult.fromJson(i))
        .toList();
    return ClassificationResponse(
      results: parsedResults,
      message: json['message'] ?? '',
    );
  }
}

class WasteClassificationService {
  // SỬA LỖI: Gọi đúng endpoint là '/classify_garbage'
  final String apiUrl = '${getApiBaseUrl()}/classify_garbage';

  Future<List<WasteClassificationResult>> classifyImage(Uint8List imageBytes, String filename) async {
    final url = Uri.parse(apiUrl);
    var request = http.MultipartRequest('POST', url);

    // SỬA LỖI: Luôn giả định file là 'image.jpg' để đảm bảo tính tương thích
    // trên mọi nền tảng, đặc biệt là web.
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'image.jpg', // Tên file giả định
      contentType: MediaType('image', 'jpeg'), // Loại nội dung giả định
    ));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();
      print('API Status: ${streamedResponse.statusCode}');
      print('API Body: $responseBody');

      if (streamedResponse.statusCode == 200) {
        final decodedJson = jsonDecode(responseBody);
        return ClassificationResponse.fromJson(decodedJson).results;
      } else {
        throw HttpException('Lỗi từ API: ${streamedResponse.statusCode} - $responseBody');
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
      rethrow;
    }
  }
}
