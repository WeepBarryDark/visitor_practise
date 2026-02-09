import 'package:another_brother/printer_info.dart' as printer;

class PrinterDiscover {
  final String printerName;
  final String printerAddress;
  final String printerModel;
  final printer.PrinterInfo? printerInfo;

  // Private constructor
  PrinterDiscover({
    required this.printerName,
    required this.printerAddress,
    required this.printerModel,
    this.printerInfo,
  });
}
