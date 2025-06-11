class WasteClassificationResult {
  final String category;
  final double categoryConfidence;
  final bool isRecyclable;
  final DateTime timestamp;

  WasteClassificationResult({
    required this.category,
    required this.categoryConfidence,
    required this.isRecyclable,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'categoryConfidence': categoryConfidence,
      'isRecyclable': isRecyclable,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WasteClassificationResult.fromJson(Map<String, dynamic> json) {
    return WasteClassificationResult(
      // Xử lý khoảng trắng thừa
      category: (json['category'] as String? ?? 'Unknown').trim(),

      // Xử lý an toàn cho giá trị số
      categoryConfidence: (json['categoryConfidence'] as num? ?? 0.0).toDouble(),

      // Xử lý cả hai trường hợp "isRecyclable" (từ history) và "recyclable" (từ API)
      isRecyclable: json['isRecyclable'] ?? json['recyclable'] ?? false,

      // Xử lý timestamp: nếu có thì dùng, không có (từ API) thì để constructor tự tạo
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}