import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/features/admin/view/admin_customer_card.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';

@RoutePage()
class AdminCustomerBayarPage extends StatefulWidget {
  const AdminCustomerBayarPage({super.key, required this.admin});

  final Admin admin;

  @override
  State<AdminCustomerBayarPage> createState() => _AdminCustomerBayarPageState();
}

class _AdminCustomerBayarPageState extends State<AdminCustomerBayarPage> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  var searchname = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchQuery.value = _searchController.text;
  }

  Query<Map<String, dynamic>> _transactionQuery() {
    int currentMonth = DateTime.now().month;
    return FirebaseFirestore.instance
        .collection('Transaksi')
        .where('status', isEqualTo: 'pembayaran')
        .where('bulan', isEqualTo: currentMonth);
  }

  Future<List<Customer>> _getCustomersFromTransactions(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    Set<String> addedCustomerIds = {};
    List<Customer> customers = [];

    for (var doc in snapshot.docs) {
      String userId = doc['userId'];
      if (!addedCustomerIds.contains(userId)) {
        DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection('Customer')
            .doc(userId)
            .get();
        if (customerSnapshot.exists) {
          var customer = Customer.fromFirestore(customerSnapshot);

          customers.add(customer);
          addedCustomerIds.add(userId);
        }
      }
    }
    return customers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Sudah Bayar")),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomTextField(
                    hintText: 'Cari pelanggan',
                    prefixIcon: IconsaxPlusLinear.search_normal,
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchname = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _searchQuery,
                    builder: (context, value, _) {
                      return value.isEmpty
                          ? _buildListNoSearch()
                          : _buildListWithSearch();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListNoSearch() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _transactionQuery().get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something went wrong: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        return FutureBuilder<List<Customer>>(
          future: _getCustomersFromTransactions(snapshot.data!),
          builder: (context, customerSnapshot) {
            if (customerSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (customerSnapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: customerSnapshot.data!.length,
              itemBuilder: (context, index) {
                final customer = customerSnapshot.data![index];
                return AdminCustomerCard(
                  customer: customer,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildListWithSearch() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _transactionQuery().snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Something went wrong: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CupertinoActivityIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        return FutureBuilder<List<Customer>>(
          future: _getCustomersFromTransactions(snapshot.data!),
          builder: (context, customerSnapshot) {
            if (customerSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            }

            if (customerSnapshot.data!.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return ListView.builder(
              itemCount: customerSnapshot.data!.length,
              itemBuilder: (context, index) {
                final customer = customerSnapshot.data![index];
                if (customer.nama
                    .toLowerCase()
                    .contains(searchname.toLowerCase())) {
                  return AdminCustomerCard(
                    customer: customer,
                  );
                }
                return SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}
