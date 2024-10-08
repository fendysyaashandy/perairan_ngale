import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaksi.freezed.dart';
part 'transaksi.g.dart';

@freezed
class Transaksi with _$Transaksi {
  const factory Transaksi({
    required String tanggal,
    required String status,
    required double saldo,
    double? meteran,
    double? meteranBulanLalu,
    required String userId,
    required String employeeId,
    @Default(null) String? pathImage,
    required String deskripsi,
    required int bulan,
    required int tahun,
  }) = _Transaksi;

  factory Transaksi.fromJson(Map<String, dynamic> json) =>
      _$TransaksiFromJson(json);

  factory Transaksi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaksi.fromJson(data);
  }
}
