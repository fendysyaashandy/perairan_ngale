import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/features/admin/save_file_mobile.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/utils/logger.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

@RoutePage()
class AdminCetakPage extends StatefulWidget {
  const AdminCetakPage({super.key});

  @override
  State<AdminCetakPage> createState() => _AdminCetakPageState();
}

class _AdminCetakPageState extends State<AdminCetakPage> {
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();
  late TransaksiDataSource transaksiDataSource;
  List<Transaksi> transaksiList = [];
  bool isLoading = true;
  String? errorMessage;
  late String _selectedBulan;
  late bool _exportAllData;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
    _exportAllData = false;
    _selectedBulan = '1';
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
        transaksiDataSource = TransaksiDataSource(transaksiList: transaksiList);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching transactions: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _exportDataGridToExcel() async {
    logger.d('current state key ${key.currentState}');
    final xlsio.Workbook workbook = key.currentState!.exportToExcelWorkbook();
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    final helper = SaveFileMobile();
    await helper.download(bytes, 'DataGrid.xlsx');
  }

  Future<void> _cetakData() async {
    if (_formKey.currentState!.validate()) {
      List<Transaksi> filteredTransaksi = _exportAllData
          ? transaksiList
          : transaksiList
              .where(
                  (transaksi) => transaksi.bulan.toString() == _selectedBulan)
              .toList();

      if (filteredTransaksi.isNotEmpty) {
        try {
          final csv = _generateCSV(filteredTransaksi);

          final helper = SaveFileMobile();
          await helper.download(
              csv.codeUnits,
              _exportAllData
                  ? 'SemuaTransaksi.csv'
                  : 'NgaleBulan$_selectedBulan.csv');
          context.showSnackBar(
              message: "File berhasil disimpan di storage:Download/ngale/");
        } catch (e) {
          logger.e('Error saat mencetak data: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mencetak data')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_exportAllData
                  ? 'Tidak ada transaksi'
                  : 'Tidak ada transaksi untuk bulan $_selectedBulan')),
        );
      }
    }
  }

  String _generateCSV(List<Transaksi> transaksiList) {
    final List<List<dynamic>> rows = [];

    rows.add([
      'Nama',
      'Status',
      'Nominal',
      'Deskripsi',
      'Tanggal',
      'Tahun',
      'Bulan',
    ]);

    for (var transaksi in transaksiList) {
      rows.add([
        transaksi.userId,
        transaksi.status,
        transaksi.saldo,
        transaksi.deskripsi,
        transaksi.tanggal,
        transaksi.tahun,
        transaksi.bulan,
      ]);
    }

    final List<String> csvRows =
        rows.map((row) => row.map((item) => '"$item"').join(',')).toList();
    return csvRows.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cetak Dokumen',
          style: context.textTheme.titleMedium,
        ),
        backgroundColor: ColorValues.primary10,
      ),
      backgroundColor: ColorValues.primary10,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: Styles.defaultPadding),
          child: Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context),
                  SizedBox(height: Styles.defaultPadding),
                  _buildBulanDropdown(context),
                  SizedBox(height: Styles.bigPadding),
                  _buildExportAllDataCheckbox(context),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Styles.defaultPadding),
                    child: CustomButton(
                      onPressed: () {
                        _cetakData();
                      },
                      text: 'Cetak',
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: Styles.defaultPadding),
                  // Expanded(child: _buildDataGrid(context)),
                ],
              ),
            ),
          ),
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
      //           fetchTransaksi();
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
  }

  Padding _buildExportAllDataCheckbox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Styles.defaultPadding,
          right: Styles.defaultPadding,
          bottom: Styles.defaultPadding),
      child: Row(
        children: [
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: _exportAllData,
            onChanged: (value) {
              setState(() {
                _exportAllData = value!;
              });
            },
          ),
          Text(
            'Export Semua Data',
            style: context.textTheme.bodyMediumSemiBold,
          ),
        ],
      ),
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : SfDataGrid(
                key: key,
                source: transaksiDataSource,
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'nama',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Nama',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'status',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Status',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'nominal',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Nominal',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'deskripsi',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Deskripsi',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'tanggal',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Tanggal',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'tahun',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Tahun',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'bulan',
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        'Bulan',
                        style: context.textTheme.bodySmallBold,
                      ),
                    ),
                  ),
                ],
              );
  }

  Padding _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Styles.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Unduh Dokumen Perbulan",
              style: context.textTheme.bodyMediumBold),
          Text("Pilih transaksi bulan di tahun ini.",
              style: context.textTheme.bodySmallGrey),
        ],
      ),
    );
  }

  Padding _buildBulanDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedBulan,
              onChanged: (String? value) {
                setState(() {
                  _selectedBulan = value!;
                });
              },
              items: List.generate(12, (index) => index + 1)
                  .map<DropdownMenuItem<String>>((int value) {
                return DropdownMenuItem<String>(
                  value: value.toString(),
                  child: Text(value.toString()),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Bulan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransaksiDataSource extends DataGridSource {
  TransaksiDataSource({required List<Transaksi> transaksiList}) {
    dataGridRows = transaksiList.map<DataGridRow>((Transaksi transaksi) {
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'nama',
          value: transaksi.userId,
        ),
        DataGridCell<String>(
          columnName: 'status',
          value: transaksi.status,
        ),
        DataGridCell<double>(
          columnName: 'nominal',
          value: transaksi.saldo,
        ),
        DataGridCell<String>(
          columnName: 'deskripsi',
          value: transaksi.deskripsi,
        ),
        DataGridCell<String>(
          columnName: 'tanggal',
          value: transaksi.tanggal,
        ),
        DataGridCell<int>(
          columnName: 'tahun',
          value: transaksi.tahun,
        ),
        DataGridCell<int>(
          columnName: 'bulan',
          value: transaksi.bulan,
        ),
      ]);
    }).toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          dataGridCell.value.toString(),
          style: TextStyle(
            fontSize: 11.0,
          ),
        ),
      );
    }).toList());
  }
}
