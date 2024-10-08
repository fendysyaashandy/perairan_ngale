import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'harga.freezed.dart';
part 'harga.g.dart';

@freezed
class Harga with _$Harga {
  const factory Harga({
    required int harga,
    required int denda,
  }) = _Harga;

  factory Harga.fromJson(Map<String, dynamic> json) => _$HargaFromJson(json);
  factory Harga.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Harga.fromJson(data);
  }
}
