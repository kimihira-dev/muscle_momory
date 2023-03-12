import 'package:intl/intl.dart';

bool intToBool(int a) => a == 0 ? false : true;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatDate(DateTime datetime) {
  var formatter = DateFormat('yyyy/MM/dd HH:mm');
  var formatted = formatter.format(datetime); // DateからString
  return formatted;
}

List<String> convertSelectColumns(List<String> columns) {
  var newColumns = columns.map((element) {
    if (element == 'create_at' || element == 'update_at') {
      return 'datetime($element, "localtime") as $element';
    } else {
      return element;
    }
  }).toList();

  return newColumns;
}