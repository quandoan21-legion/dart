import 'package:sqlite3/sqlite3.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Database createDatabase() {
  final db = sqlite3.open('my_database.sqlite');
  db.execute('''
    CREATE TABLE IF NOT EXISTS students (
      id    TEXT PRIMARY KEY,
      name  TEXT NOT NULL,
      math  REAL NOT NULL,
      eng   REAL NOT NULL
    );
  ''');
  return db;
}

void deleteStudentById(Database db) {
  final RegExp numbersOnlyRegex = RegExp(r'^\d+$');
  while (true) {
    print('\n--- XOÁ SINH VIÊN THEO ID ---');
    stdout.write('Id Sinh Viên Bạn Muốn Xoá: ');
    final String? id = stdin.readLineSync();
    if (id == null || id.trim().isEmpty || !numbersOnlyRegex.hasMatch(id)) {
      continue;
    }
    var checkStudentByIdSql = db.select(
      'Select id FROM students WHERE id = ?',
      [id],
    );
    if (checkStudentByIdSql.isEmpty) {
      print("Không có sinh viên với ID này ");
      break;
    }
    db.execute('DELETE FROM students WHERE id = ?', [id]);
    print('Xoá thành công sinh viên có ID ${id}');
    break;
  }
}

void findStudentByName(Database db) {
  while (true) {
    print('\n--- Tìm SINH VIÊN THEO Tên ---');
    stdout.write('Tên Sinh Viên Bạn Muốn Tìm: ');
    final String? name = stdin.readLineSync();
    if (name == null || name.trim().isEmpty) {
      continue;
    }
    var checkStudentByNameSql = db.select(
      'Select * FROM students WHERE name LIKE ?',
      ['%$name%'],
    );
    if (checkStudentByNameSql.isEmpty) {
      print("Không có sinh viên với Tên này ");
      break;
    }
    for (final student in checkStudentByNameSql) {
      print('ID: ${student['id']} | '
      'Tên: ${student['name']} | '
      'Điểm Toán: ${student['math']} | '
      'Điểm Anh: ${student['eng']} | ');
    }
    break;
  }
}

void showAllStudents(Database db) {
  print('\n--- DANH SÁCH SINH VIÊN ---');
  var sql = 'SELECT id, name, math, eng FROM students ORDER BY id;';
  final result = db.select(sql);
  if (result.isEmpty) {
    print('Danh sách đang trống!');
    return;
  }

  for (final student in result) {
    print(
      'ID: ${student['id']} | '
      'Tên: ${student['name']} | '
      'Điểm Toán: ${student['math']} | '
      'Điểm Anh: ${student['eng']} ',
    );
  }
  print('Tổng số sinh viên là ${result.length}');
}

void addNewStudent(Database db) {
  final RegExp numbersOnlyRegex = RegExp(r'^\d+$');
  while (true) {
    print('\n--- THÊM SINH VIÊN MỚI ---');

    stdout.write('Nhập ID sinh viên: ');
    final inputId = stdin.readLineSync();

    if (inputId == null || inputId.trim().isEmpty) {
      print('ID không được để trống!');
      continue;
    }

    final id = inputId.trim();

    if (!numbersOnlyRegex.hasMatch(id)) {
      print('ID chỉ được chứa chữ số (0-9)!');
      continue;
    }

    final check = db.select(
      'SELECT COUNT(*) AS cnt FROM students WHERE id = ?',
      [id],
    );
    final count = check.first['cnt'] as int;
    if (count > 0) {
      print('ID $id đã tồn tại trong hệ thống!');
      continue;
    }

    stdout.write('Nhập tên sinh viên: ');
    final nameInput = stdin.readLineSync();
    final name = (nameInput == null || nameInput.trim().isEmpty)
        ? 'No Name'
        : nameInput.trim();

    stdout.write('Nhập điểm Toán: ');
    final mathStr = stdin.readLineSync() ?? '0';
    final math = double.tryParse(mathStr) ?? 0.0;

    stdout.write('Nhập điểm Anh: ');
    final engStr = stdin.readLineSync() ?? '0';
    final eng = double.tryParse(engStr) ?? 0.0;

    db.execute(
      'INSERT INTO students (id, name, math, eng) VALUES (?, ?, ?, ?)',
      [id, name, math, eng],
    );

    print('Thêm sinh viên mới thành công!');
    break;
  }
}

void studentManagement(Database db) {
  outerLoop:
  while (true) {
    print('\n================ QUẢN LÝ SINH VIÊN (SQLite) ================');
    print('1. Xem danh sách sinh viên');
    print('2. Thêm sinh viên mới');
    print('3. Xóa sinh viên theo ID');
    print('4. Tìm kiếm sinh viên theo tên');
    print('0. Thoát');
    stdout.write('Chọn từ 0-4: ');
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        showAllStudents(db);
      case '2':
        addNewStudent(db);
      case '3':
        deleteStudentById(db);

      case '4':
        findStudentByName(db);
      case '0':
        break outerLoop;
    }
  }
}
