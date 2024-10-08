import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/features/admin/save_file_mobile.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/utils/logger.dart';
import 'package:perairan_ngale/widgets/custom_gesture_unfocus.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

@RoutePage()
class AdminTabsPage extends StatefulWidget {
  const AdminTabsPage({super.key});

  @override
  State<AdminTabsPage> createState() => _AdminTabsPageState();
}

class _AdminTabsPageState extends State<AdminTabsPage> {
  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();

  List<Transaksi> transaksiList = [];
  bool isLoading = true;
  String? errorMessage;
  double saldoMasuk = 0;
  double saldoKeluar = 0;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
    _getLastTransactions();
  }

  Future<void> _exportDataGridToExcel() async {
    logger.d('current state key ${key.currentState}');
    final xlsio.Workbook workbook = key.currentState!.exportToExcelWorkbook();
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final helper = SaveFileMobile();
    await helper.download(bytes, 'DataGrid.xlsx');
  }

  Future<void> fetchTransaksi() async {
    try {
      QuerySnapshot transaksiSnapshot =
          await FirebaseFirestore.instance.collection('Transaksi').get();
      QuerySnapshot customerSnapshot =
          await FirebaseFirestore.instance.collection('Customer').get();
      QuerySnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('Admin').get();

      Map<String, String> userIdToNameMap = {};

      for (var doc in customerSnapshot.docs) {
        var customer = Customer.fromFirestore(doc);
        userIdToNameMap[customer.uid] = customer.nama;
      }

      for (var doc in adminSnapshot.docs) {
        var admin = Admin.fromFirestore(doc);
        userIdToNameMap[admin.uid] = admin.nama;
      }

      transaksiList = transaksiSnapshot.docs.map((doc) {
        var transaksi = Transaksi.fromFirestore(doc);
        var userName = userIdToNameMap[transaksi.userId] ?? 'Unknown User';
        return transaksi.copyWith(userId: userName);
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching transactions: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _getLastTransactions() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Transaksi')
              .where('bulan', isEqualTo: DateTime.now().month)
              .where('tahun', isEqualTo: DateTime.now().year)
              .get();

      snapshot.docs.forEach((doc) {
        if (doc['status'] == 'pembayaran') {
          saldoMasuk += doc['saldo'];
        } else if (doc['status'] == 'pengeluaran') {
          saldoKeluar += doc['saldo'];
        }
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching transactions: $e";
        isLoading = false;
      });
    }
  }

  Widget _saldoMasuk(double saldoMasuk) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saldo Masuk', style: context.textTheme.bodySmallBoldBright),
        Text('+ $saldoMasuk',
            style: context.textTheme.bodyVeryLargeBold
                .copyWith(color: ColorValues.white)),
      ],
    );
  }

  Widget _saldoKeluar(double saldoKeluar) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saldo Keluar', style: context.textTheme.bodySmallBoldBright),
        Text('- $saldoKeluar',
            style: context.textTheme.bodyVeryLargeBold
                .copyWith(color: ColorValues.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.tabBar(
      routes: const [
        AdminIncomeRoute(),
        AdminTransactionRoute(),
      ],
      builder: (context, child, controller) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorValues.primary50,
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                "Transaksi",
                style: context.textTheme.bodyLargeBold
                    .copyWith(color: ColorValues.white),
              ),
            ),
          ),
          body: CustomGestureUnfocus(
            child: Column(
              children: [
                Container(
                  width: 100.w,
                  height: 240,
                  decoration: BoxDecoration(
                      color: ColorValues.primary50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(child: Text(errorMessage!))
                          : Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(Styles.defaultPadding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ringkasan Bulan Ini',
                                    style:
                                        context.textTheme.bodyMediumBoldBright,
                                  ),
                                  SizedBox(height: 20),
                                  _saldoMasuk(saldoMasuk),
                                  SizedBox(height: 20),
                                  _saldoKeluar(saldoKeluar),
                                ],
                              ),
                            ),

                  // SfDataGrid(
                  //             key: key,
                  //             source: transaksiDataSource,
                  //             columns: <GridColumn>[
                  //               GridColumn(
                  //                 columnName: 'nama',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Nama',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'status',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Status',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'nominal',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Nominal',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'deskripsi',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Deskripsi',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'tanggal',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Tanggal',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'tahun',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Tahun',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridColumn(
                  //                 columnName: 'bulan',
                  //                 label: Container(
                  //                   padding: EdgeInsets.all(8.0),
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     'Bulan',
                  //                     style: context.textTheme.bodySmallBold,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                ),
                _buildTabBar(controller, tabsRouter, context),
                Expanded(child: child),
              ],
            ),
          ),
          // floatingActionButton: Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     SizedBox(
          //       height: 64,
          //       width: 64,
          //       child: FloatingActionButton(
          //         tooltip: "Refresh",
          //         backgroundColor: Colors.blue,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         onPressed: () {
          //           AutoRouter.of(context).pushAndPopUntil(HomeWrapperRoute(),
          //               predicate: (route) => false);
          //           context.showSnackBar(message: "Refreshing...");
          //         },
          //         child: Icon(
          //           IconsaxPlusLinear.refresh,
          //           size: 44,
          //           color: ColorValues.white,
          //         ),
          //       ),
          //     ),
          //     SizedBox(height: 16),
          //     SizedBox(
          //       height: 64,
          //       width: 64,
          //       child: FloatingActionButton(
          //         tooltip: "Export to Excel",
          //         backgroundColor: Colors.blue,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         onPressed: () {
          //           try {
          //             _exportDataGridToExcel();
          //             context.showSnackBar(
          //                 message: "Data berhasil disimpan di Download/ngale/");
          //           } catch (e) {
          //             context.showSnackBar(
          //                 message: e.toString(), isSuccess: false);
          //           }
          //         },
          //         child: Icon(
          //           IconsaxPlusLinear.printer,
          //           size: 44,
          //           color: ColorValues.white,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        );
      },
    );
  }

  TabBar _buildTabBar(
    TabController controller,
    TabsRouter tabsRouter,
    BuildContext context,
  ) {
    return TabBar(
      controller: controller,
      onTap: (value) {
        setState(() {
          tabsRouter.setActiveIndex(value);
        });
      },
      tabs: [
        Tab(
          child: Text(
            "Pemasukan",
            style: tabsRouter.activeIndex == 0
                ? context.textTheme.bodyMediumBold
                : context.textTheme.bodyMediumBold.copyWith(
                    color: ColorValues.grey30,
                  ),
          ),
        ),
        Tab(
          child: Text(
            "Pengeluaran",
            style: tabsRouter.activeIndex == 1
                ? context.textTheme.bodyMediumBold
                : context.textTheme.bodyMediumBold.copyWith(
                    color: ColorValues.grey30,
                  ),
          ),
        ),
      ],
      indicatorColor: ColorValues.primary50,
    );
  }
}
