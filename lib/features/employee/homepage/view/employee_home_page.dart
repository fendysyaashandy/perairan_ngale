// ignore_for_file: unnecessary_import

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/features/employee/homepage/view/customer_list.dart';
import 'package:perairan_ngale/models/auth.dart';
import 'package:perairan_ngale/models/employee.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({Key? key}) : super(key: key);

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final User? user = Auth().currentUser;
  Employee? _employee;
  Future<Employee> getEmployee(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(userId)
        .get();

    final employee = Employee.fromFirestore(doc);
    return employee;
  }

  Future<void> _getEmployee() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final employee = await getEmployee(user.uid);
    setState(() {
      _employee = employee;
    });
    print(employee.nama);
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  void initState() {
    super.initState();
    _getEmployee();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTopBarWidget(),
          SizedBox(height: 16),
          Expanded(
              child: _employee != null
                  ? CustomerList(
                      employee: _employee!,
                    )
                  : Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildTopBarWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: svg.Svg('assets/Frame 6.svg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          _buildTopBarContentWidget(),
        ],
      ),
    );
  }

  Widget _buildTopBarContentWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusLinear.profile_circle,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
            ),
            if (_employee != null)
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_employee != null)
                        Text(
                          _employee!.nama,
                          style: context.textTheme.bodyMediumBoldBright,
                        ),
                      const SizedBox(
                        height: Styles.smallSpacing,
                      ),
                      Text(
                        _employee!.alamatTower,
                        style: context.textTheme.bodySmallBright,
                      ),
                    ]),
              ),
            IconButton(
              icon: const Icon(
                IconsaxPlusLinear.logout,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar',
              style: context.textTheme.bodyMediumBold),
          content: Text('Apakah Anda yakin ingin keluar dari Petugas?',
              style: context.textTheme.bodyMedium),
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
                child: Text('Keluar',
                    style: context.textTheme.bodyMediumBoldBright),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  AutoRouter.of(context).pushAndPopUntil(LoginRoute(),
                      predicate: (route) => false);
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
