class PrinterPaperType {
  final int labelNameIndex;
  final String code; // DK-22205, DK-22251, etc.
  final String name;
  final String description;
  final String width;
  final bool isContinuous;
  final String material; // Clear Film, White Paper, Yellow Film, etc.
  final bool isRemovable;
  final bool isNonAdhesive;
  final bool isSpecialTape; // true = Red/Black, false = Black/White
  final List<String> supportedModels; // Which printer models support this paper

  const PrinterPaperType({
    required this.labelNameIndex,
    required this.code,
    required this.name,
    required this.description,
    required this.width,
    required this.isContinuous,
    required this.material,
    this.isRemovable = false,
    this.isNonAdhesive = false,
    this.isSpecialTape = false,
    required this.supportedModels,
  });
  
/// Paper Type Model for Brother Label Printers
/// Defines supported paper sizes for QL-820NWB and QL-720NW
/// 
/* Support QL and PT only
Printer printer = Printer();
await printer.setPrinterInfo(printInfo);
LabelInfo labelInfo = await printer.getLabelInfo();

labelInfo.labelNameIndex;   //
labelInfo.labelColor;       //WHITE, RED, BLUE, YELLOW 等
labelInfo.labelFontColor;   // 
labelInfo.labelType;        // 
labelInfo.isAutoCut;        //
labelInfo.isSpecialTape;    // 
*/

/* support QL, PT, TD RJ 
QL, PT, TD, RJ LabelParam：


LabelParam labelParam = await printer.getLabelParam();

labelParam.paperWidth;       //
labelParam.paperLength;      //
labelParam.labelWidth;       //
labelParam.labelLength;      //
labelParam.paperName;        //
labelParam.paperNameInch;    //
labelParam.paperID;          //
labelParam.imageAreaWidth;   //
labelParam.imageAreaLength;  //
*/

  /// All supported paper types for Brother QL series printers
  static const List<PrinterPaperType> allPrinterPaperTypes = [
    // ==================== DIE-CUT LABELS ====================

    // DK-1219: 12mm x 12mm Round Labels
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1219',
      name: 'DK-1219',
      description: '12mm Round Labels (1200/roll)',
      width: '12mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1204: 17mm x 54mm Multi Purpose
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1204',
      name: 'DK-1204',
      description: '17mm x 54mm Multi Purpose (400/roll)',
      width: '17mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1203: 17mm x 87mm File Folder
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1203',
      name: 'DK-1203',
      description: '17mm x 87mm File Folder (300/roll)',
      width: '17mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1221: 23mm x 23mm Square
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1221',
      name: 'DK-1221',
      description: '23mm Square Labels (1000/roll)',
      width: '23mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1218: 24mm x 24mm Round
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1218',
      name: 'DK-1218',
      description: '24mm Round Labels (1000/roll)',
      width: '24mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1209: 29mm x 62mm Small Address
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1209',
      name: 'DK-1209',
      description: '29mm x 62mm Small Address (800/roll)',
      width: '29mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1201: 29mm x 90mm Standard Address
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1201',
      name: 'DK-1201',
      description: '29mm x 90mm Standard Address (400/roll)',
      width: '29mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1208: 38mm x 90mm Large Address
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1208',
      name: 'DK-1208',
      description: '38mm x 90mm Large Address (400/roll)',
      width: '38mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1202: 62mm x 100mm Shipping
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1202',
      name: 'DK-1202',
      description: '62mm x 100mm Shipping (300/roll)',
      width: '62mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-1234: 60mm x 86mm Name Badge
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-1234',
      name: 'DK-1234',
      description: '60mm x 86mm Name Badge (260/roll)',
      width: '60mm',
      isContinuous: false,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-3235: 29mm x 54mm Removable Die-Cut
    PrinterPaperType(
      labelNameIndex: -1,
      code: 'DK-3235',
      name: 'DK-3235',
      description: '29mm x 54mm Removable Die-Cut (800/roll)',
      width: '29mm',
      isContinuous: false,
      material: 'White Paper',
      isRemovable: true,
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // ==================== CONTINUOUS ROLLS ====================

    // DK-2210: 29mm Continuous
    PrinterPaperType(
      labelNameIndex: 14,
      code: 'DK-2210',
      name: 'DK-2210',
      description: '29mm Continuous White Paper',
      width: '29mm',
      isContinuous: true,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW', 'QL-800', 'QL-810W'],
    ),

    // DK-22113: 62mm Continuous Clear Film (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-22113',
      name: 'DK-22113',
      description: '62mm Continuous Clear Film',
      width: '62mm',
      isContinuous: true,
      material: 'Clear Film',
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-22205: 62mm Continuous White Paper (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-22205',
      name: 'DK-22205',
      description: '62mm Continuous White Paper',
      width: '62mm',
      isContinuous: true,
      material: 'White Paper',
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-22212: 62mm Continuous White Film (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-22212',
      name: 'DK-22212',
      description: '62mm Continuous White Film',
      width: '62mm',
      isContinuous: true,
      material: 'White Film',
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-22606: 62mm Continuous Yellow Film (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-22606',
      name: 'DK-22606',
      description: '62mm Continuous Yellow Film',
      width: '62mm',
      isContinuous: true,
      material: 'Yellow Film',
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-44205: 62mm Continuous White Paper (Removable) (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-44205',
      name: 'DK-44205',
      description: '62mm Continuous White Paper (Removable)',
      width: '62mm',
      isContinuous: true,
      material: 'White Paper',
      isRemovable: true,
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-44605: 62mm Continuous Yellow Paper (Removable) (Both models)
    PrinterPaperType(
      labelNameIndex: 15,
      code: 'DK-44605',
      name: 'DK-44605',
      description: '62mm Continuous Yellow Paper (Removable)',
      width: '62mm',
      isContinuous: true,
      material: 'Yellow Paper',
      isRemovable: true,
      supportedModels: ['QL-820NWB', 'QL-720NW'],
    ),

    // DK-N55224: 54mm Continuous White Paper (Non-adhesive) (QL-820NWB only)
    PrinterPaperType(
      labelNameIndex: 14,
      code: 'DK-N55224',
      name: 'DK-N55224',
      description: '54mm Continuous White Paper (Non-adhesive)',
      width: '54mm',
      isContinuous: true,
      material: 'White Paper',
      isNonAdhesive: true,
      supportedModels: ['QL-820NWB'], // Only QL-820NWB
    ),

    // DK-22251: 62mm Continuous Black/Red on White (QL-820NWB only)
    PrinterPaperType(
      labelNameIndex: 17,
      code: 'DK-22251',
      name: 'DK-22251',
      description: '62mm Continuous Black/Red on White',
      width: '62mm',
      isContinuous: true,
      material: 'White Paper',
      isSpecialTape: true,
      supportedModels: ['QL-820NWB'], // Only QL-820NWB
    ),
  ];

  /// Get paper types supported by a specific printer model
  static List<PrinterPaperType> getPrinterPaperTypesForModel(String model) {
    final normalizedModel = model.toUpperCase().trim();
    return allPrinterPaperTypes
        .where((paper) => paper.supportedModels
            .any((m) => m.toUpperCase() == normalizedModel))
        .toList();
  }

  /// Get default paper type (DK-22205 - most common)
  static PrinterPaperType get defaultType => allPrinterPaperTypes[1]; // DK-22205

  /// Find paper type by code
  static PrinterPaperType? fromCode(String code) {
    try {
      return allPrinterPaperTypes.firstWhere(
        (type) => type.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Find paper type by label name index
  static PrinterPaperType? fromLabelNameIndex(int index) {
    try {
      return allPrinterPaperTypes.firstWhere(
        (type) => type.labelNameIndex == index,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'labelNameIndex': labelNameIndex,
      'code': code,
      'name': name,
      'description': description,
      'width': width,
      'isContinuous': isContinuous,
      'material': material,
      'isRemovable': isRemovable,
      'isNonAdhesive': isNonAdhesive,
      'isSpecialTape': isSpecialTape,
      'supportedModels': supportedModels,
    };
  }

  /// Create from JSON
  factory PrinterPaperType.fromJson(Map<String, dynamic> json) {
    return PrinterPaperType(
      labelNameIndex: json['labelNameIndex'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      width: json['width'] as String,
      isContinuous: json['isContinuous'] as bool,
      material: json['material'] as String,
      isRemovable: (json['isRemovable'] as bool?) ?? false,
      isNonAdhesive: (json['isNonAdhesive'] as bool?) ?? false,
      isSpecialTape: (json['isSpecialTape'] as bool?) ?? false,
      supportedModels: List<String>.from(json['supportedModels'] as List),
    );
  }

  /// Get color type display string
  String get colorType => isSpecialTape ? 'Red/Black' : 'Black/White';

  /// Get special features display string
  String get specialFeatures {
    final features = <String>[];
    if (isRemovable) features.add('Removable');
    if (isNonAdhesive) features.add('Non-adhesive');
    if (isSpecialTape) features.add('Red/Black');
    return features.isEmpty ? 'Standard' : features.join(', ');
  }

  /// Full display name with all details
  String get fullDisplayName => '$code - $width $material${_featureSuffix()}';

  String _featureSuffix() {
    if (isRemovable) return ' (Removable)';
    if (isNonAdhesive) return ' (Non-adhesive)';
    if (isSpecialTape) return ' (Black/Red)';
    return '';
  }

  @override
  String toString() => fullDisplayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterPaperType && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
