import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// Import mô hình đúng
import '../models/waste_classification_result.dart';

// Tự động chọn đúng địa chỉ IP dựa trên nền tảng
String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://localhost:8000';
}

class WasteClassificationService {
  final String apiUrl = '${getApiBaseUrl()}/classify_garbage';

  Future<List<WasteClassificationResult>> classifyImage(Uint8List imageBytes, String filename) async {
    final url = Uri.parse(apiUrl);
    var request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'image.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));


    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await streamedResponse.stream.bytesToString();

      print('API Status: ${streamedResponse.statusCode}');
      print('API Body: $responseBody');

      if (streamedResponse.statusCode == 200) {
        final decodedJson = jsonDecode(responseBody);
        final List<dynamic> resultsJson = decodedJson['results'];

        // DÒNG ĐÃ SỬA: Gọi đến factory fromJson an toàn
        return resultsJson
            .map((json) => WasteClassificationResult.fromJson(json))
            .toList();

      } else {
        throw Exception('Lỗi từ server: ${streamedResponse.statusCode} - $responseBody');
      }
    } on TimeoutException {
      throw Exception('Yêu cầu hết thời gian. Vui lòng kiểm tra kết nối mạng hoặc server.');
    } catch (e) {
      print('Lỗi khi phân loại ảnh: $e');
      rethrow;
    }
  }
}