import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:another_brother/printer_info.dart' as printer;
import 'package:visitor_practise/core/models/printer_discover.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class PrinterDiscoverService {
  /// Discover network printers by printer model
  static Future<List<PrinterDiscover>> getNetPrinters(printer.Model model) async {
    try {
      debugPrint('Starting network printer discovery for model: ${model.getName()}');

      // Discover printers on network
      final printerInstance = printer.Printer();
      final printers = await printerInstance.getNetPrinters([model.getName()]);

      if (printers.isEmpty) {
        debugPrint('No network printers found for model: ${model.getName()}');
        return [];
      }

      debugPrint('Found ${printers.length} printer(s) on network');

      // Convert to PrinterDiscover list
      final discoveredPrinters = <PrinterDiscover>[];
      for (final netPrinter in printers) {
        // Create PrinterInfo from NetPrinter
        final printerInfo = printer.PrinterInfo()
          ..printerModel = model
          ..port = printer.Port.NET
          ..ipAddress = netPrinter.ipAddress;

        final printerDiscover = PrinterDiscover(
          printerName: model.getName(),
          printerAddress: netPrinter.ipAddress,
          printerModel: model.getName(),
          printerInfo: printerInfo,
        );
        discoveredPrinters.add(printerDiscover);
        debugPrint('found ${printerDiscover.printerName} in ${printerDiscover.printerAddress}');
      }

      return discoveredPrinters;
    } catch (e, stackTrace) {
      debugPrint('Network printer discovery failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /*
  /// Connect to printer via USB and printer model
  static Future<PrinterDiscover?> connectByUsb({
    required printer.Model model,
  }) async {
    try {
      debugPrint('Attempting to connect to printer via USB (Model: ${model.getName()})');

      // Create printer info for USB connection
      final printerInfo = printer.PrinterInfo()
        ..printerModel = model
        ..port = printer.Port.USB;

      debugPrint('Successfully created USB printer connection');

      // Create PrinterDiscover instance
      final printerDiscover = PrinterDiscover(
        printerName: model.getName(),
        printerAddress: 'USB',
        printerModel: model.getName(),
        printerInfo: printerInfo,
      );

      // Save printer to local storage
      await savePrinter(printerDiscover);

      return printerDiscover;
    } catch (e, stackTrace) {
      debugPrint('Failed to connect by USB: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
  */

  /// Connect to printer by IP address and printer model
  static Future<PrinterDiscover?> connectByIp({
    required String ipAddress,
    required printer.Model model,
  }) async {
    try {
      debugPrint('Attempting to connect to printer at $ipAddress (Model: ${model.getName()})');

      // Validate IP address format
      if (!_isValidIpAddress(ipAddress)) {
        debugPrint('Invalid IP address format: $ipAddress');
        return null;
      }

      // Create printer info with specific IP
      final printerInfo = printer.PrinterInfo()
        ..printerModel = model
        ..port = printer.Port.NET
        ..ipAddress = ipAddress;

      // Test connection by getting printer status
      debugPrint('Testing connection to printer at $ipAddress...');
      final testPrinter = printer.Printer();
      await testPrinter.setPrinterInfo(printerInfo);

      // Try to get printer status to verify connection
      final printerStatus = await testPrinter.getPrinterStatus();

      if (printerStatus.errorCode != printer.ErrorCode.ERROR_NONE) {
        debugPrint('Failed to connect: ${printerStatus.errorCode}');
        return null;
      }

      debugPrint('Successfully connected to printer at $ipAddress');
      debugPrint('Status: ${printerStatus.errorCode}');

      // Create PrinterDiscover instance
      final printerDiscover = PrinterDiscover(
        printerName: model.getName(),
        printerAddress: ipAddress,
        printerModel: model.getName(),
        printerInfo: printerInfo,
      );

      // Save printer to local storage
      await savePrinter(printerDiscover);

      return printerDiscover;
    } catch (e, stackTrace) {
      debugPrint('Failed to connect by IP: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Save printer information to local storage
  static Future<void> savePrinter(PrinterDiscover printerDiscover) async {
    try {
      await SecureStorageService.saveLastPrinter(
        name: printerDiscover.printerName,
        address: printerDiscover.printerAddress,
        model: printerDiscover.printerModel,
      );
      debugPrint('Printer saved to local storage: ${printerDiscover.printerName}');
    } catch (e) {
      debugPrint('Failed to save printer: $e');
    }
  }

  /// Get last saved printer from local storage
  static Future<PrinterDiscover?> getLastSavedPrinter() async {
    try {
      final printerData = await SecureStorageService.getLastPrinter();
      if (printerData == null) {
        debugPrint('No saved printer found');
        return null;
      }

      final modelName = printerData['model'] as String;
      final address = printerData['address'] as String;
      final name = printerData['name'] as String;

      // Find the printer model from the model name
      final model = printer.Model.getValues()
          .firstWhere(
            (m) => m.getName() == modelName,
            orElse: () => printer.Model.UNSUPPORTED,
          );

      if (model == printer.Model.UNSUPPORTED) {
        debugPrint('Invalid saved printer model: $modelName');
        return null;
      }

      final printerInfo = printer.PrinterInfo()
        ..printerModel = model
        ..port = printer.Port.NET
        ..ipAddress = address;

      return PrinterDiscover(
        printerName: name,
        printerAddress: address,
        printerModel: modelName,
        printerInfo: printerInfo,
      );
    } catch (e) {
      debugPrint('Failed to get last saved printer: $e');
      return null;
    }
  }

  /// Clear saved printer from local storage
  static Future<void> clearSavedPrinter() async {
    try {
      await SecureStorageService.clearLastPrinter();
      debugPrint('Saved printer cleared');
    } catch (e) {
      debugPrint('Failed to clear saved printer: $e');
    }
  }

  /// Get list of all supported printer models
  static List<printer.Model> getSupportedModels() {
    return printer.Model.getValues()
        .where((m) => m.getName() != 'UNSUPPORTED')
        .toList();
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// Validate IP address format (IPv4)
  static bool _isValidIpAddress(String ip) {
    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    return ipRegex.hasMatch(ip.trim());
  }
}
