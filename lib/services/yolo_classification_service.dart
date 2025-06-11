
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/yolo_detection_result.dart';

// Tự động chọn đúng địa chỉ IP dựa trên nền tảng
String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000'; // Dùng cho web
  if (Platform.isAndroid) return '[http://10.0.2.2:8000](http://10.0.2.2:8000)'; // Dùng cho máy ảo Android
  return 'http://localhost:8000'; // Dùng cho iOS và các nền tảng khác
}

class YoloClassificationService {
  // Thay đổi endpoint thành '/predict/' để khớp với backend FastAPI
  final String apiUrl = '${getApiBaseUrl()}/predict/';

  Future<List<YoloDetectionResult>> classifyImage(Uint8List imageBytes) async {
    final url = Uri.parse(apiUrl);
    var request = http.MultipartRequest('POST', url);

    // Thêm file ảnh vào request
    request.files.add(http.MultipartFile.fromBytes(
      'file', // Tên field phải là 'file' để khớp với backend
      imageBytes,
      filename: 'upload.jpg', // Tên file không quá quan trọng
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final decodedJson = jsonDecode(responseBody);
        // Dữ liệu trả về có key là 'detections'
        final List<dynamic> resultsJson = decodedJson['detections'];

        // Chuyển đổi JSON thành list các đối tượng YoloDetectionResult
        return resultsJson
            .map((json) => YoloDetectionResult.fromJson(json))
            .toList();
      } else {
        throw Exception('Lỗi từ server: ${streamedResponse.statusCode} - $responseBody');
      }
    } on TimeoutException {
      throw Exception('Yêu cầu hết thời gian. Vui lòng kiểm tra kết nối mạng hoặc server.');
    } catch (e) {
      print('Lỗi khi phân loại ảnh YOLO: $e');
      rethrow;
    }
  }
}