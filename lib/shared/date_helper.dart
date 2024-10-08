import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static String formatDateToMonthYear(String isoDate) {
    initializeDateFormatting('id_ID');
    final DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('MMMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  static String formatDateToDayMonthYearTime(String isoDate) {
    initializeDateFormatting('id_ID');
    final DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
    return formatter.format(dateTime);
  }
}
