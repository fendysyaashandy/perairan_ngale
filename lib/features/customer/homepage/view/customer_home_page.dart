import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:perairan_ngale/features/chart_template.dart';
import 'package:perairan_ngale/features/transaction_card.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

@RoutePage()
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Customer? _customer;
  List<int> tahun = [];
  List<double> penggunaanPerBulan = [];
  List<Transaksi> listTransaksi = [];
  var loading = false;
  int year = DateTime.now().year;

  void getTanggal10TahunTerakhir() {
    for (int i = 0; i < 10; i++) {
      int year = DateTime.now().year - i;
      tahun.add(year);
    }
  }

  Future<void> setPenggunaanPerBulan() async {
    final completer = Completer<void>();

    if (listTransaksi.isNotEmpty) {
      for (int i = 0; i < listTransaksi.length; i++) {
        double penggunaan =
            listTransaksi[i].meteran! - listTransaksi[i].meteranBulanLalu!;
        int bulan = listTransaksi[i].bulan;
        setState(() {
          penggunaanPerBulan[bulan - 1] += penggunaan;
        });
      }
    }

    print(penggunaanPerBulan);
    completer.complete();

    return completer.future;
  }

  Future<Customer> getCustomer(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('Customer')
        .doc(userId)
        .get();

    final customer = Customer.fromFirestore(doc);
    return customer;
  }

  Future<void> _getCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final customer = await getCustomer(user.uid);
    setState(() {
      _customer = customer;
    });
    getTransaksiByUserIdAndYear(user.uid, year);
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
      penggunaanPerBulan = List.generate(12, (index) => 0.0);

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
      penggunaanPerBulan = List.generate(12, (index) => 0.0);
      loading = false;
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
    _getCustomer();
    getTanggal10TahunTerakhir();
    getTransaksiByUserIdAndYearWithoutSorting(user!.uid);
    setPenggunaanPerBulan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildTopBarWidget(), _buildRecordsWidget()],
        ),
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

  Widget _buildSortTransaksi() {
    return CustomDropdown<int>(
      hintText: 'Pilih tahun',
      items: tahun,
      initialItem: year,
      onChanged: (value) {
        year = value;
        getTransaksiByUserIdAndYear(user!.uid, year);
      },
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
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_customer != null)
                      Text(
                        _customer!.nama,
                        style: context.textTheme.bodyMediumBoldBright,
                      ),
                    const SizedBox(
                      height: Styles.smallSpacing,
                    ),
                    if (_customer != null)
                      Text(
                        _customer!.customerNo,
                        style: context.textTheme.bodySmallBright,
                      ),
                  ]),
            ),
            IconButton(
              icon: const Icon(
                IconsaxPlusLinear.setting,
                size: Styles.bigIcon,
                color: Colors.white,
              ),
              onPressed: () {
                AutoRouter.of(context)
                    .push(CustomerProfileRoute(customer: _customer!));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
            Center(
              child: Text(
                "Riwayat Pencatatan",
                style: context.textTheme.bodyMediumBold,
              ),
            ),
            _buildSortTransaksi(),
            Expanded(
              child: !loading
                  ? ListView.builder(
                      itemCount: listTransaksi.length,
                      itemBuilder: (context, index) {
                        Transaksi transaksi = listTransaksi[index];
                        double? meteranTerakhir = 0;
                        if (index != listTransaksi.length - 1) {
                          meteranTerakhir = listTransaksi[index + 1].meteran;
                        }
                        return TransactionCard(
                          employee: null,
                          isThereTransaksi: true,
                          transaksi: transaksi,
                          meteranTerakhir: meteranTerakhir,
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
