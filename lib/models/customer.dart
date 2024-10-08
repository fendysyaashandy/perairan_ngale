import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String uid,
    required String customerNo,
    required String nama,
    required String alamat,
    required String noTelpon,
    required String rt,
    required String alamatTower,
    required String rw,
  }) = _Customer;

  factory Customer.fromJson(Map<String, Object> json) =>
      _$CustomerFromJson(json);
  factory Customer.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        return Customer(
          uid: doc.id,
          alamatTower: data['alamatTower'],
          noTelpon: data['noTelpon'],
          customerNo: data['customer_no'],
          nama: data['nama'],
          alamat: data['alamat'],
          rt: data['rt'],
          rw: data['rw'],
        );
      } else {
        throw Exception('Document data is null');
      }
    } else {
      throw Exception('Document does not exist');
    }
  }
}
