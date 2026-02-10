/// Printer Paper Type Model for Brother Label Printers
///
/// IMPORTANT - How labelNameIndex Works:
/// ========================================
/// The Brother SDK uses `labelNameIndex` to identify paper types for printing.
///
/// For CONTINUOUS ROLLS:
///   ✅ labelNameIndex has specific values (14, 15, 17, etc.)
///   ✅ Maps to QL_700 enum: W29 (14), W62 (15), W62RB (17)
///   ✅ Printer can validate the exact paper type
///
/// DIE-CUT LABELS NOT SUPPORTED:
///   - Brother SDK does not provide reliable support for die-cut labels
///   - labelNameIndex = -1 causes unpredictable behavior
///   - May cause ERROR_WRONG_LABEL or print quality issues
///   - Only CONTINUOUS ROLLS are included in this app
///
/// Supported paper types (all continuous rolls):
///   ✅ DK-2210 (29mm) - labelNameIndex: 14
///   ✅ DK-22113 (62mm Clear Film) - labelNameIndex: 15
///   ✅ DK-22205 (62mm White Paper) - labelNameIndex: 15 ⭐ Recommended
///   ✅ DK-22212 (62mm White Film) - labelNameIndex: 15
///   ✅ DK-22606 (62mm Yellow Film) - labelNameIndex: 15
///   ✅ DK-44205 (62mm Removable) - labelNameIndex: 15
///   ✅ DK-44605 (62mm Yellow Removable) - labelNameIndex: 15
///   ✅ DK-N55224 (54mm Non-adhesive, QL-820NWB only) - labelNameIndex: 14
///   ✅ DK-22251 (62mm Red/Black, QL-820NWB only) - labelNameIndex: 17
///
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
  /// ⚠️ Only CONTINUOUS ROLLS are supported - die-cut labels removed due to SDK limitations
  static const List<PrinterPaperType> allPrinterPaperTypes = [
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
  static PrinterPaperType get defaultType => allPrinterPaperTypes[2]; // DK-22205 (index adjusted after removing die-cut)

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

  /// Get the paper width in millimeters (numeric value only)
  /// Used by the printer when labelNameIndex is not available (-1)
  int get widthInMm {
    // Extract numeric value from width string (e.g., "62mm" -> 62)
    final match = RegExp(r'(\d+)').firstMatch(width);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// Check if this paper type has a valid labelNameIndex for SDK
  /// Returns false for die-cut labels that use -1 (UNSUPPORTED)
  bool get hasValidLabelIndex => labelNameIndex >= 0;

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
