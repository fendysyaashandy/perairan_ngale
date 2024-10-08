// ignore_for_file: unused_import

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:perairan_ngale/features/employee/homepage/view/customer_list_card.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/employee.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/widgets/custom_button.dart';
import 'package:perairan_ngale/widgets/custom_text_field.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key, required this.employee});

  final Employee employee;

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  late TextEditingController _searchController;

  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  var searchname = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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

  void _onSearchSubmitted(String value) {
    print("Search submitted: $value"); // Debug statement
    _searchQuery.value = value;

    print("Refresh triggered"); // Debug statement
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                borderWidth: 0,
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
            SizedBox(height: 28),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: "Sudah Bayar",
                    backgroundColor: Colors.transparent,
                    textColor: Colors.grey,
                    isOutlined: true,
                    onPressed: () {
                      AutoRouter.of(context).push(EmployeeCustomerBayarRoute(
                          employee: widget.employee));
                    },
                  ),
                  CustomButton(
                    text: "Belum Bayar",
                    backgroundColor: Colors.transparent,
                    textColor: Colors.grey,
                    isOutlined: true,
                    onPressed: () {
                      AutoRouter.of(context).push(EmployeeCustomerNonBayarRoute(
                          employee: widget.employee));
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, value, _) {
                  print("Search query: $value"); // Debug statement
                  return value.isEmpty
                      ? _buildListNoSearch()
                      : _buildListWithSearch();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListNoSearch() {
    return FirestoreListView<Map<String, dynamic>>(
      pageSize: 3,
      query: FirebaseFirestore.instance
          .collection('Customer')
          .where('alamatTower', isEqualTo: widget.employee.alamatTower)
          .orderBy('nama'),
      itemBuilder: (context, snapshot) {
        final customer = Customer.fromFirestore(snapshot);
        return CustomerCard(
          customer: customer,
          employee: widget.employee,
        );
      },
    );
  }

  Widget _buildListWithSearch() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Customer')
            .where('alamatTower', isEqualTo: widget.employee.alamatTower)
            .orderBy('nama')
            .startAt([searchname]).endAt([searchname + "\uf8ff"]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              final customer = Customer.fromFirestore(data);
              return CustomerCard(
                customer: customer,
                employee: widget.employee,
              );
            },
          );
        });
  }
}
