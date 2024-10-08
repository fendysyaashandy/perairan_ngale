import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/auth.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final User? user = Auth().currentUser;
  Admin? _admin;
  Future<Admin> getAdmin(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(userId)
        .get();

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
    return AutoTabsScaffold(
      routes: [
        AdminHomeRoute(),
        AdminCustomerRoute(),
        AdminTabsRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: (index) async {
            if (index == 3) {
              await _showLogoutConfirmationDialog(context);
            } else {
              tabsRouter.setActiveIndex(index);
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(IconsaxPlusBold.home_2),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(IconsaxPlusBold.profile_2user),
              label: 'Pelanggan',
            ),
            NavigationDestination(
              icon: Icon(IconsaxPlusBold.receipt_text),
              label: 'Transaksi',
            ),
            NavigationDestination(
              icon: Icon(IconsaxPlusBold.logout),
              label: 'Keluar',
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar', style: context.textTheme.bodyMediumBold),
          content: Text('Apakah Anda yakin ingin keluar dari Admin?', style: context.textTheme.bodyMedium),
          actions: [
            TextButton(
              child: Text('Batal', style: context.textTheme.bodyMediumBold),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: TextButton(
                child: Text('Keluar', style: context.textTheme.bodyMediumBoldBright),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  AutoRouter.of(context).pushAndPopUntil(LoginRoute(), predicate: (route) => false);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
