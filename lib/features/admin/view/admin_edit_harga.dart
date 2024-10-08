import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:perairan_ngale/models/harga.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';
import 'package:sizer/sizer.dart';

@RoutePage()
class EditHargaPage extends StatefulWidget {
  const EditHargaPage({super.key});

  @override
  State<EditHargaPage> createState() => _EditHargaPageState();
}

class _EditHargaPageState extends State<EditHargaPage> {
  final _hargaController = TextEditingController();
  final _dendaController = TextEditingController();
  final String idHarga = '6aXCOuQhjN9HeVIPTMTO';
  Harga? _harga;

  final _formKey = GlobalKey<FormState>();

  Future<void> updateDocument() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _collection = _firestore.collection('Harga');

    await _collection.doc(idHarga).update({
      'harga': int.parse(_hargaController.text),
      'denda': int.parse(_dendaController.text),
    });
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
      _hargaController.text = _harga!.harga.toString();
      _dendaController.text = _harga!.denda.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _getHarga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Biaya',
          style: context.textTheme.titleMedium,
        ),
        backgroundColor: Color(0xFFFFF6D7),
      ),
      backgroundColor: Color(0xFFFFF6D7),
      body: Padding(
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
                _buildSaldoTextField(context),
                SizedBox(height: Styles.defaultPadding),
                _buildDendaTextField(context),
                SizedBox(height: Styles.bigPadding),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Styles.defaultPadding),
                  child: CustomButton(
                    onPressed: () {
                      updateDocument();
                      AutoRouter.of(context).pushAndPopUntil(HomeWrapperRoute(),
                          predicate: (route) => false);
                      Fluttertoast.showToast(
                          msg: "Edit Harga berhasil",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    text: 'Ganti Harga',
                    backgroundColor: Color(0xFFFDD037),
                    textColor: Colors.white,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Styles.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tetapkan Biaya Tagihan",
              style: context.textTheme.bodyMediumBold),
          Text("Pastikan biaya sudah sesuai perhitungan.",
              style: context.textTheme.bodySmallGrey),
        ],
      ),
    );
  }

  Padding _buildSaldoTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
      child: CustomTextField(
        controller: _hargaController,
        hintText: "Rp 0",
        label: "Harga air per-m3",
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Jumlah saldo tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Padding _buildDendaTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
      child: CustomTextField(
        controller: _dendaController,
        hintText: "Contoh: 5",
        label: "Besar Denda dalam %",
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Jumlah saldo tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}
