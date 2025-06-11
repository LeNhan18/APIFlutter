
import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'gallery_classification_screen.dart';
// Import các màn hình YOLO mới
import 'gallery_classification_screen_yolo.dart';
import 'camera_screen_yolo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân loại rác thải', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4.0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[100]!,
              Colors.green[300]!,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ứng dụng Phân Loại Rác Thải',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Chọn chức năng bạn muốn sử dụng',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- MODEL PHÂN LOẠI RÁC CŨ ---
                      const Text("Mô hình phân loại rác", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GalleryClassificationScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo_library, size: 30),
                        label: const Text('Phân loại ảnh có sẵn'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt, size: 30),
                        label: const Text('Phân loại thời gian thực'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 10),
                      // --- MODEL YOLOV8 MỚI ---
                      const Text("Mô hình YOLOv8", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // SỬA Ở ĐÂY: Điều hướng đến màn hình YOLO mới
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GalleryClassificationScreenYolo(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo_library, size: 30),
                        label: const Text('Phân loại ảnh có sẵn'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.blue[600], // Đổi màu để phân biệt
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // SỬA Ở ĐÂY: Điều hướng đến màn hình YOLO mới
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScreenYolo(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt, size: 30),
                        label: const Text('Phân loại thời gian thực'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.blue[600], // Đổi màu để phân biệt
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
