import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/utils/logger.dart';

class UserRepository extends GetxController {
  static UserRepository get to => Get.find<UserRepository>();
  final _db = FirebaseFirestore.instance;

  createUser(Customer customer) async {
    await _db.collection("Customer").add(customer.toJson()).whenComplete(() =>
        Get.snackbar("Berhasil", "Akun berhasil dibuat.",
            snackPosition: SnackPosition.BOTTOM)).catchError((error,
        stackTrace) {
      Get.snackbar("Gagale", "Terjadi kesalahan, mohon coba kembali.",
          snackPosition: SnackPosition.BOTTOM);
      logger.e(error);
    });
    }
}
