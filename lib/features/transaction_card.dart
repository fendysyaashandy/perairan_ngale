// ignore_for_file: unused_import

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/employee.dart';
import 'package:perairan_ngale/models/transaksi.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/date_helper.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard(
      {super.key,
      required this.transaksi,
      this.customerId,
      this.meteranTerakhir,
      required this.isThereTransaksi,
      this.employee,
      this.isEditable,
      this.customer});
  final Transaksi transaksi;
  final Customer? customer;
  final String? customerId;
  final double? meteranTerakhir;
  final bool isThereTransaksi;
  final Employee? employee;
  final bool? isEditable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (customerId == null) {
          if (employee != null) {
            print('cek2');
            AutoRouter.of(context).push(EmployeeAddCustomerRecordRoute(
              isAdd: true,
              customer: customer,
              employee: employee,
              isThereTransaksi: isThereTransaksi,
              isEditable: isEditable!,
              transaksi: transaksi,
            ));
          } else {
            AutoRouter.of(context).push(EmployeeAddCustomerRecordRoute(
              isThereTransaksi: isThereTransaksi,
              isEditable: false,
              isAdd: false,
              transaksi: transaksi,
            ));
          }
        } else {
          AutoRouter.of(context).push(EmployeeAddCustomerRecordRoute(
            isThereTransaksi: isThereTransaksi,
            isAdd: true,
            isEditable: true,
            customerId: customerId,
            employee: employee,
          ));
        }
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Styles.smallerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  DateHelper.formatDateToMonthYear(transaksi.tanggal),
                  style: context.textTheme.bodyMediumBold,
                ),
              ),
              _buildHistoryItemWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItemWidget(BuildContext context) {
    final saldo = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
        .format(transaksi.saldo);
    return Container(
      decoration: BoxDecoration(
        color: ColorValues.white,
        borderRadius: BorderRadius.circular(Styles.defaultBorder),
        border: Border.all(
          color: ColorValues.grey30,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: Styles.defaultPadding),
              child: Icon(
                IconsaxPlusLinear.shopping_cart,
                size: Styles.bigIcon,
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        saldo,
                        style: context.textTheme.bodyMediumBold,
                      ),
                      const SizedBox(
                        height: Styles.smallSpacing,
                      ),
                      Text(
                        DateHelper.formatDateToDayMonthYearTime(
                            transaksi.tanggal),
                        style: context.textTheme.bodySmallGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              child: Icon(
                IconsaxPlusLinear.arrow_right_3,
                size: Styles.defaultIcon,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
