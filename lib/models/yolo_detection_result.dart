// Mô hình để lưu trữ kết quả trả về từ API YOLOv8

class BoundingBox {
  final double x1;
  final double y1;
  final double x2;
  final double y2;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num? ?? 0.0).toDouble(),
      y1: (json['y1'] as num? ?? 0.0).toDouble(),
      x2: (json['x2'] as num? ?? 0.0).toDouble(),
      y2: (json['y2'] as num? ?? 0.0).toDouble(),
    );
  }
}

class YoloDetectionResult {
  final String className;
  final double confidence;
  final BoundingBox boundingBox;

  YoloDetectionResult({
    required this.className,
    required this.confidence,
    required this.boundingBox,
  });

  factory YoloDetectionResult.fromJson(Map<String, dynamic> json) {
    return YoloDetectionResult(
      className: json['class_name'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      boundingBox: BoundingBox.fromJson(json['bounding_box'] ?? {}),
    );
  }
}