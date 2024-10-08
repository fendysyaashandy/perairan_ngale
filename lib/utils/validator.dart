import 'package:flutter/material.dart';

class Validator {
  Validator({required this.context});

  final BuildContext context;

  String? emptyValidator(String? text) {
    if (text == null) return "Tidak boleh kosong";
    if (text.trim().isEmpty) return "Tidak boleh kosong";
    return null;
  }
}
