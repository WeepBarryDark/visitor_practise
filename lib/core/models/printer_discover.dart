import 'package:another_brother/printer_info.dart' as printer;

class PrinterDiscover {
  final String printerName;
  final String printerAddress;
  final String printerModel;
  final printer.PrinterInfo? printerInfo;

  PrinterDiscover({
    required this.printerName,
    required this.printerAddress,
    required this.printerModel,
    this.printerInfo,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': printerName,
      'address': printerAddress,
      'model': printerModel,
    };
  }

  /// Create from JSON
  factory PrinterDiscover.fromJson(Map<String, dynamic> json, {printer.PrinterInfo? printerInfo}) {
    return PrinterDiscover(
      printerName: json['name'] as String,
      printerAddress: json['address'] as String,
      printerModel: json['model'] as String,
      printerInfo: printerInfo,
    );
  }

  /// Create a copy with updated fields
  PrinterDiscover copyWith({
    String? printerName,
    String? printerAddress,
    String? printerModel,
    printer.PrinterInfo? printerInfo,
  }) {
    return PrinterDiscover(
      printerName: printerName ?? this.printerName,
      printerAddress: printerAddress ?? this.printerAddress,
      printerModel: printerModel ?? this.printerModel,
      printerInfo: printerInfo ?? this.printerInfo,
    );
  }
}
