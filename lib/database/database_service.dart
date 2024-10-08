import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCustomer(String uid, String customerNo, String nama, String alamat, String rt, String rw) async {
    await _firestore.collection('Customer').doc(uid).set({
      'customer_no': customerNo,
      'nama': nama,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
    });
  }

  Future<void> addRecordPendapatan(String uid, String userId, double meteran, String pathImage, double jumlahPendapatan) async {
    await _firestore.collection('Record Pendapatan').doc(uid).set({
      'user_id': userId,
      'meteran': meteran,
      'pathImage': pathImage,
      'jumlah_pendapatan': jumlahPendapatan,
    });
  }

  Future<void> addEmployee(String uid, String nama, List<String> customerIds) async {
    await _firestore.collection('Employee').doc(uid).set({
      'nama': nama,
      'customer_ids': customerIds,
    });
  }

  Future<void> addAdmin(String uid, String nama) async {
    await _firestore.collection('Admin').doc(uid).set({
      'nama': nama,
    });
  }

  Future<void> addRecordPengeluaran(String uid, DateTime tanggal, String deskripsi, double jumlahPengeluaran, String pathImage) async {
    await _firestore.collection('Record Pengeluaran').doc(uid).set({
      'tanggal': tanggal,
      'deskripsi': deskripsi,
      'jumlah_pengeluaran': jumlahPengeluaran,
      'pathImage': pathImage,
    });
  }

  Future<void> addCompany(String uid, double saldo, double totalPendapatan, double totalPengeluaran) async {
    await _firestore.collection('Perusahaan').doc(uid).set({
      'saldo': saldo,
      'total_pendapatan': totalPendapatan,
      'total_pengeluaran': totalPengeluaran,
    });
  }

  Future<DocumentSnapshot> getCustomerById(String uid) async {
    return await _firestore.collection('Customer').doc(uid).get();
  }

  Future<DocumentSnapshot> getRecordPendapatanById(String uid) async {
    return await _firestore.collection('Record Pendapatan').doc(uid).get();
  }

  Future<DocumentSnapshot> getEmployeeById(String uid) async {
    return await _firestore.collection('Employee').doc(uid).get();
  }

  Future<DocumentSnapshot> getAdminById(String uid) async {
    return await _firestore.collection('Admin').doc(uid).get();
  }

  Future<DocumentSnapshot> getRecordPengeluaranById(String uid) async {
    return await _firestore.collection('Record Pengeluaran').doc(uid).get();
  }

  Future<DocumentSnapshot> getCompanyById(String uid) async {
    return await _firestore.collection('Perusahaan').doc(uid).get();
  }

  Future<void> editCustomer(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('Customer').doc(uid).update(data);
  }

  Future<void> editEmployee(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('Employee').doc(uid).update(data);
  }

  Future<void> editAdmin(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('Admin').doc(uid).update(data);
  }

  Future<void> deleteCustomer(String uid) async {
    await _firestore.collection('Customer').doc(uid).delete();
  }

  Future<void> deleteEmployee(String uid) async {
    await _firestore.collection('Employee').doc(uid).delete();
  }

  Future<void> deleteAdmin(String uid) async {
    await _firestore.collection('Admin').doc(uid).delete();
  }

  Stream<QuerySnapshot> getAllCustomers() {
    return _firestore.collection('Customer').snapshots();
  }

  Stream<QuerySnapshot> getAllEmployees() {
    return _firestore.collection('Employee').snapshots();
  }

  Stream<QuerySnapshot> getAllAdmins() {
    return _firestore.collection('Admin').snapshots();
  }

  Stream<QuerySnapshot> getAllRecordPendapatan() {
    return _firestore.collection('Record Pendapatan').snapshots();
  }

  Stream<QuerySnapshot> getAllRecordPengeluaran() {
    return _firestore.collection('Record Pengeluaran').snapshots();
  }
}
