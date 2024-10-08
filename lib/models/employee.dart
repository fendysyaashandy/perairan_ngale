// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
class Employee with _$Employee {
  const factory Employee({
    required String uid,
    required String nama,
    required String alamatTower,
  }) = _Employee;

  factory Employee.fromJson(Map<String, Object> json) =>
      _$EmployeeFromJson(json);
  factory Employee.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return Employee(
          uid: doc.id,
          nama: data['nama'],
          alamatTower: data['alamatTower'],
        );
      } else {
        throw Exception('Document data is null');
      }
    } else {
      throw Exception('Document does not exist');
    }
  }
}
