// lib/student.dart

// 1. Import thư viện intl đã cài
import 'package:intl/intl.dart';

class Student {
  String id;
  String name;
  DateTime dateOfBirth;
  double score;

  // Constructor
  Student({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    this.score = 0.0,
  });

  // Method 1: Lấy tuổi
  int get age {
    return DateTime.now().year - dateOfBirth.year;
  }

  // Method 2: In thông tin (Sử dụng intl để format ngày)
  void showInfo() {
    // Định dạng ngày tháng kiểu Việt Nam (dd/MM/yyyy)
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateOfBirth);
    
    print('-------------------------');
    print('SV: $name (ID: $id)');
    print('Ngày sinh: $formattedDate (Tuổi: $age)');
    print('Điểm: $score -> Xếp loại: ${_classify()}');
  }

  // Method private (chỉ dùng trong nội bộ class này)
  String _classify() {
    if (score >= 8.0) return 'Giỏi';
    if (score >= 5.0) return 'Khá';
    return 'Trung bình';
  }
}