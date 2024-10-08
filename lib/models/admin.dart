import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'admin.freezed.dart';
part 'admin.g.dart';

@freezed
class Admin with _$Admin {
  const factory Admin({
    required String uid,
    required String nama,
  }) = _Admin;

  factory Admin.fromJson(Map<String, Object> json) => _$AdminFromJson(json);
  factory Admin.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return Admin(
          uid: doc.id,
          nama: data['nama'],
        );
      } else {
        throw Exception('Document data is null');
      }
    } else {
      throw Exception('Document does not exist');
    }
  }
}