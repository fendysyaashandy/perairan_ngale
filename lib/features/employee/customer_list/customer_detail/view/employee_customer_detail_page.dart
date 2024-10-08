import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/features/chart_template.dart';
import 'package:perairan_ngale/features/transaction_card.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:perairan_ngale/models/employee.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class EmployeeCustomerDetailPage extends StatefulWidget {
  const EmployeeCustomerDetailPage({
    super.key,
    required this.customer,
    required this.employee,
  });

  final Customer customer;
  final Employee? employee;

  @override
  State<EmployeeCustomerDetailPage> createState() =>
      _EmployeeCustomerDetailPageState();
}

class _EmployeeCustomerDetailPageState
    extends State<EmployeeCustomerDetailPage> {
  List<Transaksi> listTransaksi = [];
  List<int> tahun = [];
  List<double> penggunaanPerBulan = [];
  List<Transaksi> latestTransaksi = [];
  var loading = false;
  int year = DateTime.now().year;

  void getTanggal10TahunTerakhir() {
    for (int i = 0; i < 10; i++) {
      int year = DateTime.now().year - i;
      tahun.add(year);
    }
  }

  Future<void> setPenggunaanPerBulan() async {
    penggunaanPerBulan = List.generate(12, (index) => 0.0);

    if (listTransaksi.isNotEmpty) {
      for (int i = 0; i < listTransaksi.length; i++) {
        int bulan = listTransaksi[i].bulan;
        if (bulan > 0 && bulan <= 12) {
          setState(() {
            penggunaanPerBulan[bulan - 1] +=
                listTransaksi[i].meteran! - listTransaksi[i].meteranBulanLalu!;
          });
        }
      }
    }
  }

  Future<void> getTransaksiByUserIdAndYear(String userId, int tahun) async {
    final collection = FirebaseFirestore.instance.collection('Transaksi');
    final user = FirebaseAuth.instance.currentUser;
    final startOfYear = DateTime(tahun, 1, 1).toIso8601String();
    final endOfYear = DateTime(tahun + 1, 1, 1).toIso8601String();
    setState(() {
      loading = true;
    });
    final querySnapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('tanggal', isGreaterThanOrEqualTo: startOfYear)
        .where('tanggal', isLessThan: endOfYear)
        .orderBy('tanggal', descending: true)
        .get();

    setState(() {
      listTransaksi = querySnapshot.docs
          .map((doc) => Transaksi.fromJson(doc.data()))
          .toList();

      loading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
  }

  Future<void> getTransaksiByUserIdAndYearWithoutSorting(String userId) async {
    int tahun = DateTime.now().year;
    final collection = FirebaseFirestore.instance.collection('Transaksi');
    final user = FirebaseAuth.instance.currentUser;
    final startOfYear = DateTime(tahun, 1, 1).toIso8601String();
    final endOfYear = DateTime(tahun + 1, 1, 1).toIso8601String();
    setState(() {
      loading = true;
    });
    final querySnapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('tanggal', isGreaterThanOrEqualTo: startOfYear)
        .where('tanggal', isLessThan: endOfYear)
        .orderBy('tanggal', descending: true)
        .get();

    setState(() {
      listTransaksi = querySnapshot.docs
          .map((doc) => Transaksi.fromJson(doc.data()))
          .toList();

      loading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
  }

  Future<void> getLatestTransaksi(String userId) async {
    final collection = FirebaseFirestore.instance.collection('Transaksi');
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      loading = true;
    });
    final querySnapshot = await collection
        .where('userId', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .limit(1)
        .get();

    setState(() {
      loading = false;
    });

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        latestTransaksi = querySnapshot.docs
            .map((doc) => Transaksi.fromJson(doc.data()))
            .toList();
      } else {
        latestTransaksi = [];
      }
    });
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getTanggal10TahunTerakhir();
    getTransaksiByUserIdAndYearWithoutSorting(widget.customer.uid);
    setPenggunaanPerBulan();
    getLatestTransaksi(widget.customer.uid);
  }

  @override
  Widget build(BuildContext context) {
    double meteranTerakhir = 0;
    var isThereTransaksi = false;
    if (latestTransaksi.isNotEmpty) {
      meteranTerakhir = latestTransaksi[0].meteran!;
      isThereTransaksi = true;
    }
    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.only(left: Styles.biggerPadding),
        child: ElevatedButton(
          onPressed: () {
            if (latestTransaksi.isNotEmpty) {
              AutoRouter.of(context).push(EmployeeAddCustomerRecordRoute(
                  isThereTransaksi: isThereTransaksi,
                  isAdd: true,
                  isEditable: true,
                  customer: widget.customer,
                  transaksiBulanLalu: latestTransaksi[0],
                  customerId: widget.customer.uid,
                  employee: widget.employee));
            } else {
              AutoRouter.of(context).push(EmployeeAddCustomerRecordRoute(
                  isThereTransaksi: isThereTransaksi,
                  isAdd: true,
                  isEditable: true,
                  customer: widget.customer,
                  customerId: widget.customer.uid,
                  employee: widget.employee));
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconsaxPlusLinear.add,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Catat Baru',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: ColorValues.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBarWidget(),
            _buildRecordsWidget(isThereTransaksi),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarContentWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: _buildCustomerName(),
      ),
    );
  }

  Widget _buildTopBarWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: svg.Svg('assets/Frame 6.svg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: [
          Center(child: _buildTopBarContentWidget()),
        ],
      ),
    );
  }

  Column _buildCustomerName() {
    return Column(
      children: [
        Container(
          child: Icon(IconsaxPlusBold.profile_circle,
              size: Styles.bigIcon, color: Colors.white),
        ),
        Text(
          widget.customer.nama,
          style: context.textTheme.titleLargeBright,
          textAlign: TextAlign.center,
        ),
        Text(
          widget.customer.customerNo,
          style: context.textTheme.bodyMediumBoldBright,
        ),
      ],
    );
  }

  Widget _buildSortTransaksi() {
    return CustomDropdown<int>(
      hintText: 'Pilih tahun',
      items: tahun,
      initialItem: year,
      onChanged: (value) {
        year = value;
        getTransaksiByUserIdAndYear(widget.customer.uid, year);
      },
    );
  }

  Widget _buildRecordsWidget(bool isThereTransaksi) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: ColorValues.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            Center(
              child: Text(
                "Penggunaan Per Bulan",
                style: context.textTheme.bodyMediumBold,
              ),
            ),
            FutureBuilder(
              future: setPenggunaanPerBulan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return LineChartSample2(data: penggunaanPerBulan);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            _buildSortTransaksi(),
            Center(
              child: Text(
                "Riwayat Transaksi",
                style: context.textTheme.bodyMediumBold,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            !loading
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listTransaksi.length,
                    itemBuilder: (context, index) {
                      Transaksi transaksi = listTransaksi[index];
                      if (latestTransaksi.isNotEmpty &&
                          listTransaksi[index] == latestTransaksi[0]) {
                        if (widget.employee != null) {
                          print('cek1');
                          return TransactionCard(
                            isEditable: true,
                            customer: widget.customer,
                            isThereTransaksi: isThereTransaksi,
                            transaksi: transaksi,
                            employee: widget.employee,
                          );
                        } else {
                          print('cek2');
                          return TransactionCard(
                            isEditable: true,
                            isThereTransaksi: isThereTransaksi,
                            transaksi: transaksi,
                          );
                        }
                      }
                      return TransactionCard(
                        isThereTransaksi: isThereTransaksi,
                        transaksi: transaksi,
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
            SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}
