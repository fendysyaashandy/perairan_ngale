import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:perairan_ngale/features/admin/view/customer_list_all.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/auth.dart';
import 'package:perairan_ngale/widgets/custom_gesture_unfocus.dart';

@RoutePage()
class AdminCustomerPage extends StatefulWidget {
  const AdminCustomerPage({super.key});

  @override
  State<AdminCustomerPage> createState() => _AdminCustomerPageState();
}

class _AdminCustomerPageState extends State<AdminCustomerPage> {
  final User? user = Auth().currentUser;
  Admin? _admin;

  Future<Admin> getAdmin(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('Admin').doc(userId).get();

    final admin = Admin.fromFirestore(doc);
    return admin;
  }

  Future<void> _getAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final admin = await getAdmin(user.uid);
    setState(() {
      _admin = admin;
    });
    print(admin.nama);
  }

  @override
  void initState() {
    super.initState();
    _getAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('Data Pelanggan')),
      ),
      body: CustomGestureUnfocus(
        child: Column(
          children: [
            Expanded(
                child: _admin != null
                    ? CustomerListAll(
                        admin: _admin!,
                      )
                    : Center(child: Text('Coba Lagi'))),
          ],
        ),
      ),
    );
  }
}
