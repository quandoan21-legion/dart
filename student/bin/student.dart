import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:student/student.dart' as student;
import 'package:sqlite3/sqlite3.dart';
import 'package:student/student.dart';

void main() {
  final Database db = createDatabase();
  studentManagement(db);
}
