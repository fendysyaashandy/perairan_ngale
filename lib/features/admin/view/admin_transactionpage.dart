import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perairan_ngale/features/admin/view/minus_transaction_card.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/shared/styles.dart';

@RoutePage()
class AdminTransactionPage extends StatefulWidget {
  const AdminTransactionPage({super.key});

  @override
  State<AdminTransactionPage> createState() => _AdminTransactionPageState();
}

class _AdminTransactionPageState extends State<AdminTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Styles.defaultPadding),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('Transaksi').where('status', isEqualTo: 'pengeluaran').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<Transaksi> transaksiList = [];
                  snapshot.data!.docs.forEach((doc) {
                    transaksiList.add(Transaksi.fromFirestore(doc));
                  });
                  return ListView.builder(
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final Transaksi transaksi = transaksiList[index];
                      return MinusTransactionCard(transaksi: transaksi);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
