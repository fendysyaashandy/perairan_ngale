import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/employee.dart';
import 'package:perairan_ngale/models/harga.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/widgets/custom_gesture_unfocus.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';

@RoutePage()
class EmployeeAddCustomerRecordPage extends StatefulWidget {
  const EmployeeAddCustomerRecordPage({
    super.key,
    this.transaksiBulanLalu,
    this.transaksi,
    this.customerId,
    required this.isThereTransaksi,
    this.employee,
    required this.isEditable,
    required this.isAdd,
    this.customer,
  });

  final Transaksi? transaksiBulanLalu;
  final Customer? customer;
  final Transaksi? transaksi;
  final String? customerId;
  final bool isThereTransaksi;
  final Employee? employee;
  final bool isEditable;
  final bool isAdd;

  @override
  State<EmployeeAddCustomerRecordPage> createState() =>
      _EmployeeAddCustomerRecordPageState();
}

class _EmployeeAddCustomerRecordPageState
    extends State<EmployeeAddCustomerRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomorTagihanController = TextEditingController();
  final TextEditingController _meteranSaatIniController =
      TextEditingController();
  final TextEditingController _pencatatController = TextEditingController();
  late String _imagePath = '';
  bool loading = false;
  bool isNotEmpty = false;
  bool isEditable = false;

  Employee? _employee;
  String idHarga = '6aXCOuQhjN9HeVIPTMTO';
  Harga? _harga;
  late int meteranTerakhir;

  @override
  void initState() {
    super.initState();
    setIsNotEmpty();
    getPencatat();

    _getHarga();
  }

  Future<Harga> getHarga() async {
    final doc =
        await FirebaseFirestore.instance.collection('Harga').doc(idHarga).get();

    final harga = Harga.fromFirestore(doc);
    return harga;
  }

  Future<void> _getHarga() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to view this page')),
      );
      return;
    }
    final harga = await getHarga();
    setState(() {
      _harga = harga;
    });
  }

  late File? _imageFile = null;

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {}
  }

  Future<void> getPencatat() async {
    if (isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(widget.transaksi?.employeeId) // cuman work sebagai petugas
          .get();
      final employee = Employee.fromFirestore(doc);
      _pencatatController.text = employee.nama;
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(FirebaseAuth
              .instance.currentUser!.uid) // cuman work sebagai petugas
          .get();
      final employee = Employee.fromFirestore(doc);
      _pencatatController.text = employee.nama;
      setState(() {
        _employee = employee;
      });
    }
  }

  String url = '';

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = path.basename(_imageFile!.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('transaksi/$fileName');
    _imagePath = 'transaksi/' + fileName;
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    url = await taskSnapshot.ref.getDownloadURL();
    setState(() {}); // Add this line to update the UI after uploading the image
    _getImageUrl(); // Add this line to update the url if necessary
  }

  final storageReference = FirebaseStorage.instance.ref();

  void setIsNotEmpty() async {
    if (widget.transaksi != null) {
      isNotEmpty = true;
      if (widget.transaksi?.pathImage == '') {
        _imagePath = 'transaksi/default.jpg';
      } else {
        _imagePath = widget.transaksi!.pathImage!;
      }

      Reference getImage = storageReference.child(_imagePath);
      print(_imagePath);
      setState(() {
        loading = true;
      });
      _imagePath = await getImage.getDownloadURL();
      setState(() {
        loading = false;
      });
    }
  }

  Future<String> _getImageUrl() async {
    if (url.isNotEmpty) {
      return url;
    } else {
      final defaultImage = storageReference.child("transaksi/default.jpg");
      final snapshot = await defaultImage.getDownloadURL();
      if (url.isEmpty) {
        url = snapshot;
      }
      return snapshot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Meter'),
      ),
      body: CustomGestureUnfocus(
          child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                ),
                _buildPencatatField(),
                SizedBox(
                  height: Styles.biggerSpacing,
                ),
                _buildNomorTagihanField(),
                SizedBox(
                  height: Styles.biggerSpacing,
                ),
                _buildMeteranSaatIniField(),
                SizedBox(
                  height: Styles.bigSpacing,
                ),
                Text(
                  'Foto Meteran',
                  style: context.textTheme.titleMedium,
                ),
                SizedBox(
                  height: Styles.defaultSpacing,
                ),
                GestureDetector(
                    onTap: () async {
                      if (!isNotEmpty) {
                        await pickImage();
                        if (_imageFile != null) {
                          if (_imageFile!.path.isNotEmpty) {
                            setState(() {
                              loading = true;
                            });
                            await uploadImageToFirebase(context);
                            setState(() {
                              loading = false;
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengambil gambar')),
                          );
                        }
                      }
                    },
                    child: loading
                        ? Center(child: CircularProgressIndicator())
                        : isNotEmpty
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    _imagePath,
                                    cacheHeight: 189,
                                    cacheWidth: 343,
                                  ),
                                ),
                              )
                            : FutureBuilder(
                                future: _getImageUrl(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error loading image'),
                                    );
                                  } else {
                                    return Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          snapshot.data!,
                                          cacheHeight: 189,
                                          cacheWidth: 343,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )),
                SizedBox(height: 16),
                widget.isEditable
                    ? Center(
                        child: SizedBox(
                          width: 343,
                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutConfirmationDialog(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                isNotEmpty ? 'Edit Tagihan' : 'Catat Tagihan',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.width * 0.5,
          child: AlertDialog(
            title: Text('Konfirmasi Keluar',
                style: context.textTheme.bodyMediumBold),
            content: Text(
                'Apakah Anda yakin ingin mencatat transaksi dengan keterangan berikut:\n' +
                    'Meteran Bulan Lalu:' +
                    _nomorTagihanController.text +
                    '\n' +
                    'Meteran Saat ini:' +
                    _meteranSaatIniController.text,
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
                  color: Color(0xFF0D9DF8),
                ),
                child: TextButton(
                  child: Text('Simpan',
                      style: context.textTheme.bodyMediumBoldBright),
                  onPressed: () async {
                    isNotEmpty
                        ? _editTransaksi(context)
                        : _tambahTransaksi(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tambahTransaksi(BuildContext context) async {
    double pemakaian1bulan;
    var bulanTerakhir = widget.transaksiBulanLalu?.bulan ?? 0;
    var tahunTerakhir = widget.transaksiBulanLalu?.tahun ?? 0;
    var selisihBulan = DateTime.now().month - bulanTerakhir;
    var selisihTahun = DateTime.now().year - tahunTerakhir;
    int pengali = 0;

    if (_formKey.currentState!.validate()) {
      if (!widget.isThereTransaksi) {
        double meteranTerakhir = double.parse(_nomorTagihanController.text);

        pemakaian1bulan =
            double.parse(_meteranSaatIniController.text) - meteranTerakhir;
      } else {
        pemakaian1bulan = double.parse(_meteranSaatIniController.text) -
            widget.transaksiBulanLalu!.meteran!;
      }

      if (selisihBulan < 0) {
        pengali = selisihBulan + 12 * selisihTahun;
      }

      double saldo = pemakaian1bulan * _harga!.harga;
      double saldofix = saldo + saldo * _harga!.denda / 100 * pengali;
      try {
        if (saldofix > 0) {
          final transaksi = Transaksi(
            deskripsi: 'Pembayaran Air',
            saldo: saldofix,
            meteran: double.parse(_meteranSaatIniController.text),
            status: 'pembayaran',
            meteranBulanLalu: double.parse(_nomorTagihanController.text),
            tanggal: Timestamp.now().toDate().toString(),
            userId: widget.customerId ?? '',
            employeeId: FirebaseAuth.instance.currentUser!.uid,
            pathImage: _imagePath,
            bulan: Timestamp.now().toDate().month,
            tahun: Timestamp.now().toDate().year,
          );

          await FirebaseFirestore.instance
              .collection('Transaksi')
              .add(transaksi.toJson());
          Fluttertoast.showToast(
              msg: "Tambah Transaksi berhasil",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          AutoRouter.of(context).pushAndPopUntil(HomeWrapperRoute(), predicate: (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Meteran saat ini kurang dari Meteran bulan lalu')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _editTransaksi(BuildContext context) async {
    double pemakaian1bulan = 0;
    var bulanTerakhir = widget.transaksiBulanLalu?.bulan ?? 0;
    var tahunTerakhir = widget.transaksiBulanLalu?.tahun ?? 0;
    var selisihBulan = DateTime.now().month - bulanTerakhir;
    var selisihTahun = DateTime.now().year - tahunTerakhir;
    int pengali = 0;
    if (_formKey.currentState!.validate()) {
      if (widget.transaksi != null) {
        pemakaian1bulan = double.parse(_meteranSaatIniController.text) -
            (widget.transaksi?.meteranBulanLalu ?? 0);
      }
      if (selisihBulan < 0) {
        pengali = selisihBulan + 12 * selisihTahun;
      }

      double saldo = pemakaian1bulan * _harga!.harga;
      double saldofix = saldo + saldo * _harga!.denda / 100 * pengali;
      try {
        if (saldofix > 0) {
          await FirebaseFirestore.instance
              .collection('Transaksi')
              .where('meteranBulanLalu',
                  isEqualTo: widget.transaksi?.meteranBulanLalu)
              .where('userId', isEqualTo: widget.transaksi?.userId)
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              doc.reference.update({
                'meteran': double.parse(_meteranSaatIniController.text),
                'saldo': saldo,
                'tanggal': Timestamp.now().toDate().toString()
              });
            });
          });
          Fluttertoast.showToast(
              msg: "Edit Transaksi berhasil",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
          AutoRouter.of(context).pushAndPopUntil(HomeWrapperRoute(), predicate: (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Meteran saat ini kurang dari Meteran bulan lalu')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Widget _buildNomorTagihanField() {
    var meteranTerakhir = widget.transaksiBulanLalu?.meteran ?? 0;

    if (meteranTerakhir == 0) {
      if (widget.isThereTransaksi) {
        _nomorTagihanController.text =
            widget.transaksi!.meteranBulanLalu.toString();
      }
    } else {
      _nomorTagihanController.text =
          widget.transaksiBulanLalu!.meteran.toString();
    }
    return CustomTextField(
      maxCharacter: 50,
      controller: _nomorTagihanController,
      enabled: !widget.isThereTransaksi,
      fillColor: ColorValues.white,
      label: "Meteran Bulan Lalu",
      validator: (value) {
        if (value!.isEmpty) {
          return 'Meteran tidak boleh kosong!';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.contains(',')) {
            final newText = newValue.text.replaceAll(',', '.');
            return TextEditingValue(
              text: newText,
              selection: newValue.selection,
            );
          }
          return newValue;
        }),
      ],
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildMeteranSaatIniField() {
    if (isNotEmpty) {
      _meteranSaatIniController.text = widget.transaksi!.meteran.toString();
    }
    return CustomTextField(
      maxCharacter: 50,
      controller: _meteranSaatIniController,
      fillColor: ColorValues.white,
      label: "Meteran saat ini (m³)",
      enabled: widget.isEditable,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Meteran tidak boleh kosong!';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.contains(',')) {
            final newText = newValue.text.replaceAll(',', '.');
            return TextEditingValue(
              text: newText,
              selection: newValue.selection,
            );
          }
          return newValue;
        }),
      ],
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPencatatField() {
    return CustomTextField(
      controller: _pencatatController,
      enabled: !widget.isThereTransaksi,
      fillColor: ColorValues.white,
      label: "Pencatat",
    );
  }
}
