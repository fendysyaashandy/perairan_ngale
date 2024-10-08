import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> isAdmin(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Admin').doc(userId).get();
    return userSnapshot.exists;
  } catch (e) {
    print('Error checking admin status: $e');
    return false;
  }
}

Future<bool> isEmployee(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Employee').doc(userId).get();
    return userSnapshot.exists;
  } catch (e) {
    print('Error checking employee status: $e');
    return false;
  }
}

Future<bool> isCustomer(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Customer').doc(userId).get();
    return userSnapshot.exists;
  } catch (e) {
    print('Error checking customer status: $e');
    return false;
  }
}
