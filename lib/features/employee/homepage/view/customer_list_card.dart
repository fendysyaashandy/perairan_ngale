// ignore_for_file: unused_import

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:perairan_ngale/models/admin.dart';
import 'package:perairan_ngale/models/customer.dart';
import 'package:perairan_ngale/models/employee.dart';
import 'package:perairan_ngale/routes/router.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard(
      {super.key, required this.customer, required this.employee});

  final Customer customer;
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(EmployeeCustomerDetailRoute(
          customer: customer,
          employee: employee,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, Styles.smallPadding, 0, 0),
        child: Column(
          children: [
            Container(
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
                    Flexible(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: Styles.defaultPadding),
                            child: Icon(
                              IconsaxPlusBold.profile_circle,
                              size: Styles.bigIcon,
                            ),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.nama,
                                  style: context.textTheme.bodyMediumBold,
                                ),
                                Text(customer.customerNo,
                                    style: context.textTheme.bodySmallGrey),
                                Text(
                                  customer.alamat,
                                  style: context.textTheme.bodySmallGrey,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(IconsaxPlusLinear.arrow_right_3)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
